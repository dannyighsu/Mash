//
//  NavigationController.swift
//  Mash-iOS
//
//  Created by Danny Hsu on 6/17/15.
//  Copyright (c) 2015 Mash. All rights reserved.
//

import Foundation
import UIKit

class RootNavigationController: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: "STHeitiSC-Light", size: 20)!, NSForegroundColorAttributeName: UIColor.blackColor()]
        self.edgesForExtendedLayout = UIRectEdge.None
        rootNavigationController = self
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.Default
    }
    
    override func shouldAutorotate() -> Bool {
        var result: Bool
        if self.topViewController!.respondsToSelector(#selector(UIViewController.shouldAutorotate)) {
            result = self.topViewController!.shouldAutorotate()
        } else {
            result = super.shouldAutorotate()
        }
        return result
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        var result: UIInterfaceOrientationMask
        if self.topViewController!.respondsToSelector(#selector(UIViewController.supportedInterfaceOrientations)) {
            result = self.topViewController!.supportedInterfaceOrientations()
        } else {
            result = super.supportedInterfaceOrientations()
        }
        return result
    }
    
}
