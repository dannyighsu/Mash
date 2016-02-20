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
    var followers: String? = nil
    var following: String? = nil
    var tracks: String? = nil
    var userDescription: String? = nil
    var userid: Int? = nil
    var loginToken: String? = nil
    
    convenience init() {
        self.init(frame: CGRectZero)
        self.handle = NSUserDefaults.standardUserDefaults().valueForKey("username") as? String
        self.username = ""
        self.followers = "0"
        self.following = "0"
        self.tracks = "0"
        self.userDescription = ""
    }
    
    convenience init(handle: String?, username: String?, followers: String?, following: String?, tracks: String?, description: String?) {
        self.init(frame: CGRectZero)
        self.handle = handle
        self.username = username
        self.followers = followers
        self.following = following
        self.tracks = tracks
        self.userDescription = description
        self.nameLabel.titleLabel?.text = self.display_name()
    }
    
    func display_name() -> String? {
        if (self.username!).characters.count == 0 {
            return self.handle
        }
        return self.username
    }
    
    func setProfilePic(imageView: UIImageView) {
        download("\(self.userid!)~~profile_pic.jpg", url: filePathURL("\(self.userid!)~~profile_pic.jpg"), bucket: profile_bucket) {
            (result) -> Void in
            if result != nil {
                dispatch_async(dispatch_get_main_queue()) {
                    imageView.image = UIImage(contentsOfFile: filePathString("\(self.userid!)~~profile_pic.jpg"))!
                }
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    imageView.image = UIImage(named: "no_profile_pic")
                }
            }
        }
    }
    
    func setBannerPic(imageView: UIImageView) {
        download("\(self.userid!)~~banner.jpg", url: filePathURL("\(self.userid!)~~banner.jpg"), bucket: banner_bucket) {
            (result) -> Void in
            if result != nil {
                dispatch_async(dispatch_get_main_queue()) {
                    imageView.image = UIImage(contentsOfFile: filePathString("\(self.userid!)~~banner.jpg"))!
                }
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    imageView.image = UIImage(named: "no_banner")
                }
            }
        }
    }
    
    // Update all displays of the view
    // @TODO: @andy: move this to the UserCellConfigurator
    func updateDisplays(shouldShowFollowButton: Bool) {
        if (shouldShowFollowButton && self.userid != currentUser.userid) {
            var following = false
            for u in userFollowing {
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
        }
        
        if self.nameLabel.titleLabel!.text != self.display_name() {
            self.nameLabel.setTitle(self.display_name(), forState: UIControlState.Normal)
        }
        self.setProfilePic(self.profilePicture)
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
        let request = UserRequest()
        request.userid = UInt32(currentUser.userid!)
        request.loginToken = currentUser.loginToken
        request.queryUserid = UInt32(input.userid!)
        
        server.userGetWithRequest(request) {
            (response, error) in
            if error != nil {
                Debug.printl("Error: \(error)", sender: "user")
            } else {
                input.handle = response.handle
                input.username = response.name
                input.userDescription = response.userDescription
                input.followers = "\(response.followersCount)"
                input.following = "\(response.followingCount)"
                input.tracks = "\(response.trackCount)"
                
                dispatch_async(dispatch_get_main_queue()) {
                    let controller = storyboard.instantiateViewControllerWithIdentifier("DashboardController") as! DashboardController
                    controller.user = input
                    navigationController.pushViewController(controller, animated: true)
                }
            }
        }
        
        /*
        let passwordHash = hashPassword(keychainWrapper.myObjectForKey("v_Data") as! String)
        let handle = currentUser.handle
        var request = NSMutableURLRequest(URL: NSURL(string: "\(db)/retrieve/user")!)
        var params = ["handle": handle!, "password_hash": passwordHash, "userid": "\(currentUser.userid!)", "query_name": input.handle!] as Dictionary
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
                        input.userDescription = dict["description"] as? String
                        input.followers = String(dict["followers"] as! Int)
                        input.following = String(dict["following"] as! Int)
                        input.tracks = String(dict["track_count"] as! Int)
                        input.bannerPicKey = "\(input.handle!)~~banner.jpg"
                        input.profilePicKey = "\(input.handle!)~~profile_pic.jpg"

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
        }*/
    }
    
    class func updateSelf(controller: DashboardController?) {
        let request = UserRequest()
        request.userid = UInt32(currentUser.userid!)
        request.loginToken = currentUser.loginToken
        request.queryUserid = UInt32(currentUser.userid!)
        
        server.userGetWithRequest(request) {
            (response, error) in
            if error != nil {
                Debug.printl("Error: \(error)", sender: "user")
            } else {
                currentUser.handle = response.handle
                currentUser.username = response.name
                currentUser.userDescription = response.userDescription
                currentUser.followers = "\(response.followersCount)"
                currentUser.following = "\(response.followingCount)"
                currentUser.tracks = "\(response.trackCount)"
                
                dispatch_async(dispatch_get_main_queue()) {
                    if controller != nil && controller!.tracks.headerViewForSection(0) != nil {
                        let profile = controller!.tracks.headerViewForSection(0) as! Profile
                        profile.editButton.setTitle(currentUser.display_name()!, forState: .Normal)
                        currentUser.setProfilePic(profile.profilePic)
                        currentUser.setBannerPic(profile.bannerImage)
                        //profile.descriptionLabel.text = currentUser.userDescription
                        let followers = NSMutableAttributedString(string: "    \(currentUser.followers!)\n    FOLLOWERS")
                        profile.followerCount.attributedText = followers
                        let following = NSMutableAttributedString(string: "    \(currentUser.following!)\n    FOLLOWING")
                        profile.followingCount.attributedText = following
                        let tracks = NSMutableAttributedString(string: "    \(currentUser.tracks!)\n    TRACKS")
                        profile.trackCount.attributedText = tracks
                    }
                }
            }
        }
        /*
        let passwordHash = hashPassword(keychainWrapper.myObjectForKey("v_Data") as! String)
        let handle = currentUser.handle
        var request = NSMutableURLRequest(URL: NSURL(string: "\(db)/retrieve/user")!)
        var params = ["handle": handle!, "password_hash": passwordHash, "userid": "\(currentUser.userid!)", "query_name": "\(currentUser.handle!)"] as Dictionary
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
                        currentUser.handle = dict["handle"] as? String
                        currentUser.username = dict["name"] as? String
                        currentUser.userDescription = dict["description"] as? String
                        currentUser.followers = String(dict["followers"] as! Int)
                        currentUser.following = String(dict["following"] as! Int)
                        currentUser.tracks = String(dict["track_count"] as! Int)
                        currentUser.bannerPicKey = "\(currentUser.handle!)~~banner.jpg"
                        currentUser.profilePicKey = "\(currentUser.handle!)~~profile_pic.jpg"
                        
                        if controller != nil {
                            controller!.parentViewController?.navigationItem.title! = currentUser.display_name()!
                            let profile = controller!.tracks.headerViewForSection(0) as! Profile
                            currentUser.setProfilePic(profile.profilePic)
                            currentUser.setBannerPic(profile.bannerImage)
                            profile.descriptionLabel.text = currentUser.userDescription
                            var followers = NSMutableAttributedString(string: "  \(currentUser.followers!)\n  FOLLOWERS")
                            profile.followerCount.attributedText = followers
                            var following = NSMutableAttributedString(string: "  \(currentUser.following!)\n  FOLLOWING")
                            profile.followingCount.attributedText = following
                            var tracks = NSMutableAttributedString(string: "  \(currentUser.tracks!)\n  TRACKS")
                            profile.trackCount.attributedText = tracks
                        }
                    }
                } else if statusCode == HTTP_SERVER_ERROR {
                    Debug.printl("Internal server error.", sender: nil)
                } else {
                    Debug.printl("Unrecognized status code from server: \(statusCode)", sender: nil)
                }
            }
        }*/
    }
    
    class func followUser(user: User, target: AnyObject) {
        let request = UserRequest()
        request.userid = UInt32(currentUser.userid!)
        request.loginToken = currentUser.loginToken
        request.queryUserid = UInt32(user.userid!)
        
        server.userFollowWithRequest(request) {
            (response, error) in
            if error != nil {
                Debug.printl("Error: \(error)", sender: "user")
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    userFollowing.append(user)
                    Debug.printl("Followed user \(user.handle!)", sender: nil)
                    user.followButton.setTitle("Unfollow", forState: UIControlState.Normal)
                    user.followButton.backgroundColor = lightGray()
                    user.followButton.removeTarget(target, action: "follow:", forControlEvents: UIControlEvents.TouchUpInside)
                    user.followButton.addTarget(target, action: "unfollow:", forControlEvents: UIControlEvents.TouchUpInside)
                }
            }
        }
        
        /*
        let passwordHash = hashPassword(keychainWrapper.myObjectForKey("v_Data") as! String)
        let handle = currentUser.handle
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
                        userFollowing.append(user)
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
        }*/
    }
    
    class func unfollowUser(user: User, target: AnyObject) {
        let request = UserRequest()
        request.userid = UInt32(currentUser.userid!)
        request.loginToken = currentUser.loginToken
        request.queryUserid = UInt32(user.userid!)
        
        server.userUnfollowWithRequest(request) {
            (response, error) in
            if error != nil {
                Debug.printl("Error: \(error)", sender: "user")
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    if userFollowing.count != 0 {
                        for i in 0...userFollowing.count - 1 {
                            if user.userid == userFollowing[i].userid {
                                userFollowing.removeAtIndex(i)
                                Debug.printl("Unfollowed user \(user.handle!)", sender: nil)
                            }
                        }
                    }
                    user.followButton.setTitle("Follow", forState: UIControlState.Normal)
                    user.followButton.backgroundColor = lightBlue()
                    user.followButton.removeTarget(target, action: "unfollow:", forControlEvents: UIControlEvents.TouchUpInside)
                    user.followButton.addTarget(target, action: "follow:", forControlEvents: UIControlEvents.TouchUpInside)
                }
            }
        }
    }
    
    class func getUsersFollowing() {
        let request = UserRequest()
        request.userid = UInt32(currentUser.userid!)
        request.loginToken = currentUser.loginToken
        request.queryUserid = UInt32(currentUser.userid!)
        
        server.followingsGetWithRequest(request) {
            (response, error) in
            if error != nil {
                Debug.printl("Error: \(error)", sender: "user")
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    var result: [User] = []
                    for u in response.userArray {
                        let following = u as! UserPreview
                        let user = User()
                        user.handle = following.handle
                        user.username = following.name
                        user.userid = Int(following.userid)
                        result.append(user)
                    }
                    userFollowing = result
                }
            }
        }
        /*
        let passwordHash = hashPassword(keychainWrapper.myObjectForKey("v_Data") as! String)
        let handle = currentUser.handle
        var request = NSMutableURLRequest(URL: NSURL(string: "\(db)/user/following")!)
        var params = ["handle": handle!, "password_hash": passwordHash, "query_name": currentUser.handle!] as Dictionary
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
                            user.profilePicKey = "\(user.handle!)~~profile_pic.jpg"
                            result.append(user)
                        }
                        userFollowing = result
                    }
                } else if statusCode == HTTP_SERVER_ERROR {
                    Debug.printl("Internal server error.", sender: "user")
                } else {
                    Debug.printl("Unrecognized status code from server: \(statusCode)", sender: "user")
                }
            }
        }*/
    }
    
}


