//
//  AppDelegate.swift
//  ScanQrCode
//
//  Created by Milos Dimic on 9/21/18.
//  Copyright © 2018 Milos Dimic. All rights reserved.
//

import UIKit
import AVFoundation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow()
        window?.makeKeyAndVisible()
        
        let scanQrViewController = ScanQrViewController(session: AVCaptureSession(),
                                                        imagePickerController: UIImagePickerController.self,
                                                        captureDevice: AVCaptureDevice.self)
        
        window?.rootViewController = scanQrViewController
        
        return true
    }




}

