//
//  ViewController.swift
//  BothSidesCamera
//
//  Created by daisukenagata on 11/22/2019.
//  Copyright (c) 2019 daisukenagata. All rights reserved.
//

import UIKit
import AVFoundation
import BothSidesCamera

class ViewController: UIViewController {

    private var previewView: BothSidesView?
    
    @IBOutlet weak var segmentBtn: UISegmentedControl!

    lazy var  btn: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: ""), for: .normal)
        btn.frame = CGRect(x: UIScreen.main.bounds.width/2 - 25, y: -25, width: 50, height: 50)
        btn.layer.cornerRadius = btn.frame.height/2
        btn.backgroundColor = .red
        return btn
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        UIDevice.current.beginGeneratingDeviceOrientationNotifications()

        UIApplication.shared.isIdleTimerDisabled = true

        // front is builtInWideAngleCamera only
        previewView = BothSidesView(frame: view.frame, backDeviceType: .builtInUltraWideCamera, frontDeviceType: .builtInWideAngleCamera)
        view.addSubview(previewView!)

        btn.addTarget(self, action: #selector(btaction), for: .touchUpInside)
        self.tabBarController?.tabBar.addSubview(btn)
       
        NotificationCenter.default.addObserver( self,
                                                selector:#selector(background),
                                                name: UIApplication.didEnterBackgroundNotification,object: nil)
        NotificationCenter.default.addObserver( self, selector: #selector(foreground),
                                                name: UIApplication.willEnterForegroundNotification,object: nil)
        
        view.bringSubviewToFront(segmentBtn)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // PreviewView Size
        guard let pre = previewView else { return }
        pre.frontCameraVideoPreviewView.transform = pre.frontCameraVideoPreviewView.transform.scaledBy(x: 0.5, y: 0.5)
        pre.preViewSizeSet()
    }

    @objc func background() {
        print("background")
        flg = false
        tabBarController?.tabBar.backgroundColor = .gray
        // stop camera
        previewView!.stopRunning()
    }
    
    @objc func foreground() {
        print("foreground")
        // start camera
        previewView?.cmaeraStart(completion: saveBtn)
    }

    var flg = false
    @objc func btaction() {
        // start camera
        previewView?.cmaeraStart(completion: saveBtn)
        
        // Flash
        // pushFlash()
        if flg == false {
            tabBarController?.tabBar.backgroundColor = .red
            flg = true
            btn.frame.origin.y = 0
        } else {
            tabBarController?.tabBar.backgroundColor = .gray
            flg = false
            btn.frame.origin.y = -25
        }
    }

    func saveBtn() {
        print("movie save")
    }

    // Flash
    func pushFlash() {
        guard let avDevice = AVCaptureDevice.default(for: AVMediaType.video) else { return }
        do {
            try avDevice.lockForConfiguration()
            
            if avDevice.torchMode == .off {
                avDevice.torchMode = AVCaptureDevice.TorchMode.on
            } else {
                avDevice.torchMode = AVCaptureDevice.TorchMode.off
            }
            avDevice.unlockForConfiguration()
            
        } catch {
            print("not be used")
        }
    }
    
    // Stop Record!
    @IBAction func choice(_ sender: UISegmentedControl) {
        guard let pre = previewView else { return }
        if  sender.selectedSegmentIndex == 0 {
            pre.preViewReset(backDeviceType: .builtInUltraWideCamera,
                             frontDeviceType:.builtInWideAngleCamera)
        } else {
            pre.preViewReset(backDeviceType: .builtInWideAngleCamera,
                             frontDeviceType:.builtInWideAngleCamera)
        }
    }
}
