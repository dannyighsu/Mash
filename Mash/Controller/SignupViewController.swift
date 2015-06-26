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
    @IBOutlet weak var usernameField: UITextField!
    let keychainWrapper = KeychainWrapper()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBarHidden = false
        
        // Set textfield delegates
        self.passwordField.delegate = self
        self.emailField.delegate = self
        self.usernameField.delegate = self

        // Set textfield actions
        self.passwordField.returnKeyType = UIReturnKeyType.Go
        self.emailField.returnKeyType = UIReturnKeyType.Next
        self.usernameField.returnKeyType = UIReturnKeyType.Next
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.usernameField.becomeFirstResponder()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField.text.isEmpty {
            Debug.printl("Text field is empty", sender: self)
            return false
        }
        if textField == self.usernameField {
            textField.resignFirstResponder()
            self.emailField.becomeFirstResponder()
        } else if textField == self.emailField {
            textField.resignFirstResponder()
            self.passwordField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
            self.signUpAction(nil)
        }
        return true
    }
    
    // Define alert view return behavior
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if alertView.title == "Success!" {
            self.loginAction()
        }
    }
    
    func finishedWithAuth(auth: GTMOAuth2Authentication!, error: NSError!) {
        Debug.printl("Received error \(error) and authentication \(auth)", sender: self)
    }
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        Debug.printl("Received error \(error) and result \(result)", sender: self)
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        self.logout(nil)
    }

    // Check for length & validity of text fields
    func signUpAction(sender: AnyObject?) {
        if ((count(self.usernameField.text!) < 1) || (count(self.passwordField.text!) < 1)) {
            self.raiseAlert("Username and Password must have at least 1 character.")
            return
        } else if ((count(self.usernameField.text!) > 40 || (count(self.passwordField.text!) > 40))) {
            self.raiseAlert("Username and Password must be less than 40 characters long.")
            return
        }

        var error: NSError? = nil
        var regex = NSRegularExpression(pattern: ".*@.*", options: nil, error: &error)
        let matches = regex?.numberOfMatchesInString(self.emailField.text, options: nil, range: NSMakeRange(0, count(self.emailField.text)))
        if matches != 1 {
            self.raiseAlert("Invalid email format.")
            return
        }
        self.register()
    }

    func register() {
        // Register with database
        let passwordHash = hashPassword(self.passwordField.text)
        var request = NSMutableURLRequest(URL: NSURL(string: "\(db)/register")!)
        var params = ["username": self.usernameField.text!, "password_hash": passwordHash, "email": self.emailField.text!, "display_name": "", "register_agent": "0", "profile_pic_link": "", "banner_pic_link": ""] as Dictionary
        httpPost(params, request) {
            (data, statusCode, error) -> Void in
            if error != nil {
                Debug.printl("Error: \(error)", sender: self)
            } else {
                Debug.printl("Response: \(data)", sender: self)
                // Check status codes
                if statusCode == HTTP_ERROR {
                    Debug.printl("Error: \(error)", sender: self)
                    return
                } else if statusCode == HTTP_WRONG_MEDIA {
                    return
                } else if statusCode == HTTP_KEY_IN_USE {
                    self.raiseAlert("Incorrect Username and/or Password.")
                    return
                } else if statusCode == HTTP_SUCCESS {
                    var alert = UIAlertView()
                    self.raiseAlert("Success!", message: "Welcome to Mash.")
                } else {
                    Debug.printl("Unrecognized status code from server: \(statusCode)", sender: self)
                    return
                }
            }
        }
    }
    
    func loginAction() {
        self.saveLoginItems()
        current_user = User()
        Debug.printl("Successful registration - pushing tab bar controller onto navigation controller", sender: self)
        let tabbarcontroller = self.storyboard?.instantiateViewControllerWithIdentifier("OriginController") as! TabBarController
        self.navigationController?.pushViewController(tabbarcontroller, animated: true)
        self.navigationController?.navigationBarHidden = true
    }
    
    func saveLoginItems() {
        Debug.printl("Saving user " + self.usernameField.text + " to NSUserDefaults.", sender: self)
        NSUserDefaults.standardUserDefaults().setValue(self.usernameField.text, forKey: "username")
        self.keychainWrapper.mySetObject(self.passwordField.text, forKey: kSecValueData)
        self.keychainWrapper.writeToKeychain()
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
    
    func raiseAlert(input: String) {
        dispatch_async(dispatch_get_main_queue()) {
            var alert = UIAlertView()
            alert.title = input
            alert.addButtonWithTitle("OK")
            alert.delegate = self
            alert.show()
        }
    }
    
    func raiseAlert(input: String, message: String) {
        dispatch_async(dispatch_get_main_queue()) {
            var alert = UIAlertView()
            alert.title = input
            alert.message = message
            alert.addButtonWithTitle("OK")
            alert.delegate = self
            alert.show()
        }
    }

}
