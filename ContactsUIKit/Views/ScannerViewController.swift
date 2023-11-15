//
//  ScannerViewController.swift
//  ContactsUIKit
//
//  Created by Ramona Ruoppo on 25/10/23.
//

import Foundation
import UIKit
import AVFoundation

class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!

    var scannedCode: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.black
        // Create a new AVCaptureSession
        captureSession = AVCaptureSession()

        // Get the default video capture device
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            failed()
            return
        }

        do {
            // Create a video input for the capture session
            let videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
            // Add the video input to the capture session
            if captureSession.canAddInput(videoInput) {
                captureSession.addInput(videoInput)
            } else {
                failed()
                return
            }
            
            // Create a metadata output
            let metadataOutput = AVCaptureMetadataOutput()
            // Add the metadata output to the capture session
            if captureSession.canAddOutput(metadataOutput) {
                captureSession.addOutput(metadataOutput)

                // Set the delegate for metadata output and specify the queue for callbacks
                metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                // Set the types of metadata objects to be detected (QR codes and various barcodes)
                metadataOutput.metadataObjectTypes = [
                    .qr,
                    .code128,
                    .code39,
                    .ean13,
                    .ean8,
                    .upce
                ]
                
            } else {
                failed()
                return
            }
            
            // Create a preview layer and configure it
            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            previewLayer.frame = view.layer.bounds
            previewLayer.videoGravity = .resizeAspectFill
            // Add the preview layer to the view's layer
            view.layer.addSublayer(previewLayer)
            
            // Start the capture session
            DispatchQueue.global(qos: .userInitiated).async {
                            self.captureSession.startRunning()
                        }
        } catch {
            failed()
        }
    }
    
    // Function to handle errors
    func failed() {
        let ac = UIAlertController(title: "Scanning not supported", message: "Your device does not support scanning a code from an item. Please use a device with a camera.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self] _ in
            self?.dismiss(animated: true, completion: nil)
        }))
        present(ac, animated: true)
        captureSession = nil
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Resume the capture session if it's not running
        if captureSession?.isRunning == false {
            DispatchQueue.global(qos: .userInitiated).async {
                self.captureSession.startRunning()
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        // Stop the capture session if it's running
        if captureSession?.isRunning == true {
            captureSession.stopRunning()
        }
    }

    // Callback for captured metadata objects
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if let metadataObject = metadataObjects.first, let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
           let stringValue = readableObject.stringValue {
            // Vibration feedback
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            
            // Store the scanned code
                        scannedCode = stringValue

                        // Present the ResultViewController
                        presentResultViewController()
        }
    }
    
    // Present the ResultViewController
    func presentResultViewController() {
        if let scannedCode = scannedCode {
            let resultViewController = ResultViewController(result: scannedCode)
            let navigationController = UINavigationController(rootViewController: resultViewController)
            navigationController.modalPresentationStyle = .overFullScreen
            present(navigationController, animated: true, completion: nil)
        }
    }
    
    // Hide the status bar
    override var prefersStatusBarHidden: Bool {
        return true
    }

    // Specify supported interface orientations
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
}
