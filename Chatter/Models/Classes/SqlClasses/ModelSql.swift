//
//  ModelSql.swift
//  Chatter
//
//  Created by Avihai Shabtai on 25/03/2020.
//  Copyright © 2020 Niv-Ackerman. All rights reserved.
//

import Foundation

class ModelSql{
    static let instance = ModelSql()

    var database: OpaquePointer? = nil
    
    
    
    private init() {
        let dbFileName = "database2.db"
        if let dir = FileManager.default.urls(for: .documentDirectory, in:
            .userDomainMask).first{
            let path = dir.appendingPathComponent(dbFileName)
            if sqlite3_open(path.absoluteString, &database) != SQLITE_OK {
                print("Failed to open db file: \(path.absoluteString)")
                return
            }
        }
        create();
        FUser.create_table(database: database);
    }
    
    deinit {
        sqlite3_close_v2(database);
    }
    
    private func create(){
        var errormsg: UnsafeMutablePointer<Int8>? = nil
        let res = sqlite3_exec(database, "CREATE TABLE IF NOT EXISTS LAST_UPADATE_DATE (NAME TEXT PRIMARY KEY, DATE DOUBLE)", nil, nil, &errormsg);
        if(res != 0){
            print("error creating table");
            return
        }
    }

    
}
