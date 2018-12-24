//
//  CamerController.swift
//  visionTest
//
//  Created by Peter Pohlmann on 13.12.18.
//  Copyright © 2018 Peter Pohlmann. All rights reserved.
//

import UIKit
import AVFoundation

protocol CameraControllerDelegate: class {
    func cameraController(_ controller: CameraController, didCapture buffer: CMSampleBuffer)
}

final class CameraController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    private let captureSession = AVCaptureSession()
    lazy var cameraLayer = AVCaptureVideoPreviewLayer(session: captureSession)
    let overlayLayer = CALayer()
    var scanWidth: CGFloat = 0.0
    var scanHeight: CGFloat = 0.0
    var sample: CMSampleBuffer?
    
    weak var delegate: CameraControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAVSession()
        
        
        
        // begin the session
        self.captureSession.startRunning()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scanWidth = self.view.frame.width
        scanHeight =  self.view.frame.height/6
        
       
        
        overlayLayer.bounds = CGRect(x: 0, y: 0, width: scanWidth, height: scanHeight)
        overlayLayer.position = CGPoint(x: 0, y: 65)
        overlayLayer.anchorPoint = CGPoint(x: 0, y: 0)
        overlayLayer.backgroundColor = UIColor.black.cgColor
        overlayLayer.opacity = 0.5
        
        // make sure the layer is the correct size
        cameraLayer.frame = view.bounds
        //overlayLayer.frame = view.bounds
    }
    
    private func setupAVSession() {
        captureSession.beginConfiguration()
        captureSession.sessionPreset = .high
        
        defer {
            captureSession.commitConfiguration()
        }
        
        // input
        guard
            let backCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
            let input = try? AVCaptureDeviceInput(device: backCamera),
            captureSession.canAddInput(input)
            else {
                //print("guard")
                return
        }
        //print("back camera")
        captureSession.addInput(input)
        
        // output
        let output = AVCaptureVideoDataOutput()
        //print("output")
        
        guard captureSession.canAddOutput(output) else {
            //print("guard")
            return
        }
        
        captureSession.addOutput(output)
        output.setSampleBufferDelegate(self, queue: DispatchQueue(label: "MyQueue"))
        output.alwaysDiscardsLateVideoFrames = true
        
        // connection
        let connection = output.connection(with: .video)
        connection?.videoOrientation = .landscapeLeft
        
        // preview layer
        cameraLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        view.layer.addSublayer(cameraLayer)
        
        
        //view.layer.addSublayer(overlayLayer)
        //print("finish add preview layer camera controller")
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        sample = sampleBuffer
        delegate?.cameraController(self, didCapture: sample!)
        //print("sample")
    }
    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        //print("touches began")
        if let sample = sample {
            delegate?.cameraController(self, didCapture: sample)
        }
    }

}

