//
//  HIstoricoVC.swift
//  Pay4All
//
//  Created by Carlos Doki on 04/06/17.
//  Copyright © 2017 Carlos Doki. All rights reserved.
//

import UIKit
import Firebase

class HIstoricoVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate {

    @IBOutlet weak var tableView: UITableView!
    var transacao = [Transacao]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        
        DataService.ds.REF_TRANSACAO.observe(.value, with: { (snapshot) in
            if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for snap in snapshot {
                    print("DOKI: \(snap)")
                    if let postDict = snap.value as? Dictionary<String, AnyObject> {
                        let key = snap.key
                        let post = Transacao(postKey: key, postData: postDict)
                        self.transacao.append(post)
                    }
                }
            }
            self.tableView.reloadData()
        })
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return transacao.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let post = transacao[indexPath.row]
        if let cell = tableView.dequeueReusableCell(withIdentifier: "HistoricoCell") as? HistoricoCellVC {
            cell.configureCell(data: post.data, doc: post.id, carteira: post.carteira, valor: post.valor )
            return cell
        } else {
            return HistoricoCellVC()
        }
    }
    
    @IBAction func voltarPressed(_ sender: Any) {
                 self.dismiss(animated: true, completion: nil)
    }
}
