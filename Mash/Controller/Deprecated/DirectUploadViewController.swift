//
//  DirectUploadViewController.swift
//  Mash-iOS
//
//  Created by Danny Hsu on 6/8/15.
//  Copyright (c) 2015 Mash. All rights reserved.
//

// Currently used for testing

import Foundation
import UIKit

class DirectUploadViewController: UIViewController {
    
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var tempoField: UITextField!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var keyField: UITextField!
    @IBOutlet weak var instrumentField: UITextField!
    @IBOutlet weak var uploadButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.uploadButton.addTarget(self, action: #selector(DirectUploadViewController.submit(_:)), forControlEvents: UIControlEvents.TouchDown)
        self.backButton.addTarget(self, action: #selector(DirectUploadViewController.back(_:)), forControlEvents: UIControlEvents.TouchDown)
        
        self.submit(nil)
    }
    
    func submit(sender: AnyObject?) {
        /*
        let passwordHash = hashPassword(keychainWrapper.myObjectForKey("v_Data") as! String)
        let handle = NSUserDefaults.standardUserDefaults().valueForKey("username") as! String
        let request = NSMutableURLRequest(URL: NSURL(string: "\(db)/upload")!)
        let params = ["name": handle, "password_hash": passwordHash, "song_name": "Beginning Kick", "bpm": "120", "bar": "404", "key": "0", "instrument": "3", "family": "3", "genre": "pop", "subgenre": "pop", "feel": "0", "effects": "", "theme": "", "solo": "0", "link": "https://s3.amazonaws.com/mash1/Beginning+Kick.aif"] as Dictionary
        httpPost(params, request: request) {
            (data, statusCode, error) -> Void in
            if error != nil {
                Debug.printl("Error: \(error)", sender: self)
            } else {
                // Check status codes
                if statusCode == HTTP_ERROR {
                    Debug.printl("Error: \(data)", sender: self)
                } else if statusCode == HTTP_WRONG_MEDIA {
                    return
                } else if statusCode == HTTP_SUCCESS {
                    // Parse response
                } else {
                    Debug.printl("Unrecognized status code from server: \(statusCode)", sender: self)
                    return
                }
            }
        }
        */
    }
    
    func back(sender: AnyObject?) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
}
