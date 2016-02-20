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
    var userCellConfigurators: [UserCellConfigurator] = []
    var user: User = currentUser
    var type: String? = nil
    var activityView: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
    
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
        self.activityView.startAnimating()
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.users.dequeueReusableCellWithIdentifier("User")!
        let configurator = self.userCellConfigurators[indexPath.row]
        configurator.configure(cell, viewController: self)
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! User
        let configurator = userCellConfigurators[indexPath.row]
        
        if configurator.user!.handle == currentUser.handle {
            tableView.deselectRowAtIndexPath(indexPath, animated: false)
            return
        }
        
        User.getUser(user, storyboard: self.storyboard!, navigationController: self.navigationController!)
        cell.selected = false
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.userCellConfigurators.count
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
        let request = UserRequest()
        request.userid = UInt32(currentUser.userid!)
        request.loginToken = currentUser.loginToken
        request.queryUserid = UInt32(self.user.userid!)
        if type == "followers" {
            server.followersGetWithRequest(request) {
                (response, error) in
                if error != nil {
                    Debug.printl("Error: \(error)", sender: nil)
                } else {
                    for u in response.userArray {
                        let dict = u as! UserPreview
                        let follower = User()
                        follower.handle = dict.handle
                        follower.username = dict.name
                        follower.userid = Int(dict.userid)
                        let configurator = UserCellConfigurator(user: follower, shouldShowFollowButton: true)
                        self.userCellConfigurators.append(configurator)
                    }
                    dispatch_async(dispatch_get_main_queue()) {
                        self.users.reloadData()
                        self.activityView.stopAnimating()
                    }
                }
            }
        } else {
            server.followingsGetWithRequest(request) {
                (response, error) in
                if error != nil {
                    Debug.printl("Error: \(error)", sender: nil)
                } else {
                    for u in response.userArray {
                        let dict = u as! UserPreview
                        let follower = User()
                        follower.handle = dict.handle
                        follower.username = dict.name
                        follower.userid = Int(dict.userid)
                        let configurator = UserCellConfigurator(user: follower, shouldShowFollowButton: true)
                        self.userCellConfigurators.append(configurator)
                    }
                    dispatch_async(dispatch_get_main_queue()) {
                        self.users.reloadData()
                        self.activityView.stopAnimating()
                    }
                }
            }
        }
    }
}
