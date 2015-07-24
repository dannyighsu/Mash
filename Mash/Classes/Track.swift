//
//  Track.swift
//  Mash-iOS
//
//  Created by Danny Hsu on 2/28/15.
//  Copyright (c) 2015 Mash. All rights reserved.
//

import Foundation
import UIKit
import EZAudio

class Track: UITableViewCell, EZAudioFileDelegate {
    
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var instrumentImage: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var audioPlot: EZAudioPlot!
    @IBOutlet weak var staticAudioPlot: UIImageView!
    var instruments: [String] = []
    var instrumentFamilies: [String] = []
    var titleText: String = ""
    var userText: String = ""
    var trackURL: String = ""
    var bpm: Int = 0
    var format: String = ""
    var audioFile: EZAudioFile? = nil
    
    convenience init(frame: CGRect, instruments: [String], titleText: String) {
        self.init(frame: frame)
        self.instruments = instruments
        self.titleText = titleText
    }
    
    convenience init(frame: CGRect, instruments: [String], titleText: String, bpm: Int) {
        self.init(frame: frame)
        self.instruments = instruments
        self.titleText = titleText
        self.bpm = bpm
    }

    convenience init(frame: CGRect, instruments: [String], instrumentFamilies: [String], titleText: String, bpm: Int, trackURL: String, user: String, format: String) {
        self.init(frame: frame)
        self.instruments = instruments
        self.instrumentFamilies = instrumentFamilies
        self.titleText = titleText
        self.trackURL = trackURL
        self.bpm = bpm
        self.userText = user
        self.format = format
    }
    
    func generateWaveform() {
        self.staticAudioPlot.hidden = true
        self.audioPlot.color = lightBlue()
        self.audioFile = EZAudioFile(URL: NSURL(fileURLWithPath: self.trackURL), delegate: self)
        self.audioPlot.plotType = .Buffer
        self.audioPlot.shouldFill = true
        self.audioPlot.shouldMirror = true
        self.audioPlot.gain = 2.0
        var data = self.audioFile!.getWaveformData()
        self.audioPlot.updateBuffer(data.buffers[0], withBufferSize: data.bufferSize)
    }

}
