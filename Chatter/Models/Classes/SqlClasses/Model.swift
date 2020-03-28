//
//  Model.swift
//  Chatter
//
//  Created by Avihai Shabtai on 25/03/2020.
//  Copyright © 2020 Niv-Ackerman. All rights reserved.
//

import Foundation
import UIKit

class Model {
    static let instance = Model()
    
    var blockedUsersArray : [FUser] = []
    
    var BlockedUsers:BlockedUsersViewController = BlockedUsersViewController()
    
    private init(){
    }
    
    func getAllBlockingUsers(callback:@escaping ([FUser]?)->Void){
        FUser.deleteUsersFromDB()
         if FUser.currentUser()!.blockedUsers.count > 0 {
        getUsersFromFirestore(withIds: FUser.currentUser()!.blockedUsers) { (allBlockedUsers) in
            
            self.blockedUsersArray = allBlockedUsers
        }
        //insert update to the local db
        for user in blockedUsersArray{
            user.addToDb()
        }
        }
        // get the complete users list
        let finalData = FUser.getAllUsersFromDb()
        callback(finalData);
        
    }
    
}
class ModelEvents{
    static let UserDataEvent = EventNotificationBase(eventName: "com.ackerman.UserDataEvent");
    
    private init(){}
}

class EventNotificationBase{
    let eventName:String;
    
    init(eventName:String){
        self.eventName = eventName;
    }
    
    func observe(callback:@escaping ()->Void){
        NotificationCenter.default.addObserver(forName: NSNotification.Name(eventName),
                                               object: nil, queue: nil) { (data) in
                                                callback();
        }
    }
    
    func post(){
        NotificationCenter.default.post(name: NSNotification.Name(eventName),
                                        object: self,
                                        userInfo: nil);
    }
}

