//
//  ChatViewController.swift
//  Chatter
//
//  Created by Avihai Shabtai on 24/02/2020.
//  Copyright © 2020 Niv-Ackerman. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import ProgressHUD
import IQAudioRecorderController
import IDMPhotoBrowser
import AVFoundation
import AVKit
import FirebaseFirestore


@available(iOS 13.0, *)
class ChatViewController: JSQMessagesViewController ,UIImagePickerControllerDelegate , UINavigationControllerDelegate, IQAudioRecorderViewControllerDelegate {

    var typingCounter = 0
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var messages: [JSQMessage] = []
    var objectMessages: [NSDictionary] = []
    var loadedMessages: [NSDictionary] = []
    var allPictureMessages: [String] = []
    
    var isGroup: Bool?
    var group: NSDictionary?
    var withUsers: [FUser] = []
    
    var typingListener: ListenerRegistration?
    var updatedChatListener: ListenerRegistration?
    var newChatListener: ListenerRegistration?
    
    
    var jsqAvatarDictionary: NSMutableDictionary?
    var avatarImageDictionary: NSMutableDictionary?
    var showAvatars = true
    var firstLoad: Bool?
    
    var initialLoadComplete = true
    
    let legitType = [kAUDIO,kVIDEO,kTEXT,kLOCATION,kPICTURE]
    
    var maxMessagesNumber = 0
    var minMessagesNumber = 0
    var loadOld = false
    var loadedMessagesCount = 0
    
    
    var chatRoonmId: String!
    
    var membarIds: [String]!
    
    var membersToPush: [String]!
    
    var titleName: String!
    
    var outgoingBubble = JSQMessagesBubbleImageFactory()?.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
    
    
    var incomingBubble = JSQMessagesBubbleImageFactory()?.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
    
    //MARK: CustomHeaders

