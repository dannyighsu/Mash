//
//  TabBarController.swift
//  Mash-iOS
//
//  Created by Danny Hsu on 2/27/15.
//  Copyright (c) 2015 Mash. All rights reserved.
//

import Foundation
import UIKit

class TabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.hidesBarsWhenKeyboardAppears = false
        self.navigationController?.hidesBarsOnSwipe = false
        self.navigationItem.setHidesBackButton(true, animated: false)
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.Plain, target:nil, action:nil)
        self.selectedIndex = getTabBarController("record")
    }
    
}