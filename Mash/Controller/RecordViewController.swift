//
//  RecordViewController.swift
//  Mash
//
//  Created by Danny Hsu on 7/13/15.
//  Copyright (c) 2015 Mash. All rights reserved.
//

import Foundation
import UIKit
import EZAudio
import AVFoundation

class RecordViewController: UIViewController, EZMicrophoneDelegate, EZAudioPlayerDelegate, EZAudioFileDelegate {
    
    @IBOutlet weak var audioPlot: EZAudioPlotGL!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var audioPlotBar: UIView!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var toolsView: UITableView!

    var microphone: EZMicrophone? = nil
    var player: EZAudioPlayer? = nil
    var audioFile: EZAudioFile? = nil
    var recorder: EZRecorder? = nil
    var recording: Bool = false
    var recordingStartTime: NSDate = NSDate()

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

        self.audioPlot.backgroundColor = darkGray()
        self.audioPlot.color = lightBlue()
        self.drawBufferPlot()
        
        self.microphone = EZMicrophone(delegate: self)
        self.microphone?.startFetchingAudio()
        
        self.playButton.addTarget(self, action: "play:", forControlEvents: UIControlEvents.TouchDown)
        self.recordButton.addTarget(self, action: "record:", forControlEvents: UIControlEvents.TouchDown)
        self.stopButton.addTarget(self, action: "stop:", forControlEvents: UIControlEvents.TouchDown)
        self.clearButton.addTarget(self, action: "clear:", forControlEvents: UIControlEvents.TouchDown)
        
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
        if !self.recording {
            self.drawRollingPlot()
            self.recorder = EZRecorder(destinationURL: filePathURL(nil), sourceFormat: self.microphone!.audioStreamBasicDescription(), destinationFileType: EZRecorderFileType.M4A)
            self.microphone?.startFetchingAudio()
            self.recordingStartTime = NSDate()
            self.recording = true
            self.invalidateButtons()
        } else {
            self.microphone?.stopFetchingAudio()
            self.recorder?.closeAudioFile()
            self.openAudioFile()
            self.recording = false
            self.validateButtons()
        }
    }
    
    func play(sender: AnyObject?) {
        if self.audioFile == nil {
            return
        }
        if self.player != nil && self.player!.isPlaying() {
            self.player!.pause()
            self.playButton.imageView?.image = UIImage(named: "Play")
        } else if self.player != nil && !self.player!.isPlaying() {
            self.player!.play()
            self.playButton.imageView?.image = UIImage(named: "Play_2")
        } else if self.player == nil {
            self.player = EZAudioPlayer(EZAudioFile: self.audioFile, withDelegate: self)
            self.player!.play()
            self.playButton.imageView?.image = UIImage(named: "play_2")
        }
    }
    
    func stop(sender: AnyObject?) {
        if self.player != nil && self.player!.isPlaying() {
            self.player!.pause()
            self.player = EZAudioPlayer(EZAudioFile: self.audioFile, withDelegate: self)
        } else if self.player != nil {
            self.player = EZAudioPlayer(EZAudioFile: self.audioFile, withDelegate: self)
        }
    }
    
    func clear(sender: AnyObject?) {
        if self.player != nil && self.player!.isPlaying() {
            self.player!.pause()
        }
        self.player = nil
        self.audioFile = nil
        self.recorder = nil
        self.microphone!.startFetchingAudio()
        self.drawBufferPlot()
        self.timeLabel.text = "00:00"
    }
    
    // Auxiliary methods
    func drawRollingPlot() {
        self.audioPlot.clear()
        self.audioPlotBar.hidden = false
        self.audioPlot.plotType = EZPlotType.Rolling
        self.audioPlot.shouldFill = true
        self.audioPlot.shouldMirror = true
        self.audioPlot.gain = 6.0
    }
    
    func drawBufferPlot() {
        self.audioPlot.clear()
        self.audioPlotBar.hidden = true
        self.audioPlot.plotType = EZPlotType.Buffer
        self.audioPlot.shouldFill = false
        self.audioPlot.shouldMirror = false
        self.audioPlot.gain = 1.0
    }
    
    func openAudioFile() {
        self.audioFile = EZAudioFile(URL: filePathURL(nil), andDelegate: self)
        self.drawRollingPlot()
        self.audioFile!.getWaveformDataWithCompletionBlock() {
            (waveformData, length) in
            dispatch_async(dispatch_get_main_queue()) {
                self.audioPlot.updateBuffer(waveformData, withBufferSize: length)
            }
        }
    }
    
    func invalidateButtons() {
        self.playButton.userInteractionEnabled = false
        self.clearButton.userInteractionEnabled = false
        self.stopButton.userInteractionEnabled = false
    }
    
    func validateButtons() {
        self.playButton.userInteractionEnabled = true
        self.clearButton.userInteractionEnabled = true
        self.stopButton.userInteractionEnabled = true
    }
    
    // Microphone Delegate Methods
    func microphone(microphone: EZMicrophone!, hasAudioReceived buffer: UnsafeMutablePointer<UnsafeMutablePointer<Float>>, withBufferSize bufferSize: UInt32, withNumberOfChannels numberOfChannels: UInt32) {
        dispatch_async(dispatch_get_main_queue()) {
            self.audioPlot.updateBuffer(buffer[0], withBufferSize: bufferSize)
            if self.recording {
                var time = self.recordingStartTime.timeIntervalSinceNow * -1
                var secondText = String(stringInterpolationSegment: Int(time))
                if time < 10.0 {
                    secondText = "0\(secondText)"
                }
                var milliText = String(stringInterpolationSegment: time % 1)
                milliText = milliText.substringWithRange(Range<String.Index>(start: advance(milliText.startIndex, 2), end: advance(milliText.startIndex, 4)))
                self.timeLabel.text = "\(secondText):\(milliText)"
            }
        }
    }
    
    func microphone(microphone: EZMicrophone!, hasBufferList bufferList: UnsafeMutablePointer<AudioBufferList>, withBufferSize bufferSize: UInt32, withNumberOfChannels numberOfChannels: UInt32) {
        dispatch_async(dispatch_get_main_queue()) {
            if self.recording {
                self.recorder?.appendDataFromBufferList(bufferList, withBufferSize: bufferSize)
            }
        }
    }
    
    // EZAudioPlayer Delegate
    func audioPlayer(audioPlayer: EZAudioPlayer!, readAudio buffer: UnsafeMutablePointer<UnsafeMutablePointer<Float>>, withBufferSize bufferSize: UInt32, withNumberOfChannels numberOfChannels: UInt32, inAudioFile audioFile: EZAudioFile!) {
        dispatch_async(dispatch_get_main_queue()) {
            self.audioPlot.updateBuffer(buffer[0], withBufferSize: bufferSize)
        }
    }
    
    func audioPlayer(audioPlayer: EZAudioPlayer!, updatedPosition framePosition: Int64, inAudioFile audioFile: EZAudioFile!) {
        dispatch_async(dispatch_get_main_queue()) {
            let time = audioPlayer.currentTime()
            var secondText = String(stringInterpolationSegment: Int(time))
            if time < 10.0 {
                secondText = "0\(secondText)"
            }
            var milliText = String(stringInterpolationSegment: time % 1)
            milliText = milliText.substringWithRange(Range<String.Index>(start: advance(milliText.startIndex, 2), end: advance(milliText.startIndex, 4)))
            self.timeLabel.text = "\(secondText):\(milliText)"
        }
    }

}