    let leftBarButtonView: UIView = {
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 44))
        return view
    }()
    let avatarButton: UIButton = {
       let button = UIButton(frame: CGRect(x: 0, y: 10, width: 25, height: 25))
        return button
    }()
    let titleLabel: UILabel = {
       let title = UILabel(frame: CGRect(x: 30, y: 10, width: 140, height: 15))
        title.textAlignment = .left
        title.font = UIFont(name: title.font.fontName, size: 14)
        
        return title
    }()
    let subTitleLabel: UILabel = {
       let subTitle = UILabel(frame: CGRect(x: 30, y: 25, width: 140, height: 15))
        subTitle.textAlignment = .left
        subTitle.font = UIFont(name: subTitle.font.fontName, size: 10)
        
        return subTitle
    }()

    override func viewWillAppear(_ animated: Bool) {
        clearRecentCounter(chatRoomId: chatRoonmId)
    }

    override func viewWillDisappear(_ animated: Bool) {
        clearRecentCounter(chatRoomId: chatRoonmId)
    }
    
    
    
            //fix for iphone x
    override func viewDidLayoutSubviews() {
        perform(Selector(("jsq_updateCollectionViewInsets")))
    }
            //end of iphone x fix
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createTypingObserver()
        
        navigationItem.largeTitleDisplayMode = .never
        
        self.navigationItem.leftBarButtonItems = [UIBarButtonItem(image: UIImage(named: "Back"), style: .plain, target: self, action: #selector(self.backAction))]
        
        collectionView.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
        
         jsqAvatarDictionary = [ : ]
        
        
        setCustomTitle()
        
        loadMessages()
        
        self.senderId = FUser.currentId()
        self.senderDisplayName = FUser.currentUser()!.firstname
        
        //fix for iphone x
        
        let constraints = perform(Selector(("toolbarBottomLayoutGuide")))?.takeUnretainedValue() as! NSLayoutConstraint
        
        constraints.priority = UILayoutPriority(rawValue: 1000)
        
        self.inputToolbar.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        
        
        //end of iphone x fix
        
        
        
        //custom send bottom
        
        self.inputToolbar.contentView.rightBarButtonItem.setImage(UIImage(named: "mic"), for: .normal)
            
        self.inputToolbar.contentView.rightBarButtonItem.setTitle("", for: .normal)
        
        
    }
    
    //MARK: JSQMessages dataSource functions
    
   override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        
        let data = messages[indexPath.row]
        
        //set text color
        if data.senderId == FUser.currentId() {
            cell.textView?.textColor = .white
        } else {
            cell.textView?.textColor = .black
        }
        
        return cell
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        
        return messages[indexPath.row]
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return messages.count
    }
    
        override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
               
               let data = messages[indexPath.row]
               
               if data.senderId == FUser.currentId() {
                   return outgoingBubble
               } else {
                   return incomingBubble
               }
           }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        
        if indexPath.item % 3 == 0 {
            let message = messages[indexPath.row]
            
            return JSQMessagesTimestampFormatter.shared()?.attributedTimestamp(for: message.date)
        }
        
        return nil
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellTopLabelAt indexPath: IndexPath!) -> CGFloat {
        
        if indexPath.item % 3 == 0 {
            
            return kJSQMessagesCollectionViewCellLabelHeightDefault
        }
        
        return 0.0
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellBottomLabelAt indexPath: IndexPath!) -> NSAttributedString! {

        let message = objectMessages[indexPath.row]

        let status: NSAttributedString!

        let attributedStringColor = [NSAttributedString.Key.foregroundColor : UIColor.darkGray]

        switch message[kSTATUS] as! String {
        case kDELIVERED:
            status = NSAttributedString(string: kDELIVERED)
        case kREAD:
            let statusText = "Read" + " " + readTimeFrom(dateString: message[kREADDATE] as! String)

            status = NSAttributedString(string: statusText, attributes: attributedStringColor)

        default:
            status = NSAttributedString(string: "✔︎")
        }

        if indexPath.row == (messages.count - 1) {
            return status
        } else {
            return NSAttributedString(string: "")
        }

    }

    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellBottomLabelAt indexPath: IndexPath!) -> CGFloat {

        let data = messages[indexPath.row]

        if data.senderId == FUser.currentId() {
            return kJSQMessagesCollectionViewCellLabelHeightDefault
        } else {
            return 0.0
        }
    }

    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {

        let message = messages[indexPath.row]

        var avatar: JSQMessageAvatarImageDataSource

        if let testAvatar = jsqAvatarDictionary!.object(forKey: message.senderId) {
            avatar = testAvatar as! JSQMessageAvatarImageDataSource
        } else {
            avatar = JSQMessagesAvatarImageFactory.avatarImage(with: UIImage(named: "avatarPlaceholder"), diameter: 70)
        }

        return avatar
    }
    
    
