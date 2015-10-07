//
//  RecordViewController.swift
//  Mash
//
//  Created by Danny Hsu on 7/13/15.
//  Copyright (c) 2015 Mash. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class RecordViewController: UIViewController, EZMicrophoneDelegate, EZAudioPlayerDelegate, EZAudioFileDelegate,MetronomeDelegate {
    
    @IBOutlet weak var audioPlot: EZAudioPlotGL!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var audioPlotBar: UIView!
    @IBOutlet weak var stopButton: UIButton!
    //@IBOutlet weak var recordingCoverView: UIView!

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
    var volumeSlider: UISlider!
    var speakerImage: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load AVAudioSession
        let session = AVAudioSession.sharedInstance()
        var error: NSError? = nil
        do {
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
        } catch let error1 as NSError {
            error = error1
        }
        if error != nil {
            Debug.printl("Error setting up session: \(error?.localizedDescription)", sender: self)
        }
        do {
            try session.setActive(true)
        } catch let error1 as NSError {
            error = error1
        }
        do {
            /*let output = session.currentRoute.outputs.first as! AVAudioSessionPortDescription
        if output.portType == "Receiver" {
        }*/
            try session.overrideOutputAudioPort(AVAudioSessionPortOverride.Speaker)
        } catch _ {
        }
        if error != nil {
            Debug.printl("Error setting session active: \(error?.localizedDescription)", sender: self)
        }

        // Configure EZAudio
        self.audioPlot.backgroundColor = darkGray()
        self.audioPlot.color = lightBlue()
        self.drawBufferPlot()
        //self.recordingCoverView.hidden = true
        
        self.microphone = EZMicrophone(delegate: self)
        self.microphone?.startFetchingAudio()
        
        // Set up nav buttons
        self.parentViewController?.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: UIBarButtonItemStyle.Plain, target: self, action: "save:")
        self.parentViewController?.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Clear", style: UIBarButtonItemStyle.Plain, target: self, action: "clear:")
        
        // Button targets
        self.playButton.addTarget(self, action: "play:", forControlEvents: UIControlEvents.TouchUpInside)
        self.recordButton.addTarget(self, action: "record:", forControlEvents: UIControlEvents.TouchUpInside)
        self.stopButton.addTarget(self, action: "stop:", forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        let value = UIInterfaceOrientation.Portrait.rawValue
        UIDevice.currentDevice().setValue(value, forKey: "orientation")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.parentViewController?.navigationItem.title = "Record"
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        if self.player != nil && self.player!.isPlaying {
            self.stop(nil)
        }
        if self.recording {
            self.record(nil)
        }
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    
    // Button methods
    func record(sender: AnyObject?) {
        if self.player != nil && self.player!.isPlaying {
            self.stop(nil)
        }
        if !self.recording {
            self.invalidateButtons()
            self.prepareRecording()
        } else {
            self.stopRecording()
            self.validateButtons()
        }
    }
    
    func play(sender: AnyObject?) {
        if self.audioFile == nil {
            return
        }
        if self.player!.isPlaying {
            self.player!.pause()
            self.playButton.setImage(UIImage(named: "Play"), forState: UIControlState.Normal)
        } else if !self.player!.isPlaying {
            self.player!.play()
            self.playButton.setImage(UIImage(named: "Pause"), forState: UIControlState.Normal)
        }
    }
    
    func stop(sender: AnyObject?) {
        if self.player != nil {
            self.player!.seekToFrame(0)
            self.player!.pause()
            self.player!.currentTime = 0
            self.playButton.setImage(UIImage(named: "Play"), forState: UIControlState.Normal)
        }
    }
    
    func clear(sender: AnyObject?) {
        if self.player != nil && self.player!.isPlaying {
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
        if self.player == nil || self.audioFile == nil {
            return
        }
        let controller = self.storyboard?.instantiateViewControllerWithIdentifier("UploadViewController") as! UploadViewController
        controller.recording = self.audioFile
        controller.bpm = Int(60.0 / Double(self.metronome!.duration))
        controller.timeSignature = self.metronome!.timeSigField.text
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    // Slider methods
    @IBAction func volumeDidChange(sender: UISlider) {
        if self.player != nil {
            self.player!.volume = sender.value
            if sender.value == 0 {
                self.speakerImage.setImage(UIImage(named: "speaker_white_2"), forState: UIControlState.Normal)
            } else {
                self.speakerImage.setImage(UIImage(named: "speaker_white"), forState: UIControlState.Normal)
            }
        }
    }
    
    // Auxiliary methods
    func prepareRecording() {
        let view = UIView(frame: self.view.frame)
        view.backgroundColor = UIColor(red: 40, green: 40, blue: 40, alpha: 0.6)
        view.alpha = 0.0
        
        self.beat = self.metronome!.timeSignature[0] + 1
        let beatLabel = UILabel(frame: view.frame)
        beatLabel.font = UIFont(name: "STHeitiSC-Light", size: 100)
        beatLabel.textColor = UIColor.blackColor()
        beatLabel.text = "\(self.beat)"
        beatLabel.textAlignment = NSTextAlignment.Center
        
        self.beatLabel = beatLabel
        view.addSubview(beatLabel)
        beatLabel.center = view.center
        self.countoffView = view
        self.view.addSubview(view)
        self.metronome!.toggle(nil)
        
        UIView.animateWithDuration(0.3, animations: { view.alpha = 1.0 })
    }
    
    func stopRecording() {
        self.metronome?.toggle(nil)
        self.microphone?.stopFetchingAudio()
        self.recorder?.closeAudioFile()
        self.openAudio()
        self.recording = false
        self.recordButton.setImage(UIImage(named: "Record_button"), forState: UIControlState.Normal)
        /*UIView.animateWithDuration(0.3, animations: { self.recordingCoverView.alpha = 0.0 }) {
            (completion: Bool) in
            self.recordingCoverView.hidden = true
        }*/
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
    
    func openAudio() {
        self.audioFile = EZAudioFile(URL: filePathURL(nil), delegate: self)
        self.player = EZAudioPlayer(audioFile: self.audioFile)
        self.player!.delegate = self
        self.player!.volume = self.volumeSlider.value
        let data = self.audioFile!.getWaveformData()
        self.audioPlot.updateBuffer(data.buffers[0], withBufferSize: data.bufferSize)
        
        /*self.audioFile?.getWaveformDataWithCompletionBlock() {
            (waveformData: UnsafeMutablePointer<UnsafeMutablePointer<Float>>, length: Int32) in
            dispatch_async(dispatch_get_main_queue()) {
                self.audioPlot.updateBuffer(waveformData[0], withBufferSize: UInt32(length))
            }
        }*/
    }
    
    func invalidateButtons() {
        self.playButton.userInteractionEnabled = false
        self.stopButton.userInteractionEnabled = false
    }
    
    func validateButtons() {
        self.playButton.userInteractionEnabled = true
        self.stopButton.userInteractionEnabled = true
    }
    
    func showTools(sender: AnyObject?) {
        /*
        UIView.animateWithDuration(0.5, animations: { self.toolsView.frame = self.view.frame }) {
            (completed: Bool) in
            self.swipeArrow?.image = UIImage(named: "swipe_arrow")
            self.swipeArrow?.removeGestureRecognizer(self.upTap!)
            self.swipeArrow?.addGestureRecognizer(self.downTap!)
            self.toolsView.scrollEnabled = true
        }*/
    }
    
    func hideTools(sender: AnyObject?) {
        /*
        UIView.animateWithDuration(0.5, animations: { self.toolsView.frame = self.toolsViewFrame! }) {
            (completed: Bool) in
            self.swipeArrow?.image = UIImage(named: "swipe_arrow_2")
            self.swipeArrow?.removeGestureRecognizer(self.downTap!)
            self.swipeArrow?.addGestureRecognizer(self.upTap!)
            self.toolsView.scrollEnabled = false
        }*/
    }
    
    // Microphone Delegate
    func microphone(microphone: EZMicrophone!, hasAudioReceived buffer: UnsafeMutablePointer<UnsafeMutablePointer<Float>>, withBufferSize bufferSize: UInt32, withNumberOfChannels numberOfChannels: UInt32) {
        dispatch_async(dispatch_get_main_queue()) {
            [weak self] in
            self?.audioPlot.updateBuffer(buffer[0], withBufferSize: bufferSize)
            if self != nil && self!.recording {
                let time = self!.recordingStartTime.timeIntervalSinceNow * -1
                var secondText = String(stringInterpolationSegment: Int(time))
                if time < 10.0 {
                    secondText = "0\(secondText)"
                }
                var milliText = String(stringInterpolationSegment: time % 1)
                milliText = milliText.substringWithRange(Range<String.Index>(start: milliText.startIndex.advancedBy(2), end: milliText.startIndex.advancedBy(4)))
                self!.timeLabel.text = "\(secondText):\(milliText)"
            }
        }
    }
    
    func microphone(microphone: EZMicrophone!, hasBufferList bufferList: UnsafeMutablePointer<AudioBufferList>, withBufferSize bufferSize: UInt32, withNumberOfChannels numberOfChannels: UInt32) {
        dispatch_async(dispatch_get_main_queue()) {
            [weak self] in
            if self == nil {
                return
            }
            if self!.recording {
                self?.recorder?.appendDataFromBufferList(bufferList, withBufferSize: bufferSize)
            }
        }
    }
    
    // EZAudioPlayer Delegate
    func audioPlayer(audioPlayer: EZAudioPlayer!, updatedPosition framePosition: Int64, inAudioFile audioFile: EZAudioFile!) {
        dispatch_async(dispatch_get_main_queue()) {
            let time = audioPlayer.currentTime
            if time == 0 {
                self.timeLabel.text = "00:00"
                if self.audioFile != nil {
                    self.play(nil)
                }
                return
            }
            var secondText = String(stringInterpolationSegment: Int(time))
            if time < 10.0 {
                secondText = "0\(secondText)"
            }
            var milliText = String(stringInterpolationSegment: time % 1)
            milliText = milliText.substringWithRange(Range<String.Index>(start: milliText.startIndex.advancedBy(2), end: milliText.startIndex.advancedBy(4)))
            self.timeLabel.text = "\(secondText):\(milliText)"
        }
    }
    
    // EZAudioFile Delegate
    func audioFile(audioFile: EZAudioFile!, readAudio buffer: UnsafeMutablePointer<UnsafeMutablePointer<Float>>, withBufferSize bufferSize: UInt32, withNumberOfChannels numberOfChannels: UInt32) {
        dispatch_async(dispatch_get_main_queue()) {
            [weak self] in
            self?.audioPlot.updateBuffer(buffer[0], withBufferSize: bufferSize)
        }
    }
    
    // Metronome Delegate
    func tick(metronome: Metronome) {
        if self.beat > 1 {
            self.beat -= 1
            self.beatLabel!.text = "\(self.beat)"
        } else if self.beat == 1 {
            
            // Start recording
            self.drawRollingPlot()
            self.recorder = EZRecorder(URL: filePathURL(nil), clientFormat: self.microphone!.audioStreamBasicDescription(), fileType: EZRecorderFileType.M4A)
            self.microphone?.startFetchingAudio()
            self.recordingStartTime = NSDate()
            self.recording = true
            self.beat = 0
            //self.recordingCoverView.hidden = false
            //self.recordingCoverView.alpha = 0.7
            self.recordButton.setImage(UIImage(named: "Record_stop"), forState: UIControlState.Normal)
            UIView.animateWithDuration(0.3, animations: { self.countoffView!.alpha = 0.0 }) {
                (completed: Bool) in
                self.countoffView?.removeFromSuperview()
            }
        }
    }
    
    func timeFieldDidBeginEditing(metronome: Metronome) {
        self.showTools(nil)
    }
    
    func tempoFieldDidBeginEditing(metronome: Metronome) {
        self.showTools(nil)
    }
    
    /*
    // TableView Delegate
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterViewWithIdentifier("SwipeBar") as! SwipeBar
        let up = UISwipeGestureRecognizer(target: self, action: "showTools:")
        up.direction = .Up
        let down = UISwipeGestureRecognizer(target: self, action: "hideTools:")
        down.direction = .Down
        header.swipeView.addGestureRecognizer(up)
        header.swipeView.addGestureRecognizer(down)
        
        self.upTap = UITapGestureRecognizer(target: self, action: "showTools:")
        self.downTap = UITapGestureRecognizer(target: self, action: "hideTools:")
        self.swipeArrow = header.swipeArrow
        self.swipeArrow?.addGestureRecognizer(self.upTap!)
        return header
    }

    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30.0
    }
    
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
            let metronome = Metronome.createView()
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
            return 100.0
        }
        return 60.0
    }*/

}
