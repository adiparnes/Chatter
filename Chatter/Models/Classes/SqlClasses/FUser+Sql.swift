//
//  FUser+Sql.swift
//  Chatter
//
//  Created by Avihai Shabtai on 25/03/2020.
//  Copyright © 2020 Niv-Ackerman. All rights reserved.
//

import Foundation

extension FUser{
    
    static func create_table(database: OpaquePointer?){
        var errormsg: UnsafeMutablePointer<Int8>? = nil
        
        let res = sqlite3_exec(database, "CREATE TABLE IF NOT EXISTS FUSERS (ObjectId TEXT PRIMARY KEY, PushId TEXT, CreatedAt TEXT, UpdatedAt TEXT, Email TEXT, Firstname TEXT,Lastname TEXT, Avatar TEXT , LoginMethod TEXT, PhoneNumber TEXT,City TEXT,Country TEXT)", nil, nil, &errormsg);
        if(res != 0){
            print("error creating table");
            return
        }
    }
    
    static func deleteUsersFromDB() {
    let deleteStatementString = "DELETE FROM FUSERS";
     var deleteStatement: OpaquePointer?
     if sqlite3_prepare_v2(ModelSql.instance.database, deleteStatementString, -1, &deleteStatement, nil) ==
         SQLITE_OK {
       if sqlite3_step(deleteStatement) == SQLITE_DONE {
         print("\nSuccessfully deleted row.")
       } else {
         print("\nCould not delete row.")
       }
     } else {
       print("\nDELETE statement could not be prepared")
     }
     
     sqlite3_finalize(deleteStatement)
   }
    
    

    func addToDb(){
        var sqlite3_stmt: OpaquePointer? = nil
        if (sqlite3_prepare_v2(ModelSql.instance.database,"INSERT OR REPLACE INTO FUSERS(ObjectId, PushId,CreatedAt,UpdatedAt,Email,Firstname,Lastname,Avatar,LoginMethod,PhoneNumber,City,Country) VALUES (?,?,?,?,?,?,?,?,?,?,?,?);",-1,&sqlite3_stmt,nil) == SQLITE_OK){
            let objectId = self.objectId.cString(using: .utf8)
            let pushId = self.pushId?.cString(using: .utf8)
            let createdAt = dateFormatter().string(from: self.createdAt).cString(using: .utf8)
            let updatedAt = dateFormatter().string(from: self.updatedAt).cString(using: .utf8)
            let email = self.email.cString(using: .utf8)
            let firstname = self.firstname.cString(using: .utf8)
            let lastname = self.lastname.cString(using: .utf8)
            let avatar = self.avatar.cString(using: .utf8)
            let loginMethod = self.loginMethod.cString(using: .utf8)
            let phoneNumber = self.phoneNumber.cString(using: .utf8)
            let city = self.city.cString(using: .utf8)
            let country = self.country.cString(using: .utf8)
            
            sqlite3_bind_text(sqlite3_stmt, 1, objectId,-1,nil);
            sqlite3_bind_text(sqlite3_stmt, 2, pushId,-1,nil);
            sqlite3_bind_text(sqlite3_stmt, 3, createdAt,-1,nil);
            sqlite3_bind_text(sqlite3_stmt, 4, updatedAt,-1,nil);
            sqlite3_bind_text(sqlite3_stmt, 5, email,-1,nil);
            sqlite3_bind_text(sqlite3_stmt, 6, firstname,-1,nil);
            sqlite3_bind_text(sqlite3_stmt, 7, lastname,-1,nil);
            sqlite3_bind_text(sqlite3_stmt, 8, avatar,-1,nil);
            sqlite3_bind_text(sqlite3_stmt, 9, loginMethod,-1,nil);
            sqlite3_bind_text(sqlite3_stmt, 10, phoneNumber,-1,nil);
            sqlite3_bind_text(sqlite3_stmt, 11, city,-1,nil);
            sqlite3_bind_text(sqlite3_stmt, 12, country,-1,nil);
            if(sqlite3_step(sqlite3_stmt) == SQLITE_DONE){
                print("new row added succefully")
            }
        }
    }
    
    static func getAllUsersFromDb()->[FUser]{
        var sqlite3_stmt: OpaquePointer? = nil
        var data = [FUser]()
        if (sqlite3_prepare_v2(ModelSql.instance.database,"SELECT * from FUSERS;",-1,&sqlite3_stmt,nil) == SQLITE_OK){
            while(sqlite3_step(sqlite3_stmt) == SQLITE_ROW){
                let objectId = String(cString:sqlite3_column_text(sqlite3_stmt,0)!)
                let pushId = String(cString:sqlite3_column_text(sqlite3_stmt,1)!)
                let createdAt = String(cString:sqlite3_column_text(sqlite3_stmt,2)!)
                let updatedAt = String(cString:sqlite3_column_text(sqlite3_stmt,3)!)
                let email = String(cString:sqlite3_column_text(sqlite3_stmt,4)!)
                let firstname = String(cString:sqlite3_column_text(sqlite3_stmt,5)!)
                let lastname = String(cString:sqlite3_column_text(sqlite3_stmt,6)!)
                let avatar = String(cString:sqlite3_column_text(sqlite3_stmt,7)!)
                let loginMethod = String(cString:sqlite3_column_text(sqlite3_stmt,8)!)
                let phoneNumber = String(cString:sqlite3_column_text(sqlite3_stmt,9)!)
                let city = String(cString:sqlite3_column_text(sqlite3_stmt,10)!)
                let country = String(cString:sqlite3_column_text(sqlite3_stmt,11)!)
                
                data.append(FUser(_objectId: objectId, _pushId: pushId,_createdAt: dateFormatter().date(from: createdAt)!,_updatedAt: dateFormatter().date(from: updatedAt)!, _email: email, _firstname: firstname, _lastname: lastname, _avatar: avatar, _loginMethod: loginMethod, _phoneNumber: phoneNumber, _city: city, _country: country))
            }
        }
        sqlite3_finalize(sqlite3_stmt)
        return data
    }
    
        
}

