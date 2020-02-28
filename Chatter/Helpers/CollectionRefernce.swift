//
//  CollectionRefernce.swift
//  Chatter
//
//  Created by Avihai Shabtai on 22/02/2020.
//  Copyright © 2020 Niv-Ackerman. All rights reserved.
//

import Foundation
import FirebaseFirestore


enum FCollectionReference: String {
    case User
    case Typing
    case Recent
    case Message
    case Group
    case Call
}


func reference(_ collectionReference: FCollectionReference) -> CollectionReference{
    return Firestore.firestore().collection(collectionReference.rawValue)
}
