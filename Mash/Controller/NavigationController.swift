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
        
        UINavigationBar.appearance().tintColor = darkGray()
        self.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: "STHeitiSC-Light", size: 20)!, NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.navigationBar.tintColor = UIColor.whiteColor()
        self.edgesForExtendedLayout = UIRectEdge.None
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func shouldAutorotate() -> Bool {
        var result: Bool
        if self.topViewController!.respondsToSelector("shouldAutorotate") {
            result = self.topViewController!.shouldAutorotate()
        } else {
            result = super.shouldAutorotate()
        }
        return result
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        var result: UIInterfaceOrientationMask
        if self.topViewController!.respondsToSelector("supportedInterfaceOrientations") {
            result = self.topViewController!.supportedInterfaceOrientations()
        } else {
            result = super.supportedInterfaceOrientations()
        }
        return result
    }
    
}
