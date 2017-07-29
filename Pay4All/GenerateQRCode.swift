//
//  GenerateQRCode.swift
//  Pay4All
//
//  Created by Carlos Doki on 03/06/17.
//  Copyright © 2017 Carlos Doki. All rights reserved.
//

import UIKit
import CoreLocation

class GenerateQRCode: UIViewController, CLLocationManagerDelegate {
    
    var qrcodeImage: CIImage!
    let locationManger = CLLocationManager()
    
    
    @IBOutlet weak var qrtext: UITextField!
    @IBOutlet weak var imaQRCode: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        locationManger.delegate = self
        locationManger.desiredAccuracy = kCLLocationAccuracyBest
        locationManger.requestWhenInUseAuthorization()
        locationManger.startMonitoringSignificantLocationChanges()
        
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        locationAuthStatus()
    }
    
    func locationAuthStatus() {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            //            currentLocation = locationManger.location
            //            Location.sharedInstance.latitude = currentLocation.coordinate.latitude
            //            Location.sharedInstance.longitude = currentLocation.coordinate.longitude
            Location.sharedInstance.latitude = locationManger.location?.coordinate.latitude
            Location.sharedInstance.longitude = locationManger.location?.coordinate.longitude

            
        } else {
            locationManger.requestWhenInUseAuthorization()
            locationAuthStatus()
        }
    }
    
    @IBAction func displayQRcode(_ sender: UIButton) {
        if qrcodeImage == nil {
            if qrtext.text == "" {
                return
            }
            
            let strIDFV = UIDevice.current.identifierForVendor?.uuidString
            
            print("Vendor = \(strIDFV!)")
            let contrato = "1"
            let vendedor = "1343wewqwqe"
            //contrato
            //vendedor
            
            
            let textocompleto = qrtext.text! + ";lat=\(Location.sharedInstance.latitude!);lon=\(Location.sharedInstance.longitude!);IDFV=\(String(describing: strIDFV));contrato=\(contrato);vendedor=\(vendedor)"
            let data = textocompleto.data(using: String.Encoding.isoLatin1, allowLossyConversion: false)
            
            let filter = CIFilter(name: "CIQRCodeGenerator")
            filter!.setValue(data, forKey: "inputMessage")
            filter!.setValue("Q", forKey: "inputCorrectionLevel")
            qrcodeImage = filter!.outputImage
            
            let scaleX = imaQRCode.frame.size.width / qrcodeImage.extent.size.width
            let scaleY = imaQRCode.frame.size.height / qrcodeImage.extent.size.height
            let transformedImage = qrcodeImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))
            imaQRCode.image = convert(cmage: transformedImage)
            qrtext.resignFirstResponder()
            //displayQRCodeImage()
        }
        else {
            self.imaQRCode.image = nil
            self.qrcodeImage = nil
        }
    }
    
    func convert(cmage:CIImage) -> UIImage
    {
        let context:CIContext = CIContext.init(options: nil)
        let cgImage:CGImage = context.createCGImage(cmage, from: cmage.extent)!
        let image:UIImage = UIImage.init(cgImage: cgImage)
        return image
    }
    
    @IBAction func voltarPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
}
