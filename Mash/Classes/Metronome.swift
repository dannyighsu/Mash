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

class Metronome: UIView, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var tempoField: UITextField!
    @IBOutlet weak var timeSigField: UITextField!

    var recordController: RecordViewController?
    var duration: CGFloat
    var soundPlayerThread: NSThread?
    var tickPlayer: AVAudioPlayer
    var tockPlayer: AVAudioPlayer
    var timeSignature: [Int]
    var beat: Int
    var isPlaying: Bool
    var muted: Bool
    
    required init(coder aDecoder: NSCoder) {
        self.duration = 0.50
        self.timeSignature = [4, 4]
        self.soundPlayerThread = nil
        self.beat = 0
        self.isPlaying = false
        self.muted = false
        self.recordController = nil
        
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
    class func createView(recordController: RecordViewController) -> Metronome {
        var view = NSBundle.mainBundle().loadNibNamed("Metronome", owner: nil, options: nil)
        let metronome = view[0] as! Metronome
        metronome.recordController = recordController
        metronome.startButton.addTarget(metronome, action: "toggleMetronome:", forControlEvents: UIControlEvents.TouchDown)
        metronome.tempoField.keyboardType = UIKeyboardType.NumberPad
        metronome.tempoField.delegate = metronome
        metronome.timeSigField.delegate = metronome
        metronome.timeSigField.text = "4/4"
        var picker = UIPickerView(frame: recordController.audioPlot.frame)
        picker.delegate = metronome
        picker.dataSource = metronome
        picker.backgroundColor = lightGray()
        metronome.timeSigField.inputView = picker
        metronome.timeSigField.inputAccessoryView = picker
        return metronome
    }

    func textFieldDidEndEditing(textField: UITextField) {
        if textField == self.tempoField {
            var input = self.tempoField.text
            
            if count(input) == 0 {
                let originalValue = Int(60.0 / Double(self.duration))
                self.tempoField.text = String(stringInterpolationSegment: originalValue)
                return
            }
            
            var value = input.toInt()
            if value < 40 {
                value = 40
                self.tempoField.text = "40"
            } else if value > 200 {
                value = 200
                self.tempoField.text = "220"
            }
            
            self.duration = CGFloat(60.0 / Double(value!))
        }
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if textField == self.timeSigField {
            textField.inputView!.center = self.recordController!.view.center
        }
    }

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

    func toggleMetronome(sender: AnyObject?) {
        if !muted {
            if !self.isPlaying {
                self.startDriverThread()
            } else {
                self.stopDriverThread()
            }
        }
    }

    func startDriverTimer(sender: AnyObject?) {
        NSThread.setThreadPriority(1.5)
        var continuePlaying: Bool = true
        
        while (continuePlaying) {
            self.playSound()
            
            var curtainTime: NSDate = NSDate(timeIntervalSinceNow: NSTimeInterval(self.duration))
            var currentTime: NSDate = NSDate()
            
            while (continuePlaying && currentTime.compare(curtainTime) != NSComparisonResult.OrderedDescending) {
                if (self.soundPlayerThread == nil || self.soundPlayerThread!.cancelled) {
                    continuePlaying = false
                }
                NSThread.sleepForTimeInterval(0.01)
                currentTime = NSDate()
            }
        }
    }
    
    func startDriverThread() {
        self.soundPlayerThread = NSThread(target: self, selector: "startDriverTimer:", object: nil)
        self.soundPlayerThread!.start()
        self.isPlaying = true
    }
    
    func stopDriverThread() {
        self.soundPlayerThread!.cancel()
        self.waitForSoundDriverThreadToFinish()
        self.soundPlayerThread = nil
        self.isPlaying = false
        self.beat = 0
    }
    
    func playSound() {
        dispatch_async(dispatch_get_main_queue()) {
            self.recordController?.tick()
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
    
    func waitForSoundDriverThreadToFinish() {
        while self.soundPlayerThread != nil && !self.soundPlayerThread!.finished {
            NSThread.sleepForTimeInterval(0.1)
        }
    }
    
}
