//
//  ConfirmacaoVC.swift
//  Pay4All
//
//  Created by Carlos Doki on 04/06/17.
//  Copyright © 2017 Carlos Doki. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import Firebase
import AVFoundation
import Speech
import CoreImage
import AVKit
import Vision

class ConfirmacaoVC: UIViewController, CLLocationManagerDelegate, UIPickerViewDataSource, UIPickerViewDelegate, SFSpeechRecognizerDelegate, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    var captureSession:AVCaptureSession?
    var previewLayer:AVCaptureVideoPreviewLayer?
    var sessionOutput = AVCapturePhotoOutput()
    var currentCaptureDevice: AVCaptureDevice?
    var faceFrameView:UIView?
    
    let supportedFaceType = [ AVMetadataObject.ObjectType.face]
    
    var valor : String!
    var contrato = [Contrato]()
    var carteira = [PostCarteira]()
    let locationManger = CLLocationManager()
    var pickOption = [""]
    var ID = ""
    var lat = 0.0
    var lon = 0.0
    var strIDFV  = ""
    var contratoid  = ""
    var vendedor = ""
    var texto = ""
    var qtdeFotos = 0
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "pt_BR"))  //1
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    
    @IBOutlet weak var valorLbl: UILabel!
    @IBOutlet weak var pickerText: UIPickerView!
    @IBOutlet weak var carteiraField: UITextField!
    @IBOutlet weak var frase1lbl: UILabel!
    @IBOutlet weak var fraseTexto: UITextView!
    @IBOutlet weak var confirmarBtn: FancyButton!
    @IBOutlet weak var cameraView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        speechRecognizer?.delegate = self  //3
        
        SFSpeechRecognizer.requestAuthorization { (authStatus) in  //4
            
            var isButtonEnabled = false
            
            switch authStatus {  //5
            case .authorized:
                isButtonEnabled = true
                
            case .denied:
                isButtonEnabled = false
                print("User denied access to speech recognition")
                
            case .restricted:
                isButtonEnabled = false
                print("Speech recognition restricted on this device")
                
            case .notDetermined:
                isButtonEnabled = false
                print("Speech recognition not yet authorized")
            }
            
            //            OperationQueue.main.addOperation() {
            //                self.microphoneButton.isEnabled = isButtonEnabled
            //            }
        }
        
        locationManger.delegate = self
        locationManger.desiredAccuracy = kCLLocationAccuracyBest
        locationManger.requestWhenInUseAuthorization()
        locationManger.startMonitoringSignificantLocationChanges()
        
        // Do any additional setup after loading the view.
        var myStringArr = valor.components(separatedBy: ";")
        
        self.valorLbl.text = myStringArr[0]
        //        lat = Double(myStringArr[1].replacingOccurrences(of: "lat=", with: ""))!
        //        lon = Double(myStringArr[2].replacingOccurrences(of: "lon=", with: ""))!
        strIDFV = myStringArr[1].replacingOccurrences(of: "IDFV=", with: "")
        contratoid = myStringArr[2].replacingOccurrences(of: "contrato=", with: "")
        vendedor = myStringArr[3].replacingOccurrences(of: "vendedor=", with: "")
        pickOption.removeAll()
        DataService.ds.REF_CARTEIRA.observe(.value, with: { (snapshot) in
            if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for snap in snapshot {
                    print("DOKI: \(snap)")
                    if let postDict = snap.value as? Dictionary<String, AnyObject> {
                        let key = snap.key
                        let cont = PostCarteira(postKey: key, postData: postDict)
                        self.pickOption.append(cont.nome)
                    }
                }
            }
        })
        
        // Do any additional setup after loading the view.
        let pickerView = UIPickerView()
        
        pickerView.delegate = self
        pickerView.reloadAllComponents()
        
        carteiraField.inputView = pickerView
        
        //          let textocompleto = qrtext.text! + ";lat=\(Location.sharedInstance.latitude!);lon=\(Location.sharedInstance.longitude!);IDFV=\(strIDFV);contrato=\(contrato);vendedor=\(vendedor)"
        
        //        DataService.ds.REF_CONTRATO.observe(.value, with: { (snapshot) in
        //            if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
        //                for snap in snapshot {
        //                    print("DOKI: \(snap)")
        //                    if let postDict = snap.value as? Dictionary<String, AnyObject> {
        //                        let key = snap.key
        //                        let cont = Contrato(postKey: key, postData: postDict)
        //                        self.contrato.append(cont)
        //                    }
        //                }
        //            }
        //        })
        
        //        let coordinate = CLLocation(latitude: lat, longitude: lon)
        //        let coordinate1 = CLLocation(latitude: (locationManger.location?.coordinate.latitude)!, longitude: (locationManger.location?.coordinate.longitude)!)
        //
        //        let distanceInMeters = coordinate.distance(from: coordinate1) // result is in meters
        //        if (distanceInMeters >= 1000) {
        //            let refreshAlert = UIAlertController(title: "Alerta", message: "Vendedor está a mais de 1km, confirma a compra?", preferredStyle: UIAlertControllerStyle.alert)
        //
        //            refreshAlert.addAction(UIAlertAction(title: "Sim", style: .default, handler: { (action: UIAlertAction!) in
        //                print("Handle Ok logic here")
        //            }))
        //
        //            refreshAlert.addAction(UIAlertAction(title: "Não", style: .cancel, handler: { (action: UIAlertAction!) in
        //                return
        //            }))
        //
        //            present(refreshAlert, animated: true, completion: nil)
        //        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        locationAuthStatus()
    }
    
    func locationAuthStatus() {
        if CLLocationManager.authorizationStatus() != .authorizedWhenInUse {
            locationManger.requestWhenInUseAuthorization()
            locationAuthStatus()
        }
    }
    
    func getDevice(position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        let devices: NSArray = AVCaptureDevice.devices() as NSArray;
        for de in devices {
            let deviceConverted = de as! AVCaptureDevice
            if(deviceConverted.position == position){
                return deviceConverted
            }
        }
        return nil
    }
    
    
    @IBAction func confirmarPressed(_ sender: UIButton) {
        if carteiraField.text == "" {
            let alertController = UIAlertController(title: "Alerta", message: "Favor escolher uma carteira!", preferredStyle: .alert)
            let actionOk = UIAlertAction(title: "OK",
                                         style: .default,
                                         handler: nil) //You can use a block here to handle a press on this button
            
            alertController.addAction(actionOk)
            
            self.present(alertController, animated: true, completion: nil)
            return
        }
        
        if confirmarBtn.titleLabel?.text == "CAPTURAR" {
            captureSession?.stopRunning()
            confirmarBtn.setTitle("CONFIRMAR",for: .normal)
            qtdeFotos = 0
        } else {
            let captureSession = AVCaptureSession()
            captureSession.sessionPreset = .photo
            //guard let captureDevice = AVCaptureDevice.default(for: .video) else { return }
            guard let captureDevice = getDevice(position: .front) else { return }
            guard let input = try? AVCaptureDeviceInput(device: captureDevice) else { return }
            
            captureSession.addInput(input)
            captureSession.startRunning()
            
            let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            //view.layer.addSublayer(previewLayer)
            //previewLayer.frame = view.frame
            
            previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
            previewLayer.frame = cameraView.bounds
            cameraView.layer.addSublayer(previewLayer)
            
            faceFrameView = UIView()
            
            let dataOutput = AVCaptureVideoDataOutput()
            dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
            captureSession.addOutput(dataOutput)
        }
        
        //        self.frase1lbl.isHidden = false
        //        self.fraseTexto.isHidden = false
        //        //self.confirmarBtn.isEnabled = false
        //
        //        if audioEngine.isRunning {
        //            audioEngine.stop()
        //            recognitionRequest?.endAudio()
        //            if texto.uppercased() != self.fraseTexto.text.uppercased() {
        //                let alertController = UIAlertController(title: "Alerta", message: "Frase não confere!", preferredStyle: .alert)
        //                //We add buttons to the alert controller by creating UIAlertActions:
        //                let actionOk = UIAlertAction(title: "OK",
        //                                             style: .default,
        //                                             handler: nil) //You can use a block here to handle a press on this button
        //
        //                alertController.addAction(actionOk)
        //                self.present(alertController, animated: true, completion: nil)
        //                self.frase1lbl.isHidden = true
        //                self.fraseTexto.isHidden = true
        //                self.confirmarBtn.isEnabled = true
        //                return
        //            }
        //
        //
        //            let randomNum:UInt32 = arc4random_uniform(10000) // range is 0 to 99999
        //            ID = String(format: "%05d", randomNum) //string works too
        //            ID = ID + String(round(Date().timeIntervalSince1970))
        //            let data = round(Date().timeIntervalSince1970)
        //
        //            let posttransacao : Dictionary<String, AnyObject> = [
        //                "carteira": carteiraField.text as AnyObject,
        //                "data": data as AnyObject,
        //                "idContrato": contratoid as AnyObject,
        //                "latitude": lat as AnyObject,
        //                "longitude": lon as AnyObject,
        //                "user": userUUID as AnyObject,
        //                "valor": self.valorLbl.text as AnyObject,
        //                "vedendor" : vendedor as AnyObject,
        //                "hashBlockChain": "" as AnyObject,
        //                "id" : ID as AnyObject
        //            ]
        //            let firebasePost = DataService.ds.REF_TRANSACAO.childByAutoId()
        //            firebasePost.setValue(posttransacao)
        //
        //
        //            let controller = self.storyboard?.instantiateViewController(withIdentifier: "ReciboVC") as! ReciboVC
        //            controller.valor = self.valorLbl.text
        //            controller.data = data
        //            controller.id = ID
        //            controller.carteira = carteiraField.text
        //
        //            self.frase1lbl.isHidden = true
        //            self.fraseTexto.isHidden = true
        //            self.confirmarBtn.setTitle("Confirmar" , for: .normal)
        //
        //            self.present(controller, animated: true, completion: nil)
        //
        //        } else {
        //            startRecording()
        //            self.confirmarBtn.setTitle("Parar Gravação", for: .normal)
        //            self.confirmarBtn.setNeedsDisplay()
        //            self.frase1lbl.setNeedsDisplay()
        //            self.fraseTexto.setNeedsDisplay()
        //        }
        //
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        let imageBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)!
        let ciimage : CIImage = CIImage(cvPixelBuffer: imageBuffer)
        let image : UIImage = self.convert(cmage: ciimage)
        let imageView = UIImageView(image: image)
        
        imageView.contentMode = .scaleAspectFill
        let scaleHeight = view.frame.width / image.size.width * image.size.height
        imageView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: scaleHeight)

        let request = VNDetectFaceRectanglesRequest { (req, err)
            in
            if let err = err {
                print("Failed to detect faces:", err)
                return
            }
            req.results?.forEach({ (res) in
                DispatchQueue.main.async {
                    guard let faceObservation = res as? VNFaceObservation else { return }
                    let x = self.view.frame.width * faceObservation.boundingBox.origin.x
                    let height = scaleHeight * faceObservation.boundingBox.height
                    let y = scaleHeight * (1 - faceObservation.boundingBox.origin.y) - height
                    let wifth = self.view.frame.width * faceObservation.boundingBox.width
                    
                    let redView = UIView()
                    redView.backgroundColor = .red
                    redView.alpha = 0.4
                    redView.frame = CGRect(x: x, y: y, width: wifth, height: height)
                    self.view.addSubview(redView)
                }
            })
            //print(req)
            self.qtdeFotos = self.qtdeFotos + 1
            if (self.qtdeFotos < 5 && self.qtdeFotos != 1) {
                //UIImageWriteToSavedPhotosAlbum(self.fixOrientation(img: image), self, nil, nil)
                if let imgData = UIImageJPEGRepresentation(self.fixOrientation(img: image), 0.2) {
                    let imguid = NSUUID().uuidString
                    let metadata = FIRStorageMetadata()
                    metadata.contentType = "image/jpg"
                    
                    DataService.ds.REF_POST_IMAGES.child(imguid).put(imgData, metadata: metadata) { (metadata, error) in
                        if error != nil {
                            print("DOKI: Unabled to upload to Firebase storage")
                        } else {
                            print("DOKI: Successfully uploaded image to Firebase storage")
                            let downloadUrl = (metadata?.downloadURL()?.absoluteURL.absoluteString)!
                        }
                    }
                }
            }
            //            self.captureSession?.stopRunning()
            //            let data = round(Date().timeIntervalSince1970)
            //            let randomNum:UInt32 = arc4random_uniform(10000) // range is 0 to 99999
            //            self.ID = String(format: "%05d", randomNum) //string works too
            //            //ID = ID + String(round(Date().timeIntervalSince1970))
            //
            //            let posttransacao : Dictionary<String, AnyObject> = [
            //                "carteira": self.carteiraField.text as AnyObject,
            //                "data": data as AnyObject,
            //                "idContrato": self.contratoid as AnyObject,
            //                "latitude": self.lat as AnyObject,
            //                "longitude": self.lon as AnyObject,
            //                "user": userUUID as AnyObject,
            //                "valor": self.valorLbl.text as AnyObject,
            //                "vedendor" : self.vendedor as AnyObject
            //            ]
            //            let firebasePost = DataService.ds.REF_TRANSACAO.childByAutoId()
            //            firebasePost.setValue(posttransacao)
            //
            //            let controller = self.storyboard?.instantiateViewController(withIdentifier: "ReciboVC") as! ReciboVC
            //            controller.valor = self.valorLbl.text
            //            controller.data = data
            //            controller.id = self.ID
            //            controller.carteira = self.carteiraField.text
            //
            //            self.frase1lbl.isHidden = true
            //            self.fraseTexto.isHidden = true
            //            self.confirmarBtn.setTitle("Confirmar" , for: .normal)
            //
            //            self.present(controller, animated: true, completion: nil)
            
        }
        
        guard let cgImage = image.cgImage else { return }
        let handler = VNImageRequestHandler (cgImage: cgImage, options: [:])
        do {
            try handler.perform([request])
        } catch let reqErr {
            print("Failed to perform request:", reqErr)
        }
    }
    
    func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: "Saved!", message: "Your altered image has been saved to your photos.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
    
    func fixOrientation(img: UIImage) -> UIImage {
        var transform = CGAffineTransform.identity
        transform = transform.translatedBy(x: 0, y: img.size.height)
        transform = transform.rotated(by: CGFloat(-Double.pi/2))
        let ctx = CGContext(data: nil, width: Int(img.size.width), height: Int(img.size.height), bitsPerComponent: img.cgImage!.bitsPerComponent, bytesPerRow: 0, space: img.cgImage!.colorSpace!, bitmapInfo: img.cgImage!.bitmapInfo.rawValue)
        
        ctx!.concatenate(transform);
        ctx?.draw(img.cgImage!, in: CGRect(origin: .zero, size: CGSize(width: img.size.height, height: img.size.width)))
        let cgimg = ctx!.makeImage()
        let img = UIImage(cgImage: cgimg!)
        
        
        UIGraphicsBeginImageContextWithOptions(img.size, false, img.scale)
        let rect = CGRect(x: 0, y: 0, width: img.size.width, height: img.size.height)
        img.draw(in: rect)
        
        
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return normalizedImage
    }
    
    func convert(cmage:CIImage) -> UIImage
    {
        let context:CIContext = CIContext.init(options: nil)
        let cgImage:CGImage = context.createCGImage(cmage, from: cmage.extent)!
        let image:UIImage = UIImage.init(cgImage: cgImage)
        return image
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
        carteiraField.text = pickOption[row]
        self.view.endEditing(true)
    }
    
    func startRecording() {
        
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryRecord)
            try audioSession.setMode(AVAudioSessionModeMeasurement)
            try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
            //            if blueBtn.currentTitle == "Bluetooth OFF" {
            //                try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord, with: AVAudioSessionCategoryOptions.allowBluetooth)
            //            } else {
            try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord, with: AVAudioSessionCategoryOptions.defaultToSpeaker)
            //            }
            //
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        let inputNode = audioEngine.inputNode
        //            else {
        //            fatalError("Audio engine has no input node")
        //
        //        }
        
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in
            
            var isFinal = false
            
            if result != nil {
                
                self.texto = (result?.bestTranscription.formattedString)!
                
                isFinal = (result?.isFinal)!
            }
            
            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
                //self.microphoneButton.isEnabled = true
            }
        })
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        
        do {
            try audioEngine.start()
        } catch {
            print("audioEngine couldn't start because of an error.")
        }
    }
    
    @IBAction func voltarPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}
