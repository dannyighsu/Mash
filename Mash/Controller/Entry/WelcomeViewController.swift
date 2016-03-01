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
    
    @IBAction func doneButtonPressed(sender: AnyObject) {
        let tabBarController = self.storyboard?.instantiateViewControllerWithIdentifier("OriginController") as! TabBarController
        self.navigationController?.pushViewController(tabBarController, animated: true)
    }
    
}
