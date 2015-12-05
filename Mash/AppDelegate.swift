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
        
        // Check if version is supported
        let version = NSBundle.mainBundle().infoDictionary?["CFBundleShortVersionString"] as! String
        let request = VersionRequest()
        request.version = version
        
        let serverRequestGroup = dispatch_group_create()
        dispatch_group_enter(serverRequestGroup)
        server.versionWithRequest(request) {
            (response, error) in
            if response.outdated {
                raiseAlert("Version is outdated")
            }
        }
        /*dispatch_group_notify(serverRequestGroup, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
            dispatch_async(dispatch_get_main_queue()) {
                self.checkLogin()
            }
        }*/
        dispatch_group_leave(serverRequestGroup)

        // Check if update required
        let info: NSDictionary = NSBundle.mainBundle().infoDictionary!
        let appID = info["CFBundleIdentifier"] as! String
        let url = NSURL(string: "http://itunes.apple.com/lookup?bundleId=\(appID)")
        let data = NSData(contentsOfURL: url!)
        if data != nil {
            let lookup = (try! NSJSONSerialization.JSONObjectWithData(data!, options: [])) as! NSDictionary
            if lookup["resultCount"]!.integerValue == 1 {
                let appStoreVersion = ((lookup["results"] as! NSArray)[0] as! NSDictionary)["version"] as! String
                let currentVersion = info["CFBundleShortVersionString"] as! String
                if appStoreVersion != currentVersion {
                    Debug.printl("version oudated", sender: nil)
                    // Handle outdated version
                }
            }
        }
        
        // Set up notifications
        /*let types = UIUserNotificationType.Badge.union(UIUserNotificationType.Sound.union(UIUserNotificationType.Alert))
        let settings = UIUserNotificationSettings(forTypes: types, categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(settings)
        UIApplication.sharedApplication().registerForRemoteNotifications()*/
        
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
        
        // Set up Optimizely
        Optimizely.startOptimizelyWithAPIToken("AAM7hIkBvc0Hcq4ni8hGis3hDg6-xDW4~3701484372", launchOptions: launchOptions)
        
        // Set up Flurry
        if !testing {
            Flurry.setCrashReportingEnabled(true)
            Flurry.setEventLoggingEnabled(true)
            Flurry.startSession("29BN8DC34PSV2QSG9Y22")
            Flurry.setShowErrorInLogEnabled(true)
            //Flurry.setDebugLogEnabled(true)
        }
        
        // Set up server timer
        if !localServer {
            serverTimer = NSTimer.scheduledTimerWithTimeInterval(300, target: self, selector: "requestNewServerAddress:", userInfo: nil, repeats: true)
        }

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
        
        // Retrieve server IP
        /*let request = ServerAddressRequest()
        let rand = arc4random()
        request.userid = rand
        loadBalancer.getServerAddressWithRequest(request) {
            (response, error) in
            if error != nil {
                hostAddress = "http://\(response.ipAddress)"
                server = MashService(host: hostAddress)
            }
        }*/
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        FBSDKAppEvents.activateApp()
        let defaults = NSUserDefaults.standardUserDefaults()
        let exitTime = defaults.objectForKey("exitTime") as? NSDate
        if exitTime != nil {
            // Extended absence
        }
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        AppDelegate.clearData()
        
        // Call the logout function if currentUser exists
        if currentUser.handle!.characters.count > 0 {
            let request = UserRequest()
            request.loginToken = currentUser.loginToken
            request.userid = UInt32(currentUser.userid!)
            
            server.signOutWithRequest(request) {
                (response, error) in
                if error != nil {
                    Debug.printl("Error: \(error)", sender: self)
                } else {
                    dispatch_async(dispatch_get_main_queue()) {
                        NSUserDefaults.standardUserDefaults().removeObjectForKey("hasLoginKey")
                    }
                }
            }
        }
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        var optimizely = false
        if Optimizely.handleOpenURL(url) {
            optimizely = true
        }
        return optimizely && /*GPPURLHandler.handleURL(url, sourceApplication: sourceApplication, annotation: annotation) && */FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
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
    
    // Notification registry
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        // TODO: handle error
        Debug.printl("Failed to register for notifications with error: \(error)", sender: nil)
    }
    
    // Server address refresh
    func requestNewServerAddress(sender: AnyObject?) {
        let request = ServerAddressRequest()
        let rand = arc4random()
        request.userid = rand
        loadBalancer.getServerAddressWithRequest(request) {
            (response, error) in
            if error != nil {
                Debug.printl("Error retrieving IP address: \(error)", sender: nil)
            } else {
                hostAddress = "http://\(response.ipAddress):5010"
                server = MashService(host: hostAddress)
                Debug.printl("Received IP address \(hostAddress) from load balancer.", sender: nil)
            }
        }
    }
    
    // Clear user data and downloaded files, excepting profile files
    class func clearData() {
        if NSUserDefaults.standardUserDefaults().objectForKey("hasLoginkey") != nil {
            NSUserDefaults.standardUserDefaults().removeObjectForKey("hasLoginKey")
        }
        NSNotificationCenter.defaultCenter().postNotificationName("UpdateUINotification", object: nil)
        let dir = applicationDocumentsDirectory()
        var error: NSError? = nil
        let fileManager = NSFileManager.defaultManager()
        for file in try! fileManager.contentsOfDirectoryAtPath(dir as String) {
            // Check if file is a user profile file
            let profpic = try! NSRegularExpression(pattern: ".*\(currentUser.userid!)~~profile_pic.jpg", options: [])
            let bannerpic = try! NSRegularExpression(pattern: ".*\(currentUser.userid!)~~banner.jpg", options: [])
            let profcount = profpic.matchesInString(file, options: [], range: NSRange(location: 0, length: file.characters.count))
            let bannercount = bannerpic.matchesInString(file, options: [], range: NSRange(location: 0, length: file.characters.count))
            if profcount.count > 0 || bannercount.count > 0 {
                continue
            }
            
            // If not, then remove file
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
                Debug.printl("removed file \(file)", sender: nil)
            }
        }
    }

}

