//
//  User.swift
//  Mash-iOS
//
//  Created by Danny Hsu on 6/23/15.
//  Copyright (c) 2015 Mash. All rights reserved.
//

import Foundation
import UIKit

class User: UITableViewCell {
    
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var nameLabel: UIButton!
    var username: String? = nil
    var altname: String? = nil
    var profile_pic_link: String? = nil
    var banner_pic_link: String? = nil
    var followers: String? = nil
    var following: String? = nil
    var tracks: String? = nil
    var user_description: String? = nil
    
    convenience init() {
        self.init(frame: CGRectZero)
        self.username = NSUserDefaults.standardUserDefaults().valueForKey("username") as? String
        self.altname = ""
        self.followers = "0"
        self.following = "0"
        self.tracks = "0"
        self.user_description = ""
    }
    
    convenience init(username: String?, altname: String?, profile_pic_link: String?, banner_pic_link: String?, followers: String?, following: String?, tracks: String?, description: String?) {
        self.init(frame: CGRectZero)
        self.username = username
        self.altname = altname
        self.profile_pic_link = profile_pic_link
        self.banner_pic_link = banner_pic_link
        self.followers = followers
        self.following = following
        self.tracks = tracks
        self.user_description = description
        self.profilePicture.image = self.profile_pic()
        self.nameLabel.titleLabel?.text = self.display_name()
    }
    
    func display_name() -> String? {
        if count(self.altname!) == 0 {
            return self.username
        }
        return self.altname
    }
    
    func profile_pic() -> UIImage {
        if self.profile_pic_link == nil {
            return UIImage(named: "no_profile_pic")!
        } else if count(self.profile_pic_link!) != 0 {
            return UIImage(contentsOfFile: self.profile_pic_link!)!
        } else {
            return UIImage(named: "no_profile_pic")!
        }
    }
    
    func banner_pic() -> UIImage {
        if self.banner_pic_link == nil {
            return UIImage(named: "no_banner")!
        } else if count(self.banner_pic_link!) != 0 {
            return UIImage(contentsOfFile: self.banner_pic_link!)!
        } else {
            return UIImage(named: "no_banner")!
        }
    }
}

// User-related Helper Functions
func follow(user: User) {
    
}

func unfollow(user: User) {
    
}

func getUserFollowers(user: User) -> [User] {
    var result: [User] = []
    if user == current_user {
        result = user_followers
    }
    return result
}

func getUserFollowing(user:User) -> [User] {
    var result: [User] = []
    if user == current_user {
        result = user_following
    }
    return result
}