//
//  ActivityView.swift
//  Mash
//
//  Created by Danny Hsu on 1/19/16.
//  Copyright © 2016 Mash. All rights reserved.
//

import Foundation
import UIKit

class ActivityView: UIView {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    
    class func createView() -> ActivityView {
        let view = NSBundle.mainBundle().loadNibNamed("ActivityView", owner: nil, options: nil)
        let activityView = view[0] as! ActivityView
        activityView.layer.cornerRadius = 8.0
        activityView.clipsToBounds = true
        activityView.hidden = true
        
        return activityView
    }
    
    func setText(text: String) {
        self.titleLabel.text = text
        self.titleLabel.sizeToFit()
    }
    
    func startAnimating() {
        self.hidden = false
        self.activityView.startAnimating()
    }
    
    func stopAnimating() {
        self.hidden = true
        self.activityView.startAnimating()
    }

}
