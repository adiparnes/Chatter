//
//  ProfileViewTableViewController.swift
//  Chatter
//
//  Created by Avihai Shabtai on 23/02/2020.
//  Copyright © 2020 Niv-Ackerman. All rights reserved.
//

import UIKit
import ProgressHUD

@available(iOS 13.0, *)
class ProfileViewTableViewController: UITableViewController {

    @IBOutlet weak var FullNameLable: UILabel!
    
    @IBOutlet weak var phoneNumber: UILabel!
    
    @IBOutlet weak var messageButtonOutlet: UIButton!
    
    @IBOutlet weak var cellButtonOutlet: UIButton!
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var blockButtonOutlet: UIButton!
   
    
    var user: FUser?
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        setupUI()
        
    }
    
    //MARK:IBAction
 
    
       
       @IBAction func chatButtonPressed(_ sender: Any) {
           
           if !checkBlockedStatus(withUser: user!) {
               
               let chatVC = ChatViewController()
               chatVC.titleName = user!.firstname
               chatVC.membersToPush = [FUser.currentId(), user!.objectId]
               chatVC.membarIds = [FUser.currentId(), user!.objectId]
               chatVC.chatRoonmId = startPrivateChat(user1: FUser.currentUser()!, user2: user!)
               
               chatVC.isGroup = false
               chatVC.hidesBottomBarWhenPushed = true
               self.navigationController?.pushViewController(chatVC, animated: true)
               
               
           } else {
               ProgressHUD.showError("This user is not available for chat!")
           }
    
       }
    
    
    @IBAction func blockUserButtonPressed(_ sender: Any) {
        var currentBlockedIds = FUser.currentUser()!.blockedUsers
        
        if currentBlockedIds.contains(user!.objectId){
            
            let index = currentBlockedIds.index(of: user!.objectId)!
            currentBlockedIds.remove(at: index)
            
        }else{
            currentBlockedIds.append(user!.objectId)
        }
        updateCurrentUserInFirestore(withValues: [kBLOCKEDUSERID : currentBlockedIds]) { (error) in
            if error != nil {
                print("error\(error!.localizedDescription)")
                return
            }
            self.updateBlockStatus()
            ModelEvents.UserDataEvent.post();
        }
        
        blockUser(userToBlock: user!)
        
    }
    
    
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ""
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        }
        return 30
    }
    
    //MARK: SetUpUI
    func setupUI() {
        
        if user != nil {
            
            self.title = "Profile"
            
            FullNameLable.text = user!.fullname
            phoneNumber.text = user!.phoneNumber
            
            updateBlockStatus()
            
            imageFromData(pictureData: user!.avatar) { (avatarImage) in
                
                if avatarImage != nil {
                    self.avatarImageView.image = avatarImage!.circleMasked
                }
            }
        }
    }
    func updateBlockStatus()
    {
        if user!.objectId != FUser.currentId(){
            blockButtonOutlet.isHidden = false
         //   messageButtonOutlet.isHidden = false
         //   cellButtonOutlet.isHidden = false
            
        }else{
        blockButtonOutlet.isHidden = true
       // messageButtonOutlet.isHidden = true
      //  cellButtonOutlet.isHidden = true
        }
        if FUser.currentUser()!.blockedUsers.contains(user!.objectId)
        {
            blockButtonOutlet.setTitle("Unblock User", for: .normal)
        }else{
            blockButtonOutlet.setTitle("Block User", for: .normal)
        }
    }

}
