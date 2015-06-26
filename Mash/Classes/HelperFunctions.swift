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

// Post request with JSON params
func httpPost(params: Dictionary<String, String>, request: NSMutableURLRequest!, callback: (String, Int, String?) -> Void) {
    var session = NSURLSession.sharedSession()
    var err: NSError?
    request.HTTPMethod = "POST"
    request.HTTPBody = NSJSONSerialization.dataWithJSONObject(params, options: nil, error: &err)
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("application/json", forHTTPHeaderField: "Accept")
    
    var task = session.dataTaskWithRequest(request) {
        (data, response, error) -> Void in
        Debug.printl("HTTP Error: \(error)", sender: "helpers")
        Debug.printl("HTTP Response: \(response)", sender: "helpers")
        if error != nil {
            callback("", 0, error.localizedDescription)
        } else {
            var dataResult = NSString(data: data, encoding: NSASCIIStringEncoding)!
            var responseResult = response as! NSHTTPURLResponse
            var statusCode = responseResult.statusCode
            callback(dataResult as String, statusCode, nil)
        }
    }
    task.resume()
}

// Patch request with JSON params
func httpPatch(params: Dictionary<String, String>, request: NSMutableURLRequest!, callback: (String, Int, String?) -> Void) {
    var session = NSURLSession.sharedSession()
    var err: NSError?
    request.HTTPMethod = "PATCH"
    request.HTTPBody = NSJSONSerialization.dataWithJSONObject(params, options: nil, error: &err)
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("application/json", forHTTPHeaderField: "Accept")
    
    var task = session.dataTaskWithRequest(request) {
        (data, response, error) -> Void in
        Debug.printl("HTTP Error: \(error)", sender: "helpers")
        Debug.printl("HTTP Response: \(response)", sender: "helpers")
        if error != nil {
            callback("", 0, error.localizedDescription)
        } else {
            var dataResult = NSString(data: data, encoding: NSASCIIStringEncoding)!
            var responseResult = response as! NSHTTPURLResponse
            var statusCode = responseResult.statusCode
            callback(dataResult as String, statusCode, nil)
        }
    }
    task.resume()
}

// Delete request
func httpDelete(params: Dictionary<String, String>, request: NSMutableURLRequest!, callback: (String, Int, String?) -> Void) {
    var session = NSURLSession.sharedSession()
    var err: NSError?
    request.HTTPMethod = "DELETE"
    request.HTTPBody = NSJSONSerialization.dataWithJSONObject(params, options: nil, error: &err)
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("application/json", forHTTPHeaderField: "Accept")
    
    var task = session.dataTaskWithRequest(request) {
        (data, response, error) -> Void in
        Debug.printl("HTTP Error: \(error)", sender: "helpers")
        Debug.printl("HTTP Response: \(response)", sender: "helpers")
        if error != nil {
            callback("", 0, error.localizedDescription)
        } else {
            var dataResult = NSString(data: data, encoding: NSASCIIStringEncoding)!
            var responseResult = response as! NSHTTPURLResponse
            var statusCode = responseResult.statusCode
            callback(dataResult as String, statusCode, nil)
        }
    }
    task.resume()
}

// Get request
func httpGet(request: NSMutableURLRequest!, callback: (String, Int, String?) -> Void) {
    var session = NSURLSession.sharedSession()
    var err: NSError?
    request.HTTPMethod = "GET"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")

    var task = session.dataTaskWithRequest(request) {
        (data, response, error) -> Void in
        Debug.printl("HTTP Error: \(error)", sender: "helpers")
        Debug.printl("HTTP Response: \(response)", sender: "helpers")
        if error != nil {
            callback("", 0, error.localizedDescription)
        } else {
            var dataResult = NSString(data: data, encoding: NSASCIIStringEncoding)!
            var responseResult = response as! NSHTTPURLResponse
            var statusCode = responseResult.statusCode
            callback(dataResult as String, statusCode, nil)
        }
    }
    task.resume()
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
    
    for track in tracks {
        var URL = filePathURL(track.titleText + track.format)
        download(track.titleText + track.format, URL, track_bucket)
        track.trackURL = filePathString(track.titleText + track.format)
        Debug.printl("Adding track with \(track.instruments), url \(track.trackURL) named \(track.titleText) to project view", sender: "helpers")
        project?.data.append(track)
    }

    project?.stopPlaying()

    // Load new audioplayers
    if (project!.data.count != project!.audioPlayers.count) {
        for (var i = project!.audioPlayers.count; i < project!.data.count; i++) {
            var error: NSError? = nil
            let player = AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: project!.data[i].trackURL), error: &error)
            if player == nil {
                Debug.printl("Error playing file: \(error)", sender: "helpers")
                return
            }
            player.numberOfLoops = -1
            project!.audioPlayers.append(player)
        }
    }
}

// Download from S3 bucket
func download(key: String, url: NSURL, bucket: String) {
    /*let request: AWSS3TransferManagerDownloadRequest = AWSS3TransferManagerDownloadRequest.new()
    request.bucket = bucket
    request.key = key
    request.downloadingFileURL = url
    let transferManager: AWSS3TransferManager = AWSS3TransferManager.defaultS3TransferManager()
    
    transferManager.download(request).continueWithExecutor(BFExecutor.mainThreadExecutor(), withBlock: {
        (task: BFTask!) -> BFTask! in
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
    })*/
}

// Upload to S3 bucket
func upload(key: String, url: NSURL, bucket: String) {
    /*let request: AWSS3TransferManagerUploadRequest = AWSS3TransferManagerUploadRequest.new()
    request.bucket = bucket
    request.key = key
    request.body = url
    let transferManager: AWSS3TransferManager = AWSS3TransferManager.defaultS3TransferManager()

    transferManager.upload(request).continueWithExecutor(BFExecutor.mainThreadExecutor(), withBlock: {
        (task: BFTask!) -> BFTask! in
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
    })*/
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
