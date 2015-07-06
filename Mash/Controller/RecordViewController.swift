//
//  RecordViewController.swift
//  Mash-iOS
//
//  Created by Danny Hsu on 6/9/15.
//  Copyright (c) 2015 Mash. All rights reserved.
//

import Foundation
import UIKit
import EZAudio
import AVFoundation

class RecordViewController: UIViewController, AVAudioPlayerDelegate, EZMicrophoneDelegate, EZAudioFileDelegate, EZOutputDataSource {
    
    @IBOutlet var micButton: UIButton!
    @IBOutlet weak var metronomeView: UIView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var instructionLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var audioPlot: EZAudioPlotGL!

    var recording: Bool = false
    var eof: Bool = false
    var metronome: Metronome? = nil
    var microphone: EZMicrophone? = nil
    var audioFile: EZAudioFile? = nil
    var recorder: EZRecorder? = nil
    var toolsShowing: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        var metronome = Metronome.createView()
        self.metronomeView.addSubview(metronome)
        self.metronome = metronome
        metronome.frame = self.metronomeView.frame
        
        let tools = UITapGestureRecognizer(target: self, action: "showTools:")
        self.navigationController?.navigationBar.addGestureRecognizer(tools)
        
        let tap = UITapGestureRecognizer(target: self, action: "resignKeyboard:")
        self.view.addGestureRecognizer(tap)
        
        self.audioPlot?.hidden = true
        self.audioPlot?.alpha = 0
        self.playButton?.hidden = true
        self.playButton.alpha = 0
        self.clearButton?.hidden = true
        self.playButton.alpha = 0
        self.saveButton?.hidden = true
        self.saveButton.alpha = 0
        self.audioPlot?.color = UIColor.blackColor()
        self.audioPlot?.backgroundColor = UIColor(red: 242, green: 197, blue: 117, alpha: 1)
        self.audioPlot?.shouldFill = true
        self.audioPlot?.shouldMirror = true
        self.audioPlot?.gain = 2.0
        self.timeLabel.text = String(self.metronome!.timeSignature[0])
        self.microphone = EZMicrophone(microphoneDelegate: self)
        
