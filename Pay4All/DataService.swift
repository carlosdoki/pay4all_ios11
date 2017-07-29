//
//  DataService.swift
//  Pay4All
//
//  Created by Carlos Doki on 03/06/17.
//  Copyright © 2017 Carlos Doki. All rights reserved.
//

import Foundation
import Firebase
import SwiftKeychainWrapper

let DB_BASE = FIRDatabase.database().reference()
let STORAGE_BASE = FIRStorage.storage().reference()

class DataService {
    static let ds = DataService()
    
    // DB References
    private var _REF_BASE = DB_BASE
    private var _REF_CARTEIRA = DB_BASE.child("carteira")
    private var _REF_USERS = DB_BASE.child("users")
    private var _REF_CONTRATO = DB_BASE.child("contrato")
    private var _REF_TRANSACAO = DB_BASE.child("transacao")
    
    // Storage References
    private var _REF_POST_IMAGES=STORAGE_BASE.child("post-pics")
    
    
    var REF_BASE: FIRDatabaseReference {
        return _REF_BASE
    }
    
    var REF_CARTEIRA: FIRDatabaseReference {
        return _REF_CARTEIRA
    }
    
    var REF_USERS: FIRDatabaseReference {
        return _REF_USERS
    }
    
    var REF_CONTRATO: FIRDatabaseReference {
        return _REF_CONTRATO
    }

    var REF_TRANSACAO: FIRDatabaseReference {
        return _REF_TRANSACAO
    }
    
    var REF_POST_IMAGES: FIRStorageReference {
        return _REF_POST_IMAGES
    }
    
    var REF_USER_CURRENT: FIRDatabaseReference {
        let uid = KeychainWrapper.standard.string(forKey: KEY_UID)
        let user = REF_USERS.child(uid!)
        return user
    }
    
    func createFirebaseDBUser(uid: String, userData: Dictionary<String, String>) {
        REF_USERS.child(uid).updateChildValues(userData)
    }
    
}

