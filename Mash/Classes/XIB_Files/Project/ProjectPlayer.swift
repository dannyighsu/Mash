//
//  ProjectPlayer.swift
//  Mash
//
//  Created by Danny Hsu on 7/6/15.
//  Copyright (c) 2015 Mash. All rights reserved.
//

import Foundation
import UIKit

@objc protocol PlayerDelegate {
    optional func showTools()
    optional func showMixer()
    optional func didPressPlay(audioPlayer: ProjectPlayer)
    optional func didStopPlaying(audioPlayer: ProjectPlayer)
    optional func didToggleRecording(audioPlayer: ProjectPlayer)
    optional func tempoLabelDidEndEditing(textField: UITextField)
    func addTracks()
    func toggleMetronome()
}

class ProjectPlayer: UITableViewHeaderFooterView {
    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var volumeSlider: UISlider!
    @IBOutlet weak var tempoLabel: UITextField!
    @IBOutlet weak var toolsButton: UIButton!
    @IBOutlet weak var metronomeButton: UIButton!
    
    var delegate: PlayerDelegate? = nil
    var audioPlayers: [AVAudioPlayer] = []
    var volumes: [Float] = []
    var mutes: [Bool] = []
    var previousVolume: Float = 0.8
    var metronomeToggled: Bool = false
    
    // Button Methods
    @IBAction func playButtonPressed(sender: AnyObject) {
        if self.audioPlayers.count == 0 {
            return
        }
        if !self.audioPlayers[0].playing {
            self.play()
        } else {
            self.stop()
        }
        self.delegate?.didPressPlay?(self)
    }
    
    @IBAction func recordButtonPressed(sender: AnyObject) {
        self.delegate?.didToggleRecording?(self)
    }
    
    /*@IBAction func addButtonPressed(sender: AnyObject) {
        self.delegate?.addTracks()
    }*/
    
    /*@IBAction func stopButtonPressed(sender: AnyObject) {
        self.stop()
        self.delegate?.didStopPlaying?(self)
    }*/
    
    @IBAction func tempoLabelEdited(sender: AnyObject) {
        let textField = sender as! UITextField
        self.delegate?.tempoLabelDidEndEditing!(textField)
    }
    
    @IBAction func toolsButtonPressed(sender: AnyObject) {
        self.delegate?.showTools!()
    }
    
    @IBAction func mixerButtonPressed(sender: AnyObject) {
        self.delegate?.showMixer!()
    }
    
    @IBAction func metronomeButtonPressed(sender: AnyObject) {
        if !self.metronomeToggled {
            self.metronomeButton.setImage(UIImage(named: "metronome"), forState: UIControlState.Normal)
            self.metronomeToggled = true
        } else {
            self.metronomeButton.setImage(UIImage(named: "metronome_2"), forState: UIControlState.Normal)
            self.metronomeToggled = false
        }
        self.delegate?.toggleMetronome()
    }
    
    func play() {
        for (var i = 0; i < self.audioPlayers.count; i++) {
            self.audioPlayers[i].play()
        }
        self.playButton.setImage(UIImage(named: "Pause"), forState: UIControlState.Normal)
    }
    
    func pause() {
        for (var i = 0; i < self.audioPlayers.count; i++) {
            self.audioPlayers[i].pause()
        }
        self.playButton.setImage(UIImage(named: "Play"), forState: UIControlState.Normal)
    }
    
    func stop() {
        for (var i = 0; i < self.audioPlayers.count; i++) {
            self.audioPlayers[i].stop()
            self.audioPlayers[i].currentTime = 0
            self.playButton.setImage(UIImage(named: "Play"), forState: UIControlState.Normal)
        }
    }
    
    // Volume controls
    @IBAction func volumeDidChange(sender: UISlider) {
        if self.audioPlayers.count != 0 {
            for i in 0...self.audioPlayers.count - 1 {
                if !self.mutes[i] {
                    self.audioPlayers[i].volume = sender.value
                }
            }
        }
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
    
    // Mute track. Returns true if now muted.
    func muteTrack(number: Int) -> Bool {
        let player = self.audioPlayers[number]
        let muted = self.mutes[number]
        if muted {
            player.volume = self.volumes[number]
        } else {
            self.volumes[number] = player.volume
            player.volume = 0
        }
        self.mutes[number] = !muted
        return !muted
    }
    
    // Auxiliary
    func addTrack(trackURL: String) {
        var error: NSError? = nil
        let player: AVAudioPlayer!
        do {
            player = try AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: trackURL))
        } catch let error1 as NSError {
            error = error1
            player = nil
        }
        if player == nil {
            Debug.printl("Error playing file: \(error)", sender: "helpers")
            return
        }
        player.numberOfLoops = -1
        self.audioPlayers.append(player)
        self.volumes.append(0.8)
        self.mutes.append(false)
    }
    
    func resetPlayers() {
        if self.audioPlayers.count > 0 {
            for i in 0...self.audioPlayers.count - 1 {
                self.audioPlayers[i] = try! AVAudioPlayer(contentsOfURL: self.audioPlayers[i].url!)
            }
        }
    }
}