//MARK: JSQmessages Delegate functions
    
    override func didPressAccessoryButton(_ sender: UIButton!) {
       
        
         let camera = Camera(delegate_: self)
        
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let takePhotoOrVideo = UIAlertAction(title: "Camera", style: .default) { (action) in
            
            camera.PresentMultyCamera(target: self, canEdit: false)
            
        }
        
         let sharedPhoto = UIAlertAction(title: "Photo Liabrary", style: .default) { (action) in
                   
            camera.PresentPhotoLibrary(target: self, canEdit: false)
                   
               }
        
        
        let sharedVideo = UIAlertAction(title: "Video Liabrary", style: .default) { (action) in
            
            camera.PresentVideoLibrary(target: self, canEdit: false)
            
        }
        
        let sharedLoction = UIAlertAction(title: "Share Loction", style: .default) { (action) in
            
            if self.haveAccessToUserLocation() {
                self.sendMessage(text: nil, date: Date(), picture: nil, location: kLOCATION, video: nil, audio: nil)
            }
            
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
        }
        
        takePhotoOrVideo.setValue(UIImage(named: "camera"), forKey: "image")
        sharedPhoto.setValue(UIImage(named: "picture"), forKey: "image")
        sharedVideo.setValue(UIImage(named: "video"), forKey: "image")
        sharedLoction.setValue(UIImage(named: "location"), forKey: "image")
        
        optionMenu.addAction(takePhotoOrVideo)
        optionMenu.addAction(sharedPhoto)
        optionMenu.addAction(sharedVideo)
        optionMenu.addAction(sharedLoction)
        optionMenu.addAction(cancelAction)
        self.present(optionMenu, animated: true , completion: nil)
        
        
    }
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        
        if text != "" {
            
            self.sendMessage(text: text, date: date, picture: nil, location: nil, video: nil, audio: nil)
            
            updateSendButton(isSend: false)
            
        }else {
            let audioVC = AudioViewController(delegate_: self)
            audioVC.presentAudioRecorder(target: self)
        }
        
    }
    
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, header headerView: JSQMessagesLoadEarlierHeaderView!, didTapLoadEarlierMessagesButton sender: UIButton!) {
        
        self.loadMoreMessages(maxNumber: maxMessagesNumber, minNumber: minMessagesNumber)
        self.collectionView.reloadData()
    }
    
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, didTapMessageBubbleAt indexPath: IndexPath!) {
           
           let messageDictionary = objectMessages[indexPath.row]
           let messageType = messageDictionary[kTYPE] as! String
           
           switch messageType {
           case kPICTURE:
               
               let message = messages[indexPath.row]
               
               let mediaItem = message.media as! JSQPhotoMediaItem
               
               let photos = IDMPhoto.photos(withImages: [mediaItem.image])
               let browser = IDMPhotoBrowser(photos: photos)
               
               self.present(browser!, animated: true, completion: nil)
               
           case kLOCATION:
               
            print("location")
               let message = messages[indexPath.row]

               let mediaItem = message.media as! JSQLocationMediaItem

               let mapView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MapViewController") as! MapViewController

               mapView.location = mediaItem.location

               self.navigationController?.pushViewController(mapView, animated: true)

           case kVIDEO:

               let message = messages[indexPath.row]
               
               let mediaItem = message.media as! VideoMessage
               
               let player = AVPlayer(url: mediaItem.fileURL! as URL)
               let moviewPlayer = AVPlayerViewController()
               
               let session = AVAudioSession.sharedInstance()
               
               try! session.setCategory(.playAndRecord, mode: .default, options: .defaultToSpeaker)

               moviewPlayer.player = player
               
               self.present(moviewPlayer, animated: true) {
                   moviewPlayer.player!.play()
               }
               
           default:
               print("unkown mess tapped")

           }
           
       }
    
    
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, didTapAvatarImageView avatarImageView: UIImageView!, at indexPath: IndexPath!) {
        
        let senderId = messages[indexPath.row].senderId
        var selectedUser: FUser?
        
        if senderId == FUser.currentId() {
            selectedUser = FUser.currentUser()
        } else {
            for user in withUsers {
                if user.objectId == senderId {
                    selectedUser = user
                }
            }
        }

        presentUserProfile(forUser: selectedUser!)
    }
    
    
    
    
    //MARK: Sand Messages
    
    func sendMessage(text: String?, date: Date , picture: UIImage?,location: String?,video: NSURL?, audio: String?){
        
        var outgoingMessage: OutgoingMessages?
        let currenUser = FUser.currentUser()!
        
        //text massage
        if let text = text {
            outgoingMessage = OutgoingMessages(message: text, senderId: currenUser.objectId, senderName: currenUser.firstname, date: date, status: kDELIVERED, type: kTEXT)
        }
        
        //picture message
        
        if let pic = picture {
            uploadImage(image: pic, chatRoomId: chatRoonmId, view: self.navigationController!.view) { (imageLink) in
                
                if imageLink != nil {
                    
                    let text = kPICTURE
                    
                    outgoingMessage = OutgoingMessages(message: text, pictureLink: imageLink!, senderId: currenUser.objectId, senderName: currenUser.firstname, date: date, status: kDELIVERED, type: kPICTURE)
                    JSQSystemSoundPlayer.jsq_playMessageSentSound()
                    self.finishSendingMessage()
                    outgoingMessage?.sendMessage(chatRoomID: self.chatRoonmId, messageDictionary: outgoingMessage!.messageDictionary, memberIds: self.membarIds, membersToPush: self.membersToPush)
                }
                
            }
            return
        }
        
        
        //send video
               
               if let video = video {
                   
                   let videoData = NSData(contentsOfFile: video.path!)
                   
                   let dataThumbnail = videoThumbnail(video: video).jpegData(compressionQuality: 0.3)
                   
                   uploadVideo(video: videoData!, chatRoomId: chatRoonmId, view: self.navigationController!.view) { (videoLink) in
                       
                       if videoLink != nil {
                           
                        let text = "[\(kVIDEO)]"
                        
                        outgoingMessage = OutgoingMessages(message: text, video: videoLink!, thumbNail: dataThumbnail! as NSData, senderId: currenUser.objectId, senderName: currenUser.firstname, date: date, status: kDELIVERED, type: kVIDEO)
                    
                           JSQSystemSoundPlayer.jsq_playMessageSentSound()
                           self.finishSendingMessage()
                           
                           outgoingMessage?.sendMessage(chatRoomID: self.chatRoonmId, messageDictionary: outgoingMessage!.messageDictionary, memberIds: self.membarIds, membersToPush: self.membersToPush)
                           
                       }
                   }
                   return
               }
        
        
        //send audio
        
            if let audioPath = audio {
                
                uploadAudio(autioPath: audioPath, chatRoomId: chatRoonmId, view: (self.navigationController?.view)!) { (audioLink) in
                    
                    if audioLink != nil {
                        
                        let text = "[\(kAUDIO)]"

                        
                        outgoingMessage = OutgoingMessages(message: text, audio: audioLink!, senderId: currenUser.objectId, senderName: currenUser.firstname, date: date, status: kDELIVERED, type: kAUDIO)
                        
                        JSQSystemSoundPlayer.jsq_playMessageSentSound()
                        self.finishSendingMessage()
                        
                        outgoingMessage!.sendMessage(chatRoomID: self.chatRoonmId, messageDictionary: outgoingMessage!.messageDictionary, memberIds: self.membarIds, membersToPush: self.membersToPush)
                    }
                }
                return
            }
        
        
        //send location message
            if location != nil {
                
                let lat: NSNumber = NSNumber(value: appDelegate.coordinates!.latitude)
                let long: NSNumber = NSNumber(value: appDelegate.coordinates!.longitude)
                
                let text = "[\(kLOCATION)]"
                
                
                outgoingMessage = OutgoingMessages(message: text, latitude: lat, longitude: long, senderId: currenUser.objectId, senderName: currenUser.firstname, date: date, status: kDELIVERED, type: kLOCATION)
            }
            
        
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        self.finishSendingMessage()
        
        outgoingMessage!.sendMessage(chatRoomID: chatRoonmId, messageDictionary: outgoingMessage!.messageDictionary, memberIds: membarIds, membersToPush: membersToPush)
        
    }
    
    
