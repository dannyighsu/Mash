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
    
    init(user : User) {
        self.user = user;
    }
    
    override func configure(cell: UITableViewCell, viewController: UIViewController) {
        let userCell = cell as! User
        userCell.handle = self.user!.handle
        userCell.username = self.user!.username
        userCell.userid = self.user!.userid
        userCell.updateDisplays()
        userCell.bringSubviewToFront(userCell.followButton)
    }
}
