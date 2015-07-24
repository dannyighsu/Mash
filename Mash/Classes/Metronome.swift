//
//  Metronome.swift
//  Mash-iOS
//
//  Created by Danny Hsu on 6/8/15.
//  Copyright (c) 2015 Mash. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

@objc protocol MetronomeDelegate {
    optional func tick(metronome: Metronome)
    optional func tempoFieldDidBeginEditing(metronome: Metronome)
    optional func timeFieldDidBeginEditing(metronome: Metronome)
}

class Metronome: UITableViewCell, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var tempoField: UITextField!
    @IBOutlet weak var timeSigField: UITextField!
    @IBOutlet weak var volumeSlider: UISlider!
    @IBOutlet weak var tempoSlider: UISlider!
    @IBOutlet weak var speakerImage: UIButton!

    var delegate: MetronomeDelegate?
    var duration: CGFloat
    var soundPlayerThread: NSThread?
    var tickPlayer: AVAudioPlayer
    var tockPlayer: AVAudioPlayer
    var timeSignature: [Int]
    var beat: Int
    var isPlaying: Bool
    var muted: Bool
    var previousVolume: Float = 0.8
    var wasManuallyTriggered: Bool = false
    var timer: CADisplayLink? = nil
    
    required init(coder aDecoder: NSCoder) {
        self.duration = 0.50
        self.timeSignature = [4, 4]
        self.soundPlayerThread = nil
        self.beat = 0
        self.isPlaying = false
        self.muted = false
        
        var tickURL = NSBundle.mainBundle().URLForResource("tick", withExtension: ".caf")
        var tockURL = NSBundle.mainBundle().URLForResource("tock", withExtension: ".caf")
        var error:NSError? = nil
        
        self.tickPlayer = AVAudioPlayer(contentsOfURL: tickURL, error: &error)
        self.tockPlayer = AVAudioPlayer(contentsOfURL: tockURL, error: &error)
        
        if error != nil {
            Debug.printl("Audio player error: \(error!.localizedDescription)", sender: "Metronome")
        }

        super.init(coder: aDecoder)
    }
    
    // Create a metronome with recordController
    class func createView() -> Metronome {
        var view = NSBundle.mainBundle().loadNibNamed("Metronome", owner: nil, options: nil)
        let metronome = view[0] as! Metronome
        metronome.startButton.addTarget(metronome, action: "toggle:", forControlEvents: UIControlEvents.TouchDown)
        
        metronome.tempoField.keyboardType = UIKeyboardType.NumberPad
        metronome.tempoField.delegate = metronome
        metronome.timeSigField.delegate = metronome
        metronome.timeSigField.text = "4/4"
        metronome.tempoSlider.minimumValue = 40
        metronome.tempoSlider.maximumValue = 220
        metronome.tempoSlider.value = 120
        metronome.speakerImage.addTarget(metronome, action: "muteAudio:", forControlEvents: UIControlEvents.TouchDown)
        
        var picker = UIPickerView(frame: CGRectZero)
        picker.delegate = metronome
        picker.dataSource = metronome
        picker.backgroundColor = lightGray()

        metronome.timeSigField.inputView = picker
        return metronome
    }
    
    @IBAction func volumeDidChange(sender: UISlider) {
        self.tickPlayer.volume = sender.value
        self.tockPlayer.volume = sender.value
        if sender.value == 0 {
            self.speakerImage.setImage(UIImage(named: "speaker_white_2"), forState: UIControlState.Normal)
        } else {
            self.speakerImage.setImage(UIImage(named: "speaker_white"), forState: UIControlState.Normal)
        }
    }
    
    @IBAction func tempoDidChange(sender: UISlider) {
        let value = Int(sender.value)
        self.setTempo(value)
    }
    
    func muteAudio(sender: AnyObject?) {
        if self.volumeSlider.value == 0 {
            self.volumeSlider.value = self.previousVolume
            self.volumeDidChange(self.volumeSlider)
        } else {
            self.previousVolume = self.volumeSlider.value
            self.volumeSlider.value = 0
            self.volumeDidChange(self.volumeSlider)
        }
    }

    // Text Field Delegate
    func textFieldDidEndEditing(textField: UITextField) {
        if textField == self.tempoField {
            var input = self.tempoField.text
            
            if count(input) == 0 {
                let originalValue = Int(60.0 / Double(self.duration))
                self.tempoField.text = String(stringInterpolationSegment: originalValue)
                return
            }
            
            var value = input.toInt()
            self.setTempo(value!)
        }
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if textField == self.timeSigField {
            self.delegate?.timeFieldDidBeginEditing!(self)
        } else if textField == self.tempoField {
            self.delegate?.tempoFieldDidBeginEditing!(self)
        }
    }

    // Picker View Delegate
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        var value = timeSignatureArray[row]
        if value == "None" {
            self.timeSignature[0] = 1
            self.timeSignature[1] = 4
            self.timeSigField.text = "None"
        } else {
            var valSplit = split(value) {$0 == "/"}
            self.timeSignature[0] = valSplit[0].toInt()!
            self.timeSignature[1] = valSplit[1].toInt()!
            self.timeSigField.text = value
        }
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return timeSignatureArray[row]
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return timeSignatureArray.count
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // Metronome functions
    func toggle(sender: AnyObject?) {
        if sender != nil {
            self.wasManuallyTriggered = true
        }
        if !self.muted {
            if !self.isPlaying {
                self.start()
            } else {
                self.stop()
            }
        }
    }
    
    func start() {
        self.soundPlayerThread = NSThread(target: self, selector: "startDriverTimer:", object: nil)
        self.soundPlayerThread!.start()
        self.isPlaying = true
        /*self.timer = CADisplayLink(target: self, selector: "playSound")
        self.timer!.frameInterval = 30
        self.timer!.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)*/
    }
    
    func stop() {
        self.wasManuallyTriggered = false
        self.soundPlayerThread!.cancel()
        self.finishDriverThread()
        self.soundPlayerThread = nil
        self.isPlaying = false
        self.beat = 0
    }
    
    func startDriverTimer(sender: AnyObject?) {
        NSThread.setThreadPriority(1.0)
        var continuePlaying: Bool = true
        
        while (continuePlaying) {
            let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
            dispatch_async(dispatch_get_global_queue(priority, 0)) {
                self.playSound()
            }
            var curtainTime: NSDate = NSDate(timeIntervalSinceNow: NSTimeInterval(self.duration))
            var currentTime: NSDate = NSDate()
            
            while (continuePlaying && currentTime.compare(curtainTime) != NSComparisonResult.OrderedDescending) {
                if (self.soundPlayerThread == nil || self.soundPlayerThread!.cancelled) {
                    continuePlaying = false
                }
                currentTime = NSDate()
            }
        }
    }
    
    func playSound() {
        if !self.wasManuallyTriggered {
            dispatch_async(dispatch_get_main_queue()) {
                self.delegate?.tick!(self)
            }
        }
        if self.beat == 0 {
            self.tickPlayer.stop()
            self.tickPlayer.currentTime = 0
            self.tickPlayer.play()
            self.beat += 1
        } else if self.beat == self.timeSignature[0] - 1 {
            self.tockPlayer.stop()
            self.tockPlayer.currentTime = 0
            self.tockPlayer.play()
            self.beat = 0
        } else {
            self.tockPlayer.stop()
            self.tockPlayer.currentTime = 0
            self.tockPlayer.play()
            self.beat += 1
        }
    }
    
    func finishDriverThread() {
        while self.soundPlayerThread != nil && !self.soundPlayerThread!.finished {
            NSThread.sleepForTimeInterval(0.1)
        }
    }
    
    // Auxiliary
    func setTempo(input: Int) {
        var value = input
        if value < 40 {
            value = 40
        } else if value > 220 {
            value = 220
        }
        self.tempoField.text = "\(value)"
        self.tempoSlider.value = Float(value)
        self.duration = CGFloat(60.0 / Double(value))
    }
    
}
