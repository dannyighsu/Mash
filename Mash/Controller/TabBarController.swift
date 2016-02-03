//
//  TabBarController.swift
//  Mash-iOS
//
//  Created by Danny Hsu on 2/27/15.
//  Copyright (c) 2015 Mash. All rights reserved.
//

import Foundation
import UIKit

class TabBarController: UITabBarController, UIViewControllerTransitioningDelegate, UIAlertViewDelegate {
    
    let animationController: ProjectTransitionAnimationController = ProjectTransitionAnimationController()
    let dismissAnimationController: ProjectDismissAnimationController = ProjectDismissAnimationController()
    let swipeInteractionController: SwipeInteractionController = SwipeInteractionController()
    var tabBarButton: ProjectTabBar? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UITabBar.appearance().tintColor = lightBlue()
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .Light))
        blurView.frame = self.tabBar.bounds
        blurView.contentView.backgroundColor = darkBlueTranslucent()
        self.tabBar.insertSubview(blurView, atIndex: 0)
        
        // Hardcode image tints
        let home = self.tabBar.items![0]
        let unselectedImage = UIImage(named: "home")
        home.image = unselectedImage?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
                
        self.navigationController?.hidesBarsWhenKeyboardAppears = false
        self.navigationController?.hidesBarsOnSwipe = false
        self.navigationItem.setHidesBackButton(true, animated: false)
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.Plain, target:nil, action:nil)
        self.selectedIndex = getTabBarController("record")
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "update:", name: "UpdateUINotification", object: nil)
        rootTabBarController = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.tabBarButton == nil {
            let button = NSBundle.mainBundle().loadNibNamed("ProjectTabBar", owner: nil, options: nil)[0] as! ProjectTabBar
            button.tapButton.addTarget(self, action: "showProject:", forControlEvents: .TouchUpInside)
            button.addButton.addTarget(self, action: "showProject:", forControlEvents: .TouchUpInside)
            button.frame = CGRect(x: 0.0, y: self.tabBar.frame.minY - 30.0, width: UIScreen.mainScreen().bounds.width, height: 35.0)
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
    
    // Animations
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
    
    // Alert View Delegate
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if alertView.title == "New Project" {
            if buttonIndex == 1 {
                let titleButton = currentProject!.viewControllers[0].navigationItem.titleView as! UIButton
                titleButton.setTitle(alertView.textFieldAtIndex(0)!.text, forState: .Normal)
                self.tabBarButton?.tapButton.setTitle(alertView.textFieldAtIndex(0)!.text, forState: .Normal)
                self.tabBarButton?.addButton.hidden = true
            } else if buttonIndex == 0 {
                currentProject!.dismissViewControllerAnimated(true, completion: nil)
                currentProject = nil
            }
        } else if alertView.title == "You have not created a project yet." {
            if buttonIndex == 1 {
                let project = self.storyboard!.instantiateViewControllerWithIdentifier("ProjectViewController") as! ProjectViewController
                let navController = UINavigationController(rootViewController: project)
                currentProject = navController
                currentProject!.transitioningDelegate = self
                // Add for interaction
                //self.swipeInteractionController.addViewController(currentProject)
                self.presentViewController(currentProject!, animated: true) {
                    ProjectViewController.importTracks(tracksToAdd, navigationController: self.navigationController!, storyboard: self.storyboard!)
                    let titleButton = project.navigationItem.titleView as! UIButton
                    titleButton.setTitle(tracksToAdd[0].titleText, forState: .Normal)
                    self.tabBarButton?.tapButton.setTitle(tracksToAdd[0].titleText, forState: .Normal)
                    self.tabBarButton?.addButton.hidden = true
                }
            }
        }
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
            let project = self.storyboard!.instantiateViewControllerWithIdentifier("ProjectViewController") as! ProjectViewController
            let navController = UINavigationController(rootViewController: project)
            currentProject = navController
            currentProject!.transitioningDelegate = self
            // Add for interaction
            //self.swipeInteractionController.addViewController(currentProject)
            self.presentViewController(currentProject!, animated: true, completion: nil)
            let alert = UIAlertView(title: "New Project", message: "Name your project.", delegate: self, cancelButtonTitle: "Cancel", otherButtonTitles: "Done")
            alert.alertViewStyle = UIAlertViewStyle.PlainTextInput
            alert.show()
        } else {
            self.presentViewController(currentProject!, animated: true, completion: nil)
        }
    }
    
}