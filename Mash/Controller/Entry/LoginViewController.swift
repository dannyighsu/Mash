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
        self.handleField.autocapitalizationType = .None
        
        if let background = UIImage(named: "concert_faded") {
            self.view.backgroundColor = UIColor(patternImage: background)
        }
        
        let tap = UITapGestureRecognizer(target: self, action: "resignTextField:")
        self.view.addGestureRecognizer(tap)
        
        self.view.addSubview(self.activityView)
        self.activityView.center = self.view.center
        
        let handle = NSUserDefaults.standardUserDefaults().objectForKey("username") as? String
        if handle != nil {
            self.handleField.text = handle!
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
        self.navigationItem.title = "Sign In"
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationItem.setRightBarButtonItem(nil, animated: false)
        self.navigationItem.title = ""
    }

    func signinAction(sender: AnyObject?) {
        if (((self.handleField.text!).characters.count < 1) || ((self.passwordField.text!).characters.count < 1)) {
            raiseAlert("Incorrect Username and/or Password", delegate: self)
            return
        }
        
        authenticate(self.handleField.text!.lowercaseString, password: self.passwordField.text!)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == self.handleField {
            self.handleField.resignFirstResponder()
            self.passwordField.becomeFirstResponder()
        } else {
            if textField.text!.isEmpty {
                raiseAlert("Please enter a password.", delegate: self)
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
        self.activityView.startAnimating()
        let passwordHash = hashPassword(password)
        let request = SignInRequest()
        request.passwordHash = passwordHash
        // Check for username/email
        var regex: NSRegularExpression?
        do {
            regex = try NSRegularExpression(pattern: ".*@.*", options: [])
        } catch _ as NSError {
            regex = nil
        }
        let matches = regex?.numberOfMatchesInString(handle, options: [], range: NSMakeRange(0, handle.characters.count))
        
        if matches > 0 {
            request.email = handle
        } else {
            request.handle = handle
        }
        
        server.signInWithRequest(request) {
            (response, error) in
            self.activityView.stopAnimating()
            if error != nil {
                Debug.printl("Error: \(error)", sender: nil)
                raiseAlert("Incorrect Username and/or Password")
            } else {
                Debug.printl("\(response.data())", sender: self)
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
                    }
                    self.completeLogin(handle, password: password)
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
        sendTokenRequest()

        Debug.printl("Successful login - pushing tab bar controller onto navigation controller", sender: self)
        let tabbarcontroller = self.storyboard?.instantiateViewControllerWithIdentifier("OriginController") as! TabBarController
        self.navigationController?.pushViewController(tabbarcontroller, animated: false)
    }
    
    func saveLoginItems() {
        Debug.printl("Saving user " + self.handleField.text! + " to NSUserDefaults.", sender: self)
        NSUserDefaults.standardUserDefaults().setValue(self.handleField.text!.lowercaseString, forKey: "username")
        keychainWrapper.mySetObject(self.passwordField.text!, forKey: kSecValueData)
        keychainWrapper.writeToKeychain()
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: "hasLoginKey")
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
}
