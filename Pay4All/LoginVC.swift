//
//  LoginVC.swift
//  Pay4All
//
//  Created by Carlos Doki on 03/06/17.
//  Copyright © 2017 Carlos Doki. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper
import LocalAuthentication

class LoginVC: UIViewController {

    @IBOutlet weak var usuarioText: UITextField!
    @IBOutlet weak var senhaText: UITextField!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let _ = KeychainWrapper.standard.string(forKey: KEY_UID) {
            print("DOKI: ID found in keychain")
            performSegue(withIdentifier: "EntrarSegue", sender: nil)
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
    
    @IBAction func Login(_ sender: Any) {
        if let email = usuarioText.text, let pwd = senhaText.text {
            FIRAuth.auth()?.signIn(withEmail: email, password: pwd, completion: { (user, error) in
                if error == nil {
                    print("DOKI: User authenticated with Firebase")
                    if let user = user {
                        let userData = ["provider": user.providerID]
                        self.completeSignIn(id: user.uid, userData: userData)
                    }
                } else {
                    let alert = UIAlertController(title: "Erro ao Entrar", message: "E-mail ou senha inválidos ou não cadastrado!", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            })
        }
    }
    
    func firebaseAuth(_ credential: FIRAuthCredential) {
        FIRAuth.auth()?.signIn(with: credential, completion: { (user, error) in
            if error != nil {
                print("DOKI: unable to authentication with Firebase - \(error)")
            } else {
                print("DOKI: Sucessfully authentication with Firebase")
                if let user = user {
                    let userData = [
                        "provider": credential.provider,
                        "username": user.displayName,
                        "photoUrl": user.photoURL?.absoluteString
                    ]
                    self.completeSignIn(id: user.uid, userData: userData as! Dictionary<String, String>)
                }
            }
        })
    }
    
    func completeSignIn(id: String, userData: Dictionary<String, String>) {
        DataService.ds.createFirebaseDBUser(uid: id, userData: userData)
        let keychainResult = KeychainWrapper.standard.set(id, forKey: KEY_UID)
        userUUID = id
        print("DOKI: Data saved to keychain \(keychainResult)")
        performSegue(withIdentifier: "EntrarSegue", sender: nil)
    }
    
}
