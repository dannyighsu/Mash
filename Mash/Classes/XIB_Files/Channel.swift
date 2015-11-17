//
//  Channel.swift
//  Mash-iOS
//
//  Created by Danny Hsu on 4/8/15.
//  Copyright (c) 2015 Mash. All rights reserved.
//

import Foundation
import UIKit

protocol ChannelDelegate {
    func channelVolumeDidChange(channel: Channel, number: Int, value: Float)
}

class Channel: UITableViewCell, EZAudioFileDelegate {
    
    @IBOutlet weak var trackTitle: UILabel!
    @IBOutlet weak var instrumentImage: UIImageView!
    @IBOutlet weak var audioPlot: EZAudioPlot!
    @IBOutlet weak var staticAudioPlot: UIImageView!
    @IBOutlet weak var optionsExtension: UIView!
    @IBOutlet weak var volumeSlider: UISlider!
    @IBOutlet weak var content: UIView!
    var audioFile: EZAudioFile? = nil
    var track: Track?
    var trackNumber: Int? = nil
    var delegate: ChannelDelegate? = nil
    
    convenience init(frame: CGRect, track: Track, trackNumber: Int, delegate: ChannelDelegate) {
        self.init(frame: frame)
        self.track = track
        self.trackTitle.text = track.titleText
        self.instrumentImage.image = findImage(track.instruments)
        self.trackNumber = trackNumber
    }
    
    func generateWaveform() {
        self.staticAudioPlot.hidden = true
        self.audioFile = EZAudioFile(URL: NSURL(fileURLWithPath: self.track!.trackURL), delegate: self)
        self.audioPlot.plotType = .Buffer
        self.audioPlot.shouldFill = true
        self.audioPlot.shouldMirror = true
        self.audioPlot.gain = 2.0
        let data = self.audioFile!.getWaveformData()
        self.audioPlot.updateBuffer(data.buffers[0], withBufferSize: data.bufferSize)
    }
    
    @IBAction func volumeDidChange(sender: UISlider) {
        self.delegate?.channelVolumeDidChange(self, number: self.trackNumber!, value: sender.value)
    }

}
