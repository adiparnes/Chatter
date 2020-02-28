//
//  ChatsViewController.swift
//  Chatter
//
//  Created by Avihai Shabtai on 23/02/2020.
//  Copyright © 2020 Niv-Ackerman. All rights reserved.
//

import UIKit
import FirebaseFirestore


class ChatsViewController: UIViewController,UITableViewDelegate,UITableViewDataSource , RecentChatTableViewCellDelegate, UISearchResultsUpdating{
    
    
    
    

    @IBOutlet weak var tableView: UITableView!
    
    var recentChats: [NSDictionary] = []
    var filteredChats: [NSDictionary] = []
    var recenetLisner: ListenerRegistration!
    
    let searchController = UISearchController(searchResultsController: nil)
    
    
    override func viewWillAppear(_ animated: Bool) {
        loadRecentChats()
        
        tableView.tableFooterView = UIView()
    }
    
    
    
    override func viewWillDisappear(_ animated: Bool) {
    
        recenetLisner.remove()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true
        
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        
        setTableViewHeader()
        
    }
    
//MARK:IBAction
    
    @IBAction func createNewChatButtonPressed(_ sender: Any) {
        let userVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier:"usersTableView") as! UsersTableViewController
        self.navigationController?.pushViewController(userVC, animated: true)
    }
    
    
    
  //MARK: TableViewsDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if searchController.isActive && searchController.searchBar.text != "" {
            return filteredChats.count
        }else{
            return recentChats.count
        }
        
        
        
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! RecentChatTableViewCell
        
        cell.delegate = self
        
        var recent: NSDictionary!
        
        
        
        if searchController.isActive && searchController.searchBar.text != "" {
            
                    recent = filteredChats[indexPath.row]

               }else{
                    
                        recent = recentChats[indexPath.row]
                }
        
        cell.genrateCell(recentChat: recent, indexPath: indexPath)
        
        
        return cell
    }
    
    
    //MARK: TableViewDelegate fanctions
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        
        var tempRecent: NSDictionary!
        
        
        if searchController.isActive && searchController.searchBar.text != "" {
                 tempRecent = filteredChats[indexPath.row]
         }else{
                  tempRecent = recentChats[indexPath.row]
                    }
        var muteTitle = "Unmute"
        var mute = false
        
        
        if(tempRecent[kMEMBERSTOPUSH] as! [String]).contains(FUser.currentId()) {
            muteTitle = "Mute"
            mute = true
        }
        
        let deleteAction = UITableViewRowAction(style: .default, title: "Delete") { (action, indexPath) in
            
            self.recentChats.remove(at: indexPath.row)
            
            deleteRecentChat(recentChatDictionary: tempRecent)
            
            self.tableView.reloadData()
            
        }
        
        
        let muteAction = UITableViewRowAction(style: .default, title: muteTitle) { (action, indexPath) in
            print("mute\(indexPath)")
        }
       
        muteAction.backgroundColor = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
        return [deleteAction, muteAction]
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        var recent: NSDictionary!
        
        
        if searchController.isActive && searchController.searchBar.text != "" {
                 recent = filteredChats[indexPath.row]
         }else{
                  recent = recentChats[indexPath.row]
                    }
        
        
        restatRecentChat(recent: recent)
        
        let chatVC = ChatViewController()
        chatVC.hidesBottomBarWhenPushed = true
        chatVC.membarIds = (recent[kMEMBERS] as? [String])!
        chatVC.membersToPush = (recent[kMEMBERSTOPUSH] as? [String])!
        chatVC.chatRoonmId = (recent[kCHATROOMID] as? String)!
        chatVC.titleName = (recent[kWITHUSERFULLNAME] as? String)!
        
        
        navigationController?.pushViewController(chatVC, animated: true)
        
        
    }
    
    
    //MARK: LoadRecenetChats
    
    func loadRecentChats() {
        
        recenetLisner = reference(.Recent).whereField(kUSERID, isEqualTo: FUser.currentId()).addSnapshotListener({ (snapshot, error) in
            
            guard let snapshot = snapshot else {return}
            
            
            self.recentChats = []
            
            if !snapshot.isEmpty {
                
                let sorted = ((dictionaryFromSnapshots(snapshots: snapshot.documents)) as NSArray).sortedArray(using: [NSSortDescriptor(key: kDATE, ascending: false)]) as! [NSDictionary]
                
                
                for recent in sorted {
                    
                    if recent[kLASTMESSAGE] as! String != "" && recent[kCHATROOMID] != nil && recent[kRECENTID] != nil {
                        self.recentChats.append(recent)
                        
                    }
                }
                
                self.tableView.reloadData()
            }
            
        })
        
    }
    
    
    //MARK: Custom tableViewHeader
        
    func setTableViewHeader() {
        let headerView = UIView(frame: CGRect(x:0,y:0, width: tableView.frame.width, height: 45))
        
        let buttonView = UIView(frame: CGRect(x: -30, y: 5, width: tableView.frame.width, height: 35))
        
        let groupButton = UIButton(frame: CGRect(x: tableView.frame.width - 110, y: 10, width: 100, height: 20))
        groupButton.addTarget(self, action: #selector(self.groupButtonPressed), for: .touchUpInside)
        groupButton.setTitle("New Group", for: .normal)
        let buttonColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
        groupButton.setTitleColor(buttonColor, for: .normal)
        
        let lineView = UIView(frame: CGRect(x: 0, y: headerView.frame.height - 1,width: tableView.frame.width, height: 1))
        lineView.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        buttonView.addSubview(groupButton)
        headerView.addSubview(buttonView)
        headerView.addSubview(lineView)
        
        tableView.tableHeaderView = headerView
        
    }

    @objc func groupButtonPressed() {
        print("hello")
    }
    
    
    //
    
    
    
   //MARK:Recent chatsCell dalegate
    
    func didTapAvatarImage(indexPath: IndexPath) {
                
        var recentChat: NSDictionary!
        
        if searchController.isActive && searchController.searchBar.text != "" {
            
                    recentChat = filteredChats[indexPath.row]

               }else{
                    
                        recentChat = recentChats[indexPath.row]
                }
        
        
        if recentChat[kTYPE] as! String == kPRIVATE {
            
            reference(.User).document(recentChat[kWITHUSERUSERID] as! String).getDocument { (snapshot, error) in
                guard let snapshot = snapshot else{return}
                
                if snapshot.exists {
                    let userDictionary = snapshot.data() as! NSDictionary
                    let tempUser = FUser(_dictionary: userDictionary)
                    
                    
                    self.showUserProfile(user: tempUser)
            
                }
            }
        }
        
    }
    
    func showUserProfile(user: FUser)
    {
        let profileVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier:"profileView") as! ProfileViewTableViewController
        
        profileVC.user = user
        self.navigationController?.pushViewController(profileVC, animated: true)
        
    }
    
    //MARK: Search controller functions
    
    func filterContentForSearchText(searchText: String, scop: String = "All"){
        
        filteredChats = recentChats.filter({ (recenChat) -> Bool in
            
            return (recenChat[kWITHUSERFULLNAME] as! String).lowercased().contains(searchText.lowercased())
        })
        tableView.reloadData()
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        
        filterContentForSearchText(searchText: searchController.searchBar.text!)
    }
    
    
}
