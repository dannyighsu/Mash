//
//  Helpers.swift
//  Mash-iOS
//
//  Created by Danny Hsu on 4/8/15.
//  Copyright (c) 2015 Mash. All rights reserved.
//

import Foundation
import Security
import UIKit

// Returns UIImage corresponding to input string
func findImage(instrument: [String]) -> UIImage {
    if instrument.count == 1 {
        let image = UIImage(named: instrument[0])
        if image == nil {
            Debug.printl("No such instrument found: \(instrument)", sender: "helpers")
            return UIImage(named: "Electronic")!
        }
        return image!
    } else {
        return UIImage(named: "Other")!
    }
}

// Returns UIImage corresponding to input string (white)
func findImageWhite(instrument: [String]) -> UIImage {
    if instrument.count == 1 {
        let image = UIImage(named: "\(instrument[0])1")
        if image == nil {
            Debug.printl("No such instrument found: \(instrument)", sender: "helpers")
            return UIImage(named: "Other1")!
        }
        return image!
    } else {
        return UIImage(named: "Other1")!
    }
}

// Returns the instrument index of input instrument
func findInstrument(instrument: String) -> Int {
    var keys = Array(instrumentArray.keys)
    for i in 0...keys.count {
        if instrument == keys[i] {
            return i
        }
    }
    return -1
}

func getTabBarController(input: String) -> Int {
    if input == "home" {
        return 0
    } else if input == "record" {
        return 1
    } else {
        return 2
    }
}

func getTabBarController(input: String, navcontroller: UINavigationController) -> UIViewController {
    let tabBarController = navcontroller.viewControllers[2] as! TabBarController
    let controllers = tabBarController.viewControllers!
    if input == "home" {
        return controllers[0] 
    } else if input == "record" {
        return controllers[1]
    } else {
        return controllers[2]
    }
}

func returnProjectView(navcontroller: UINavigationController) -> ProjectViewController? {
    /*let tabBarController = navcontroller.viewControllers[2] as! UITabBarController
    for (var i = 0; i < tabBarController.viewControllers!.count; i++) {
        let controller = tabBarController.viewControllers![i] as? ProjectViewController
        if controller != nil {
            return tabBarController.viewControllers![i] as? ProjectViewController
        }
    }
    return nil*/
    return currentProject
}


// Cryptographic Hash function for password hashes
func hashPassword(input: String) -> String {
    let data: NSData = NSData(bytes: input, length: input.characters.count)
    let hash = sha256(data)
    return hash.toHexString().uppercaseString
}

func sha256(data : NSData) -> NSData {
    var hash = [UInt8](count: Int(CC_SHA256_DIGEST_LENGTH), repeatedValue: 0)
    CC_SHA256(data.bytes, CC_LONG(data.length), &hash)
    let res = NSData(bytes: hash, length: Int(CC_SHA256_DIGEST_LENGTH))
    return res
}

extension NSData {
    public func toHexString() -> String {
        let count = self.length / sizeof(UInt8)
        var bytesArray = [UInt8](count: count, repeatedValue: 0)
        self.getBytes(&bytesArray, length:count * sizeof(UInt8))
        
        var s:String = "";
        for byte in bytesArray {
            s = s + String(format:"%02x", byte)
        }
        return s
    }
}

// Parse DB time stamp
func parseTimeStamp(timestamp: String) -> String {
    if timestamp == "Just now" {
        return "Just now"
    }
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    dateFormatter.timeZone = NSTimeZone(name: "UTC")
    let date: NSDate? = dateFormatter.dateFromString(timestamp)
    let timeString = stringFromTimeInterval(date!.timeIntervalSinceNow)
    
    // Time format should now be in hh:mm:ss
    let times: [String] = timeString.characters.split {$0 == ":"}.map(String.init)
    let hour = Int(times[0])! - 8
    let minute = Int(times[1])!
    
    var result = ""
    // Less than a day ago
    if hour < 24 {
        // Less than an hour ago
        if hour < 1 {
            if minute == 0 {
                result = "Just now"
            } else if minute == 1 {
                result = "\(minute) minute ago"
            } else {
                result = "\(minute) minutes ago"
            }
        } else {
            if hour == 1 {
                result = "\(hour) hour ago"
            } else {
                result = "\(hour) hours ago"
            }
        }
    } else {
        let day = hour / 24
        if day == 1 {
            result = "yesterday"
        } else {
            result = "\(day) days ago"
        }
    }
    
    return result
}

func stringFromTimeInterval(interval: NSTimeInterval) -> String {
    let interval = Int(interval)
    let seconds = interval % 60
    let minutes = (interval / 60) % 60
    let hours = (interval / 3600)
    return String(format: "%02d:%02d:%02d", -hours, -minutes, -seconds)
}

// Returns directory to application's documents
func applicationDocuments() -> NSArray {
    return NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
}

// Returns directory to application's documents
func applicationDocumentsDirectory() -> NSString {
    var paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
    let basePath = paths[0]
    return basePath
}

// Returns file path URL
func filePathURL(input: String?) -> NSURL {
    if input == nil {
        return NSURL(fileURLWithPath: NSString(format: "%@/%@", applicationDocumentsDirectory(), "EZAudioTest.m4a") as String)
    } else {
        return NSURL(fileURLWithPath: NSString(format: "%@/%@", applicationDocumentsDirectory(), input!) as String)
    }
    
}

// Returns file path String
func filePathString(input: String?) -> String {
    if input == nil {
        return NSString(format: "%@/%@", applicationDocumentsDirectory(), "EZAudioTest.m4a") as String!
    } else {
        return NSString(format: "%@/%@", applicationDocumentsDirectory(), input!) as String!
    }
}

// Alert methods
func raiseAlert(input: String) {
    dispatch_async(dispatch_get_main_queue()) {
        let alert = UIAlertView()
        alert.title = input
        alert.addButtonWithTitle("OK")
        alert.show()
    }
}

func raiseAlert(input: String, delegate: UIViewController) {
    dispatch_async(dispatch_get_main_queue()) {
        let alert = UIAlertView()
        alert.title = input
        alert.addButtonWithTitle("OK")
        alert.delegate = delegate
        alert.show()
    }
}

func raiseAlert(input: String, delegate: UIViewController, message: String) {
    dispatch_async(dispatch_get_main_queue()) {
        let alert = UIAlertView()
        alert.title = input
        alert.message = message
        alert.addButtonWithTitle("OK")
        alert.delegate = delegate
        alert.show()
    }
}

// Save view as UIImage
func takeShotOfView(view: UIView) -> UIImage {
    UIGraphicsBeginImageContext(CGSizeMake(view.frame.size.width, view.frame.size.height))
    view.drawViewHierarchyInRect(CGRectMake(0, 0, view.frame.size.width, view.frame.size.height), afterScreenUpdates: true)
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return image
}
