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
    var timer: NSTimer = NSTimer()
    
    class func createView() -> ActivityView {
        let view = NSBundle.mainBundle().loadNibNamed("ActivityView", owner: nil, options: nil)
        let activityView = view[0] as! ActivityView
        activityView.layer.cornerRadius = 8.0
        activityView.clipsToBounds = true
        activityView.hidden = true
        
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .Light))
        blurView.frame = activityView.bounds
        blurView.contentView.backgroundColor = lightBlueTranslucent()
        activityView.insertSubview(blurView, atIndex: 0)
        
        return activityView
    }
    
    func setText(text: String) {
        self.titleLabel.text = text
        self.titleLabel.sizeToFit()
    }
    
    func startAnimating() {
        self.activityView.startAnimating()
        self.timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(ActivityView.showSpinner(_:)), userInfo: nil, repeats: false)
    }
    
    func stopAnimating() {
        self.timer.invalidate()
        self.hidden = true
        self.activityView.startAnimating()
    }
    
    func showSpinner(sender: NSTimer) {
        self.hidden = false
    }

}