//    MARK: LOAD MESSAGES
    
    func loadMessages() {
        
        //to update message status
        
        updatedChatListener = reference(.Message).document(FUser.currentId()).collection(chatRoonmId).addSnapshotListener({ (snapshot, error) in
            
            guard let snapshot = snapshot else { return }
            
            if !snapshot.isEmpty {
           
                snapshot.documentChanges.forEach({ (diff) in
                    
                    if diff.type == .modified {
                        
                        self.updateMessage(messageDictionary: diff.document.data() as NSDictionary)
                    }
                })
            }
        })
        
        //get last 11 meassages
        reference(.Message).document(FUser.currentId()).collection(chatRoonmId).order(by: kDATE, descending: true).limit(to: 11).getDocuments { (snapshot, error) in
            
            guard let snapshot = snapshot else{

                self.initialLoadComplete = true
                
                self.listenForNewChats()
                return
            }
            
            let sorted = ((dictionaryFromSnapshots(snapshots: snapshot.documents)) as NSArray).sortedArray(using: [NSSortDescriptor(key: kDATE, ascending: true)]) as! [NSDictionary]
            
            //Remove bad messages
            self.loadedMessages = self.removeBedMeassages(allMessages: sorted)
            
            //insert messages
            self.insertMessages()
            self.finishReceivingMessage(animated: true)
            
            self.initialLoadComplete = true
            
            self.getPictureMessages()
            
            self.getOldMessagesInBackground()
            //start listing for new chats
            self.listenForNewChats()
            
            
        }
        
        
    }
    
    func listenForNewChats() {
           
           var lastMessageDate = "0"
           
           if loadedMessages.count > 0 {
               lastMessageDate = loadedMessages.last![kDATE] as! String
           }
           
           
           newChatListener = reference(.Message).document(FUser.currentId()).collection(chatRoonmId).whereField(kDATE, isGreaterThan: lastMessageDate).addSnapshotListener({ (snapshot, error) in
               
               guard let snapshot = snapshot else { return }
               
               if !snapshot.isEmpty {
                   
                   for diff in snapshot.documentChanges {
                       
                       if (diff.type == .added) {
                           
                           let item = diff.document.data() as NSDictionary
                           
                           if let type = item[kTYPE] {
                               
                               if self.legitType.contains(type as! String) {
                                   
                                   //this is for picture messages
                                   if type as! String == kPICTURE {
                                       self.addNewPictureMessageLink(link: item[kPICTURE] as! String)
                                   }
                                   
                                if self.insertInitalLoadMessages(messageDitionary: item) {
                                       
                                       JSQSystemSoundPlayer.jsq_playMessageReceivedSound()
                                   }
                                   
                                   self.finishReceivingMessage()
                               }
                           }
                           
                       }
                   }
                   
               }
    
           })
       }
    func getOldMessagesInBackground() {
          
          if loadedMessages.count > 10 {
              
              let firstMessageDate = loadedMessages.first![kDATE] as! String
              
              reference(.Message).document(FUser.currentId()).collection(chatRoonmId).whereField(kDATE, isLessThan: firstMessageDate).getDocuments { (snapshot, error) in
                  
                  guard let snapshot = snapshot else { return }
                  
                  let sorted = ((dictionaryFromSnapshots(snapshots: snapshot.documents)) as NSArray).sortedArray(using: [NSSortDescriptor(key: kDATE, ascending: true)]) as! [NSDictionary]
                  
                  
                  self.loadedMessages = self.removeBedMeassages(allMessages: sorted) + self.loadedMessages
                  
                  self.getPictureMessages()

                  
                  self.maxMessagesNumber = self.loadedMessages.count - self.loadedMessagesCount - 1
                  self.minMessagesNumber = self.maxMessagesNumber - kNUMBEROFMESSAGES
              }
          }
      }
    
    
    //MARK:insert messages
    
    func insertMessages()
    {
        maxMessagesNumber = loadedMessages.count - loadedMessagesCount
        minMessagesNumber = maxMessagesNumber - kNUMBEROFMESSAGES
        
        if minMessagesNumber < 0
        {
            minMessagesNumber = 0
            
            }
        
        for i in minMessagesNumber ..< maxMessagesNumber {
            let messageDictionary = loadedMessages[i]
            
            //insert message
            insertInitalLoadMessages(messageDitionary: messageDictionary)
            
            loadedMessagesCount += 1
            
            
        }
        self.showLoadEarlierMessagesHeader = (loadedMessagesCount != loadedMessages.count)
        
    }
    
    func insertInitalLoadMessages(messageDitionary: NSDictionary) -> Bool {
       
        let incomingMessage = IncomingMessage(collectionView_: self.collectionView!)
        
        //check if incoming
        if (messageDitionary[kSENDERID] as! String) != FUser.currentId() {
            
             OutgoingMessages.updateMessage(withId: messageDitionary[kMESSAGEID] as! String, chatRoomId: chatRoonmId, memberIds: membarIds)
            
        }
        let message = incomingMessage.createMessage(messageDictionary: messageDitionary, chatRoomId: chatRoonmId)
        
        if message != nil {
            objectMessages.append(messageDitionary)
            messages.append(message!)
        }
        
        return isIncoming(messageDictionary: messageDitionary)
        
    }
    
    
    func updateMessage(messageDictionary: NSDictionary) {
        
        for index in 0 ..< objectMessages.count {
            let temp = objectMessages[index]
            
            if messageDictionary[kMESSAGEID] as! String == temp[kMESSAGEID] as! String {
                objectMessages[index] = messageDictionary
                self.collectionView!.reloadData()
            }
        }
    }
    
    
    //MARK: LoadMoreMessages
    
    func loadMoreMessages(maxNumber: Int, minNumber: Int) {
        
        if loadOld {
            maxMessagesNumber = minNumber - 1
            minMessagesNumber = maxMessagesNumber - kNUMBEROFMESSAGES
        }
        
        if minMessagesNumber < 0 {
            minMessagesNumber = 0
        }
        
        for i in (minMessagesNumber ... maxMessagesNumber).reversed() {
            
            let messageDictionary = loadedMessages[i]
            insertNewMessage(messageDictionary: messageDictionary)
            loadedMessagesCount += 1
        }
        
        loadOld = true
        self.showLoadEarlierMessagesHeader = (loadedMessagesCount != loadedMessages.count)
    }
    
    func insertNewMessage(messageDictionary: NSDictionary) {
        
        let incomingMessage = IncomingMessage(collectionView_: self.collectionView!)
        
        let message = incomingMessage.createMessage(messageDictionary: messageDictionary, chatRoomId: chatRoonmId)
        
        objectMessages.insert(messageDictionary, at: 0)
        messages.insert(message!, at: 0)
    }
    
    
