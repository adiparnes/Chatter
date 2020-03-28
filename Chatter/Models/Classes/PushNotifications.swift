//
//  PushNotifications.swift
//  Chatter
//
//  Created by Avihai Shabtai on 21/03/2020.
//  Copyright © 2020 Niv-Ackerman. All rights reserved.
//


import Foundation


func sendPushNotification(memberToPush: [String], message: String) {
    
    let updatedMembers = removeCurrentUserFromMembersArray(members: memberToPush)
    
    getMembersToPush(members: updatedMembers) { (userPushIds) in
        
        let currentUser = FUser.currentUser()!
        
    }
    
}


func removeCurrentUserFromMembersArray(members: [String]) -> [String] {
    
    var updatedMembers : [String] = []
    
    for memberId in members {
        if memberId != FUser.currentId() {
            updatedMembers.append(memberId)
        }
    }
    
    return updatedMembers
}


func getMembersToPush(members: [String], completion: @escaping (_ usersArray: [String]) -> Void) {
    
    var pushIds: [String] = []
    var count = 0
    
    for memberId in members {
        
        reference(.User).document(memberId).getDocument { (snapshot, error) in
            
            guard let snapshot = snapshot else { completion(pushIds); return }
            
            if snapshot.exists {
                
                let userDictionary = snapshot.data() as! NSDictionary
                
                let fUser = FUser.init(_dictionary: userDictionary)
                
                pushIds.append(fUser.pushId!)
                count += 1
                
                if members.count == count {
                    completion(pushIds)
                }
                
            } else {
                completion(pushIds)
            }
        }
    }
    
}
