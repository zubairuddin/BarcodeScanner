//
//  ViewController.swift
//  BarcodeScannerDemo
//
//  Created by Zubair.Nagori on 23/10/18.
//  Copyright © 2018 ideavate. All rights reserved.
//

import UIKit

import AVFoundation
import UIKit

class ScannerViewController: UIViewController {
    
    @IBOutlet weak var viewVideoPreview: UIView!
    
    override func viewDidLoad() {
        //scanBarcode()
        startScan()
    }
    
    func scanBarcode() {
        
        //Create a capture session
        let session = AVCaptureSession()
        
        //Get the device from which input will be taken
        guard let device = AVCaptureDevice.default(for: .video) else {
            return
        }
        
        let deviceInput: AVCaptureDeviceInput?
        
        do {
            
            deviceInput = try AVCaptureDeviceInput(device: device)
        
            let output = AVCaptureMetadataOutput()
            
            output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            
            session.addInput(deviceInput!)
            session.addOutput(output)
            
            output.metadataObjectTypes = [.ean13]

            //Create the layer to show the video over UIView
            let videoPreviewLayer = AVCaptureVideoPreviewLayer(session: session)
            videoPreviewLayer.videoGravity = .resizeAspectFill
            
            videoPreviewLayer.frame = viewVideoPreview.bounds
            viewVideoPreview.layer.addSublayer(videoPreviewLayer)
            
            //Red line
            let from = CGPoint(x: 20, y: 80)
            let to = CGPoint(x: viewVideoPreview.frame.width - 20, y: 80)
            
            let redLine = drawLine(fromPoint: from, toPoint: to)
            
            viewVideoPreview.layer.addSublayer(redLine)
            
            session.startRunning()
            
            let rect = CGRect(x: 20, y: 80, width: viewVideoPreview.frame.width - 20, height: 10)
            
            let rectOfInterest = videoPreviewLayer.metadataOutputRectConverted(fromLayerRect: redLine.frame)
            output.rectOfInterest = rectOfInterest


        }
        catch {
            
        }
    }
    
    func startScan() {
        // Get an instance of the AVCaptureDevice class to initialize a device object and provide the video
        // as the media type parameter.
        
        //Create a capture session
        let session = AVCaptureSession()
        
        //Get the device from which input will be taken
        guard let captureDevice = AVCaptureDevice.default(for: .video) else {
            return
        }
        
        
        // Get an instance of the AVCaptureDeviceInput class using the previous device object.
        let deviceInput: AVCaptureDeviceInput?
        
        do {
            deviceInput = try AVCaptureDeviceInput(device: captureDevice)
            
            let output = AVCaptureMetadataOutput()
            
            output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            
            session.addInput(deviceInput!)
            session.addOutput(output)
            
            output.metadataObjectTypes = [.ean13]
            
            
            //Scan rect
            let redLineView = UIView()
            redLineView.layer.borderColor = UIColor.red.cgColor
            redLineView.layer.borderWidth = 2
            redLineView.frame = CGRect(x: 20, y: 60, width: view.frame.width - 20, height: 10)
            view.addSubview(redLineView)

            
            //Add the preview layer
            let videoPreviewLayer = AVCaptureVideoPreviewLayer(session: session)
            videoPreviewLayer.videoGravity = .resizeAspectFill
            videoPreviewLayer.frame = view.layer.bounds
            view.layer.addSublayer(videoPreviewLayer)
            
            session.startRunning()
            
            let visibleRect = videoPreviewLayer.metadataOutputRectConverted(fromLayerRect: videoPreviewLayer.bounds)
            
            output.rectOfInterest = visibleRect
            
            view.bringSubviewToFront(redLineView)
        }
        catch {
            
        }
    }

    
    func drawLine(fromPoint start: CGPoint, toPoint end: CGPoint) -> CALayer {
        let line = CAShapeLayer()
        let linePath = UIBezierPath()
        linePath.move(to: start)
        linePath.addLine(to: end)
        line.path = linePath.cgPath
        line.fillColor = nil
        line.opacity = 1.0
        line.strokeColor = UIColor.red.cgColor
        
        return line
    }

}

extension ScannerViewController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        if metadataObjects.count > 0 {
            guard let readableCode = metadataObjects.first as? AVMetadataMachineReadableCodeObject else {
                return
            }
            
            if readableCode.type == .ean13 {
                print("Barcode detected: \(readableCode.stringValue)")
                return
            }
        }
    }
}
