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
    var currTrack: Track? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure tab bar appearance
        UITabBar.appearance().barTintColor = darkGray()
        UITabBar.appearance().tintColor = lightBlue()
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .Light))
        blurView.frame = self.tabBar.bounds
        blurView.contentView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.7)
        //self.tabBar.insertSubview(blurView, atIndex: 0)
        
        // Hardcode image tints
        let home = self.tabBar.items![0]
        home.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
        let homeImage = UIImage(named: "home")
        home.image = homeImage?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        
        let record = self.tabBar.items![1]
        record.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
        let recordImage = UIImage(named: "record")
        record.image = recordImage?.imageWithRenderingMode(.AlwaysOriginal)
        
        let profile = self.tabBar.items![2]
        profile.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
        let profileImage = UIImage(named: "dashboard")
        profile.image = profileImage?.imageWithRenderingMode(.AlwaysOriginal)
                
        self.navigationController?.hidesBarsWhenKeyboardAppears = false
        self.navigationController?.hidesBarsOnSwipe = false
        self.navigationItem.setHidesBackButton(true, animated: false)
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.Plain, target:nil, action:nil)
        self.selectedIndex = getTabBarController("record")
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(TabBarController.update(_:)), name: "UpdateUINotification", object: nil)
        rootTabBarController = self
        
        // Load AVAudioSession
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
        } catch let error1 as NSError {
            Debug.printl("Error setting up session: \(error1.localizedDescription)", sender: self)
        }
        do {
            try session.setActive(true)
        } catch let error1 as NSError {
            Debug.printl("Error setting session active: \(error1.localizedDescription)", sender: self)
        }
        
        do {
            try session.overrideOutputAudioPort(AVAudioSessionPortOverride.Speaker)
        } catch let error1 as NSError {
            Debug.printl("\(error1.localizedDescription)", sender: self)
            raiseAlert("Error setting up audio.")
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.tabBarButton == nil {
            let button = NSBundle.mainBundle().loadNibNamed("ProjectTabBar", owner: nil, options: nil)[0] as! ProjectTabBar
            button.tapButton.addTarget(self, action: #selector(TabBarController.showProject(_:)), forControlEvents: .TouchUpInside)
            button.addButton.addTarget(self, action: #selector(TabBarController.showProject(_:)), forControlEvents: .TouchUpInside)
            button.frame = CGRect(x: 0.0, y: self.tabBar.frame.minY - 30.0, width: UIScreen.mainScreen().bounds.width, height: 35.0)
            self.view.addSubview(button)
            self.tabBarButton = button
        }
        
        self.navigationController?.navigationBarHidden = false
    }
    
    // FIXME: Some issue to do with coming in from welcome view controller causes these calls to crash.
    /*override func shouldAutorotate() -> Bool {
        var result: Bool
        if self.selectedViewController!.respondsToSelector(#selector(UIViewController.shouldAutorotate)) {
            result = self.selectedViewController!.shouldAutorotate()
        } else {
            result = super.shouldAutorotate()
        }
        return result
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        var result: UIInterfaceOrientationMask
        if self.selectedViewController!.respondsToSelector(#selector(UIViewController.supportedInterfaceOrientations)) {
            result = self.selectedViewController!.supportedInterfaceOrientations()
        } else {
            result = super.supportedInterfaceOrientations()
        }
        return result
    }*/
    
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
                titleButton.sizeToFit()
                self.tabBarButton?.tapButton.setTitle(alertView.textFieldAtIndex(0)!.text, forState: .Normal)
                self.tabBarButton?.addButton.hidden = true
            } else if buttonIndex == 0 {
                currentProject!.dismissViewControllerAnimated(true, completion: nil)
                currentProject = nil
            }
        } else if alertView.title == "You have not created a project yet." {
            /*if buttonIndex == 1 {
                let project = self.storyboard!.instantiateViewControllerWithIdentifier("ProjectViewController") as! ProjectViewController
                let navController = UINavigationController(rootViewController: project)
                currentProject = navController
                currentProject!.transitioningDelegate = self
                // Add for interaction
                //self.swipeInteractionController.addViewController(currentProject)
                self.presentViewController(currentProject!, animated: true) {
                    ProjectViewController.importTracks(tracksToAdd)
                    let titleButton = project.navigationItem.titleView as! UIButton
                    titleButton.setTitle(tracksToAdd[0].titleText, forState: .Normal)
                    titleButton.sizeToFit()
                    self.tabBarButton?.tapButton.setTitle(tracksToAdd[0].titleText, forState: .Normal)
                    self.tabBarButton?.addButton.hidden = true
                }
            }*/
        } else if alertView.title == "Reporting a Sound" {
            if buttonIndex == 1 {
                sendReportRequest(alertView.textFieldAtIndex(0)!.text, trackid: self.currTrack!.id)
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
            currentProject!.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: "STHeitiSC-Light", size: 20)!, NSForegroundColorAttributeName: UIColor.blackColor()]
            self.tabBarButton!.addButton.hidden = true

            // Add for interaction
            //self.swipeInteractionController.addViewController(currentProject)
            self.presentViewController(currentProject!, animated: true, completion: nil)
            /*let alert = UIAlertView(title: "New Project", message: "Name your project.", delegate: self, cancelButtonTitle: "Cancel", otherButtonTitles: "Done")
            alert.alertViewStyle = UIAlertViewStyle.PlainTextInput
            alert.show()*/
        } else {
            self.presentViewController(currentProject!, animated: true, completion: nil)
        }
    }
    
    // Show menu view
    func showMenu(track: Track) {
        let alertController = UIAlertController(title: "More options", message: nil, preferredStyle: .ActionSheet)
        let addAction = UIAlertAction(title: "Add to Project", style: .Default, handler: {
            (action) in
            ProjectViewController.importTracks([track])
        })
        var likeAction: UIAlertAction
        if track.liked {
            likeAction = UIAlertAction(title: "Unlike", style: .Default, handler: {
                (action) in
                track.like(nil)
            })
        } else {
            likeAction = UIAlertAction(title: "Like", style: .Default, handler: {
                (action) in
                track.like(nil)
            })
        }
        let reportAction = UIAlertAction(title: "Report", style: .Default, handler: {
            (action) in
            self.currTrack = track
            //TODO: Report action
            let alert = UIAlertView(title: "Reporting a Sound", message: "Please enter a reason for your report.", delegate: self, cancelButtonTitle: "Cancel", otherButtonTitles: "Report")
            alert.alertViewStyle = .PlainTextInput
            alert.show()
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
            (action) in
            alertController.dismissViewControllerAnimated(true, completion: nil)
        })
        
        alertController.addAction(addAction)
        alertController.addAction(likeAction)
        alertController.addAction(reportAction)
        alertController.addAction(cancelAction)
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.Pad) {
            alertController.popoverPresentationController!.sourceView = self.view
            alertController.popoverPresentationController!.sourceRect = CGRect(x: self.view.bounds.size.width / 2.0, y: self.view.bounds.size.height / 2.0, width: 1.0, height: 1.0)
        }
        
        topViewController().presentViewController(alertController, animated: true, completion: nil)
    }
    
}