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
    
    @IBOutlet weak var btnStartStopScan: UIBarButtonItem!
    @IBOutlet weak var viewVideoPreview: UIView!
    
    var isScanning = false
    
    var session: AVCaptureSession?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var redLineView: UIView?
    
    override func viewDidLoad() {
        startScan()
    }
    
    func startScan() {
        
        //Create a capture session
        session = AVCaptureSession()
        
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
            
            session?.addInput(deviceInput!)
            session?.addOutput(output)
            
            output.metadataObjectTypes = [.ean13]
            
            
            //Add the preview layer
            guard let captureSession = session else {
                return
            }
            
            //Video recording layer
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            videoPreviewLayer?.videoGravity = .resizeAspectFill
            videoPreviewLayer?.frame = view.layer.bounds
            videoPreviewLayer?.isHidden = false
            view.layer.addSublayer(videoPreviewLayer!)

            //Red line view
            redLineView = UIView()
            redLineView?.isHidden = false
            redLineView?.layer.borderColor = UIColor.red.cgColor
            redLineView?.layer.borderWidth = 2
            redLineView?.frame = CGRect(x: 20, y: (videoPreviewLayer?.frame.size.height)! / 2, width: view.frame.width - 40, height: 1)
            view.addSubview(redLineView!)

            //view.bringSubviewToFront(redLineView!)
            
            //Start video
            session?.startRunning()
            
            //Restrict scanning to a certain rect
            let visibleRect = videoPreviewLayer?.metadataOutputRectConverted(fromLayerRect: (redLineView?.frame)!)
            
            print("Area of interest: \(visibleRect)")
            output.rectOfInterest = visibleRect!
            
            
        }
        catch {
            
        }
    }
    
    func stopScan() {
        session?.stopRunning()
        session = nil
        videoPreviewLayer?.isHidden = true
        redLineView?.isHidden = true
        //isScanning = false
        btnStartStopScan.title = "Scan"
    }
    
    @IBAction func startStopScan(_ sender: UIBarButtonItem) {
        if isScanning {
            stopScan()
            btnStartStopScan.title = "Scan"
        }
        else {
            startScan()
            btnStartStopScan.title = "Stop"
        }
        
        isScanning = !isScanning
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
    
    func showAlert(withTitle title: String, andMessage message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let restartAction = UIAlertAction(title: "Restart", style: .default) { (action) in
            self.startScan()
        }
        
        alert.addAction(cancelAction)
        alert.addAction(restartAction)
        present(alert, animated: true, completion: nil)
    }

}

extension ScannerViewController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        if metadataObjects.count > 0 {
            guard let readableCode = metadataObjects.first as? AVMetadataMachineReadableCodeObject else {
                return
            }
            
            //Check if detected code is a barcode and convert it to string
            if readableCode.type == .ean13 {
                guard let stringCode = readableCode.stringValue else {
                    return
                }
                //Stop scanning
                stopScan()
                isScanning = false
                
                print("Barcode detected: \(stringCode)")
                showAlert(withTitle: "Barcode Scanned.", andMessage: stringCode)
                return
            }
        }
    }
}
