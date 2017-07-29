//
//  HistoricoCellVC.swift
//  Pay4All
//
//  Created by Carlos Doki on 04/06/17.
//  Copyright © 2017 Carlos Doki. All rights reserved.
//

import UIKit
import Firebase

class HistoricoCellVC: UITableViewCell {

    @IBOutlet weak var datalbl: UILabel!
    @IBOutlet weak var doclbl: UILabel!
    @IBOutlet weak var carteiralbl: UILabel!
    @IBOutlet weak var valorlbl: UILabel!
    
    var post: Transacao!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configureCell(data: Double, doc: String, carteira: String, valor: String ) {
        let date = Date(timeIntervalSince1970: data)
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT-3") //Set timezone that you want
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "dd/MM/yyyy HH:mm" //Specify your format that you want
        let strDate = dateFormatter.string(from: date)
        
        self.doclbl.text = "DOC: " + doc
        self.carteiralbl.text = "Carteira: " + carteira
        self.valorlbl.text = "Valor: R$ " + valor
        self.datalbl.text = "Data: " + strDate
    }
}
