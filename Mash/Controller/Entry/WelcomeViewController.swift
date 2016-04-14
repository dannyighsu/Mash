//
//  WelcomeViewController.swift
//  Mash
//
//  Created by Danny Hsu on 2/28/16.
//  Copyright © 2016 Mash. All rights reserved.
//

import Foundation
import UIKit

class WelcomeViewController: UIViewController {
    
    @IBOutlet weak var doneButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBarHidden = true
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBarHidden = false
    }
    
    @IBAction func doneButtonPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
        let tabBarController = self.storyboard?.instantiateViewControllerWithIdentifier("OriginController") as! TabBarController
        rootNavigationController?.pushViewController(tabBarController, animated: false)
    }
    
}