        self.micButton.addTarget(self, action: "toggleMicrophone:", forControlEvents: UIControlEvents.TouchDown)
        self.clearButton.addTarget(self, action: "reset:", forControlEvents: UIControlEvents.TouchDown)
        self.playButton.addTarget(self, action: "playRecording:", forControlEvents: UIControlEvents.TouchDown)
        self.saveButton.addTarget(self, action: "saveRecording:", forControlEvents: UIControlEvents.TouchDown)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.parentViewController?.navigationItem.title = "Record"
        self.metronomeView.frame.size.height = 0.1
        self.metronomeView.hidden = true
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.stopRecording()
    }
    
    func toggleMicrophone(sender: AnyObject?) {
        if !recording {
            self.metronome?.toggleMetronome(nil)
            
            self.timeLabel.text = String(self.metronome!.timeSignature[0])
            self.timeLabel.hidden = false
            UIView.animateWithDuration(0.3, animations: { self.micButton.alpha = 0; self.timeLabel.alpha = 1 }) {
                (success: Bool) in
                self.micButton.hidden = true
            }
            
            UIView.animateWithDuration(1.0, delay: 0.0, options: UIViewAnimationOptions.Autoreverse|UIViewAnimationOptions.Repeat|UIViewAnimationOptions.AllowUserInteraction, animations: {self.micButton.transform = CGAffineTransformMakeScale(1.2, 1.2)}) {
                (success: Bool) in
            }

            self.instructionLabel.hidden = false
            UIView.animateWithDuration(0.3, animations: { self.instructionLabel.alpha = 0; self.playButton.alpha = 0; self.clearButton.alpha = 0; self.saveButton.alpha = 0 }) {
                (finished: Bool) in
                self.instructionLabel.text = "Recording..."
                UIView.animateWithDuration(0.3, animations: { self.instructionLabel.alpha = 1 })
                self.playButton.hidden = true
                self.clearButton.hidden = true
                self.saveButton.hidden = true
            }

            self.recording = true
            self.startTimer()
        } else {
            self.metronome?.toggleMetronome(nil)
            self.micButton.layer.removeAllAnimations()
            var scale = CGFloat(128 / self.micButton.frame.height)

            UIView.animateWithDuration(1.0, delay: 0.0, options: nil, animations: {self.micButton.transform = CGAffineTransformMakeScale(scale, scale)}, completion: nil)
            
            self.playButton.hidden = false
            self.clearButton.hidden = false
            self.saveButton.hidden = false
            
            UIView.animateWithDuration(0.3, animations: { self.instructionLabel.alpha = 0; self.playButton.alpha = 1; self.clearButton.alpha = 1; self.saveButton.alpha = 1 }) {
                (finished: Bool) in
                self.instructionLabel.hidden = true
            }
            
            self.recording = false
            self.stopRecording()
        }
    }
    
    func resignKeyboard(sender: AnyObject?) {
        if self.metronome!.tempoField.isFirstResponder() {
            self.metronome!.tempoField.resignFirstResponder()
        } else if self.metronome!.timeSigField.isFirstResponder() {
            self.metronome!.timeSigField.resignFirstResponder()
        }
    }
    
    func reset(sender: AnyObject?) {
        self.instructionLabel.text = "Tap To Begin Recording"
        self.instructionLabel.hidden = false
        self.micButton.hidden = false
        
        UIView.animateWithDuration(0.3, animations: { self.playButton.alpha = 0; self.clearButton.alpha = 0; self.saveButton.alpha = 0; self.audioPlot.alpha = 0; self.instructionLabel.alpha = 1; self.micButton.alpha = 1 }) {
            (finished: Bool) in
            self.playButton.hidden = true
            self.clearButton.hidden = true
            self.saveButton.hidden = true
            self.audioPlot.hidden = true
        }
        
        EZOutput.sharedOutput().outputDataSource = nil
        EZOutput.sharedOutput().stopPlayback()
        self.recorder?.closeAudioFile()
    }

    func playRecording(sender: AnyObject?) {
        if !EZOutput.sharedOutput().isPlaying() {
            EZOutput.sharedOutput().outputDataSource = self
            EZOutput.sharedOutput().startPlayback()
            self.audioPlot?.hidden = false
            UIView.animateWithDuration(0.3, animations: { self.audioPlot.alpha = 1; self.micButton.alpha = 0 }) {
                (finished: Bool) in
                self.micButton.hidden = true
            }
        } else {
            EZOutput.sharedOutput().outputDataSource = nil
            EZOutput.sharedOutput().stopPlayback()
            self.audioFile?.seekToFrame(0)
            self.micButton.hidden = false
            UIView.animateWithDuration(0.3, animations: { self.audioPlot.alpha = 0; self.micButton.alpha = 1 }) {
                (finished: Bool) in
                self.audioPlot?.hidden = true
            }
        }
    }

    func saveRecording(sender: AnyObject?) {
        if EZOutput.sharedOutput().isPlaying() {
            self.playRecording(nil)
        } else if self.recording {
            self.toggleMicrophone(nil)
        }
        
        var controller = self.storyboard?.instantiateViewControllerWithIdentifier("UploadViewController") as! UploadViewController
        controller.recording = self.audioFile
        let bpm = Int(60.0 / Double(self.metronome!.duration))
        controller.bpm = bpm
        controller.timeSignature = self.metronome!.timeSigField.text
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func record() {
        Debug.printl("Now recording.", sender: self)
        self.recorder = EZRecorder(destinationURL: filePathURL(nil), sourceFormat: self.microphone!.audioStreamBasicDescription(), destinationFileType: EZRecorderFileType.M4A)
        self.microphone?.startFetchingAudio()
    }
    
    func stopRecording() {
        self.microphone?.stopFetchingAudio()
        self.recorder?.closeAudioFile()
        self.openFile(filePathURL(nil))
    }
    
    func openFile(url: NSURL) {
        self.audioPlot?.clear()
        EZOutput.sharedOutput().stopPlayback()
        EZOutput.sharedOutput().outputDataSource = nil
        self.audioFile = EZAudioFile(URL: url)
        self.eof = false
        EZOutput.sharedOutput().setAudioStreamBasicDescription(self.audioFile!.clientFormat())
        
        self.audioPlot.gain = 2.0
        self.audioFile?.audioFileDelegate = self
        self.audioPlot.plotType = EZPlotType.Rolling
        self.audioPlot.shouldFill = true
        self.audioPlot.shouldMirror = true
        self.audioFile?.getWaveformDataWithCompletionBlock() {
            (waveForm: UnsafeMutablePointer<Float>, length: UInt32) in
            self.audioPlot.updateBuffer(waveForm, withBufferSize: length)
        }
    }
    
    func audioFile(audioFile: EZAudioFile!, readAudio buffer: UnsafeMutablePointer<UnsafeMutablePointer<Float>>, withBufferSize bufferSize: UInt32, withNumberOfChannels numberOfChannels: UInt32) {
        dispatch_async(dispatch_get_main_queue()) {
            if EZOutput.sharedOutput().isPlaying() {
                self.audioPlot.updateBuffer(buffer[0], withBufferSize: bufferSize)
            }
        }
    }
    
    func output(output: EZOutput!, shouldFillAudioBufferList audioBufferList: UnsafeMutablePointer<AudioBufferList>, withNumberOfFrames frames: UInt32) {
        if self.audioFile != nil {
            var bufferSize: UInt32 = 0
            var boolPointer = ObjCBool(self.eof)
            self.audioFile!.readFrames(frames, audioBufferList: audioBufferList, bufferSize: &bufferSize, eof: &boolPointer)
            if (self.eof) {
                self.audioFile?.seekToFrame(0)
            }
        }
    }
    
    func microphone(microphone: EZMicrophone!, hasAudioReceived buffer: UnsafeMutablePointer<UnsafeMutablePointer<Float>>, withBufferSize bufferSize: UInt32, withNumberOfChannels numberOfChannels: UInt32) {
        dispatch_async(dispatch_get_main_queue()) {
            self.audioPlot.updateBuffer(buffer[0], withBufferSize: bufferSize)
        }
    }
    
    func microphone(microphone: EZMicrophone!, hasBufferList bufferList: UnsafeMutablePointer<AudioBufferList>, withBufferSize bufferSize: UInt32, withNumberOfChannels numberOfChannels: UInt32) {
        if self.recording {
            self.recorder?.appendDataFromBufferList(bufferList, withBufferSize: bufferSize)
        }
    }
    
    func startTimer() {
        var timer = NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(self.metronome!.duration), target: self, selector: "tick:", userInfo: nil, repeats: true)
    }
    
    func tick(sender: NSTimer) {
        if self.timeLabel.text!.toInt() > 1 {
            self.timeLabel.text = String(self.timeLabel.text!.toInt()! - 1)
        } else {
            self.record()
            self.micButton.hidden = false
            UIView.animateWithDuration(0.3, animations: { self.timeLabel.alpha = 0; self.micButton.alpha = 1 }) {
                (finished: Bool) in
                self.timeLabel.hidden = true
                sender.invalidate()
            }
        }
    }
    
    func showTools(sender: AnyObject?) {
        if !self.toolsShowing {
            Debug.printl("Showing tools", sender: self)
            self.metronomeView.hidden = false
            UIView.animateWithDuration(0.3, animations: { self.metronomeView.frame.size.height = 75 }) {
                (finished: Bool) in
                self.toolsShowing = true
            }
        } else {
            Debug.printl("Hiding tools", sender: self)
            UIView.animateWithDuration(0.3, animations: { self.metronomeView.frame.size.height = 0 }) {
                (finished: Bool) in
                self.metronomeView.hidden = true
                self.toolsShowing = false
            }
        }
    }
    
}
