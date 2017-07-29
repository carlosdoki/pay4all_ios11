//
//  Transacao.swift
//  Pay4All
//
//  Created by Carlos Doki on 04/06/17.
//  Copyright © 2017 Carlos Doki. All rights reserved.
//

import Foundation
import Firebase

class Transacao {
    private var _carteira : String!
    private var _data : Double!
    private var _idContrato : String!
    private var _latitude : String!
    private var _longitude : String!
    private var _user : String!
    private var _valor : String!
    private var _vendedor: String!
    private var _hashBlockChain: String!
    private var _id : String!
    private var _postRef: FIRDatabaseReference!
    private var _postKey: String!
    
    var carteira : String {
        return _carteira
    }
    
    var data: Double {
        return _data
    }
    
    var idContrato: String {
        return _idContrato
    }
    
    var latitude: String {
        return _latitude
    }
    
    var longitude: String {
        return _longitude
    }
    
    var user: String {
        return _user
    }
    var id: String {
        return _id
    }
    
    var valor: String {
        return _valor
    }
    
    var vedendor: String {
        return _vendedor
    }
    
    var hashBlockChain: String {
        return _hashBlockChain
    }
    
    init(carteira: String, data: Double, idContrato: String, latitude: String, longitude: String, user: String, valor: String, vedendor: String, hashBlockChain: String, id: String) {
        self._carteira = carteira
        self._data = data
        self._idContrato = idContrato
        self._latitude = latitude
        self._longitude = longitude
        self._user = user
        self._valor = valor
        self._vendedor = vedendor
        self._hashBlockChain = hashBlockChain
        self._id = id
    }
    
    init(postKey: String, postData: Dictionary<String, AnyObject>) {
        self._postKey = postKey
        
        if let carteira = postData["carteira"] as? String {
            self._carteira = carteira
        }
        
        if let data = postData["data"] as? Double {
            self._data = data
        }
        
        if let idContrato = postData["idContrato"] as? String {
            self._idContrato = idContrato
        }
        
        if let latitude = postData["latitude"] as? String {
            self._latitude = latitude
        }
        
        if let longitude = postData["longitude"] as? String {
            self._longitude = longitude
        }
        
        if let user = postData["user"] as? String {
            self._user = user
        }
        
        if let valor = postData["valor"] as? String {
            self._valor = valor
        }
        
        if let vedendor = postData["vedendor"] as? String {
            self._vendedor = vedendor
        }
        
        if let hashBlockChain = postData["hashBlockChain"] as? String {
            self._hashBlockChain = hashBlockChain
        }
        
        if let id = postData["id"] as? String {
            self._id = id
        }
        
        _postRef = DataService.ds.REF_TRANSACAO.child(_postKey)
    }
}
