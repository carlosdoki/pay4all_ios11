//
//  CellVCTableViewCell.swift
//  
//
//  Created by Carlos Doki on 03/06/17.
//
//

import UIKit
import Firebase

class CellVC: UITableViewCell {

    @IBOutlet weak var tipoField: UILabel!
    @IBOutlet weak var nomeField: UILabel!
    
    var post: PostCarteira!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    
    func configureCell(nome: String, tipo: String ) {
        self.nomeField.text = nome
        self.tipoField.text = tipo
    }

}
