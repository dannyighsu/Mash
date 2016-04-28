//
//  HandleController.swift
//  Mash
//
//  Created by Danny Hsu on 4/11/16.
//  Copyright © 2016 Mash. All rights reserved.
//

import Foundation
import UIKit

class HandleController: UIViewController {
    
    @IBOutlet weak var handleField: UITextField!
    @IBOutlet weak var goButton: UIButton!
    var request: FbAuthRequest? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let background = UIImage(named: "concert") {
            self.view.backgroundColor = UIColor(patternImage: background)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        self.navigationItem.title = "Set a Handle"
    }
    
    @IBAction func goButtonPressed(sender: AnyObject) {
        if self.handleField.text == nil || self.handleField.text == "" {
            shakeScreen(self.view)
            return
        } else if self.handleField.text!.characters.count < 4 {
            raiseAlert("Handles must be greater than 4 characters.")
            return
        } else if self.handleField.text!.characters.count > 40 {
            raiseAlert("Handles and Passwords must be less than 40 characters long.", delegate: self)
            return
        } else if self.handleField.text!.rangeOfString(" ") != nil {
            raiseAlert("Handles cannot contain spaces.", delegate: self)
            return
        }
        
        let updateRequest = UserUpdateRequest()
        updateRequest.userid = UInt32(currentUser.userid!)
        updateRequest.loginToken = currentUser.loginToken
        updateRequest.handle = self.handleField.text
        
        
        server.userUpdateWithRequest(updateRequest) {
            (response, error) in
            if error != nil {
                Debug.printl(error, sender: self)
            } else {
                NSUserDefaults.standardUserDefaults().setBool(true, forKey: "hasFacebookLoginToken")
                NSUserDefaults.standardUserDefaults().setValue(self.request!.fbToken, forKey: "facebookLoginToken")
                NSUserDefaults.standardUserDefaults().setValue(self.request!.email, forKey: "facebookEmail")
                NSUserDefaults.standardUserDefaults().setValue(self.request!.fbid, forKey: "facebookID")
                
                User.updateSelf(nil)
                let controller = self.storyboard?.instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
                self.navigationController?.viewControllers.removeLast()
                self.navigationController?.pushViewController(controller, animated: false)
                self.performSegueWithIdentifier("welcome", sender: nil)
            }
        }
    }
}
