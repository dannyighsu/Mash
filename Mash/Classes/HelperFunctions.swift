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
    Debug.printl(hash!.hexString, sender: "helpers")
    return hash!.hexString
}

// Adds input tracks to current project view
func importTracks(tracks: [Track], navigationController: UINavigationController?, storyboard: UIStoryboard?) {
    var project: ProjectViewController? = nil
    let tabBarController = navigationController?.viewControllers[2] as! UITabBarController
    
    for (var i = 0; i < tabBarController.viewControllers!.count; i++) {
        let controller = tabBarController.viewControllers![i] as? ProjectViewController
        if controller != nil {
            Debug.printl("Using existing project view controller", sender: "helpers")
            project = controller
            break
        }
    }
    
    if project == nil {
        Debug.printl("Something went horrendously wrong because project view does not exist.", sender: "helpers")
        return
    }
    
    // Download new tracks asnychronously
    let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
    dispatch_async(dispatch_get_global_queue(priority, 0)) {
        for track in tracks {
            var URL = filePathURL(track.titleText + track.format)
            download("\(current_user.username!)~~\(track.titleText)\(track.format)", URL, track_bucket)
            track.trackURL = filePathString(track.titleText + track.format)
            Debug.printl("Adding track with \(track.instruments), url \(track.trackURL) named \(track.titleText) to project view", sender: "helpers")
            project?.data.append(track)
        }
        
        project?.audioPlayer?.stop()
        
        // Load new audioplayers
        if (project!.data.count != project!.audioPlayer!.audioPlayers.count) {
            for (var i = project!.audioPlayer!.audioPlayers.count; i < project!.data.count; i++) {
                while !NSFileManager.defaultManager().fileExistsAtPath(project!.data[i].trackURL) {
                    Debug.printnl("waiting...")
                    NSThread.sleepForTimeInterval(0.5)
                }
                project!.audioPlayer!.addTrack(project!.data[i].trackURL)
            }
        }
        
        dispatch_async(dispatch_get_main_queue()) {
            project!.tracks.reloadData()
        }
    }
}

// Download from S3 bucket
func download(key: String, url: NSURL, bucket: String) {
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
        }
        if (task.result != nil) {
            let downloadOutput: AWSS3TransferManagerDownloadOutput = task.result as! AWSS3TransferManagerDownloadOutput
            Debug.printl("download complete:\(downloadOutput)", sender: "helpers")
            return task
        }
        return nil
    }
}

func download(key: String, url: NSURL, bucket: String, completion: (result: AWSS3TransferManagerDownloadOutput) -> Void) {
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
        }
        if (task.result != nil) {
            let downloadOutput: AWSS3TransferManagerDownloadOutput = task.result as! AWSS3TransferManagerDownloadOutput
            Debug.printl("download complete:\(downloadOutput)", sender: "helpers")
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
        }
        if (task.result != nil) {
            let uploadOutput: AWSS3TransferManagerUploadOutput = task.result as! AWSS3TransferManagerUploadOutput
            Debug.printl("File uploaded succesfully", sender: "helpers")
            Debug.printl(uploadOutput, sender: "helpers")
        }
        return nil
    }
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
