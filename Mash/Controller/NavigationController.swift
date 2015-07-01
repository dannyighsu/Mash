//
//  NavigationController.swift
//  Mash-iOS
//
//  Created by Danny Hsu on 6/17/15.
//  Copyright (c) 2015 Mash. All rights reserved.
//

import Foundation
import UIKit

class NavigationController: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UINavigationBar.appearance().barTintColor = darkGray()
        UINavigationBar.appearance().translucent = false
        UINavigationBar.appearance().tintColor = offWhite()
        //self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: self, action: "back:")
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.hidesBarsOnSwipe = true
    }
    
    func back(sender: AnyObject?) {
        self.popViewControllerAnimated(true)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
}
