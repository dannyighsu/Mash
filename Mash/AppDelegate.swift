//
//  AppDelegate.swift
//  Mash
//
//  Created by Danny Hsu, Sean Han
//  Copyright (c) 2014 Mash. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        let credentialsProvider: AWSCognitoCredentialsProvider = AWSCognitoCredentialsProvider(regionType: AWSRegionType.USEast1, identityPoolId: "us-east-1:8ed187bb-6d28-4540-9172-924c687e9f74")
        let configuration: AWSServiceConfiguration = AWSServiceConfiguration(region: AWSRegionType.USEast1, credentialsProvider: credentialsProvider)
        
        AWSServiceManager.defaultServiceManager().defaultServiceConfiguration = configuration
        
        // Check if update required
        let info: NSDictionary = NSBundle.mainBundle().infoDictionary!
        let appID = info["CFBundleIdentifier"] as! String
        let url = NSURL(string: "http://itunes.apple.com/lookup?bundleId=\(appID)")
        let data = NSData(contentsOfURL: url!)!
        let lookup = (try! NSJSONSerialization.JSONObjectWithData(data, options: [])) as! NSDictionary
        
        if lookup["resultCount"]!.integerValue == 1 {
            let appStoreVersion = ((lookup["results"] as! NSArray)[0] as! NSDictionary)["version"] as! String
            let currentVersion = info["CFBundleShortVersionString"] as! String
            if appStoreVersion != currentVersion {
                Debug.printl("version oudated", sender: nil)
                // Handle outdated version
            }
        }
        
        AppDelegate.clearData()
        
        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(NSDate(), forKey: "exitTime")
        defaults.synchronize()
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        FBSDKAppEvents.activateApp()
        let defaults = NSUserDefaults.standardUserDefaults()
        let exitTime = defaults.objectForKey("exitTime") as? NSDate
        if exitTime != nil {
            let currentTime = NSDate()
            let diff = currentTime.timeIntervalSinceDate(exitTime!)
            if diff > 120 {
                AppDelegate.clearData()
            }
        }
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        let dir = applicationDocumentsDirectory()
        var error: NSError? = nil
        let fileManager = NSFileManager.defaultManager()
        for file in try! fileManager.contentsOfDirectoryAtPath(dir as String) {
            var success: Bool
            do {
                try fileManager.removeItemAtPath(NSString(format: "%@/%@", dir, file ) as String)
                success = true
            } catch let error1 as NSError {
                error = error1
                success = false
            }
            if (!success || error != nil) {
                Debug.printl("removal of file failed", sender: nil)
            } else {
                Debug.printl("removed file", sender: nil)
            }
        }
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        return /*GPPURLHandler.handleURL(url, sourceApplication: sourceApplication, annotation: annotation) && */FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    func application(application: UIApplication, supportedInterfaceOrientationsForWindow window: UIWindow?) -> UIInterfaceOrientationMask {
        var orientations = UIInterfaceOrientationMask.Portrait
        if self.window?.rootViewController != nil {
            let navController = self.window?.rootViewController as! NavigationController
            let viewController = navController.viewControllers.last
            orientations = viewController!.supportedInterfaceOrientations()
        }
        return orientations
    }
    
    // Clear user data and downloaded files
    class func clearData() {
        NSUserDefaults.standardUserDefaults().removeObjectForKey("hasLoginKey")
        
        NSNotificationCenter.defaultCenter().postNotificationName("UpdateUINotification", object: nil)
        let dir = applicationDocumentsDirectory()
        var error: NSError? = nil
        let fileManager = NSFileManager.defaultManager()
        for file in try! fileManager.contentsOfDirectoryAtPath(dir as String) {
            var success: Bool
            do {
                try fileManager.removeItemAtPath(NSString(format: "%@/%@", dir, file ) as String)
                success = true
            } catch let error1 as NSError {
                error = error1
                success = false
            }
            if (!success || error != nil) {
                Debug.printl("removal of file failed", sender: nil)
            } else {
                Debug.printl("removed file", sender: nil)
            }
        }
    }
    
}

