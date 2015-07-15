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

class RecordViewController: UIViewController, EZMicrophoneDelegate, EZAudioPlayerDelegate, EZAudioFileDelegate, UITableViewDelegate, UITableViewDataSource, MetronomeDelegate {
    
    @IBOutlet weak var audioPlot: EZAudioPlotGL!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var audioPlotBar: UIView!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var toolsView: UITableView!

    var microphone: EZMicrophone? = nil
    var player: EZAudioPlayer? = nil
    var audioFile: EZAudioFile? = nil
    var recorder: EZRecorder? = nil
    var recording: Bool = false
    var recordingStartTime: NSDate = NSDate()
    var metronome: Metronome? = nil
    var beat: Int = 5
    var beatLabel: UILabel? = nil
    var countoffView: UIView? = nil

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
        self.saveButton.addTarget(self, action: "save:", forControlEvents: UIControlEvents.TouchDown)
        
        self.toolsView.delegate = self
        self.toolsView.dataSource = self
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        /*self.parentViewController?.navigationItem.setRightBarButtonItem(UIBarButtonItem(title: "Tools", style: UIBarButtonItemStyle.Plain, target: self, action: "showTools:"), animated: false)
        self.parentViewController?.navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "STHeitiSC-Light", size: 15)!, NSForegroundColorAttributeName: UIColor.whiteColor()], forState: UIControlState.Normal)*/
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.parentViewController?.navigationItem.title = "Record"
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        if self.player != nil && self.player!.isPlaying() {
            self.stop(nil)
        }
        if self.recording {
            self.record(nil)
        }
    }
    
    // Button methods
    func record(sender: AnyObject?) {
        if self.player != nil && self.player!.isPlaying() {
            self.stop(nil)
        }
        if !self.recording {
            self.invalidateButtons()
            self.prepareRecording()
        } else {
            self.microphone?.stopFetchingAudio()
            self.recorder?.closeAudioFile()
            self.openAudioFile()
            self.recording = false
            self.metronome?.toggleMetronome(nil)
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
            self.playButton.imageView?.image = UIImage(named: "Play_2")
        }
    }
    
    func stop(sender: AnyObject?) {
        if self.player != nil {
            self.player!.stop()
            self.playButton.imageView?.image = UIImage(named: "Play")
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
    
    func save(sender: AnyObject?) {
        let controller = self.storyboard?.instantiateViewControllerWithIdentifier("UploadViewController") as! UploadViewController
        controller.recording = self.audioFile
        controller.bpm = Int(60.0 / Double(self.metronome!.duration))
        controller.timeSignature = self.metronome!.timeSigField.text
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    // Auxiliary methods
    func prepareRecording() {
        var view = UIView(frame: self.view.frame)
        view.backgroundColor = UIColor(red: 40, green: 40, blue: 40, alpha: 0.6)
        view.alpha = 0.0
        
        self.beat = self.metronome!.timeSignature[0] + 1
        var beatLabel = UILabel(frame: view.frame)
        beatLabel.font = UIFont(name: "STHeitiSC-Light", size: 100)
        beatLabel.textColor = UIColor.blackColor()
        beatLabel.text = "\(self.beat)"
        beatLabel.textAlignment = NSTextAlignment.Center
        
        self.beatLabel = beatLabel
        view.addSubview(beatLabel)
        beatLabel.center = view.center
        self.countoffView = view
        self.view.addSubview(view)
        
        UIView.animateWithDuration(0.3, animations: { view.alpha = 1.0 })
        self.metronome!.toggleMetronome(nil)
    }
    
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
            if time == 0 {
                self.timeLabel.text = "00:00"
                return
            }
            var secondText = String(stringInterpolationSegment: Int(time))
            if time < 10.0 {
                secondText = "0\(secondText)"
            }
            var milliText = String(stringInterpolationSegment: time % 1)
            milliText = milliText.substringWithRange(Range<String.Index>(start: advance(milliText.startIndex, 2), end: advance(milliText.startIndex, 4)))
            self.timeLabel.text = "\(secondText):\(milliText)"
        }
    }
    
    // Metronome Delegate
    func tick(metronome: Metronome) {
        if self.beat > 1 {
            self.beat -= 1
            self.beatLabel!.text = "\(self.beat)"
        } else if self.beat == 1 {
            self.drawRollingPlot()
            self.recorder = EZRecorder(destinationURL: filePathURL(nil), sourceFormat: self.microphone!.audioStreamBasicDescription(), destinationFileType: EZRecorderFileType.M4A)
            self.microphone?.startFetchingAudio()
            self.recordingStartTime = NSDate()
            self.recording = true
            self.beat = 0
            UIView.animateWithDuration(0.3, animations: { self.countoffView!.alpha = 0.0 }) {
                (completed: Bool) in
                self.countoffView?.removeFromSuperview()
            }
        }
    }
    
    // TableView Delegate
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            var metronome = Metronome.createView()
            metronome.delegate = self
            metronome.backgroundColor = lightGray()
            self.metronome = metronome
            return metronome
        } else {
            return UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "Default")
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 75
        }
        return 60.0
    }

}
