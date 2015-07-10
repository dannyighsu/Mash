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
        if count(self.profile_pic_link!) == 0 {
            return UIImage(named: "no_profile_pic")!
        } else {
            download("\(self.username)~~profile_pic.jpg", filePathURL(self.profile_pic_link), profile_bucket)
            while !NSFileManager.defaultManager().fileExistsAtPath(filePathString(self.profile_pic_link)) {
                Debug.printnl("waiting...")
                NSThread.sleepForTimeInterval(0.5)
            }
            NSThread.sleepForTimeInterval(0.5)
            
            return UIImage(contentsOfFile: filePathString(self.profile_pic_link))!
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
    
    // User-related Helper Functions

    // Make get request for user and instantiate dashboard
    class func getUser(input: User, storyboard: UIStoryboard, navigationController: UINavigationController) {
        let passwordHash = hashPassword(keychainWrapper.myObjectForKey("v_Data") as! String)
        let username = current_user.username
        var request = NSMutableURLRequest(URL: NSURL(string: "\(db)/retrieve/user")!)
        var params = ["username": username!, "password_hash": passwordHash, "userid": "\(current_user.userid!)", "query_name": input.username!] as Dictionary
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
                        input.username = dict["username"] as? String
                        input.altname = dict["display_name"] as? String
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
    
    class func updateSelf(controller: DashboardController) {
        let passwordHash = hashPassword(keychainWrapper.myObjectForKey("v_Data") as! String)
        let username = current_user.username
        var request = NSMutableURLRequest(URL: NSURL(string: "\(db)/retrieve/user")!)
        var params = ["username": username!, "password_hash": passwordHash, "userid": "\(current_user.userid!)", "query_name": "\(current_user.username)"] as Dictionary
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
                        current_user.username = dict["username"] as? String
                        current_user.altname = dict["display_name"] as? String
                        current_user.banner_pic_link = dict["banner_pic_link"] as? String
                        current_user.profile_pic_link = dict["profile_pic_link"] as? String
                        current_user.user_description = dict["description"] as? String
                        current_user.followers = String(dict["followers"] as! Int)
                        current_user.following = String(dict["following"] as! Int)
                        current_user.tracks = String(dict["track_count"] as! Int)
                        current_user.user_description = data["description"] as? String
                        
                        controller.parentViewController?.navigationItem.title! = current_user.display_name()!
                        let profile = controller.tracks.headerViewForSection(0) as! Profile
                        profile.profilePic.image = current_user.profile_pic()
                        profile.bannerImage.image = current_user.banner_pic()
                        profile.followerCount.text = current_user.followers
                        profile.followingCount.text = current_user.following
                        profile.descriptionLabel.text = current_user.description
                        profile.trackCount.text = current_user.tracks
                    }
                } else if statusCode == HTTP_SERVER_ERROR {
                    Debug.printl("Internal server error.", sender: nil)
                } else {
                    Debug.printl("Unrecognized status code from server: \(statusCode)", sender: nil)
                }
            }
        }
    }
    
    class func followUser(user: User, controller: UIViewController) {
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
    
    class func unfollowUser(user: User, controller: UIViewController) {
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
    
    class func getUsersFollowing() {
        let passwordHash = hashPassword(keychainWrapper.myObjectForKey("v_Data") as! String)
        let username = current_user.username
        var request = NSMutableURLRequest(URL: NSURL(string: "\(db)/user/following")!)
        var params = ["username": username!, "password_hash": passwordHash, "query_name": current_user.username!] as Dictionary
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
                            user.username = dict["username"] as? String
                            user.altname = dict["display_name"] as? String
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


