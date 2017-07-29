//
//  PostCarteira.swift
//  Pay4All
//
//  Created by Carlos Doki on 03/06/17.
//  Copyright © 2017 Carlos Doki. All rights reserved.
//

import Foundation
import Firebase

class PostCarteira {
    private var _id : String!
    private var _idUser : String!
    private var _nome : String!
    private var _hashBlockChain : String!
    private var _tipo: String!
    private var _postKey: String!
    private var _postRef: FIRDatabaseReference!
    
    var id : String {
        return _id
    }
    
    var idUser: String {
        return _idUser
    }

    var nome: String {
        return _nome
    }
    
    var tipo: String {
        return _tipo
    }
    
    var postKey: String {
        return _postKey
    }
    
    var hashBlockChain: String {
        return _hashBlockChain
    }
    
    init(id: String, idUSer: String, nome: String, hashBlockChain: String, tipo: String) {
        self._id = id
        self._idUser = idUSer
        self._nome = nome
        self._hashBlockChain = hashBlockChain
        self._tipo = tipo
    }
    
    init(postKey: String, postData: Dictionary<String, AnyObject>) {
        self._postKey = postKey
        
        if let nome = postData["nome"] as? String {
            self._nome = nome
        }
        
        if let id = postData["id"] as? String {
            self._id = id
        }
        
        if let idUser = postData["idUser"] as? String {
            self._idUser = idUser
        }
        
        if let tipo = postData["tipo"] as? String {
            self._tipo = tipo
        }
        
        if let hashBlockChain = postData["hashBlockChain"] as? String {
            self._hashBlockChain = hashBlockChain
        }
        
        _postRef = DataService.ds.REF_CARTEIRA.child(_postKey)
    }
}

