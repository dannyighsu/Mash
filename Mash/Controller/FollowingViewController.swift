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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let user = UINib(nibName: "User", bundle: nil)
        self.users.registerNib(user, forCellReuseIdentifier: "User")
    }
    
    override func viewDidAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden = false
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = self.users.dequeueReusableCellWithIdentifier("User") as! User
        var user = self.data[indexPath.row]
        cell.nameLabel?.titleLabel?.text = user.display_name()
        cell.imageView?.image = user.profile_pic()
        var following: Bool = false
        for u in user_following {
            if u.username! == user.username! {
                following = true
            }
        }
        if following {
            cell.followButton.addTarget(self, action: "unfollow:", forControlEvents: UIControlEvents.TouchDown)
            cell.followButton.titleLabel?.text = "Unfollow"
            cell.followButton.backgroundColor = lightGray()
        } else {
            cell.followButton.addTarget(self, action: "follow:", forControlEvents: UIControlEvents.TouchDown)
        }
        return cell
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
        println(sender)
    }
    
    func unfollow(sender: UIButton) {
        
    }

}
