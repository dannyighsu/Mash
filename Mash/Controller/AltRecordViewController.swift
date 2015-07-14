//
//  AltRecordViewController.swift
//  Mash
//
//  Created by Danny Hsu on 7/13/15.
//  Copyright (c) 2015 Mash. All rights reserved.
//

import Foundation
import UIKit
import EZAudio
import AVFoundation

class AltRecordViewController: UIViewController, EZMicrophoneDelegate, EZAudioPlayerDelegate {
    
    @IBOutlet weak var audioPlot: EZAudioPlotGL!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var playButton: UIButton!

    var microphone: EZMicrophone? = nil
    var player: EZAudioPlayer? = nil
    var audioFile: EZAudioFile? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let session = AVAudioSession.sharedInstance()
        var error: NSError? = nil
        session.setCategory(AVAudioSessionCategoryPlayAndRecord, error: &error)
        if error != nil {
            Debug.printl("Error setting up session: \(error?.localizedDescription)", sender: self)
        }
        session.setActive(true, error: &error)
        if error != nil {
            Debug.printl("Error setting session active: \(error?.localizedDescription)", sender: self)
        }
        
        self.openAudioFile()
        
        self.player = EZAudioPlayer(EZAudioFile: self.audioFile, withDelegate: self)
        
        self.audioPlot.backgroundColor = lightBlue()
        self.audioPlot.color = darkGray()
        self.drawBufferPlot()
        
        self.microphone = EZMicrophone(delegate: self)
        
        self.playButton.addTarget(self, action: "play:", forControlEvents: UIControlEvents.TouchDown)
        self.recordButton.addTarget(self, action: "record:", forControlEvents: UIControlEvents.TouchDown)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.parentViewController?.navigationItem.setRightBarButtonItem(UIBarButtonItem(title: "Tools", style: UIBarButtonItemStyle.Plain, target: self, action: "showTools:"), animated: false)
        self.parentViewController?.navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "STHeitiSC-Light", size: 15)!, NSForegroundColorAttributeName: UIColor.whiteColor()], forState: UIControlState.Normal)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.parentViewController?.navigationItem.title = "Record"
    }
    
    // Button methods
    func record(sender: AnyObject?) {
        self.toggleMicrophone()
    }
    
    func play(sender: AnyObject?) {
        
    }
    
    // Auxiliary methods
    
    func drawRollingPlot() {
        self.audioPlot.plotType = EZPlotType.Rolling
        self.audioPlot.shouldFill = true
        self.audioPlot.shouldMirror = true
    }
    
    func drawBufferPlot() {
        self.audioPlot.plotType = EZPlotType.Buffer
        self.audioPlot.shouldFill = false
        self.audioPlot.shouldMirror = false
    }
    
    func toggleMicrophone() {
        self.drawRollingPlot()
        self.microphone?.startFetchingAudio()
    }
    
    func openAudioFile() {
        self.audioFile = EZAudioFile(URL: filePathURL(nil))
    }
    
    // Microphone Delegate Methods
    func microphone(microphone: EZMicrophone!, hasAudioReceived buffer: UnsafeMutablePointer<UnsafeMutablePointer<Float>>, withBufferSize bufferSize: UInt32, withNumberOfChannels numberOfChannels: UInt32) {
        dispatch_async(dispatch_get_main_queue()) {
            self.audioPlot.updateBuffer(buffer[0], withBufferSize: bufferSize)
        }
    }
    
    func microphone(microphone: EZMicrophone!, hasBufferList bufferList: UnsafeMutablePointer<AudioBufferList>, withBufferSize bufferSize: UInt32, withNumberOfChannels numberOfChannels: UInt32) {
        
    }

}
