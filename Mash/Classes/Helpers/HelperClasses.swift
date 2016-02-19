//
//  HelperClasses.swift
//  Mash
//
//  Created by Danny Hsu on 2/19/16.
//  Copyright © 2016 Mash. All rights reserved.
//

import Foundation
import UIKit

class MetronomeManualTrigger {
    init() {
        
    }
}

class ExtUISlider: UISlider {
    
    var thumbTouchSize: CGSize = CGSizeMake(50, 50)
    
    override func pointInside(point: CGPoint, withEvent event: UIEvent?) -> Bool {
        let bounds = CGRectInset(self.bounds, -thumbTouchSize.width, -thumbTouchSize.height)
        return CGRectContainsPoint(bounds, point)
    }
    
}