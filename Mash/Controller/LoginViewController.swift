//
//  LoginViewController.swift
//  Mash-iOS
//
//  Created by Danny Hsu on 3/21/15.
//  Copyright (c) 2015 Mash. All rights reserved.
//

import Foundation
import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var handleField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    var activityView: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBarHidden = false
        self.handleField.delegate = self
        self.passwordField.delegate = self
        self.handleField.returnKeyType = UIReturnKeyType.Next
        self.passwordField.returnKeyType = UIReturnKeyType.Go
        
        let tap = UITapGestureRecognizer(target: self, action: "resignTextField:")
        self.view.addGestureRecognizer(tap)
        
        self.view.addSubview(self.activityView)
        self.activityView.center = self.view.center
        
        let hasLoginKey = NSUserDefaults.standardUserDefaults().boolForKey("hasLoginKey")
        if hasLoginKey == true {
            let handle = NSUserDefaults.standardUserDefaults().valueForKey("username") as! String
            let password = keychainWrapper.myObjectForKey("v_Data") as! String
            self.handleField.text = handle
            self.passwordField.text = password
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.handleField.becomeFirstResponder()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.setRightBarButtonItem(UIBarButtonItem(title: "Log In", style: UIBarButtonItemStyle.Plain, target: self, action: "signinAction:"), animated: false)
        self.navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "STHeitiSC-Light", size: 15)!, NSForegroundColorAttributeName: UIColor.whiteColor()], forState: UIControlState.Normal)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationItem.setRightBarButtonItem(nil, animated: false)
    }

    func signinAction(sender: AnyObject?) {
        if ((count(self.handleField.text!) < 1) || (count(self.passwordField.text!) < 1)) {
            raiseAlert("Incorrect Username and/or Password", self)
            return
        }
        
        authenticate(self.handleField.text, password: self.passwordField.text)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == self.handleField {
            self.handleField.resignFirstResponder()
            self.passwordField.becomeFirstResponder()
        } else {
            if textField.text.isEmpty {
                raiseAlert("Please enter a password.", self)
                return false
            }
            self.passwordField.resignFirstResponder()
            self.signinAction(nil)
        }
        return true
    }

    func resignTextField(sender: AnyObject?) {
        self.handleField.resignFirstResponder()
        self.passwordField.resignFirstResponder()
    }

    func authenticate(handle: String, password: String) {
        // Check authentication with database
        let passwordHash = hashPassword(password)
        var request = NSMutableURLRequest(URL: NSURL(string: "\(db)/signin")!)
        var params = ["handle": handle, "password_hash": passwordHash, "query_name": handle] as Dictionary
        self.activityView.startAnimating()
        httpPost(params, request) {
            (data, statusCode, error) -> Void in
            dispatch_async(dispatch_get_main_queue()) {
                self.activityView.stopAnimating()
            }
            if error != nil {
                Debug.printl("Error: \(error)", sender: self)
                return
            } else {
                // Check status codes
                if statusCode == HTTP_ERROR {
                    Debug.printl("Error: \(error)", sender: self)
                    return
                } else if statusCode == HTTP_WRONG_MEDIA {
                    return
                } else if statusCode == HTTP_AUTH_FAIL {
                    raiseAlert("Incorrect Username and/or Password.", self)
                    return
                } else if statusCode == HTTP_SUCCESS_WITH_MESSAGE {
                    dispatch_async(dispatch_get_main_queue()) {
                        [weak self] in
                        var error: NSError? = nil
                        var response = NSJSONSerialization.JSONObjectWithData(data.dataUsingEncoding(NSUTF8StringEncoding)!, options: NSJSONReadingOptions.AllowFragments, error: &error) as! NSDictionary
                        
                        if error != nil {
                            Debug.printl("Error: \(error)", sender: self)
                        }
                        current_user = User()
                        var data = response["user"] as! NSDictionary
                        current_user.handle = handle
                        current_user.username = data["name"] as? String
                        current_user.profile_pic_link = data["profile_pic_link"] as? String
                        current_user.banner_pic_link = data["banner_pic_link"] as? String
                        current_user.followers = String(data["followers_count"] as! Int)
                        current_user.following = String(data["following_count"] as! Int)
                        current_user.tracks = String(data["track_count"] as! Int)
                        current_user.user_description = data["description"] as? String
                        current_user.userid = data["id"] as? Int
                        self!.completeLogin(handle, password: password)
                    }
                } else {
                    Debug.printl("Unrecognized status code from server: \(statusCode)", sender: self)
                    return
                }
            }
        }
    }

    func completeLogin(handle: String, password: String) {
        let hasLoginKey = NSUserDefaults.standardUserDefaults().boolForKey("hasLoginKey")
        if !hasLoginKey {
            self.saveLoginItems()
        } else {
            if (NSUserDefaults.standardUserDefaults().valueForKey("username") as? String != handle || keychainWrapper.myObjectForKey("v_Data") as? String != password) {
                Debug.printl("Updating saved username and password", sender: self)
                self.saveLoginItems()
            }
        }
        User.getUsersFollowing()

        Debug.printl("Successful login - pushing tab bar controller onto navigation controller", sender: self)
        let tabbarcontroller = self.storyboard?.instantiateViewControllerWithIdentifier("OriginController") as! TabBarController
        self.navigationController?.pushViewController(tabbarcontroller, animated: false)
    }
    
    func saveLoginItems() {
        Debug.printl("Saving user " + self.handleField.text + " to NSUserDefaults.", sender: self)
        NSUserDefaults.standardUserDefaults().setValue(self.handleField.text, forKey: "username")
        keychainWrapper.mySetObject(self.passwordField.text, forKey: kSecValueData)
        keychainWrapper.writeToKeychain()
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: "hasLoginKey")
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
}
