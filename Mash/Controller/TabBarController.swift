//
//  TabBarController.swift
//  Mash-iOS
//
//  Created by Danny Hsu on 2/27/15.
//  Copyright (c) 2015 Mash. All rights reserved.
//

import Foundation
import UIKit

class TabBarController: UITabBarController, UIViewControllerTransitioningDelegate {
    
    let animationController: ProjectTransitionAnimationController = ProjectTransitionAnimationController()
    let dismissAnimationController: ProjectDismissAnimationController = ProjectDismissAnimationController()
    let swipeInteractionController: SwipeInteractionController = SwipeInteractionController()
    var tabBarButton: ProjectTabBar? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UITabBar.appearance().backgroundImage = UIImage(named: "tab_bar_background")
        UITabBar.appearance().tintColor = lightBlue()
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .Light))
        blurView.frame = self.tabBar.bounds
        blurView.contentView.backgroundColor = UIColor(red: 20/255, green: 20/255, blue: 40/255, alpha: 0.7)
        self.tabBar.insertSubview(blurView, atIndex: 0)
        
        self.navigationController?.hidesBarsWhenKeyboardAppears = false
        self.navigationController?.hidesBarsOnSwipe = false
        self.navigationItem.setHidesBackButton(true, animated: false)
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.Plain, target:nil, action:nil)
        self.selectedIndex = getTabBarController("record")
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "update:", name: "UpdateUINotification", object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.tabBarButton == nil {
            let button = NSBundle.mainBundle().loadNibNamed("ProjectTabBar", owner: nil, options: nil)[0] as! ProjectTabBar
            button.tapButton.addTarget(self, action: "showProject:", forControlEvents: .TouchUpInside)
            button.frame = CGRect(x: 0.0, y: self.tabBar.frame.minY - 40.0, width: UIScreen.mainScreen().bounds.width, height: 40.0)
            self.view.addSubview(button)
            self.tabBarButton = button
        }
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
    
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if presented as? ProjectViewController != nil {
            self.animationController.originFrame = self.tabBarButton!.frame
            return self.animationController
        }
        return nil
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if dismissed as? ProjectViewController != nil {
            self.dismissAnimationController.destinationFrame = self.tabBarButton!.frame
            return self.dismissAnimationController
        }
        return nil
    }
    
    func interactionControllerForDismissal(animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return self.swipeInteractionController.interacting ? self.swipeInteractionController : nil
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
    
    // Show project view
    func showProject(sender: AnyObject?) {
        if currentProject == nil {
            currentProject = self.storyboard!.instantiateViewControllerWithIdentifier("ProjectViewController") as? ProjectViewController
            currentProject!.transitioningDelegate = self
            // Add for interaction
            //self.swipeInteractionController.addViewController(currentProject!)
        }
        self.presentViewController(currentProject!, animated: true, completion: nil)
    }
    
}