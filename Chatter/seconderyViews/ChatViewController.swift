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


class ChatViewController: JSQMessagesViewController {

    var chatRoonmId: String!
    
    var membarIds: [String]!
    
    var membersToPush: [String]!
    
    var titleName: String!
    
    var outgoingBubble = JSQMessagesBubbleImageFactory()?.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
    
    
    var incomingBubble = JSQMessagesBubbleImageFactory()?.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
    
            //fix for iphone x
    override func viewDidLayoutSubviews() {
        perform(Selector(("jsq_updateCollectionViewInsets")))
    }
            //end of iphone x fix
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.largeTitleDisplayMode = .never
        
        self.navigationItem.leftBarButtonItems = [UIBarButtonItem(image: UIImage(named: "Back"), style: .plain, target: self, action: #selector(self.backAction))]
        
        collectionView.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
        
        
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
    
//MARK: JSQmessages Delegate functions
    
    override func didPressAccessoryButton(_ sender: UIButton!) {
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let takePhotoOrVideo = UIAlertAction(title: "Camera", style: .default) { (action) in
            
            
            
        }
        
         let sharedPhoto = UIAlertAction(title: "Photo Liabrary", style: .default) { (action) in
                   
                   
                   
               }
        
        
        let sharedVideo = UIAlertAction(title: "Video Liabrary", style: .default) { (action) in
            
            
            
        }
        
        let sharedLoction = UIAlertAction(title: "Share Loction", style: .default) { (action) in
            
            
            
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
            
        }
        
    }
    
    
    //MARK: Sand Messages
    
    func sendMessage(text: String?, date: Date , picture: UIImage?,location: String?,video: NSURL?, audio: String?){
        
        var outgoingMessage: OutgoingMessages?
        let currenUser = FUser.currentUser()!
        
        //text massage
        if let text = text {
            outgoingMessage = OutgoingMessages(message: text, senderId: currenUser.objectId, senderName: currenUser.firstname, date: date, status: kDELIVERED, type: kTEXT)
        }
        
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        self.finishSendingMessage()
        
        outgoingMessage!.sendMessage(chatRoomID: chatRoonmId, messageDictionary: outgoingMessage!.messageDictionary, memberIds: membarIds, membersToPush: membersToPush)
        
    }
    
    
    
//MARK:IBAction
  @objc func backAction()
  {
    self.navigationController?.popViewController(animated: true)
    
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

}
