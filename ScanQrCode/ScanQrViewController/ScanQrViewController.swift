//
//  ScanQrViewController.swift
//  ScanQrCode
//
//  Created by Milos Dimic on 9/21/18.
//  Copyright © 2018 Milos Dimic. All rights reserved.
//

import UIKit
import AVFoundation

class ScanQrViewController: UIViewController {

    // MARK: - Properties
    
    @IBOutlet weak var viewQR: UIView!
    
    private var session: AVCaptureSession
    private var imagePickerController: UIImagePickerController.Type
    private var captureDevice: AVCaptureDevice.Type
    
    // MARK: - View Life Cycle
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if imagePickerController.isSourceTypeAvailable(.camera) {
            checkCameraAuthorizationStatus()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        dismantleSession()
    }
    
    // MARK: - Init
    
    init(session: AVCaptureSession, imagePickerController: UIImagePickerController.Type, captureDevice: AVCaptureDevice.Type) {
        self.session = session
        self.imagePickerController = imagePickerController
        self.captureDevice = captureDevice
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private methods

    private func checkCameraAuthorizationStatus() {
        switch captureDevice.authorizationStatus(for: .video) {
            
        case .notDetermined:
            requestCameraPermission()
        case .denied, .restricted:
            showRequestAccessToCameraAlert()
        case .authorized:
            if let captureDevice = captureDevice.default(for: .video) {
                setupCaptureSession(withCaptureDevice: captureDevice)
            }
        }
    }
    
    private func dismantleSession() {
        session.beginConfiguration()
        if let currentCameraInput = session.inputs.first {
            session.removeInput(currentCameraInput)
        }
        if let currentOutput = session.outputs.first {
            session.removeOutput(currentOutput)
        }
        session.commitConfiguration()
        
        session.stopRunning()
    }
    
    private func requestCameraPermission() {
        AVCaptureDevice.requestAccess(for: .video, completionHandler: { [weak self] accessGranted in
            guard accessGranted == true else { return }
            self?.checkCameraAuthorizationStatus()
        })
    }
    
    private func showRequestAccessToCameraAlert() {
        let alert = UIAlertController(title: "Alert", message: "Camera access is necessary to scan QR code, would you like to allow this app to use camera?", preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            switch action.style{
            case .default:
                if let applicationOpenSettingsURLString = URL(string: UIApplicationOpenSettingsURLString) {
                    UIApplication.shared.open(applicationOpenSettingsURLString)
                }
            case .cancel:
                print("cancel")
                
            case .destructive:
                print("destructive")

            }}))
        present(alert, animated: true, completion: nil)
    }
    
    private func setupCaptureSession(withCaptureDevice captureDevice: AVCaptureDevice) {
        session.beginConfiguration()
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            session.addInput(input)
        } catch {
            return
        }
        
        let output = AVCaptureMetadataOutput()
        session.addOutput(output)
        output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        output.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
        
        let preview = AVCaptureVideoPreviewLayer(session: session)
        preview.videoGravity = AVLayerVideoGravity.resizeAspectFill
        DispatchQueue.main.async {
            preview.frame = self.view.layer.bounds
        }
        session.commitConfiguration()
        session.startRunning()
    }
}


// MARK: - AVCaptureMetadataOutputObjectsDelegate

extension ScanQrViewController: AVCaptureMetadataOutputObjectsDelegate {
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if let object = metadataObjects.first as? AVMetadataMachineReadableCodeObject {
            if object.type == AVMetadataObject.ObjectType.qr {
                if let stringValue = object.stringValue {
                    print(stringValue)
                }
            }
        }
    }
}
