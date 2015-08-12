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
import AVFoundation
import CryptoSwift
import AWSCore
import AWSS3

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
    } else if input == "explore" {
        return 1
    } else if input == "record" {
        return 2
    } else if input == "project" {
        return 3
    } else {
        return 4
    }
}

func getTabBarController(input: String, navcontroller: UINavigationController) -> UIViewController {
    let tabBarController = navcontroller.viewControllers[2] as! TabBarController
    let controllers = tabBarController.viewControllers!
    if input == "home" {
        return controllers[0] as! UIViewController
    } else if input == "explore" {
        return controllers[1] as! UIViewController
    } else if input == "record" {
        return controllers[2] as! UIViewController
    } else if input == "project" {
        return controllers[3] as! UIViewController
    } else {
        return controllers[4] as! UIViewController
    }
}

func returnProjectView(navcontroller: UINavigationController) -> ProjectViewController? {
    let tabBarController = navcontroller.viewControllers[2] as! UITabBarController
    for (var i = 0; i < tabBarController.viewControllers!.count; i++) {
        let controller = tabBarController.viewControllers![i] as? ProjectViewController
        if controller != nil {
            return tabBarController.viewControllers![i] as? ProjectViewController
        }
    }
    return nil
}


// Cryptographic Hash function for password hashes
func hashPassword(input: String) -> String {
    var data: NSData = NSData(bytes: input, length: count(input))
    let hash = data.sha256()
    return hash!.hexString
}

// Download from S3 bucket
func download(key: String, url: NSURL, bucket: String) {
    if NSFileManager.defaultManager().fileExistsAtPath(url.path!) {
        return
    }
    let request: AWSS3TransferManagerDownloadRequest = AWSS3TransferManagerDownloadRequest.new()
    request.bucket = bucket
    request.key = key
    request.downloadingFileURL = url
    let transferManager: AWSS3TransferManager = AWSS3TransferManager.defaultS3TransferManager()
    
    transferManager.download(request).continueWithBlock() {
        (task: AWSTask!) -> AnyObject! in
        if (task.error != nil) {
            if task.error.domain == AWSS3TransferManagerErrorDomain {
                Debug.printl("Download Error: \(task.error)", sender: "helpers")
                return nil
            } else {
                Debug.printl("Download Error: \(task.error)", sender: "helpers")
            }
        } else if (task.result != nil) {
            let downloadOutput: AWSS3TransferManagerDownloadOutput = task.result as! AWSS3TransferManagerDownloadOutput
            Debug.printl("download complete:\(downloadOutput)", sender: "helpers")
            return task
        }
        return nil
    }
}

func download(key: String, url: NSURL, bucket: String, completion: (result: AWSS3TransferManagerDownloadOutput?) -> Void) {
    if NSFileManager.defaultManager().fileExistsAtPath(url.path!) {
        return completion(result: AWSS3TransferManagerDownloadOutput())
    }
    let request: AWSS3TransferManagerDownloadRequest = AWSS3TransferManagerDownloadRequest.new()
    request.bucket = bucket
    request.key = key
    request.downloadingFileURL = url
    let transferManager: AWSS3TransferManager = AWSS3TransferManager.defaultS3TransferManager()
    
    transferManager.download(request).continueWithBlock() {
        (task: AWSTask!) -> AnyObject! in
        if (task.error != nil) {
            if task.error.domain == AWSS3TransferManagerErrorDomain {
                Debug.printl("Download Error: \(task.error)", sender: "helpers")
            } else {
                Debug.printl("Download Error: \(task.error)", sender: "helpers")
            }
            completion(result: nil)
        } else if (task.result != nil) {
            let downloadOutput: AWSS3TransferManagerDownloadOutput = task.result as! AWSS3TransferManagerDownloadOutput
            Debug.printl("download complete: \(downloadOutput)", sender: "helpers")
            completion(result: downloadOutput)
            return task
        }
        return nil
    }
}

// Upload to S3 bucket
func upload(key: String, url: NSURL, bucket: String) {
    let request: AWSS3TransferManagerUploadRequest = AWSS3TransferManagerUploadRequest.new()
    request.bucket = bucket
    request.key = key
    request.body = url
    let transferManager: AWSS3TransferManager = AWSS3TransferManager.defaultS3TransferManager()

    transferManager.upload(request).continueWithBlock() {
        (task: AWSTask!) -> AnyObject! in
        if (task.error != nil) {
            if task.error.domain == AWSS3TransferManagerErrorDomain {
                Debug.printl("Upload Error: \(task.error)", sender: "helpers")
                return nil
            } else {
                Debug.printl("Upload Error: \(task.error)", sender: "helpers")
            }
        } else if (task.result != nil) {
            let uploadOutput: AWSS3TransferManagerUploadOutput = task.result as! AWSS3TransferManagerUploadOutput
            Debug.printl("File uploaded succesfully", sender: "helpers")
        }
        return nil
    }
}

func upload(key: String, url: NSURL, bucket: String, completion: (result: AWSS3TransferManagerUploadOutput?) -> Void) {
    let request: AWSS3TransferManagerUploadRequest = AWSS3TransferManagerUploadRequest.new()
    request.bucket = bucket
    request.key = key
    request.body = url
    let transferManager: AWSS3TransferManager = AWSS3TransferManager.defaultS3TransferManager()
    
    transferManager.upload(request).continueWithBlock() {
        (task: AWSTask!) -> AnyObject! in
        if (task.error != nil) {
            if task.error.domain == AWSS3TransferManagerErrorDomain {
                Debug.printl("Upload Error: \(task.error)", sender: "helpers")
                return nil
            } else {
                Debug.printl("Upload Error: \(task.error)", sender: "helpers")
            }
            completion(result: nil)
        } else if (task.result != nil) {
            let uploadOutput: AWSS3TransferManagerUploadOutput = task.result as! AWSS3TransferManagerUploadOutput
            Debug.printl("File uploaded succesfully", sender: "helpers")
            completion(result: uploadOutput)
        }
        return nil
    }
}

// Returns AWSS3 bucket name
func getS3Key(track: Track) -> String {
    return "\(track.userText)~~\(track.titleText)\(track.format)"
}

// Returns AWSS3 waveform bucket name
func getS3WaveformKey(track: Track) -> String {
    return "\(track.userText)~~\(track.titleText)_waveform.jpg"
}

// Returns directory to application's documents
func applicationDocuments() -> NSArray {
    return NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
}

// Returns directory to application's documents
func applicationDocumentsDirectory() -> NSString {
    var paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
    var basePath = paths[0] as? NSString
    return basePath!
}

// Returns file path URL
func filePathURL(input: String?) -> NSURL {
    if input == nil {
        return NSURL(fileURLWithPath: NSString(format: "%@/%@", applicationDocumentsDirectory(), "EZAudioTest.m4a") as String)!
    } else {
        return NSURL(fileURLWithPath: NSString(format: "%@/%@", applicationDocumentsDirectory(), input!) as String)!
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
func raiseAlert(input: String, delegate: UIViewController) {
    dispatch_async(dispatch_get_main_queue()) {
        var alert = UIAlertView()
        alert.title = input
        alert.addButtonWithTitle("OK")
        alert.delegate = delegate
        alert.show()
    }
}

func raiseAlert(input: String, delegate: UIViewController, message: String) {
    dispatch_async(dispatch_get_main_queue()) {
        var alert = UIAlertView()
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
    var image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return image
}
