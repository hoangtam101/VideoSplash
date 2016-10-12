//
//  VideoSplashViewController.swift
//  VideoSplashKit
//
//  Created by TamNguyen on 10/4/16.
//  Copyright © 2016 TamNguyen. All rights reserved.
//

import UIKit
import AVFoundation

class VideoSplashViewController: UIViewController {
    
    //MARK: Private Variable
    private var player: AVPlayer!
    private var playerLayer: AVPlayerLayer!
    
    //MARK: Public Variable
    public var fileNameVideo: String! {
        didSet {
            let fileStr = NSString(string: self.fileNameVideo)
            self.createVideoAnimationWithFile(fileName: fileStr.deletingPathExtension,
                                              type: fileStr.pathExtension)
        }
    }
    
    public var isAutoReplay = true {
        didSet {
            if (self.player != nil) {
                if (self.isAutoReplay) {
                    self.player.actionAtItemEnd = .none
                } else {
                    self.player.actionAtItemEnd = .pause
                }
            }
        }
    }
    
    public var isEnableSound = false {
        didSet {
            if (self.player != nil) {
                if (self.isEnableSound) {
                    self.player.volume = 0.0
                } else {
                    self.player.volume = 1.0
                }
            }
        }
    }

    //MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.registerNotifications()
    }
        
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if (self.playerLayer != nil) {
            self.playerLayer.frame = self.view.bounds
        }
    }
    
    deinit {
        self.unRegisterNotification()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Notification
    private func registerNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(goToBecomeActive(_:)),
                                               name: Notification.Name.UIApplicationDidBecomeActive,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didReceiveEndVideoNotification(_:)),
                                               name:Notification.Name.AVPlayerItemDidPlayToEndTime,
                                               object:nil)
    }
    
    private func unRegisterNotification() {
        NotificationCenter.default.removeObserver(self)
    }
    
    func goToBecomeActive(_ notif: NSNotification){
        if (self.player != nil) {
            if (self.player.rate == 0.0) {
                self.player.play()
            }
        }
    }
    
    func didReceiveEndVideoNotification(_ notif: NSNotification) {
        if let currPlayer = notif.object as? AVPlayerItem {
            if (self.isAutoReplay) {
                currPlayer.seek(to: kCMTimeZero)
            }
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: Utils
    private func createVideoAnimationWithFile(fileName: String, type: String) {
        autoreleasepool {
            if (self.playerLayer != nil) {
                self.stopVideoPlayer()
            }
            let volume: Float = self.isEnableSound ? 1.0 : 0.0
            let pathFile = Bundle.main.path(forResource: fileName, ofType: type)
            if (pathFile != nil) {
                let url = NSURL.fileURL(withPath: pathFile!)
                self.player = AVPlayer(url: url)
                if (self.isAutoReplay) {
                    self.player.actionAtItemEnd = .none
                } else {
                    self.player.actionAtItemEnd = .pause
                }
                self.player.volume = volume
                self.playerLayer = AVPlayerLayer(player:self.player)
                
                self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
                self.playerLayer.backgroundColor = UIColor.white.cgColor
                self.view.layer.insertSublayer(self.playerLayer, at:0)
                self.view.layer.setNeedsLayout()
                self.view.layer.setNeedsDisplay()
                
                self.player.play()
            }
        }
    }
    
    public func stopVideoPlayer() {
        DispatchQueue.main.async {
            if (self.player != nil) {
                self.player.pause()
                self.player.rate = 0.0
            }
            if (self.playerLayer != nil) {
                self.playerLayer.removeAllAnimations()
                self.playerLayer.removeFromSuperlayer()
            }
            self.playerLayer = nil
            self.player = nil
        }
    }
}
