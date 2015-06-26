//
//  ProjectTrack.swift
//  Mash-iOS
//
//  Created by Danny Hsu on 4/8/15.
//  Copyright (c) 2015 Mash. All rights reserved.
//

import Foundation
import UIKit

class ProjectTrack: UITableViewCell{
    
    @IBOutlet weak var trackTitle: UILabel!
    @IBOutlet weak var speakerImage: UIImageView!
    @IBOutlet weak var instrumentImage: UIImageView!
    var track: Track?
    
    convenience init(frame: CGRect, track: Track) {
        self.init(frame: frame)
        self.track = track
        self.trackTitle = track.title
        self.instrumentImage.image = findImage(track.instruments)
    }

}
