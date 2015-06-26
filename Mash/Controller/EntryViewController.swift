//
//  EntryViewController.swift
//  Mash-iOS
//
//  Created by Danny Hsu on 6/15/15.
//  Copyright (c) 2015 Mash. All rights reserved.
//

import Foundation
import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class EntryViewController: UIViewController {

    @IBOutlet weak var facebookButton: UIButton! // Currently disabled
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var logo: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.Plain, target:nil, action:nil)

        if let background = UIImage(named: "concert") {
            self.view.backgroundColor = UIColor(patternImage: background)
        }
        self.navigationController?.navigationBarHidden = true
        self.facebookButton.imageView?.image = UIImage(named: "fb_logo_invert")
        self.facebookButton.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
        self.facebookButton.addTarget(self, action: "facebookLogin:", forControlEvents: UIControlEvents.TouchDown)
        self.logo.contentMode = UIViewContentMode.ScaleAspectFit
        
        // Check for login key
        let hasLoginKey = NSUserDefaults.standardUserDefaults().boolForKey("hasLoginKey")
        if hasLoginKey == true {
            var login = self.storyboard?.instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
            self.navigationController?.pushViewController(login, animated: false)
            let username = NSUserDefaults.standardUserDefaults().valueForKey("username") as! String
            let password = keychainWrapper.myObjectForKey("v_Data") as! String
            Debug.printl("Attempting to log in with username \(username) and password \(password)", sender: self)
            login.authenticate(username, password: password)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden = true
    }
    
    func facebookLogin(sender: AnyObject?) {
        var login = FBSDKLoginManager()
        login.logInWithReadPermissions(["email", "public_profile"]) {
            (result: FBSDKLoginManagerLoginResult!, error: NSError!) -> Void in
            if error != nil {
                Debug.printl(error, sender: self)
            } else if result.isCancelled {
                Debug.printl("Login was cancelled by user.", sender: self)
            } else {
                self.login(result)
            }
        }
    }
    
    func login(permissions: FBSDKLoginManagerLoginResult) {
        var accessToken = permissions.token
        if permissions.grantedPermissions.contains("email") && permissions.grantedPermissions.contains("public_profile") {
            FBSDKGraphRequest(graphPath: "me", parameters: nil).startWithCompletionHandler() {
                (connection, result, error) -> Void in
                if (error == nil ) {
                    Debug.printl("Error: \(error)", sender: self)
                } else {
                    Debug.printl(result, sender: self)
                }
            }
        }
    }
    
}
