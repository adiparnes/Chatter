//
//  SettingsTableViewController.swift
//  Chatter
//
//  Created by Avihai Shabtai on 22/02/2020.
//  Copyright © 2020 Niv-Ackerman. All rights reserved.
//

import UIKit
import ProgressHUD

@available(iOS 13.0, *)
class SettingsTableViewController: UITableViewController {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var fullNameLabel: UILabel!
//    @IBOutlet weak var deleteButtonOutlet: UIButton!
    @IBOutlet weak var avatarStatusSwitch: UISwitch!
    
    
    let userDefaults = UserDefaults.standard
    var avatarSwitchStatus = false
    var firstLoad: Bool?
    
    
    override func viewDidAppear(_ animated: Bool) {
           if FUser.currentUser() != nil {
               setupUI()
               loadUserDefaults()
           }
        
//        reference(.Message).document().collection("NK6LM1bK0BTpp9t3wds40ibob2G3tcOhN2UiruNt7MzhLeKc1AMIOEq1").document("D1766445-8137-460B-82A1-88AB2D5DE88A").delete()
        
        
       }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.prefersLargeTitles = true
        tableView.tableFooterView = UIView()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 1 {
            return 2
        }
        if section == 2 {
            return 1
        }
        return 2
    }

  //MARK: TableViewDelegate
  
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
  
    
    //MARK: IBActions
    
    
    @IBAction func showAvatarSwitchValueCanged(_ sender: UISwitch) {
        
        avatarSwitchStatus = sender.isOn
        
        saveUserDefaults()
    }
    
    
    
    @IBAction func logOutButtonPressed(_ sender: Any) {
        
        FUser.logOutCurrentUser { (success) in
            if success{
                self.showLoginView()
            }
        }
        
    }
    
    
    
    func showLoginView()
    {
        let mainView = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "welcome")
        mainView.modalPresentationStyle = .fullScreen
        self.present(mainView, animated: true, completion: nil)
    }
    
    
    //MARK: SetupUI
      
      func setupUI() {
          
          let currentUser = FUser.currentUser()!
          
          fullNameLabel.text = currentUser.fullname
          
          if currentUser.avatar != "" {
              
              imageFromData(pictureData: currentUser.avatar) { (avatarImage) in
                  
                  if avatarImage != nil {
                      self.avatarImageView.image = avatarImage!.circleMasked
                  }
              }
          }
          
         
      }
    
    //MARK: UserDefaults
    
    func saveUserDefaults() {
        
        userDefaults.set(avatarSwitchStatus, forKey: kSHOWAVATAR)
        userDefaults.synchronize()
    }
    
    func loadUserDefaults() {
        
        firstLoad = userDefaults.bool(forKey: kFIRSTRUN)
        
        if !firstLoad! {
            userDefaults.set(true, forKey: kFIRSTRUN)
            userDefaults.set(avatarSwitchStatus, forKey: kSHOWAVATAR)
            userDefaults.synchronize()
        }
        
        avatarSwitchStatus = userDefaults.bool(forKey: kSHOWAVATAR)
        avatarStatusSwitch.isOn = avatarSwitchStatus
    }
}
