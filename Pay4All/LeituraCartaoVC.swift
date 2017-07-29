//
//  LeituraCartaoVC.swift
//  Pay4All
//
//  Created by Carlos Doki on 03/06/17.
//  Copyright © 2017 Carlos Doki. All rights reserved.
//

import UIKit
import Alamofire

class LeituraCartaoVC: UIViewController, CardIOPaymentViewControllerDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    
    //@IBOutlet weak var resultLabel: UILabel!
    var pickOption = ["ApplePay", "PayPal", "Skrill", "Mastercard", "BB", "BitCoin", "Cartão Debito", "Cartão Crédito"]
    //usuario/senha ("ApplePay", "PayPal", "Skrill", "Mastercard", "BB", "BitCoin")
    //Captura Cartão.
    
    var postcarteira = [PostCarteira]()
    var ID = ""
    
    @IBOutlet weak var pickerTextField: UITextField!
    @IBOutlet weak var numberField: UITextField!
    @IBOutlet weak var vencField: UITextField!
    @IBOutlet weak var cvvField: UITextField!
    @IBOutlet weak var nomeCarteiraField: UITextField!
    @IBOutlet weak var capturaBtn: UIButton!
    @IBOutlet weak var usuarioField: UITextField!
    @IBOutlet weak var senhaField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        capturaBtn.isHidden = true
        usuarioField.isHidden = true
        senhaField.isHidden = true
        numberField.isHidden = true
        cvvField.isHidden = true
        vencField.isHidden = true
        
        let randomNum:UInt32 = arc4random_uniform(10000) // range is 0 to 99999
        
        // convert the UInt32 to some other  types
        
        ID = String(format: "%05d", randomNum) //string works too
        ID = ID + String(round(Date().timeIntervalSince1970))
        
        // Do any additional setup after loading the view.
        let pickerView = UIPickerView()
        
        pickerView.delegate = self
        
        pickerTextField.inputView = pickerView
        
        CardIOUtilities.preload()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickOption.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickOption[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if (pickOption[row] == "Cartão Debito" || pickOption[row] == "Cartão Crédito") {
            capturaBtn.isHidden = false
            usuarioField.isHidden = true
            if (pickOption[row] != "BitCoin") {
                senhaField.isHidden = true
            }
            
            numberField.isHidden = false
            cvvField.isHidden = false
            vencField.isHidden = false
        } else {
            
            capturaBtn.isHidden = true
            usuarioField.isHidden = false
            senhaField.isHidden = false
            numberField.isHidden = true
            cvvField.isHidden = true
            vencField.isHidden = true
        }
        pickerTextField.text = pickOption[row]
    }
    
    @IBAction func CriarCarteiraPressed(_ sender: Any) {
        let cardIOVC = CardIOPaymentViewController(paymentDelegate: self)
        cardIOVC?.modalPresentationStyle = .formSheet
        present(cardIOVC!, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func userDidCancel(_ paymentViewController: CardIOPaymentViewController!) {
        //resultLabel.text = "user canceled"
        paymentViewController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func salvarPressed(_ sender: UIButton) {
        let blockchain = NSString(format : "https://block.io/api/v2/get_new_address/?api_key=95d2-c52b-195c-98a9&label=%@", userUUID + ID)
        let url = URL(string: blockchain as String)
        
        Alamofire.request(url!)
            .responseJSON {  response in
                //print(response)
                //to get status code
                //                if let status = response.response?.statusCode {
                //                    switch(status){
                //                    case 201:
                //                       // print("example success")
                //                    default:
                //                        //print("error with response status: \(status)")
                //                    }
                //                }
                let responseJSON = response.result.value as? [String: Any]
                let results = responseJSON?["data"] as? NSDictionary
                let address = results?["address"] as! String
                
                let postcarteira : Dictionary<String, AnyObject> = [
                    "id": self.ID as AnyObject,
                    "idUser": userUUID as AnyObject,
                    "nome": self.nomeCarteiraField.text as AnyObject,
                    "tipo": self.pickerTextField.text as AnyObject,
                    "hashBlockChain": address as AnyObject
                ]
                let firebasePost = DataService.ds.REF_CARTEIRA.childByAutoId()
                firebasePost.setValue(postcarteira)
                let alertController = UIAlertController(title: "Informação", message: "Carteira cadastrada com sucesso!", preferredStyle: .alert)
                //We add buttons to the alert controller by creating UIAlertActions:
                let actionOk = UIAlertAction(title: "OK",
                                             style: .default,
                                             handler: nil) //You can use a block here to handle a press on this button
                
                alertController.addAction(actionOk)
                
                self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func voltarPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func userDidProvide(_ cardInfo: CardIOCreditCardInfo!, in paymentViewController: CardIOPaymentViewController!) {
        if let info = cardInfo {
            numberField.text = info.redactedCardNumber
            vencField.text = String(info.expiryMonth)+"/"+String( info.expiryYear)
            cvvField.text = info.cvv
            
            paymentViewController?.dismiss(animated: true, completion: nil)
        }
    }
}
