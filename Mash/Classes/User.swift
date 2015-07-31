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
    var handle: String? = nil
    var username: String? = nil
    var profile_pic_link: String? = nil
    var banner_pic_link: String? = nil
    var followers: String? = nil
    var following: String? = nil
    var tracks: String? = nil
    var user_description: String? = nil
    var userid: Int? = nil
    
    convenience init() {
        self.init(frame: CGRectZero)
        self.handle = NSUserDefaults.standardUserDefaults().valueForKey("username") as? String
        self.username = ""
        self.profile_pic_link = ""
        self.banner_pic_link = ""
        self.followers = "0"
        self.following = "0"
        self.tracks = "0"
        self.user_description = ""
    }
    
    convenience init(handle: String?, username: String?, profile_pic_link: String?, banner_pic_link: String?, followers: String?, following: String?, tracks: String?, description: String?) {
        self.init(frame: CGRectZero)
        self.handle = handle
        self.username = username
        self.profile_pic_link = profile_pic_link
        self.banner_pic_link = banner_pic_link
        self.followers = followers
        self.following = following
        self.tracks = tracks
        self.user_description = description
        self.profile_pic(self.profilePicture)
        self.nameLabel.titleLabel?.text = self.display_name()
    }
    
    func display_name() -> String? {
        if count(self.username!) == 0 {
            return self.handle
        }
        return self.username
    }
    
    func profile_pic(imageView: UIImageView) {
        if count(self.profile_pic_link!) == 0 {
            imageView.image = UIImage(named: "no_profile_pic")!
            return
        } else {
            download("\(self.handle!)~~profile_pic.jpg", filePathURL(self.profile_pic_link), profile_bucket) {
                (result) -> Void in
                dispatch_async(dispatch_get_main_queue()) {
                    imageView.image = UIImage(contentsOfFile: filePathString(self.profile_pic_link))!
                }
            }
        }
    }
    
    func banner_pic(imageView: UIImageView) {
        if count(self.banner_pic_link!) == 0 {
            imageView.image = UIImage(named: "no_banner")!
            return
        } else {
            download("\(self.handle!)~~banner.jpg", filePathURL(self.banner_pic_link), banner_bucket) {
                (result) -> Void in
                dispatch_async(dispatch_get_main_queue()) {
                    imageView.image = UIImage(contentsOfFile: filePathString(self.banner_pic_link))!
                }
            }
        }
    }
    
    // Update all displays of the view
    func updateDisplays() {
        self.nameLabel.setTitle(self.display_name(), forState: UIControlState.Normal)
        var following = false
        for u in user_following {
            if u.handle! == self.handle {
                following = true
                break
            }
        }
        if following {
            self.followButton.addTarget(self, action: "unfollow:", forControlEvents: UIControlEvents.TouchUpInside)
            self.followButton.setTitle("Unfollow", forState: UIControlState.Normal)
            self.followButton.backgroundColor = lightGray()
        } else {
            self.followButton.addTarget(self, action: "follow:", forControlEvents: UIControlEvents.TouchUpInside)
        }
        self.profile_pic(self.profilePicture)
        self.profilePicture?.layer.cornerRadius = self.profilePicture!.frame.size.width / 2
        self.profilePicture?.layer.borderWidth = 1.0
        self.profilePicture?.layer.masksToBounds = true
    }
    
    func follow(sender: AnyObject?) {
        User.followUser(self, target: self)
    }
    
    func unfollow(sender: AnyObject?) {
        User.unfollowUser(self, target: self)
    }
    
    // User-related Helper Functions

    // Make get request for user and instantiate dashboard
    class func getUser(input: User, storyboard: UIStoryboard, navigationController: UINavigationController) {
        let passwordHash = hashPassword(keychainWrapper.myObjectForKey("v_Data") as! String)
        let handle = current_user.handle
        var request = NSMutableURLRequest(URL: NSURL(string: "\(db)/retrieve/user")!)
        var params = ["handle": handle!, "password_hash": passwordHash, "userid": "\(current_user.userid!)", "query_name": input.handle!] as Dictionary
        httpPost(params, request) {
            (data, statusCode, error) -> Void in
            if error != nil {
                Debug.printl("Error: \(error)", sender: nil)
            } else {
                // Check status codes
                if statusCode == HTTP_ERROR {
                    Debug.printl("HTTP Error: \(error)", sender: nil)
                } else if statusCode == HTTP_WRONG_MEDIA {
                    
                } else if statusCode == HTTP_SUCCESS_WITH_MESSAGE {
                    dispatch_async(dispatch_get_main_queue()) {
                        var error: NSError? = nil
                        var data = NSJSONSerialization.JSONObjectWithData(data.dataUsingEncoding(NSUTF8StringEncoding)!, options: NSJSONReadingOptions.AllowFragments, error: &error) as! NSDictionary
                        
                        var dict = data["user"] as! NSDictionary
                        input.handle = dict["handle"] as? String
                        input.username = dict["name"] as? String
                        input.banner_pic_link = dict["banner_pic_link"] as? String
                        input.profile_pic_link = dict["profile_pic_link"] as? String
                        input.user_description = dict["description"] as? String
                        input.followers = String(dict["followers"] as! Int)
                        input.following = String(dict["following"] as! Int)
                        input.tracks = String(dict["track_count"] as! Int)

                        let controller = storyboard.instantiateViewControllerWithIdentifier("DashboardController") as! DashboardController
                        controller.user = input
                        navigationController.pushViewController(controller, animated: true)
                    }
                } else if statusCode == HTTP_SERVER_ERROR {
                    Debug.printl("Internal server error.", sender: nil)
                } else {
                    Debug.printl("Unrecognized status code from server: \(statusCode)", sender: nil)
                }
            }
        }
    }
    
    class func updateSelf(controller: DashboardController?) {
        let passwordHash = hashPassword(keychainWrapper.myObjectForKey("v_Data") as! String)
        let handle = current_user.handle
        var request = NSMutableURLRequest(URL: NSURL(string: "\(db)/retrieve/user")!)
        var params = ["handle": handle!, "password_hash": passwordHash, "userid": "\(current_user.userid!)", "query_name": "\(current_user.handle!)"] as Dictionary
        httpPost(params, request) {
            (data, statusCode, error) -> Void in
            if error != nil {
                Debug.printl("Error: \(error)", sender: nil)
            } else {
                // Check status codes
                if statusCode == HTTP_ERROR {
                    Debug.printl("HTTP Error: \(error)", sender: nil)
                } else if statusCode == HTTP_WRONG_MEDIA {
                    
                } else if statusCode == HTTP_SUCCESS_WITH_MESSAGE {
                    dispatch_async(dispatch_get_main_queue()) {
                        var error: NSError? = nil
                        var data = NSJSONSerialization.JSONObjectWithData(data.dataUsingEncoding(NSUTF8StringEncoding)!, options: NSJSONReadingOptions.AllowFragments, error: &error) as! NSDictionary
                        
                        var dict = data["user"] as! NSDictionary
                        current_user.handle = dict["handle"] as? String
                        current_user.username = dict["name"] as? String
                        current_user.banner_pic_link = dict["banner_pic_link"] as? String
                        current_user.profile_pic_link = dict["profile_pic_link"] as? String
                        current_user.user_description = dict["description"] as? String
                        current_user.followers = String(dict["followers"] as! Int)
                        current_user.following = String(dict["following"] as! Int)
                        current_user.tracks = String(dict["track_count"] as! Int)
                        
                        if controller != nil {
                            controller!.parentViewController?.navigationItem.title! = current_user.display_name()!
                            let profile = controller!.tracks.headerViewForSection(0) as! Profile
                            current_user.profile_pic(profile.profilePic)
                            current_user.banner_pic(profile.bannerImage)
                            profile.descriptionLabel.text = current_user.user_description
                            var followers = NSMutableAttributedString(string: "  \(current_user.followers!)\n  FOLLOWERS")
                            profile.followerCount.attributedText = followers
                            var following = NSMutableAttributedString(string: "  \(current_user.following!)\n  FOLLOWING")
                            profile.followingCount.attributedText = following
                            var tracks = NSMutableAttributedString(string: "  \(current_user.tracks!)\n  TRACKS")
                            profile.trackCount.attributedText = tracks
                        }
                    }
                } else if statusCode == HTTP_SERVER_ERROR {
                    Debug.printl("Internal server error.", sender: nil)
                } else {
                    Debug.printl("Unrecognized status code from server: \(statusCode)", sender: nil)
                }
            }
        }
    }
    
    class func followUser(user: User, target: AnyObject) {
        let passwordHash = hashPassword(keychainWrapper.myObjectForKey("v_Data") as! String)
        let handle = current_user.handle
        var request = NSMutableURLRequest(URL: NSURL(string: "\(db)/follow/user")!)
        var params = ["handle": handle!, "password_hash": passwordHash, "following_name": user.handle!] as Dictionary
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
                        user.followButton.removeTarget(target, action: "follow:", forControlEvents: UIControlEvents.TouchDown)
                        user.followButton.addTarget(target, action: "unfollow:", forControlEvents: UIControlEvents.TouchDown)
                    }
                } else if statusCode == HTTP_SERVER_ERROR {
                    Debug.printl("Internal server error.", sender: "helper")
                } else {
                    Debug.printl("Unrecognized status code from server: \(statusCode)", sender: "helper")
                }
            }
        }
    }
    
    class func unfollowUser(user: User, target: AnyObject) {
        let passwordHash = hashPassword(keychainWrapper.myObjectForKey("v_Data") as! String)
        let handle = current_user.handle
        var request = NSMutableURLRequest(URL: NSURL(string: "\(db)/unfollow/user")!)
        var params = ["handle": handle!, "password_hash": passwordHash, "following_name": user.handle!] as Dictionary
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
                            if user_following[i].handle == user.handle {
                                user_following.removeAtIndex(i)
                            }
                        }
                        user.followButton.setTitle("Follow", forState: UIControlState.Normal)
                        user.followButton.backgroundColor = lightBlue()
                        user.followButton.removeTarget(target, action: "unfollow:", forControlEvents: UIControlEvents.TouchDown)
                        user.followButton.addTarget(target, action: "follow:", forControlEvents: UIControlEvents.TouchDown)
                    }
                } else if statusCode == HTTP_SERVER_ERROR {
                    Debug.printl("Internal server error.", sender: "helper")
                } else {
                    Debug.printl("Unrecognized status code from server: \(statusCode)", sender: "helper")
                }
            }
        }
    }
    
    class func getUsersFollowing() {
        let passwordHash = hashPassword(keychainWrapper.myObjectForKey("v_Data") as! String)
        let handle = current_user.handle
        var request = NSMutableURLRequest(URL: NSURL(string: "\(db)/user/following")!)
        var params = ["handle": handle!, "password_hash": passwordHash, "query_name": current_user.handle!] as Dictionary
        var result: [User] = []
        httpPost(params, request) {
            (data, statusCode, error) -> Void in
            if error != nil {
                Debug.printl("Error: \(error)", sender: "user")
            } else {
                // Check status codes
                if statusCode == HTTP_ERROR {
                    Debug.printl("HTTP Error: \(error)", sender: "user")
                } else if statusCode == HTTP_WRONG_MEDIA {
                    
                } else if statusCode == HTTP_SUCCESS_WITH_MESSAGE {
                    dispatch_async(dispatch_get_main_queue()) {
                        var error: NSError? = nil
                        var data = NSJSONSerialization.JSONObjectWithData(data.dataUsingEncoding(NSUTF8StringEncoding)!, options: NSJSONReadingOptions.AllowFragments, error: &error) as! NSDictionary
                        
                        var users = data["following"] as! NSArray
                        var result: [User] = []
                        for u in users {
                            var dict = u as! NSDictionary
                            var user = User()
                            user.handle = dict["handle"] as? String
                            user.username = dict["name"] as? String
                            user.profile_pic_link = dict["profile_pic_link"] as? String
                            result.append(user)
                        }
                        user_following = result
                    }
                } else if statusCode == HTTP_SERVER_ERROR {
                    Debug.printl("Internal server error.", sender: "user")
                } else {
                    Debug.printl("Unrecognized status code from server: \(statusCode)", sender: "user")
                }
            }
        }
    }
    
}


