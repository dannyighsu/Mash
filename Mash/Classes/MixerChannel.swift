//
//  MixerChannel.swift
//  Mash
//
//  Created by Danny Hsu on 7/27/15.
//  Copyright (c) 2015 Mash. All rights reserved.
//

import Foundation
import UIKit

protocol MixerChannelDelegate {
    func volumeSliderDidChange(channel: MixerChannel, value: Float, trackNumber: Int)
}

class MixerChannel: UITableViewCell {
    
    @IBOutlet weak var muteButton: UIButton!
    @IBOutlet weak var volumeSlider: UISlider!
    var delegate: MixerChannelDelegate? = nil
    
    // NOTE: Set track number when instantiating
    var trackNumber: Int = 0
    
    @IBAction func volumeSliderDidChange(sender: UISlider) {
        self.delegate?.volumeSliderDidChange(self, value: sender.value, trackNumber: self.trackNumber)
    }

}
