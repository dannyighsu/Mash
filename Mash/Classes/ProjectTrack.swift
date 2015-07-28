//
//  ProjectTrack.swift
//  Mash-iOS
//
//  Created by Danny Hsu on 4/8/15.
//  Copyright (c) 2015 Mash. All rights reserved.
//

import Foundation
import UIKit
import EZAudio

class ProjectTrack: UITableViewCell, EZAudioFileDelegate {
    
    @IBOutlet weak var trackTitle: UILabel!
    @IBOutlet weak var speakerImage: UIImageView!
    @IBOutlet weak var instrumentImage: UIImageView!
    @IBOutlet weak var audioPlot: EZAudioPlot!
    @IBOutlet weak var staticAudioPlot: UIImageView!
    var audioFile: EZAudioFile? = nil
    var track: Track?
    
    convenience init(frame: CGRect, track: Track) {
        self.init(frame: frame)
        self.track = track
        self.trackTitle.text = track.titleText
        self.instrumentImage.image = findImage(track.instruments)
    }
    
    func generateWaveform() {
        self.staticAudioPlot.hidden = true
        self.audioPlot.color = UIColor.blackColor()
        self.audioFile = EZAudioFile(URL: NSURL(fileURLWithPath: self.track!.trackURL), delegate: self)
        self.audioPlot.plotType = .Buffer
        self.audioPlot.shouldFill = true
        self.audioPlot.shouldMirror = true
        self.audioPlot.gain = 2.0
        var data = self.audioFile!.getWaveformData()
        self.audioPlot.updateBuffer(data.buffers[0], withBufferSize: data.bufferSize)
    }

}
