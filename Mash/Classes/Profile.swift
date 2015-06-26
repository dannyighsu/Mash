//
//  Profile.swift
//  Mash-iOS
//
//  Created by Danny Hsu on 2/28/15.
//  Copyright (c) 2015 Mash. All rights reserved.
//

import Foundation
import UIKit

class Profile: UITableViewHeaderFooterView {

    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var trackCount: UILabel!
    @IBOutlet weak var followingCount: UILabel!
    @IBOutlet weak var followerCount: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var bannerImage: UIImageView!
    @IBOutlet weak var editButton: UIButton!

    /*override init(frame: CGRect) {
        super.init(frame: frame)
        self.initialize()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initialize()
    } */

}
