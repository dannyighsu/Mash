//
//  ShareItemSource.swift
//  Mash
//
//  Created by Danny Hsu on 4/10/16.
//  Copyright © 2016 Mash. All rights reserved.
//

import Foundation
import UIKit

class ShareItemSource: NSObject, UIActivityItemSource {
    
    @objc func activityViewControllerPlaceholderItem(activityViewController: UIActivityViewController) -> AnyObject {
        return ""
    }
    
    @objc func activityViewController(activityViewController: UIActivityViewController, itemForActivityType activityType: String) -> AnyObject? {
        return nil
    }
    
    @objc func activityViewController(activityViewController: UIActivityViewController, subjectForActivityType activityType: String?) -> String {
        return ""
    }
    
    @objc func activityViewController(activityViewController: UIActivityViewController, thumbnailImageForActivityType activityType: String?, suggestedSize size: CGSize) -> UIImage? {
        return nil
    }
    
}
