//
//  ListarCarteira.swift
//  Pay4All
//
//  Created by Carlos Doki on 03/06/17.
//  Copyright © 2017 Carlos Doki. All rights reserved.
//

import UIKit
import Firebase

class ListarCarteira: UIViewController, UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func voltarPressed(_ sender: UIButton) {
         self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func exitPressed(_ sender: Any) {
        exit(0)
    }
    
    @IBAction func geraQRPressed(_ sender: Any) {
        performSegue(withIdentifier: "GeraQRSegue", sender: nil)
    }
    

    var postcarteira = [PostCarteira]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        DataService.ds.REF_CARTEIRA.observe(.value, with: { (snapshot) in
            if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for snap in snapshot {
                    print("DOKI: \(snap)")
                    if let postDict = snap.value as? Dictionary<String, AnyObject> {
                        let key = snap.key
                        let post = PostCarteira(postKey: key, postData: postDict)
                        self.postcarteira.append(post)
                    }
                }
            }
            self.tableView.reloadData()
        })
        
        // Do any additional setup after loading the view.
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postcarteira.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let post = postcarteira[indexPath.row]
        if let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as? CellVC {
            cell.configureCell(nome: post.nome, tipo: post.tipo)
            return cell
        } else {
            return CellVC()
        }
    }
    @IBAction func historicoPressed(_ sender: Any) {
        performSegue(withIdentifier: "HistoricoVCSegue", sender: nil)
    }
}
