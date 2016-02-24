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
    var shouldShowFollowButton: Bool
    
    init(user : User, shouldShowFollowButton: Bool) {
        self.user = user;
        self.shouldShowFollowButton = shouldShowFollowButton
    }
    
    override func configure(cell: AnyObject, viewController: UIViewController) {
        let userCell = cell as! User
        
        userCell.handle = self.user!.handle
        userCell.username = self.user!.username
        userCell.userid = self.user!.userid
        
        userCell.updateDisplays(self.shouldShowFollowButton)
        userCell.bringSubviewToFront(userCell.followButton)
    }
}