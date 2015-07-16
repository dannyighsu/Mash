//
//  ProjectPlayer.swift
//  Mash
//
//  Created by Danny Hsu on 7/6/15.
//  Copyright (c) 2015 Mash. All rights reserved.
//

import Foundation
import UIKit

protocol PlayerDelegate {
}

class ProjectPlayer: UITableViewCell {
    
    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var volumeSlider: UISlider!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var speakerImage: UIButton!

    var delegate: PlayerDelegate? = nil
    var audioPlayers: [AVAudioPlayer] = []
    var volumes: [Float] = []
    var mutes: [Bool] = []
    var previousVolume: Float = 0.8
    
    // Button Methods
    @IBAction func playButtonPressed(sender: AnyObject) {
        if self.audioPlayers.count == 0 {
            return
        }
        if !self.audioPlayers[0].playing {
            self.play()
        } else {
            self.pause()
        }
    }
    
    @IBAction func stopButtonpressed(sender: AnyObject) {
        self.stop()
    }
    
    @IBAction func muteButtonPressed(sender: AnyObject) {
        self.muteAudio(sender)
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
        for i in 0...self.audioPlayers.count - 1 {
            if !self.mutes[i] {
                self.audioPlayers[i].volume = sender.value
            }
        }
        if sender.value == 0 {
            self.speakerImage.setImage(UIImage(named: "speaker_white_2"), forState: UIControlState.Normal)
        } else {
            self.speakerImage.setImage(UIImage(named: "speaker_white"), forState: UIControlState.Normal)
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
    
    // Returns true if now muted
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
        let player = AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: trackURL), error: &error)
        if player == nil {
            Debug.printl("Error playing file: \(error)", sender: "helpers")
            return
        }
        player.numberOfLoops = -1
        self.audioPlayers.append(player)
        self.volumes.append(0.8)
        self.mutes.append(false)
    }

}
