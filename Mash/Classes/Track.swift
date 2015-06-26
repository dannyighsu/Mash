//
//  Track.swift
//  Mash-iOS
//
//  Created by Danny Hsu on 2/28/15.
//  Copyright (c) 2015 Mash. All rights reserved.
//

import Foundation
import UIKit

class Track: UITableViewCell{
    
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var instrumentImage: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var userLabel: UILabel!
    var instruments: [String] = []
    var instrumentFamilies: [String] = []
    var titleText: String = ""
    var userText: String = ""
    var trackURL: String = ""
    var bpm: Int = 0
    var format: String = ""
    
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

    convenience init(frame: CGRect, instruments: [String], titleText: String, bpm: Int, trackURL: String, user: String, format: String) {
        self.init(frame: frame)
        self.instruments = instruments
        self.titleText = titleText
        self.trackURL = trackURL
        self.bpm = bpm
        self.userText = user
        self.format = format
    }

}
