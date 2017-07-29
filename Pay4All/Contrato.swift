//
//  Contrato.swift
//  Pay4All
//
//  Created by Carlos Doki on 04/06/17.
//  Copyright © 2017 Carlos Doki. All rights reserved.
//

import Foundation
import Firebase

class Contrato {
    private var _id :String!
    private var _carteira: String!
    private var _celularIMEI: String!
    private var _tipoContrato: String!
    private var _vendedor: String!
    private var _DataInicio: String!
    private var _DataFim: String!
    private var _postRef: FIRDatabaseReference!
    private var _postKey: String!
    
    var id : String {
        return _id
    }
    
    var carteira : String {
        return _carteira
    }
    
    var celularIMEI: String {
        return _celularIMEI
    }
    
    var tipoContrato : String {
        return _tipoContrato
    }
    
    var vendedor: String {
        return _vendedor
    }
    
    var DataInicio:String {
        return _DataInicio
    }
    
    var DataFim: String {
        return _DataFim
    }
    
    var postKey: String {
        return _postKey
    }
    
    
    init(id: String, carteira: String, celularIMEI: String, tipoContrato: String, vendedor: String, DataInicio: String, DataFim: String) {
        self._id  = id
        self._carteira = carteira
        self._celularIMEI = celularIMEI
        self._tipoContrato = tipoContrato
        self._vendedor = vendedor
        self._DataInicio = DataInicio
        self._DataFim = DataFim
        
    }
    
    init(postKey: String, postData: Dictionary<String, AnyObject>) {
        self._postKey = postKey
        
        if let id = postData["id"] as? String {
            self._id = id
        }
        
        if let carteira = postData["carteira"] as? String {
            self._carteira = carteira
        }
        
        if let celularIMEI = postData["celularIMEI"] as? String {
            self._celularIMEI = celularIMEI
        }
        
        if let tipoContrato = postData["tipoContrato"] as? String {
            self._tipoContrato = tipoContrato
        }
        
        if let vendedor = postData["vendedor"] as? String {
            self._vendedor = vendedor
        }

        if let DataInicio = postData["DataInicio"] as? String {
            self._DataInicio = DataInicio
        }
        
        if let DataFim = postData["DataFim"] as? String {
            self._DataFim = DataFim
        }
        _postRef = DataService.ds.REF_CONTRATO.child(_postKey)
    }
}
