//
//  ReciboVC.swift
//  Pay4All
//
//  Created by Carlos Doki on 04/06/17.
//  Copyright © 2017 Carlos Doki. All rights reserved.
//

import UIKit

class ReciboVC: UIViewController {

    var data : Double!
    var id: String!
    var valor: String!
    var carteira: String!
    
    @IBOutlet weak var dataLbl: UILabel!
    @IBOutlet weak var idLbl: UILabel!
    @IBOutlet weak var empresaLbl: UILabel!
    @IBOutlet weak var valorLbl: UILabel!
    @IBOutlet weak var carteiraLbl: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let date = Date(timeIntervalSince1970: data!)
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT-3") //Set timezone that you want
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "dd/MM/yyyy HH:mm" //Specify your format that you want
        let strDate = dateFormatter.string(from: date)
        
        dataLbl.text = strDate
        idLbl.text = "DOC=" + id
        empresaLbl.text = ""
        valorLbl.text = "Valor: " + valor
        carteiraLbl.text = "Carteira: " + carteira
        // Do any additional setup after loading the view.
    }


}
