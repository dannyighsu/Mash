//
//  Track.swift
//  Mash-iOS
//
//  Created by Danny Hsu on 2/28/15.
//  Copyright (c) 2015 Mash. All rights reserved.
//

import Foundation
import UIKit

class Track: UITableViewCell, EZAudioFileDelegate {
    
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var instrumentImage: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var userLabel: UIButton!
    @IBOutlet weak var audioPlot: EZAudioPlot!
    @IBOutlet weak var staticAudioPlot: UIImageView!
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    var instruments: [String] = []
    var instrumentFamilies: [String] = []
    var titleText: String = ""
    var userText: String = ""
    var trackURL: String = ""
    var bpm: Int = 0
    var timeSignature: Int = 0
    var format: String = ""
    var id: Int = 0
    var audioFile: EZAudioFile? = nil
    var userid: Int = 0
    var time: String = ""
    var playCount: Int = 0
    var likeCount: Int = 0
    var mashCount: Int = 0
    var liked: Bool = false
    
    convenience init(frame: CGRect, instruments: [String], titleText: String) {
        self.init(frame: frame)
        self.instruments = instruments
        self.titleText = titleText
    }

    convenience init(frame: CGRect, recid: Int, userid: Int, instruments: [String], instrumentFamilies: [String], titleText: String, bpm: Int, timeSignature: Int, trackURL: String, user: String, format: String, time: String, playCount: Int, likeCount: Int, mashCount: Int, liked: Bool) {
        self.init(frame: frame)
        self.instruments = instruments
        self.id = recid
        self.userid = userid
        self.instrumentFamilies = instrumentFamilies
        self.titleText = titleText
        self.trackURL = trackURL
        self.bpm = bpm
        self.timeSignature = timeSignature
        self.userText = user
        self.format = format
        self.time = time
        self.playCount = playCount
        self.likeCount = likeCount
        self.mashCount = mashCount
        self.liked = liked
    }
    
    // Should only be called in the completion block of a download function.
    func generateWaveform() {
        self.staticAudioPlot.hidden = true
        self.audioPlot.color = lightBlue()
        
        // FIXME: figure out why this is called before file finishes download and remove the hacky shit below
        while !NSFileManager.defaultManager().fileExistsAtPath(self.trackURL) {
            NSThread.sleepForTimeInterval(0.1)
        }
        self.audioFile = EZAudioFile(URL: NSURL(fileURLWithPath: self.trackURL), delegate: self)
        self.audioPlot.plotType = .Buffer
        self.audioPlot.shouldFill = true
        self.audioPlot.shouldMirror = true
        self.audioPlot.gain = 2.0
        let data = self.audioFile!.getWaveformData()
        self.audioPlot.updateBuffer(data.buffers[0], withBufferSize: data.bufferSize)
    }

}
