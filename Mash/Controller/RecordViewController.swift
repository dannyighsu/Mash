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
    @IBOutlet weak var volumeSlider: UISlider!
    @IBOutlet weak var speakerImage: UIButton!
    @IBOutlet weak var recordingCoverView: UIView!

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
    var toolsViewFrame: CGRect? = nil
    var swipeArrow: UIImageView? = nil
    var upTap: UITapGestureRecognizer? = nil
    var downTap: UITapGestureRecognizer? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load AVAudioSession
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

        // Configure EZAudio
        self.audioPlot.backgroundColor = darkGray()
        self.audioPlot.color = lightBlue()
        self.drawBufferPlot()
        self.recordingCoverView.hidden = true
        
        self.microphone = EZMicrophone(delegate: self)
        self.microphone?.startFetchingAudio()
        
        // Button targets
        self.playButton.addTarget(self, action: "play:", forControlEvents: UIControlEvents.TouchDown)
        self.recordButton.addTarget(self, action: "record:", forControlEvents: UIControlEvents.TouchDown)
        self.stopButton.addTarget(self, action: "stop:", forControlEvents: UIControlEvents.TouchDown)
        self.clearButton.addTarget(self, action: "clear:", forControlEvents: UIControlEvents.TouchDown)
        self.saveButton.addTarget(self, action: "save:", forControlEvents: UIControlEvents.TouchDown)
        
        // Configure toolsView table
        self.toolsView.delegate = self
        self.toolsView.dataSource = self
        self.toolsView.allowsSelection = false
        let swipebar = UINib(nibName: "SwipeBar", bundle: nil)
        self.toolsView.registerNib(swipebar, forHeaderFooterViewReuseIdentifier: "SwipeBar")
        self.toolsView.scrollEnabled = false
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        /*self.parentViewController?.navigationItem.setRightBarButtonItem(UIBarButtonItem(title: "Tools", style: UIBarButtonItemStyle.Plain, target: self, action: "showTools:"), animated: false)
        self.parentViewController?.navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "STHeitiSC-Light", size: 15)!, NSForegroundColorAttributeName: UIColor.whiteColor()], forState: UIControlState.Normal)*/
        self.toolsViewFrame = self.toolsView.frame
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
            self.player!.pause()
            self.player!.seekToFrame(0)
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
        self.metronome!.toggleMetronome(nil)
        
        UIView.animateWithDuration(0.3, animations: { view.alpha = 1.0 })
    }
    
    func stopRecording() {
        self.metronome?.toggleMetronome(nil)
        self.microphone?.stopFetchingAudio()
        self.recorder?.closeAudioFile()
        self.openAudio()
        self.recording = false
        UIView.animateWithDuration(0.3, animations: { self.recordingCoverView.alpha = 0.0 }) {
            (completion: Bool) in
            self.recordingCoverView.hidden = true
        }
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
        var data = self.audioFile!.getWaveformData()
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
        self.clearButton.userInteractionEnabled = false
        self.stopButton.userInteractionEnabled = false
    }
    
    func validateButtons() {
        self.playButton.userInteractionEnabled = true
        self.clearButton.userInteractionEnabled = true
        self.stopButton.userInteractionEnabled = true
    }
    
    func showTools(sender: AnyObject?) {
        UIView.animateWithDuration(0.5, animations: { self.toolsView.frame = self.view.frame }) {
            (completed: Bool) in
            self.swipeArrow?.image = UIImage(named: "swipe_arrow")
            self.swipeArrow?.removeGestureRecognizer(self.upTap!)
            self.swipeArrow?.addGestureRecognizer(self.downTap!)
            self.toolsView.scrollEnabled = true
        }
    }
    
    func hideTools(sender: AnyObject?) {
        UIView.animateWithDuration(0.5, animations: { self.toolsView.frame = self.toolsViewFrame! }) {
            (completed: Bool) in
            self.swipeArrow?.image = UIImage(named: "swipe_arrow_2")
            self.swipeArrow?.removeGestureRecognizer(self.downTap!)
            self.swipeArrow?.addGestureRecognizer(self.upTap!)
            self.toolsView.scrollEnabled = false
        }
    }
    
    // Microphone Delegate
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
            milliText = milliText.substringWithRange(Range<String.Index>(start: advance(milliText.startIndex, 2), end: advance(milliText.startIndex, 4)))
            self.timeLabel.text = "\(secondText):\(milliText)"
        }
    }
    
    // EZAudioFile Delegate
    func audioFile(audioFile: EZAudioFile!, readAudio buffer: UnsafeMutablePointer<UnsafeMutablePointer<Float>>, withBufferSize bufferSize: UInt32, withNumberOfChannels numberOfChannels: UInt32) {
        dispatch_async(dispatch_get_main_queue()) {
            self.audioPlot.updateBuffer(buffer[0], withBufferSize: bufferSize)
        }
    }
    
    // Metronome Delegate
    func tick(metronome: Metronome) {
        if self.beat > 1 {
            self.beat -= 1
            self.beatLabel!.text = "\(self.beat)"
        } else if self.beat == 1 {
            self.drawRollingPlot()
            self.recorder = EZRecorder(URL: filePathURL(nil), clientFormat: self.microphone!.audioStreamBasicDescription(), fileType: EZRecorderFileType.M4A)
            self.microphone?.startFetchingAudio()
            self.recordingStartTime = NSDate()
            self.recording = true
            self.beat = 0
            self.recordingCoverView.hidden = false
            self.recordingCoverView.alpha = 0.7
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
            return 100.0
        }
        return 60.0
    }

}
