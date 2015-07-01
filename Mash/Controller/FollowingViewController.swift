//
//  FollowingViewController.swift
//  Mash
//
//  Created by Danny Hsu on 6/30/15.
//  Copyright (c) 2015 Mash. All rights reserved.
//

import Foundation
import UIKit

class FollowingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var users: UITableView!
    var data: [User] = []
    var user: User = current_user
    var type: String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let user = UINib(nibName: "User", bundle: nil)
        self.users.registerNib(user, forCellReuseIdentifier: "User")
        self.users.delegate = self
        self.users.dataSource = self
        self.getUserFollowing(self.user, type: self.type!)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBarHidden = false
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = self.users.dequeueReusableCellWithIdentifier("User") as! User
        var follower = self.data[indexPath.row]
        cell.nameLabel?.setTitle(follower.display_name(), forState: UIControlState.Normal)
        cell.username = follower.username
        cell.altname = follower.altname
        cell.profile_pic_link = follower.profile_pic_link
        cell.profilePicture?.image = follower.profile_pic()
        cell.profilePicture?.layer.cornerRadius = cell.imageView!.frame.size.width / 2
        cell.profilePicture?.layer.borderWidth = 1.0
        cell.profilePicture?.layer.masksToBounds = true
        var following: Bool = false
        for u in user_following {
            if u.username! == follower.username! {
                following = true
            }
        }
        if following {
            cell.followButton.addTarget(self, action: "unfollow:", forControlEvents: UIControlEvents.TouchDown)
            cell.followButton.setTitle("Unfollow", forState: UIControlState.Normal)
            cell.followButton.backgroundColor = lightGray()
        } else {
            cell.followButton.addTarget(self, action: "follow:", forControlEvents: UIControlEvents.TouchDown)
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.getUser(tableView.cellForRowAtIndexPath(indexPath) as! User)
        tableView.cellForRowAtIndexPath(indexPath)!.selected = false
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 75.0
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        self.navigationController?.navigationBarHidden = true
    }

    func follow(sender: UIButton) {
        followUser(getUserCell(sender), self)
    }
    
    func unfollow(sender: UIButton) {
        unfollowUser(getUserCell(sender), self)
    }
    
    func getUserCell(input: UIButton) -> User {
        if input.superview as? User != nil {
            return input.superview as! User
        } else if input.superview!.superview as? User != nil {
            return input.superview!.superview as! User
        } else {
            return input.superview!.superview!.superview as! User
        }
    }
    
    func getUserFollowing(user: User, type: String) {
        let passwordHash = hashPassword(keychainWrapper.myObjectForKey("v_Data") as! String)
        let username = current_user.username
        var request = NSMutableURLRequest(URL: NSURL(string: "\(db)/user/\(type)")!)
        var params = ["username": username!, "password_hash": passwordHash, "query_name": user.username!] as Dictionary
        httpPost(params, request) {
            (data, statusCode, error) -> Void in
            if error != nil {
                Debug.printl("Error: \(error)", sender: self)
            } else {
                // Check status codes
                if statusCode == HTTP_ERROR {
                    Debug.printl("HTTP Error: \(error)", sender: self)
                } else if statusCode == HTTP_WRONG_MEDIA {
                    
                } else if statusCode == HTTP_SUCCESS_WITH_MESSAGE {
                    dispatch_async(dispatch_get_main_queue()) {
                        var error: NSError? = nil
                        var data = NSJSONSerialization.JSONObjectWithData(data.dataUsingEncoding(NSUTF8StringEncoding)!, options: NSJSONReadingOptions.AllowFragments, error: &error) as! NSDictionary
                        
                        var users = data[type] as! NSArray
                        for u in users {
                            var dict = u as! NSDictionary
                            var follower = User()
                            follower.username = dict["username"] as? String
                            follower.altname = dict["display_name"] as? String
                            follower.profile_pic_link = dict["profile_pic_link"] as? String
                            self.data.append(follower)
                        }
                        self.users.reloadData()
                    }
                } else if statusCode == HTTP_SERVER_ERROR {
                    Debug.printl("Internal server error.", sender: self)
                } else {
                    Debug.printl("Unrecognized status code from server: \(statusCode)", sender: self)
                }
            }
        }
    }
    
    // Make get request for user and instantiate dashboard
    func getUser(input: User) {
        let passwordHash = hashPassword(keychainWrapper.myObjectForKey("v_Data") as! String)
        let username = current_user.username
        var request = NSMutableURLRequest(URL: NSURL(string: "\(db)/retrieve/user")!)
        var params = ["username": username!, "password_hash": passwordHash, "userid": "\(current_user.userid!)", "query_name": input.username!] as Dictionary
        println(current_user.userid)
        httpPost(params, request) {
            (data, statusCode, error) -> Void in
            if error != nil {
                Debug.printl("Error: \(error)", sender: self)
            } else {
                // Check status codes
                if statusCode == HTTP_ERROR {
                    Debug.printl("HTTP Error: \(error)", sender: self)
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
                        
                        let controller = self.storyboard?.instantiateViewControllerWithIdentifier("DashboardController") as! DashboardController
                        controller.user = input
                        self.navigationController?.pushViewController(controller, animated: true)
                    }
                } else if statusCode == HTTP_SERVER_ERROR {
                    Debug.printl("Internal server error.", sender: self)
                } else {
                    Debug.printl("Unrecognized status code from server: \(statusCode)", sender: self)
                }
            }
        }
    }

}
