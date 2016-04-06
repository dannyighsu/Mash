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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.Plain, target:nil, action:nil)

        if let background = UIImage(named: "concert") {
            self.view.backgroundColor = UIColor(patternImage: background)
        }
        self.facebookButton.imageView?.image = UIImage(named: "fb_logo_invert")
        self.facebookButton.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
        self.facebookButton.addTarget(self, action: #selector(EntryViewController.facebookLogin(_:)), forControlEvents: UIControlEvents.TouchDown)
        // TODO: implement facebook login
        //self.facebookButton.hidden = true
        
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
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden = true
    }
    
    @IBAction func termsButtonPressed(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(NSURL(string: "http://mashwithme.us/terms")!)
    }
    
    func register(sender: AnyObject?) {
        self.performSegueWithIdentifier("Register", sender: self)
    }
    
    func facebookLogin(sender: AnyObject?) {
        let login = FBSDKLoginManager()
        login.logInWithReadPermissions(["email", "public_profile"]) {
            (result: FBSDKLoginManagerLoginResult!, error: NSError!) -> Void in
            if error != nil {
                Debug.printl(error, sender: self)
            } else if result.isCancelled {
                Debug.printl("Login was cancelled by user.", sender: self)
            } else {
                self.loginWithFacebook(result)
            }
        }
    }
    
    func loginWithFacebook(permissions: FBSDKLoginManagerLoginResult) {
        if permissions.grantedPermissions.contains("email") && permissions.grantedPermissions.contains("public_profile") {
            /*FBSDKGraphRequest(graphPath: "me", parameters: nil).startWithCompletionHandler() {
                (connection, result, error) -> Void in
                if (error == nil ) {
                    Debug.printl("Error: \(error)", sender: self)
                } else {
                    Debug.printl(result, sender: self)
                }
            }*/
        }
    }
    
}
