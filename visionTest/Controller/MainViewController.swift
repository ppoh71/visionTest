////
////  ViewController.swift
////  visionTest
////
////  Created by Peter Pohlmann on 13.12.18.
////  Copyright © 2018 Peter Pohlmann. All rights reserved.
////
//
//import UIKit
//
//import AVFoundation
//import Vision
//import TesseractOCR
//import Firebase
//
//
//class MainViewController: UIViewController{
//
//    @IBOutlet weak var testImage: UIImageView!
//    @IBOutlet weak var testImage2: UIImageView!
//    @IBOutlet weak var testImage3: UIImageView!
//    @IBOutlet weak var timePassed: UILabel!
//    
//    @IBOutlet weak var screenSize: UILabel!
//    @IBOutlet weak var cameraSize: UILabel!
//    @IBOutlet weak var scanSize: UILabel!
//    @IBOutlet weak var imageSize: UILabel!
//    @IBOutlet weak var croppedImageSize: UILabel!
//    @IBOutlet weak var overlaySize: UILabel!
//    @IBOutlet weak var stackLabels: UIStackView!
//    @IBOutlet weak var scanArea: UIView!
//    @IBOutlet weak var scanButton: UIButton!
//    @IBOutlet weak var imagesStackView: UIStackView!
//    @IBOutlet weak var ocrText: UITextView!
//    
//    var scanWidth: CGFloat = 0.0
//    var scanHeight: CGFloat = 0
//    var scanTopPosition = 100.0
//    var visibleLayerFrame = CGRect()
//    let overlayLayer2 = CALayer()
//    
//    private let cameraController = CameraController()
//    private let visionService = VisionService()
//    private let boxService = BoxService()
//    
//    var textRecognizer: VisionTextRecognizer!
//    var scanText = ""
//    var doScan = false
//    
//    @IBAction func scanButtonPressed(_ sender: Any) {
//        
//    }
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(normalTap(_:)))
//        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(longTap(_:)))
//        
//        let vision = Vision.vision()
//        textRecognizer = vision.onDeviceTextRecognizer()
//        
//        
//        tapGesture.numberOfTapsRequired = 1
//        scanButton.addGestureRecognizer(tapGesture)
//        scanButton.addGestureRecognizer(longGesture)
//        
//        // Do any additional setup after loading the view, typically from a nib.
//        scanWidth = self.view.frame.width
//        scanHeight = self.view.frame.height/6
//        //let visibleY = CGFloat(self.view.frame.height) - (scanArea.frame.height + CGFloat(scanTopPosition))
//        let visibleY = CGFloat(self.view.frame.height) - (scanArea.frame.height + CGFloat(scanTopPosition))
//        
//        visibleLayerFrame = CGRect(x: scanArea.frame.minX, y: visibleY, width:  scanArea.frame.width, height: scanArea.frame.height)
//        print(visibleLayerFrame)
//        
//        print(view.bounds)
//        screenSize.text = "Scr:\(self.view.frame.width)*\(self.view.frame.height) scl\(UIScreen.main.scale)"
//        
//        cameraController.delegate = self
//        
//        self.addChild(cameraController)
//        cameraController.view.backgroundColor = UIColor.blue
//        
//        self.view.addSubview(cameraController.view)
//       
//        
//        
//        print("add finish")
//        cameraController.view.translatesAutoresizingMaskIntoConstraints = false
//        //cameraController.view.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
//        cameraController.view.topAnchor.constraint(equalTo: topLayoutGuide.topAnchor, constant: 0.0).isActive = true
//        cameraController.view.widthAnchor.constraint(equalToConstant: self.view.frame.width).isActive = true
//        cameraController.view.heightAnchor.constraint(equalToConstant: self.view.frame.height).isActive = true
//        cameraSize.text = "Screen: \(cameraController.view.frame.size.width) * \(cameraController.view.frame.size.height) "
//        
//        overlayLayer2.bounds = CGRect(x: 0, y: 0, width:  scanArea.frame.width, height: scanArea.frame.height)
//        overlayLayer2.position = CGPoint(x: 0, y: scanTopPosition)
//        overlayLayer2.anchorPoint = CGPoint(x: 0, y: 0)
//        overlayLayer2.backgroundColor = UIColor.green.cgColor
//        overlayLayer2.opacity = 0.5
//        
//        self.view.addSubview(cameraController.view)
//        
//        self.view.bringSubviewToFront(testImage)
//        self.view.bringSubviewToFront(testImage2)
//        self.view.bringSubviewToFront(testImage3)
//        self.view.bringSubviewToFront(imagesStackView)
//        self.view.bringSubviewToFront(stackLabels)
//        self.view.bringSubviewToFront(scanArea)
//        self.view.bringSubviewToFront(scanButton)
//        self.view.bringSubviewToFront(ocrText)
//        view.layer.addSublayer(overlayLayer2)
//
//        visionService.delegate = self
//        boxService.delegate = self
//        
//        scanArea.frame.origin.y = 500
//    }
//    
//
//    
//    func imageRotatedByDegrees(oldImage: UIImage, deg degrees: CGFloat) -> UIImage {
//        let size = oldImage.size
//        
//        UIGraphicsBeginImageContext(size)
//        
//        let bitmap: CGContext = UIGraphicsGetCurrentContext()!
//        //Move the origin to the middle of the image so we will rotate and scale around the center.
//        //bitmap.translateBy(x: size.width / 2, y: size.height / 2)
//        //Rotate the image context
//        bitmap.rotate(by: (degrees * CGFloat(Double.pi / 180)))
//        //Now, draw the rotated/scaled image into the context
//       // bitmap.scaleBy(x: 1.0, y: -1.0)
//        
//        let origin = CGPoint(x: -size.width , y: -size.height)
//        
//        bitmap.draw(oldImage.cgImage!, in: CGRect(origin: origin, size: size))
//        
//        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
//        UIGraphicsEndImageContext()
//        print("old \(size)")
//        print("new \(newImage.size)")
//        return newImage
//    }
//    
//    func cropImage(image: UIImage, normalisedRect: CGRect) -> UIImage? {
//        let x = normalisedRect.origin.x
//        let y = normalisedRect.origin.y
//        let width = normalisedRect.width
//        let height = normalisedRect.height
//        
//        DispatchQueue.main.async {
//            self.croppedImageSize.text = "cropped w:\(width.rounded()) h:\(height.rounded())"
//        }
//        
//        let rect = CGRect(x: x, y: y, width: width, height: height)
//        
//        guard let cropped = image.cgImage?.cropping(to: rect) else {
//            print("guard cropped image")
//            return nil
//        }
//        //print("cropped image scale")
//        //print(image.imageOrientation)
//        let croppedImage = UIImage(cgImage: cropped, scale: image.scale, orientation: image.imageOrientation)
//        return croppedImage
//    }
//    
//    func scanRect(image: UIImage) -> UIImage?{
//        var originalSize: CGSize
//        
//        // Calculate the fractional size that is shown in the preview
//        let metaRect = (self.cameraController.cameraLayer.metadataOutputRectConverted(fromLayerRect: visibleLayerFrame ))
//        originalSize = image.size
//
//        let cropRect: CGRect = CGRect(x: metaRect.origin.x * originalSize.width, y: metaRect.origin.y * originalSize.height, width: metaRect.size.width * originalSize.width, height: metaRect.size.height * originalSize.height).integral
//
//        
//        
//        if let finalCgImage = image.cgImage?.cropping(to: cropRect) {
//            let finalImage = UIImage(cgImage: finalCgImage, scale: 1.0, orientation: image.imageOrientation)
//            
//            let rotImage = finalImage.rotate(radians: 4.7123889804) //rotat 270 degree
//            
//            DispatchQueue.main.async {
//                 self.testImage.image = rotImage
//            }
//            return rotImage
//        } else{
//            return nil
//        }
//    }
//    
//    
//}
//
//extension MainViewController: CameraControllerDelegate{
//    func cameraController(_ controller: CameraController, didCapture buffer: CMSampleBuffer) {
//        //print("capture")
//        
//        //process image before vision
//        guard let pixelBuffer = CMSampleBufferGetImageBuffer(buffer) else {
//            print("guard vision service")
//            return
//        }
//        
//        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
//        guard let image = ciImage.toUIImage() else {
//            return
//        }
//        
//        DispatchQueue.main.async {
//           // print("image scale: \(image.scale)")
//            self.imageSize.text = "Vimg: \(image.size.width*image.scale) * \(image.size.height*image.scale) "
//        }
//        
////        //let start1 = CFAbsoluteTimeGetCurrent()
////        //let croppedImage0 = self.cropImage(image: image, normalisedRect: CGRect(x: 0, y: CGFloat(scanTopPosition), width: image.size.width, height:  scanHeight))
////        //let diff1 = CFAbsoluteTimeGetCurrent() - start1
////
//        let start2 = CFAbsoluteTimeGetCurrent()
//        let croppedImage = scanRect(image: image)
//        let diff2 = CFAbsoluteTimeGetCurrent() - start2
//
//        DispatchQueue.main.async {
//            //self.overlaySize.text = "simple crop: \(diff1) seconds"
//            self.overlaySize.text = "scanRect: \(diff2) seconds"
//            self.scanSize.text = "Cropped: \(croppedImage!.size.width) * \(croppedImage!.size.height) "
//        }
//
//
//        DispatchQueue.main.async {
//           // print(image.imageOrientation.rawValue)
//            self.testImage2.image = image
//            self.testImage.image = croppedImage
//        }
//
//        //
//
//        visionService.handle(image: croppedImage!)
//    }
//}
//
//extension MainViewController: VisionServiceDelegate{
//    func visionService(_ version: VisionService, didDetect image: UIImage, results: [VNTextObservation]) {
//        boxService.handle(
//            overlayLayer: overlayLayer2,
//            image: image,
//            results: results,
//            on: cameraController.view
//        )
//    }
//}
//
//extension MainViewController: BoxServiceDelegate {
//    func boxService(_ service: BoxService, didDetect image: UIImage) {
//        
//        //print("box service delegate did detect image")
//        if doScan{
//            print("scan")
//            self.imagesStackView.removeArrangedSubview()
//            DispatchQueue.main.async {
//                let imabeView = UIImageView(image: image)
//                self.testImage3.image = image
//                self.imagesStackView.addArrangedSubview(imabeView)
//            }
//            
//            //ocr(image: image)
//            firebaseOCR(image: image)
//        }
//        
//    }
//}
//
//extension MainViewController{
//    
//    @objc func normalTap(_ sender: UIGestureRecognizer){
//        print("Normal tap")
//    }
//    
//    @objc func longTap(_ sender: UIGestureRecognizer){
//        print("Long tap")
//        if sender.state == .ended {
//            doScan = false
//            self.scanText = ""
//        }
//        else if sender.state == .began {
//            doScan = true
//            imagesStackView.removeArrangedSubview()
//        }
//    }
//    
//}
//
//extension MainViewController{
//    func ocr(image: UIImage?){
//        print("start ocr")
//        let start = CFAbsoluteTimeGetCurrent()
//        if let image = image{
//            if let tesseract = G8Tesseract(language: "eng") {
//                // 2
//                tesseract.engineMode = .tesseractCubeCombined
//                // 3
//                tesseract.pageSegmentationMode = .singleColumn
//                // 4
//                tesseract.image = image
//                // 5
//                tesseract.recognize()
//                // 6
//                
//               
//                ocrText.text = tesseract.recognizedText
//                print("######### ocr finish")
//                print(tesseract.recognizedText as Any)
//                
//            }
//            
//            let diff = CFAbsoluteTimeGetCurrent() - start
//            timePassed.text = "Took \(diff) seconds"
//            print("Took \(diff) seconds")
//        }
//        
//    }
//}
//
//extension MainViewController{
//    func firebaseOCR(image: UIImage){
//        let start = CFAbsoluteTimeGetCurrent()
//        let visionImage = VisionImage(image: image)
//        print(visionImage)
//        textRecognizer.process(visionImage) { result, error in
//            guard error == nil, let result = result else {
//                print("error vision ocr")
//                return
//            }
//            
//           print("FIREBASE OCR RESULT")
//            print(result.text)
//            self.scanText = self.scanText + " " + result.text
//            self.ocrText.text = "\(self.scanText)"
//            
//            
//            let diff = CFAbsoluteTimeGetCurrent() - start
//            DispatchQueue.main.async {
//                self.timePassed.text = "Took \(diff) seconds"
//                print("Took \(diff) seconds")
//            }
//            
//        }
//        
//    }
//}
