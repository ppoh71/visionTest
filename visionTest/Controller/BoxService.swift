//
//  BoxDrawer.swift
//  MathSolver
//
//  Created by Khoa Pham on 26.06.2018.
//  Copyright © 2018 onmyway133. All rights reserved.
//

import UIKit
import Vision
import AVFoundation

protocol BoxServiceDelegate: class {
    func boxService(_ service: BoxService, didDetect image: UIImage, lastElement: Bool)
}

final class BoxService {
    weak var delegate: BoxServiceDelegate?
    var lastElementResult = false
    
    func handle(overlayLayer: CALayer, image: UIImage, results: [VNTextObservation], on view: UIView) {
        
        lastElementResult = false
        
        overlayLayer.sublayers?.forEach({ (layer) in
            layer.removeFromSuperlayer()
        })
        
        //let results = results.filter({ $0.confidence > 0.5 })
        //print("box starting")
        
        // box
        results.forEach({ result in
            let normalisedRect = normalise(box: result)
            drawBox(overlayLayer: overlayLayer, normalisedRect: normalisedRect)
        })
        //print("box starting 2")
        // image
//        guard let biggestResult = results
//            .sorted(by: { $0.boundingBox.width > $1.boundingBox.width })
//            .first else {
//                return
//        }
        //print("box starting 3")
        //print(results.count)
//        print("############################### - \(results.count)")
//        print(results.endIndex)
        
        
        for (index,result) in results.enumerated(){

            //print("index \(index)")
            let normalisedRect = normalise(box: result)
            
            if index == results.endIndex-1 {
                lastElementResult = true
              // print("Last Element ------- \(lastElementResult)")
               
            }
            
            if let croppedImage = cropImage(image: image, normalisedRect: normalisedRect) {
                delegate?.boxService(self, didDetect: croppedImage, lastElement: lastElementResult)
            }
        }
        //print("###############################")
        
        
    }
    
    private func cropImage(image: UIImage, normalisedRect: CGRect) -> UIImage? {
        let x = normalisedRect.origin.x * image.size.width
        let y = normalisedRect.origin.y * image.size.height
        let width = normalisedRect.width * image.size.width
        let height = normalisedRect.height * image.size.height
        
        let rect = CGRect(x: x, y: y, width: width, height: height).scaleUp(scaleUp: 0.1)
        
        guard let cropped = image.cgImage?.cropping(to: rect) else {
            return nil
        }
        
        let croppedImage = UIImage(cgImage: cropped, scale: image.scale, orientation: image.imageOrientation)
        return croppedImage
    }
    
    private func drawBox(overlayLayer: CALayer, normalisedRect: CGRect) {
        let x = normalisedRect.origin.x * overlayLayer.frame.size.width
        let y = normalisedRect.origin.y * overlayLayer.frame.size.height
        let width = normalisedRect.width * overlayLayer.frame.size.width
        let height = normalisedRect.height * overlayLayer.frame.size.height
        
        let outline = CALayer()
        outline.frame = CGRect(x: x, y: y, width: width, height: height).scaleUp(scaleUp: 0.02)
        outline.borderWidth = 2.0
        outline.borderColor = UIColor.red.cgColor
        //print("box draw box")
        overlayLayer.addSublayer(outline)
    }
    
    private func normalise(box: VNTextObservation) -> CGRect {
        return CGRect(
            x: box.boundingBox.origin.x,
            y: 1 - box.boundingBox.origin.y - box.boundingBox.height,
            width: box.boundingBox.size.width,
            height: box.boundingBox.size.height
        )
    }
}

extension CGRect {
    func scaleUp(scaleUp: CGFloat) -> CGRect {
        let biggerRect = self.insetBy(
            dx: -self.size.width * scaleUp,
            dy: -self.size.height * scaleUp
        )
        
        return biggerRect
    }
}
