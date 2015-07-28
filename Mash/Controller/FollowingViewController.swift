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
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = self.users.dequeueReusableCellWithIdentifier("User") as! User
        var follower = self.data[indexPath.row]
        cell.nameLabel?.setTitle(follower.display_name(), forState: UIControlState.Normal)
        cell.handle = follower.handle
        cell.username = follower.username
        cell.profile_pic_link = follower.profile_pic_link
        follower.profile_pic(cell.profilePicture!)
        cell.profilePicture?.layer.cornerRadius = cell.profilePicture!.frame.size.width / 2
        cell.profilePicture?.layer.borderWidth = 1.0
        cell.profilePicture?.layer.masksToBounds = true
        var following: Bool = false
        for u in user_following {
            if u.handle! == follower.handle! {
                following = true
            }
        }
        if following {
            cell.followButton.addTarget(self, action: "unfollow:", forControlEvents: UIControlEvents.TouchUpInside)
            cell.followButton.setTitle("Unfollow", forState: UIControlState.Normal)
            cell.followButton.backgroundColor = lightGray()
        } else {
            cell.followButton.addTarget(self, action: "follow:", forControlEvents: UIControlEvents.TouchUpInside)
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        User.getUser(tableView.cellForRowAtIndexPath(indexPath) as! User, storyboard: self.storyboard!, navigationController: self.navigationController!)
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

    func follow(sender: UIButton) {
        User.followUser(getUserCell(sender), target: self)
    }
    
    func unfollow(sender: UIButton) {
        User.unfollowUser(getUserCell(sender), target: self)
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
        let handle = current_user.handle
        var request = NSMutableURLRequest(URL: NSURL(string: "\(db)/user/\(type)")!)
        var params = ["handle": handle!, "password_hash": passwordHash, "query_name": user.handle!] as Dictionary
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
                            follower.handle = dict["handle"] as? String
                            follower.username = dict["name"] as? String
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

}
