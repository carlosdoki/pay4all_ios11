//
//  CadastroUsuarioVC.swift
//  Pay4All
//
//  Created by Carlos Doki on 03/06/17.
//  Copyright © 2017 Carlos Doki. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper
import CoreImage

class CadastroUsuarioVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imageAdd: UIImageView!
    @IBOutlet weak var nomeField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var confirmarEmailField: UITextField!
    @IBOutlet weak var dddField: UITextField!
    @IBOutlet weak var celularField: UITextField!
    @IBOutlet weak var senhaField: UITextField!
    @IBOutlet weak var confirmarSenhaField: UITextField!
    @IBOutlet weak var cpfField: UITextField!
    
    var ID = ""
    var imagePicker: UIImagePickerController!
    static var imageCache: NSCache<AnyObject, UIImage> = NSCache()
    var imageSelected = false
    var newMedia: Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        //        imagePicker.delegate = self as! UIImagePickerControllerDelegate & UINavigationControllerDelegate
        imagePicker.delegate = self
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
    
    @IBAction func cadastrarBtn(_ sender: UIButton) {
        if emailField.text != confirmarEmailField.text {
            let alertController = UIAlertController(title: "Alerta", message: "Email digitados não conferem!", preferredStyle: .alert)
            //We add buttons to the alert controller by creating UIAlertActions:
            let actionOk = UIAlertAction(title: "OK",
                                         style: .default,
                                         handler: nil) //You can use a block here to handle a press on this button
            
            alertController.addAction(actionOk)
            
            self.present(alertController, animated: true, completion: nil)
            return
            
        }
        if senhaField.text != confirmarSenhaField.text {
            let alertController = UIAlertController(title: "Alerta", message: "Senhas digitadas não conferem!", preferredStyle: .alert)
            //We add buttons to the alert controller by creating UIAlertActions:
            let actionOk = UIAlertAction(title: "OK",
                                         style: .default,
                                         handler: nil) //You can use a block here to handle a press on this button
            
            alertController.addAction(actionOk)
            
            self.present(alertController, animated: true, completion: nil)
            return
        }
        if (emailField.text ==  "" || confirmarEmailField.text == "" ||
            senhaField.text == "" || confirmarSenhaField.text == "") {
            let alertController = UIAlertController(title: "Alerta", message: "Campos em branco!", preferredStyle: .alert)
            //We add buttons to the alert controller by creating UIAlertActions:
            let actionOk = UIAlertAction(title: "OK",
                                         style: .default,
                                         handler: nil) //You can use a block here to handle a press on this button
            
            alertController.addAction(actionOk)
            
            self.present(alertController, animated: true, completion: nil)
            return
        }
        
        if let email = emailField.text, let pwd = senhaField.text, let nome = nomeField.text, let ddd = dddField.text, let celular = celularField.text, let cpf = cpfField.text {
            var downloadUrl = ""
            guard  let img = self.imageAdd.image, self.imageSelected == true else {
                print("DOKI: An image must be selected")
                return
            }
            
            if let imgData = UIImageJPEGRepresentation(img, 0.2) {
                let imguid = NSUUID().uuidString
                let metadata = FIRStorageMetadata()
                metadata.contentType = "image/jpeg"
                
                DataService.ds.REF_POST_IMAGES.child(imguid).put(imgData, metadata: metadata) { (metadata, error) in
                    if error != nil {
                        print("DOKI: Unabled to upload to Firebase storage")
                    } else {
                        print("DOKI: Successfully uploaded image to Firebase storage")
                        downloadUrl = (metadata?.downloadURL()?.absoluteURL.absoluteString)!
                        FIRAuth.auth()?.signIn(withEmail: email, password: pwd, completion: { (user, error) in
                            if error == nil {
                                print("DOKI: User authenticated with Firebase")
                                if let user = user {
                                    let userData = ["provider": user.providerID,
                                                    "ddd" : ddd,
                                                    "celular" : celular,
                                                    "nome" : nome,
                                                    "cpfcnpj" : cpf,
                                                    "foto" : downloadUrl]
                                    self.completeSignIn(id: user.uid, userData: userData)
                                }
                            } else {
                                
                                FIRAuth.auth()?.createUser(withEmail: email, password: pwd, completion: {(user, error) in
                                    if error != nil {
                                        print("DOKI: Unable to authenticated using email - \(String(describing: error))")
                                    } else {
                                        print("DOKI: Sucessfully authenticated with Firebase")
                                        if let user = user {
                                            let userData = ["provider": user.providerID,
                                                            "ddd" : ddd,
                                                            "celular" : celular,
                                                            "nome" : nome,
                                                            "cpfcnpj" : cpf,
                                                            "foto" : downloadUrl]
                                            self.completeSignIn(id: user.uid, userData: userData)
                                        }
                                        //self.dismiss(animated: true, completion: nil)
                                    }
                                })
                            }
                        })
                    }
                }
            }
        }
    }
    
    func completeSignIn(id: String, userData: Dictionary<String, String>) {
        DataService.ds.createFirebaseDBUser(uid: id, userData: userData)
        let keychainResult = KeychainWrapper.standard.set(id, forKey: KEY_UID)
        print("DOKI: Data saved to keychain \(keychainResult)")
        performSegue(withIdentifier: "TelaPrincipal", sender: nil)
    }
    
    @IBAction func voltarPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            imageAdd.image = image
            imageSelected = true
        } else {
            print("DOKI: A valid image wasn't selected")
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addPhotoPressed(_ sender: Any) {
        present(imagePicker, animated: true, completion: nil)
    }
}
