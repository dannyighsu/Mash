//
//  HomeCell.swift
//  Mash-iOS
//
//  Created by Danny Hsu on 2/27/15.
//  Copyright (c) 2015 Mash. All rights reserved.
//

import Foundation
import UIKit

class HomeCell: UITableViewCell {
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var userLabel: UIButton!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    @IBOutlet weak var artistButton: UIButton!
    @IBOutlet weak var trackButton: UIButton!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var audioPlotView: UIImageView!
    @IBOutlet weak var backgroundArt: UIImageView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var playCountLabel: UILabel!
    @IBOutlet weak var likeCountLabel: UILabel!
    var eventText: String? = nil
    var userText: String? = nil
    var timeText: String? = nil
    var user: User? = nil
    var track: Track? = nil
    
    convenience init(frame: CGRect, eventText: String, userText: String, timeText: String, user: User, track: Track) {
        self.init(frame: frame)
        self.userText = userText
        self.timeText = timeText
        self.eventText = eventText
        self.user = user
        self.track = track
    }
}