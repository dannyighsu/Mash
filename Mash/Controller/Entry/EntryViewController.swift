//
//  EntryViewController.swift
//  Mash-iOS
//
//  Created by Danny Hsu on 6/15/15.
//  Copyright (c) 2015 Mash. All rights reserved.
//

import Foundation
import UIKit

class EntryViewController: UIViewController {

    @IBOutlet weak var facebookButton: UIButton! // Currently disabled
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var termsButton: UIButton!
    @IBOutlet weak var logo: UIImageView!
    var activityView: ActivityView = ActivityView.createView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.Plain, target:nil, action:nil)

        if let background = UIImage(named: "concert") {
            self.view.backgroundColor = UIColor(patternImage: background)
        }
        self.facebookButton.imageView?.image = UIImage(named: "fb_logo_invert")
        self.facebookButton.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
        self.facebookButton.addTarget(self, action: #selector(EntryViewController.facebookLogin(_:)), forControlEvents: UIControlEvents.TouchDown)
        
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .Light))
        blurView.frame = self.registerButton.bounds
        blurView.contentView.backgroundColor = lightBlueTranslucent()
        blurView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(EntryViewController.register(_:))))
        self.registerButton.insertSubview(blurView, atIndex: 0)
        
        self.logo.contentMode = UIViewContentMode.ScaleAspectFit

        // Check for login key
        let login = self.storyboard?.instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
        self.navigationController?.pushViewController(login, animated: false)
        let tabbarcontroller = self.storyboard?.instantiateViewControllerWithIdentifier("OriginController") as! TabBarController
        self.navigationController?.pushViewController(tabbarcontroller, animated: false)
        
        self.activityView.center = self.view.center
        self.view.addSubview(self.activityView)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    @IBAction func termsButtonPressed(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(NSURL(string: "http://mashwithme.us/terms")!)
    }
    
    func register(sender: AnyObject?) {
        self.performSegueWithIdentifier("Register", sender: self)
    }
    
    func facebookLogin(sender: AnyObject?) {
        let hasFacebookLoginToken = NSUserDefaults.standardUserDefaults().boolForKey("hasFacebookLoginToken")
        print(hasFacebookLoginToken)
        if hasFacebookLoginToken {
            self.sendAuthRequest()
        } else {
            // FB Token not stored; account may not exist
            let login = FBSDKLoginManager()
            login.logInWithReadPermissions(["email", "public_profile", "user_location", "user_friends"]) {
                (result: FBSDKLoginManagerLoginResult!, error: NSError!) -> Void in
                if error != nil {
                    Debug.printl(error, sender: self)
                } else if result.isCancelled {
                    Debug.printl("Login was cancelled by user.", sender: self)
                } else {
                    Debug.printl("Sending graph request.", sender: self)
                    NSUserDefaults.standardUserDefaults().setValue(result.token.tokenString, forKey: "facebookLoginToken")
                    NSUserDefaults.standardUserDefaults().setBool(true, forKey: "hasFacebookLoginToken")
                    self.sendGraphRequest(result)
                }
            }
        }
    }
    
    func sendAuthRequest() {
        let loginToken = NSUserDefaults.standardUserDefaults().valueForKey("facebookLoginToken") as! String
        let request = FbAuthRequest()
        request.email = NSUserDefaults.standardUserDefaults().valueForKey("facebookEmail") as! String
        request.fbid = NSUserDefaults.standardUserDefaults().valueForKey("facebookID") as! String
        request.fbToken = loginToken
        dispatch_async(dispatch_get_main_queue()) {
            self.activityView.startAnimating()
        }
        
        server.fbAuthWithRequest(request) {
            (response, error) in
            dispatch_async(dispatch_get_main_queue()) {
                self.activityView.stopAnimating()
            }
            if error != nil {
                // FB Token outdated
                Debug.printl(error, sender: self)
                let login = FBSDKLoginManager()
                login.logInWithReadPermissions(["email", "public_profile", "user_location", "user_friends"]) {
                    (result: FBSDKLoginManagerLoginResult!, error: NSError!) -> Void in
                    if error != nil {
                        Debug.printl(error, sender: self)
                        raiseAlert("Please try again.", message: "We could not log you in through Facebook.")
                    } else {
                        NSUserDefaults.standardUserDefaults().setValue(result.token.tokenString, forKey: "facebookLoginToken")
                        NSUserDefaults.standardUserDefaults().setBool(true, forKey: "hasFacebookLoginToken")
                        self.sendAuthRequest()
                    }
                }
            } else {
                // FB Token valid
                Debug.printl("Valid Facebook Token", sender: nil)
                self.loginAction(response)
            }
        }
    }
    
    func sendGraphRequest(permissions: FBSDKLoginManagerLoginResult) {
        if permissions.grantedPermissions.contains("email") && permissions.grantedPermissions.contains("public_profile") && permissions.grantedPermissions.contains("user_location") && permissions.grantedPermissions.contains("user_friends") {
            
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, location, email, first_name, last_name, friends"]).startWithCompletionHandler() {
                (connection, result, error) -> Void in
                if (error != nil) {
                    Debug.printl("Error: \(error)", sender: self)
                } else {
                    NSUserDefaults.standardUserDefaults().setValue(result.valueForKey("id"), forKey: "facebookID")
                    Debug.printl("Received result for email \(result.valueForKey("email"))", sender: nil)

                    let request = FbAuthRequest()
                    request.fbToken = NSUserDefaults.standardUserDefaults().valueForKey("facebookLoginToken") as! String
                    request.email = result.valueForKey("email") as! String
                    request.fbid = result.valueForKey("id") as! String
                    request.name = "\(result.valueForKey("first_name")!) \(result.valueForKey("last_name")!)"
                    //request.friendFbidArray = NSMutableArray(array: (result.valueForKey("friends") as! NSDictionary).valueForKey("data") as! NSArray)
                    
                    self.registerAction(request)
                }
            }
        }
    }
    
    func registerAction(request: FbAuthRequest) {
        dispatch_async(dispatch_get_main_queue()) {
            self.activityView.startAnimating()
        }
        Debug.printl("Sending register action with request \(request)", sender: nil)
        server.fbAuthWithRequest(request) {
            (response, error) in
            dispatch_async(dispatch_get_main_queue()) {
                self.activityView.stopAnimating()
            }
            if error != nil {
                Debug.printl("Error: \(error)", sender: self)
                raiseAlert("Please try again.", message: "There was a problem authenticating with your Facebook credentials.")
            } else {
                if response.newUser {
                    // Construct new User
                    NSUserDefaults.standardUserDefaults().setValue(response.email, forKey: "facebookEmail")
                    
                    Debug.printl("Constructing new user \(response.handle)", sender: nil)
                    currentUser = User()
                    currentUser.loginToken = response.loginToken
                    currentUser.handle = response.handle
                    currentUser.userid = Int(response.userid)
                    currentUser.followers = "\(response.followersCount)"
                    currentUser.following = "\(response.followingCount)"
                    currentUser.tracks = "\(response.trackCount)"
                    currentUser.userDescription = response.userDescription
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        if !testing {
                            Flurry.setUserID("\(response.userid)")
                            Flurry.logEvent("User_Login", withParameters: ["userid": Int(response.userid)])
                        }
                        let controller = self.storyboard?.instantiateViewControllerWithIdentifier("HandleController") as! HandleController
                        controller.request = request
                        self.navigationController?.pushViewController(controller, animated: true)
                    }
                } else {
                    self.loginAction(response)
                }
            }
        }
    }
    
    func loginAction(response: SignInResponse) {
        NSUserDefaults.standardUserDefaults().setValue(response.email, forKey: "facebookEmail")
        NSUserDefaults.standardUserDefaults().setValue(response.handle, forKey: "handle")
        
        currentUser = User()
        currentUser.handle = response.handle
        currentUser.loginToken = response.loginToken
        currentUser.userid = Int(response.userid)
        currentUser.followers = "\(response.followersCount)"
        currentUser.following = "\(response.followingCount)"
        currentUser.tracks = "\(response.trackCount)"
        currentUser.userDescription = response.userDescription
        
        dispatch_async(dispatch_get_main_queue()) {
            if !testing {
                Flurry.setUserID("\(response.userid)")
                Flurry.logEvent("User_Login", withParameters: ["userid": Int(response.userid)])
            }
            self.completeLogin()
        }
    }
    
    func completeLogin() {
        User.getUsersFollowing()
        sendTokenRequest()
        
        // Set up notifications
        let types = UIUserNotificationType.Badge.union(UIUserNotificationType.Sound.union(UIUserNotificationType.Alert))
        let settings = UIUserNotificationSettings(forTypes: types, categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(settings)
        UIApplication.sharedApplication().registerForRemoteNotifications()
        
        Debug.printl("Pushing tab bar controller.", sender: self)
        let login = self.storyboard?.instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
        self.navigationController?.pushViewController(login, animated: false)
        let tabbarcontroller = self.storyboard?.instantiateViewControllerWithIdentifier("OriginController") as! TabBarController
        self.navigationController?.pushViewController(tabbarcontroller, animated: true)
    }
    
}
