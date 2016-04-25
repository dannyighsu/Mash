//
//  QuickActivityView.swift
//  Mash
//
//  Created by Danny Hsu on 4/19/16.
//  Copyright © 2016 Mash. All rights reserved.
//

import Foundation
import UIKit

class QuickActivityView: UIView {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    var timer: NSTimer = NSTimer()
    
    class func createView() -> QuickActivityView {
        let view = NSBundle.mainBundle().loadNibNamed("QuickActivityView", owner: nil, options: nil)
        let activityView: QuickActivityView = view[0] as! QuickActivityView
        activityView.layer.cornerRadius = 8.0
        activityView.clipsToBounds = true
        activityView.hidden = true
        activityView.alpha = 0.0
        
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .Light))
        blurView.frame = activityView.frame
        blurView.frame = activityView.bounds
        blurView.contentView.backgroundColor = lightBlueTranslucent()
        activityView.insertSubview(blurView, atIndex: 0)
        
        activityView.imageView.image = UIImage(named: "checkmark")
        activityView.titleLabel.text = "Track Added"
        
        return activityView
    }
    
    func show() {
        self.hidden = false
        self.alpha = 1.0
        self.timer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: #selector(QuickActivityView.hide), userInfo: nil, repeats: false)
    }
    
    func hide() {
        UIView.animateWithDuration(0.5, animations: {self.alpha = 0.0}) {
            (completion) in
            self.hidden = true
        }
    }
    
}