//MARK:IBAction
  @objc func backAction()
  {
    clearRecentCounter(chatRoomId: chatRoonmId)
    removeListeners()
    self.navigationController?.popViewController(animated: true)
    
    }
    
    @objc func infoButtonPressed() {
        
        let mediaVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mediaView") as! PicturesCollectionViewController

        mediaVC.allImageLinks = allPictureMessages

        self.navigationController?.pushViewController(mediaVC, animated: true)
    }
    
    @objc func showGroup() {
        
//        let groupVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "groupView") as! GroupViewController
//
//        groupVC.group = group!
//        self.navigationController?.pushViewController(groupVC, animated: true)
    }
    
    @objc func showUserProfile() {
        
        let profileVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "profileView") as! ProfileViewTableViewController
        
        profileVC.user = withUsers.first!
        self.navigationController?.pushViewController(profileVC, animated: true)
    }
    
    
    func presentUserProfile(forUser: FUser) {
          
          let profileVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "profileView") as! ProfileViewTableViewController
          
          profileVC.user = forUser
          self.navigationController?.pushViewController(profileVC, animated: true)

      }
    
    
    //MARK: Typing Indicator
       
       func createTypingObserver() {
           
           typingListener = reference(.Typing).document(chatRoonmId).addSnapshotListener({ (snapshot, error) in
               
               guard let snapshot = snapshot else { return }
               
               if snapshot.exists {
                   
                   for data in snapshot.data()! {
                       if data.key != FUser.currentId() {
                           
                           let typing = data.value as! Bool
                           self.showTypingIndicator = typing
                           
                           if typing {
                               self.scrollToBottom(animated: true)
                           }
                       }
                   }
               } else {
                   reference(.Typing).document(self.chatRoonmId).setData([FUser.currentId() : false])
               }
               
           })
           
       }
    
    func typingCounterStart() {
           
           typingCounter += 1
           
           typingCounterSave(typing: true)
           
           self.perform(#selector(self.typingCounterStop), with: nil, afterDelay: 2.0)
       }
       
       @objc func typingCounterStop() {
           typingCounter -= 1

           if typingCounter == 0 {
               typingCounterSave(typing: false)
           }
       }

       func typingCounterSave(typing: Bool) {
           
           reference(.Typing).document(chatRoonmId).updateData([FUser.currentId() : typing])
       }
       
    
    //MARK: UITextViewDelegate
    
    override func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        typingCounterStart()
        return true
    }
    
 //MARK: CustomSendButton
    
    
    override func textViewDidChange(_ textView: UITextView) {
        
        
        if textView.text != "" {
            updateSendButton(isSend: true)
        }else{
            updateSendButton(isSend: false)
        }
    }
    
    
    func updateSendButton(isSend: Bool) {
        
        if isSend {
            self.inputToolbar.contentView.rightBarButtonItem.setImage(UIImage(named: "send"), for: .normal)
        }else {
            self.inputToolbar.contentView.rightBarButtonItem.setImage(UIImage(named: "mic"), for: .normal)
        }
    }

    
    //MARK: IQAudioDelegate
       
       func audioRecorderController(_ controller: IQAudioRecorderViewController, didFinishWithAudioAtPath filePath: String) {
           
           controller.dismiss(animated: true, completion: nil)
           self.sendMessage(text: nil, date: Date(), picture: nil, location: nil, video: nil, audio: filePath)
       }

       
       func audioRecorderControllerDidCancel(_ controller: IQAudioRecorderViewController) {
           controller.dismiss(animated: true, completion: nil)
       }
    
    
    
    //MARK: UpdateUI
    
    func setCustomTitle() {
           
           leftBarButtonView.addSubview(avatarButton)
           leftBarButtonView.addSubview(titleLabel)
           leftBarButtonView.addSubview(subTitleLabel)
           
           let infoButton = UIBarButtonItem(image: UIImage(named: "info"), style: .plain, target: self, action: #selector(self.infoButtonPressed))
           
           self.navigationItem.rightBarButtonItem = infoButton
           
           let leftBarButtonItem = UIBarButtonItem(customView: leftBarButtonView)
           self.navigationItem.leftBarButtonItems?.append(leftBarButtonItem)
           
           if isGroup! {
               avatarButton.addTarget(self, action: #selector(self.showGroup), for: .touchUpInside)
           } else {
               avatarButton.addTarget(self, action: #selector(self.showUserProfile), for: .touchUpInside)
           }
           
           getUsersFromFirestore(withIds: membarIds) { (withUsers) in
               
               self.withUsers = withUsers
               self.getAvatarImages()
               if !self.isGroup! {
                   self.setUIForSingleChat()
               }
           }
           
       }
    
    func setUIForSingleChat() {
        
        let withUser = withUsers.first!

        imageFromData(pictureData: withUser.avatar) { (image) in
            
            if image != nil {
                avatarButton.setImage(image!.circleMasked, for: .normal)
            }
        }
        
        titleLabel.text = withUser.fullname
        
        if withUser.isOnline {
            subTitleLabel.text = "Online"
        } else {
            subTitleLabel.text = "Offline"
        }
        
        avatarButton.addTarget(self, action: #selector(self.showUserProfile), for: .touchUpInside)
    }
    
    //MARK: UIImagePickerController delegate
       
       func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
           
           let video = info[UIImagePickerController.InfoKey.mediaURL] as? NSURL
           let picture = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
           
           sendMessage(text: nil, date: Date(), picture: picture, location: nil, video: video, audio: nil)
           
           picker.dismiss(animated: true, completion: nil)
       }
    
    
    
    //MARK: GetAvatars
    
    func getAvatarImages() {
        
        if showAvatars {
            
            collectionView?.collectionViewLayout.incomingAvatarViewSize = CGSize(width: 30, height: 30)
            collectionView?.collectionViewLayout.outgoingAvatarViewSize = CGSize(width: 30, height: 30)
            
            //get current user avatar
            avatarImageFrom(fUser: FUser.currentUser()!)
            
            for user in withUsers {
                avatarImageFrom(fUser: user)
            }
            
        }
    }
    
    func avatarImageFrom(fUser: FUser) {
        
        if fUser.avatar != "" {
            
            dataImageFromString(pictureString: fUser.avatar) { (imageData) in
                
                if imageData == nil {
                    return
                }
                
                
                if self.avatarImageDictionary != nil {
                    //update avatar if we had one
                    self.avatarImageDictionary!.removeObject(forKey: fUser.objectId)
                    self.avatarImageDictionary!.setObject(imageData!, forKey: fUser.objectId as NSCopying)
                } else {
                    self.avatarImageDictionary = [fUser.objectId : imageData!]
                }
                
                self.createJSQAvatars(avatarDictionary: self.avatarImageDictionary)
            }
        }
        
    }
    
    func createJSQAvatars(avatarDictionary: NSMutableDictionary?) {
        
        let defaultAvatar = JSQMessagesAvatarImageFactory.avatarImage(with: UIImage(named: "avatarPlaceholder"), diameter: 70)
        
        if avatarDictionary != nil {
            
            for userId in membarIds {
                
                if let avatarImageData = avatarDictionary![userId] {
                    
                    let jsqAvatar = JSQMessagesAvatarImageFactory.avatarImage(with: UIImage(data: avatarImageData as! Data), diameter: 70)
                    
                    self.jsqAvatarDictionary!.setValue(jsqAvatar, forKey: userId)
                } else {
                    self.jsqAvatarDictionary!.setValue(defaultAvatar, forKey: userId)
                }

            }
            
            self.collectionView.reloadData()
        }
    }
    
    
    //MARK: Location access
       
       func haveAccessToUserLocation() -> Bool {
           if appDelegate.locationManager != nil {
               return true
           } else {
               ProgressHUD.showError("Please give access tp loacation in Settings.")
               return false
           }
       }
    
    
    
    //MARK: Helper function
    
    func addNewPictureMessageLink(link: String) {
           allPictureMessages.append(link)
       }
       
       func getPictureMessages() {
           
           allPictureMessages = []
           
           for message in loadedMessages {
               
               if message[kTYPE] as! String == kPICTURE {
                   allPictureMessages.append(message[kPICTURE] as! String)
               }
           }
       }
    
    
    func readTimeFrom(dateString: String) -> String {
        
        let date = dateFormatter().date(from: dateString)
        
        let currentDateFormat = dateFormatter()
        currentDateFormat.dateFormat = "HH:mm"
        
        return currentDateFormat.string(from: date!)
        
    }
    
    
    
    func removeBedMeassages(allMessages : [NSDictionary]) -> [NSDictionary]
    {
            var tempMessages = allMessages
        for message in tempMessages{
            
            if message[kTYPE] != nil {
                
                if !self.legitType.contains(message[kTYPE] as! String){
                    //remove the message
                    tempMessages.remove(at: tempMessages.index(of:message)!)
                }
                
            } else {
                tempMessages.remove(at: tempMessages.index(of:message)!)

            }
        }
        return tempMessages
    }
    
    
    func isIncoming(messageDictionary: NSDictionary) -> Bool {
        
        if FUser.currentId() == messageDictionary[kSENDERID] as! String {
            return false
        }else {
            return true
        }
    }
    
    
    func removeListeners() {
          
          if typingListener != nil {
              typingListener!.remove()
          }
          if newChatListener != nil {
              newChatListener!.remove()
          }
          if updatedChatListener != nil {
              updatedChatListener!.remove()
          }
      }
    
}
