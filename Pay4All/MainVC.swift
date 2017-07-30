//
//  ViewController.swift
//  Pay4All
//
//  Created by Carlos Doki on 02/06/17.
//  Copyright © 2017 Carlos Doki. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper
import Firebase

class MainVC: UIViewController {

    @IBOutlet weak var leadingSuperior: NSLayoutConstraint!
    @IBOutlet weak var leadingPrincipal: NSLayoutConstraint!
    @IBOutlet weak var leadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var profileImg: CircleView!
    @IBOutlet weak var saudacaoLbl: UILabel!
    
    @IBOutlet weak var menuView: UIView!
    
    var menuShowing = false
    var userref: FIRDatabaseReference!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        menuView.layer.shadowOpacity = 1
        menuView.layer.shadowRadius = 6
        
        userref = DataService.ds.REF_USER_CURRENT
        userref.observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            if let username = value?["nome"] as? String {
                self.saudacaoLbl.text = "Olá \(username)"
            }
            if let img = value?["foto"] as? String {
                if let data = NSData(contentsOf: NSURL(string: img) as! URL) {
                    self.profileImg.image  = UIImage(data: data as Data)
                }
            }
        })
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func menuButton(_ sender: UIButton) {
        if (menuShowing) {
            leadingConstraint.constant = 0
            leadingSuperior.constant = 0
            leadingPrincipal.constant = 0
        } else {
            leadingConstraint.constant = -280
            leadingSuperior.constant = 0
            leadingPrincipal.constant = 0
            UIView.animate(withDuration: 0.4, animations: {
                self.menuView.alpha = 1
                self.view.layoutIfNeeded()
            })
        }
        
        menuShowing = !menuShowing

//        showMenu()
    }
    
    func showMenu() {
        UIView.animate(withDuration: 0.4, animations: {
            self.menuView.alpha = 1
            //self.menuView.screenCoverButton.alpha = 1
            })
    }

    func hideMenu() {
        UIView.animate(withDuration: 0.4, animations: {
            self.menuView.alpha = 0
            //self.menuView.screenCoverButton.alpha = 0
        })
    }
    
    @IBAction func exitPressed(_ sender: Any) {
        let removeSuccessful: Bool = KeychainWrapper.standard.removeObject(forKey: KEY_UID)
        print("DOKI: ID removed from keychain \(removeSuccessful)")
        try! FIRAuth.auth()?.signOut()
        exit(0)
    }

    @IBAction func geraQRPressed(_ sender: Any) {
        performSegue(withIdentifier: "gerarQRSegue", sender: nil)
    }
    @IBAction func historicoPressed(_ sender: Any) {
        performSegue(withIdentifier: "HistoricoVCSegue", sender: nil)
    }
    
    @IBAction func gerarQR(_ sender: UIButton) {
        performSegue(withIdentifier: "PagarSegue", sender: nil)
    }
    
}

