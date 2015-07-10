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
    
    @IBOutlet weak var eventLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    var eventText: String? = nil
    var userText: String? = nil
    var timeText: String? = nil
    
    convenience init(frame: CGRect, eventText: String, userText: String, timeText: String) {
        self.init(frame: frame)
        self.userText = userText
        self.timeText = timeText
        self.eventText = eventText
    }

}