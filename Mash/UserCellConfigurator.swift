//
//  UserCellConfigurator.swift
//  Mash
//
//  Created by Andy Lee on 2016.02.10.
//  Copyright © 2016 Mash. All rights reserved.
//

import Foundation

class UserCellConfigurator : CellConfigurator {
    var user: User?
    var isFollower: Bool
    
    init(user : User, isFollower : Bool) {
        self.user = user;
        self.isFollower = isFollower
    }
    
    override func configure(cell: UITableViewCell) {
        let userCell = cell as! User
        userCell.handle = self.user!.handle
        userCell.username = self.user!.username
        userCell.userid = self.user!.userid
        
        if (isFollower) {
            userCell.nameLabel?.setTitle(self.user!.display_name(), forState: UIControlState.Normal)
            self.user!.setProfilePic(userCell.profilePicture!)
            userCell.profilePicture?.layer.cornerRadius = userCell.profilePicture!.frame.size.width / 2
            userCell.profilePicture?.layer.borderWidth = 1.0
            userCell.profilePicture?.layer.masksToBounds = true
            userCell.bringSubviewToFront(userCell.followButton)
            
            // @TODO: @danny: Go back to SearchViewController and HomeTableViewController and set isFollower to false
            // for all the configurators that configure the current user's cell. We can remove this logic here
            var following: Bool = false
            for u in userFollowing {
                if u.handle! == self.user!.handle! {
                    following = true
                }
            }
            
            if userCell.userid == currentUser.userid {
                userCell.followButton.hidden = true
            } else if following {
                userCell.followButton.setTitle("Unfollow", forState: UIControlState.Normal)
                // @TODO: @andy: Do this in the storyboard instead
                userCell.followButton.addTarget(self, action: "unfollow:", forControlEvents: UIControlEvents.TouchUpInside)
                userCell.followButton.backgroundColor = lightGray()
            } else {
                userCell.followButton.addTarget(self, action: "follow:", forControlEvents: UIControlEvents.TouchUpInside)
                //
            }
        } else {
            userCell.updateDisplays()
        }
    }
}
