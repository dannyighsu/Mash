//
//  NavigationController.swift
//  Mash-iOS
//
//  Created by Danny Hsu on 6/17/15.
//  Copyright (c) 2015 Mash. All rights reserved.
//

import Foundation
import UIKit

class NavigationController: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationBar.backgroundColor = darkGray()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.hidesBarsOnSwipe = true
    }
    
}
