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
        
        UITabBar.appearance().backgroundImage = UIImage(named: "tab_bar_background")
        UITabBar.appearance().backgroundColor = darkGray()
        UITabBar.appearance().tintColor = lightBlue()
        self.navigationController?.hidesBarsWhenKeyboardAppears = false
        self.navigationController?.hidesBarsOnSwipe = false
        self.navigationItem.setHidesBackButton(true, animated: false)
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.Plain, target:nil, action:nil)
        self.selectedIndex = getTabBarController("record")
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "update:", name: "UpdateUINotification", object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let button = NSBundle.mainBundle().loadNibNamed("ProjectTabBar", owner: nil, options: nil)[0] as! ProjectTabBar
        button.frame = CGRect(x: 0.0, y: self.tabBar.frame.minY - 40.0, width: UIScreen.mainScreen().bounds.width, height: 40.0)
        self.view.addSubview(button)
    }
    
    override func shouldAutorotate() -> Bool {
        var result: Bool
        if self.selectedViewController!.respondsToSelector("shouldAutorotate") {
            result = self.selectedViewController!.shouldAutorotate()
        } else {
            result = super.shouldAutorotate()
        }
        return result
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        var result: UIInterfaceOrientationMask
        if self.selectedViewController!.respondsToSelector("supportedInterfaceOrientations") {
            result = self.selectedViewController!.supportedInterfaceOrientations()
        } else {
            result = super.supportedInterfaceOrientations()
        }
        return result
    }

    // Update view controllers on return from extended inactivity
    func update(sender: AnyObject?) {
        if self.navigationController!.viewControllers.count > 3 {
            for _ in 0...self.navigationController!.viewControllers.count - 3 {
                self.navigationController!.popViewControllerAnimated(false)
            }
        }
        self.selectedIndex = getTabBarController("record")
    }
    
}