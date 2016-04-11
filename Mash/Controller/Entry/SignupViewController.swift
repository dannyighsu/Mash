//
//  SignupViewController.swift
//  Mash-iOS
//
//  Created by Danny Hsu on 3/21/15.
//  Copyright (c) 2015 Mash. All rights reserved.
//

import Foundation
import UIKit

class SignupViewController: UIViewController, UITextFieldDelegate, UIAlertViewDelegate {
    
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var handleField: UITextField!
    @IBOutlet weak var confirmPasswordField: UITextField!

    var activityView: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBarHidden = false
        
        if let background = UIImage(named: "concert_faded") {
            self.view.backgroundColor = UIColor(patternImage: background)
        }
        
        // Set textfield delegates
        self.passwordField.delegate = self
        self.emailField.delegate = self
        self.handleField.delegate = self
        self.confirmPasswordField.delegate = self
        self.emailField.autocapitalizationType = .None
        self.handleField.autocapitalizationType = .None
        self.emailField.autocorrectionType = .No
        self.handleField.autocorrectionType = .No

        // Set textfield actions
        self.passwordField.returnKeyType = UIReturnKeyType.Next
        self.confirmPasswordField.returnKeyType = UIReturnKeyType.Go
        self.emailField.returnKeyType = UIReturnKeyType.Next
        self.handleField.returnKeyType = UIReturnKeyType.Next
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.handleField.becomeFirstResponder()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.setRightBarButtonItem(UIBarButtonItem(title: "Register", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(SignupViewController.signUpAction(_:))), animated: false)
        self.navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "STHeitiSC-Light", size: 15)!, NSForegroundColorAttributeName: UIColor.blackColor()], forState: UIControlState.Normal)
        self.navigationItem.title = "Register An Account"
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationItem.setRightBarButtonItem(nil, animated: false)
        self.navigationItem.title = ""
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField.text!.isEmpty {
            Debug.printl("Text field is empty", sender: self)
            return false
        }
        if textField == self.handleField {
            textField.resignFirstResponder()
            self.emailField.becomeFirstResponder()
        } else if textField == self.emailField {
            textField.resignFirstResponder()
            self.passwordField.becomeFirstResponder()
        } else if textField == self.passwordField {
            textField.resignFirstResponder()
            self.confirmPasswordField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
            self.signUpAction(nil)
        }
        return true
    }
    
    /* func finishedWithAuth(auth: GTMOAuth2Authentication!, error: NSError!) {
        Debug.printl("Received error \(error) and authentication \(auth)", sender: self)
    }*/
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        Debug.printl("Received error \(error) and result \(result)", sender: self)
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        self.logout(nil)
    }

    // Check for length & validity of text fields
    func signUpAction(sender: AnyObject?) {
        if (((self.handleField.text!).characters.count < 4) || ((self.passwordField.text!).characters.count < 4)) {
            raiseAlert("Username and Password must have at least 4 character.", delegate: self)
            return
        } else if (((self.handleField.text!).characters.count > 40 || ((self.passwordField.text!).characters.count > 40))) {
            raiseAlert("Username and Password must be less than 40 characters long.", delegate: self)
            return
        } else if self.handleField.text!.rangeOfString(" ") != nil {
            raiseAlert("Username cannot contain spaces.", delegate: self)
            return
        } else if self.confirmPasswordField.text != self.passwordField.text {
            raiseAlert("Passwords do not match.", delegate: self)
            return
        }

        // Check email
        var regex: NSRegularExpression?
        do {
            regex = try NSRegularExpression(pattern: ".*@.+\\..+", options: [])
        } catch _ as NSError {
            regex = nil
        }
        let matches = regex?.numberOfMatchesInString(self.emailField.text!, options: [], range: NSMakeRange(0, self.emailField.text!.characters.count))
        if matches != 1 {
            raiseAlert("Invalid email format.", delegate: self)
            return
        }
        
        // Check for alphanumeric
        let trimmedHandle = self.handleField.text!.stringByTrimmingCharactersInSet(NSCharacterSet.alphanumericCharacterSet().invertedSet)
        
        if trimmedHandle != self.handleField.text {
            raiseAlert("Handles can only contain letters and numbers.")
            return
        }
        
        self.register()
    }

    func register() {
        self.activityView.startAnimating()
        let request = RegisterRequest()
        request.handle = self.handleField.text!.lowercaseString
        request.passwordHash = hashPassword(self.passwordField.text!)
        request.email = self.emailField.text!.lowercaseString
        request.name = ""
        request.registerAgent = 0
        server.registerWithRequest(request) {
            (response, error) in
            dispatch_async(dispatch_get_main_queue()) {
                self.activityView.stopAnimating()
            }
            if error != nil {
                Debug.printl("Error: \(error)", sender: self)
                if error.code == 6 {
                    raiseAlert("Username already exists.")
                    return
                }
            } else {
                Debug.printl("\(response.data())", sender: self)
                self.saveLoginItems()
                currentUser = User()
                currentUser.userid = Int(response.userid)
                currentUser.loginToken = response.loginToken
                User.getUsersFollowing()
                User.updateSelf(nil)
                sendTokenRequest()
                
                dispatch_async(dispatch_get_main_queue()) {
                    if !testing {
                        Flurry.setUserID("\(response.userid)")
                        Flurry.logEvent("User_Register", withParameters: ["userid": Int(response.userid)])
                    }
                    self.loginAction()
                }
            }
        }
    }
    
    func loginAction() {
        Debug.printl("Successful registration - pushing tab bar controller onto navigation controller", sender: self)
        
        // Set up notifications
        let types = UIUserNotificationType.Badge.union(UIUserNotificationType.Sound.union(UIUserNotificationType.Alert))
        let settings = UIUserNotificationSettings(forTypes: types, categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(settings)
        UIApplication.sharedApplication().registerForRemoteNotifications()
        
        self.performSegueWithIdentifier("welcome", sender: nil)
    }
    
    func saveLoginItems() {
        Debug.printl("Saving user " + self.handleField.text!.lowercaseString + " to NSUserDefaults.", sender: self)
        NSUserDefaults.standardUserDefaults().setValue(self.handleField.text!.lowercaseString, forKey: "username")
        keychainWrapper.mySetObject(self.passwordField.text, forKey: kSecValueData)
        keychainWrapper.writeToKeychain()
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: "hasLoginKey")
        NSUserDefaults.standardUserDefaults().synchronize()
    }

    // Log out
    func logout(sender: AnyObject?) {
        NSUserDefaults.standardUserDefaults().removeObjectForKey("hasLoginKey")
        NSUserDefaults.standardUserDefaults().removeObjectForKey("username")
        
        Debug.printl("User has successfully logged out - popping to root view controller.", sender: self)
        self.navigationController?.popToRootViewControllerAnimated(true)
    }

}
