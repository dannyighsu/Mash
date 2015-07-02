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
    var userid: Int? = nil
    
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
            // Replace this once photo upload/download is implemented
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
func followUser(user: User, controller: UIViewController) {
    let passwordHash = hashPassword(keychainWrapper.myObjectForKey("v_Data") as! String)
    let username = current_user.username
    var request = NSMutableURLRequest(URL: NSURL(string: "\(db)/follow/user")!)
    var params = ["username": username!, "password_hash": passwordHash, "following_name": user.username!] as Dictionary
    httpPost(params, request) {
        (data, statusCode, error) -> Void in
        if error != nil {
            Debug.printl("Error: \(error)", sender: "helper")
        } else {
            // Check status codes
            if statusCode == HTTP_ERROR {
                Debug.printl("HTTP Error: \(error)", sender: "helper")
            } else if statusCode == HTTP_WRONG_MEDIA {
                
            } else if statusCode == HTTP_SUCCESS {
                dispatch_async(dispatch_get_main_queue()) {
                    user_following.append(user)
                    user.followButton.setTitle("Unfollow", forState: UIControlState.Normal)
                    user.followButton.backgroundColor = lightGray()
                    user.followButton.removeTarget(controller, action: "follow:", forControlEvents: UIControlEvents.TouchDown)
                    user.followButton.addTarget(controller, action: "unfollow:", forControlEvents: UIControlEvents.TouchDown)
                }
            } else if statusCode == HTTP_SERVER_ERROR {
                Debug.printl("Internal server error.", sender: "helper")
            } else {
                Debug.printl("Unrecognized status code from server: \(statusCode)", sender: "helper")
            }
        }
    }
}

func unfollowUser(user: User, controller: UIViewController) {
    let passwordHash = hashPassword(keychainWrapper.myObjectForKey("v_Data") as! String)
    let username = current_user.username
    var request = NSMutableURLRequest(URL: NSURL(string: "\(db)/unfollow/user")!)
    var params = ["username": username!, "password_hash": passwordHash, "following_name": user.username!] as Dictionary
    httpPost(params, request) {
        (data, statusCode, error) -> Void in
        if error != nil {
            Debug.printl("Error: \(error)", sender: "helper")
        } else {
            // Check status codes
            if statusCode == HTTP_ERROR {
                Debug.printl("HTTP Error: \(error)", sender: "helper")
            } else if statusCode == HTTP_WRONG_MEDIA {
                
            } else if statusCode == HTTP_SUCCESS {
                dispatch_async(dispatch_get_main_queue()) {
                    for (var i = 0; i < user_following.count; i++) {
                        if user_following[i].username == user.username {
                            user_following.removeAtIndex(i)
                        }
                    }
                    user.followButton.setTitle("Follow", forState: UIControlState.Normal)
                    user.followButton.backgroundColor = lightBlue()
                    user.followButton.removeTarget(controller, action: "unfollow:", forControlEvents: UIControlEvents.TouchDown)
                    user.followButton.addTarget(controller, action: "follow:", forControlEvents: UIControlEvents.TouchDown)
                }
            } else if statusCode == HTTP_SERVER_ERROR {
                Debug.printl("Internal server error.", sender: "helper")
            } else {
                Debug.printl("Unrecognized status code from server: \(statusCode)", sender: "helper")
            }
        }
    }
}
