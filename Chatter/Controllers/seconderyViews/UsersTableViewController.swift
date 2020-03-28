//
//  UsersTableViewController.swift
//  Chatter
//
//  Created by Avihai Shabtai on 22/02/2020.
//  Copyright © 2020 Niv-Ackerman. All rights reserved.
//

import UIKit
import Firebase
import ProgressHUD

@available(iOS 13.0, *)
class UsersTableViewController: UITableViewController, UISearchResultsUpdating, UserTableViewCellDelegate {
    
    
    
    

    @IBOutlet weak var hadarView: UIView!
    @IBOutlet weak var filterSegmantionControll: UISegmentedControl!
    
    var allUsers:[FUser] = []
    var filterdUsers: [FUser] = []
    var allUsersGropped = NSDictionary() as! [String: [FUser]]
    var sectionTitlelist : [String] = []
    
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Users"
        navigationItem.largeTitleDisplayMode = .never
        tableView.tableFooterView = UIView()
        
        navigationItem.searchController = searchController
        
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        
        loadUser(filter: "")
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        if searchController.isActive && searchController.searchBar.text != "" {
            return 1
        }else {
            return allUsersGropped.count
        }
        
        
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        if searchController.isActive && searchController.searchBar.text != "" {
            
            return filterdUsers.count
        }else {
            //find section title
            let sectionTitle = self.sectionTitlelist[section]
            
            //user for given title
            let users = self.allUsersGropped[sectionTitle]
            
            return users!.count
            
        }

        
        
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! UserTableViewCell

        var user: FUser
        
        if searchController.isActive && searchController.searchBar.text != "" {
            user = filterdUsers[indexPath.row]
        
        }else{
          
            let sectionTitle = self.sectionTitlelist[indexPath.section]
            
            let users = self.allUsersGropped[sectionTitle]
            user = users![indexPath.row]
            
        }
        
        
        cell.genrateCellWith(fUser: user, indexPath: indexPath)
        cell.delegate = self
        return cell
    }
    
    //MARK:TableView Delgate
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if searchController.isActive && searchController.searchBar.text != "" {
            return ""
        }else{
            return sectionTitlelist[section]
        }
        
    }
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        if searchController.isActive && searchController.searchBar.text != "" {
        return nil
        }else {
            return self.sectionTitlelist
        }
    }
    
    
    
    
    override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return index
    }
        
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        var user: FUser
        
        if searchController.isActive && searchController.searchBar.text != "" {
            user = filterdUsers[indexPath.row]
        
        }else{
          
            let sectionTitle = self.sectionTitlelist[indexPath.section]
            
            let users = self.allUsersGropped[sectionTitle]
            user = users![indexPath.row]
            
        }
        
       if !checkBlockedStatus(withUser: user) {
                
                let chatVC = ChatViewController()
                chatVC.titleName = user.firstname
                chatVC.membersToPush = [FUser.currentId(), user.objectId]
                chatVC.membarIds = [FUser.currentId(), user.objectId]
                chatVC.chatRoonmId = startPrivateChat(user1: FUser.currentUser()!, user2: user)
                chatVC.isGroup = false
                chatVC.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(chatVC, animated: true)
                
                
            } else {
                ProgressHUD.showError("This user is not available for chat!")
            }
            
        }
    
    func loadUser(filter:String)
    {
        
        ProgressHUD.show()
        var query : Query!
        switch filter {
        case kCITY:
            query = reference(.User).whereField(kCITY, isEqualTo: FUser.currentUser()!.city).order(by: kFIRSTNAME, descending: false)
        case kCOUNTRY:
            query = reference(.User).whereField(kCOUNTRY, isEqualTo: FUser.currentUser()!.country).order(by: kFIRSTNAME, descending: false)

        default:
            query = reference(.User).order(by: kFIRSTNAME, descending: false)
        }
        
        query.getDocuments { (sanpshot, error) in
            self.allUsers = []
            self.sectionTitlelist = []
            self.allUsersGropped = [:]
            
            if error != nil {
                print(error!.localizedDescription)
                ProgressHUD.dismiss()
                self.tableView.reloadData()
                return
            }
            guard let snapshot = sanpshot else{
                ProgressHUD.dismiss(); return
            }
            if !snapshot.isEmpty{
                for userDictionary in snapshot.documents{
                    let userDictionary = userDictionary.data() as NSDictionary
                    let fUser = FUser(_dictionary: userDictionary)
                    
                    if fUser.objectId != FUser.currentId() {
                        self.allUsers.append(fUser)
                    }
                }
                self.splitDataIntoSection()
                self.tableView.reloadData()
            }
            self.tableView.reloadData()
            ProgressHUD.dismiss()
        }
    }
    
    //MARK: IBAction
    
    @IBAction func filterSegmentValueChange(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            loadUser(filter: kCITY)
        case 1:
            loadUser(filter: kCOUNTRY)
        case 2:
            loadUser(filter: "")
        default:
            return
        }
    }
    
    //MARK: Search controller functions
    
    func filterContentForSearchText(searchText: String, scop: String = "All"){
        
        filterdUsers = allUsers.filter({ (user) -> Bool in
            
            return user.firstname.lowercased().contains(searchText.lowercased())
        })
        tableView.reloadData()
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        
        filterContentForSearchText(searchText: searchController.searchBar.text!)
    }
    
  //MARK: Helper Fanftions
    
    fileprivate func splitDataIntoSection(){
        var sectionTitle: String = ""
        for i in 0..<self.allUsers.count{
            
            let currentUser = self.allUsers[i]
            
            let firstChar = currentUser.firstname.first!
            
            let firstCharString = "\(firstChar)"
            
            if firstCharString != sectionTitle {
                sectionTitle = firstCharString
                self.allUsersGropped[sectionTitle] = []
                
                if !sectionTitlelist.contains(sectionTitle) {
                self.sectionTitlelist.append(sectionTitle)
                }
            }
            self.allUsersGropped[firstCharString]?.append(currentUser)
        }
    }
    
    
    //MARK: UserTableViewCellDelgate
    func didTapAvatarImage(indexPath: IndexPath) {
        let profileVc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "profileView") as! ProfileViewTableViewController
        
        var user: FUser
        if searchController.isActive && searchController.searchBar.text != "" {
                    user = filterdUsers[indexPath.row]
               
               }else{
                 
                   let sectionTitle = self.sectionTitlelist[indexPath.section]
                   
                   let users = self.allUsersGropped[sectionTitle]
                   user = users![indexPath.row]
                   
               }
        profileVc.user = user
        
        self.navigationController?.pushViewController(profileVc, animated: true)
    }

}
