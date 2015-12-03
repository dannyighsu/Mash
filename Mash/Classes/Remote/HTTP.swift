//
//  HTTP.swift
//  Mash
//
//  Created by Danny Hsu on 7/7/15.
//  Copyright (c) 2015 Mash. All rights reserved.
//

import Foundation
import UIKit

// FIXME: HTTP currently throws errors due to no SSL, so this file is commented out.
/*
// Previous request parameters for duplicate requests
var previousRequest: NSMutableURLRequest? = nil
var previousRequestTime = CFAbsoluteTimeGetCurrent()

func checkDuplicate(params: Dictionary<String, String>, request: NSMutableURLRequest!) -> Bool {
    var result = false
    let timeDifference = CFAbsoluteTimeGetCurrent() - previousRequestTime
    if previousRequest != nil {
        if request.URL!.absoluteString == previousRequest!.URL!.absoluteString && timeDifference < 2 {
            result = true
        }
    }
    previousRequest = request
    previousRequestTime = CFAbsoluteTimeGetCurrent()
    return result
}

// Post request with JSON params
func httpPost(params: Dictionary<String, String>, request: NSMutableURLRequest!, callback: (String, Int, String?) -> Void) {
    if checkDuplicate(params, request: request) {
        return
    }
    let session = NSURLSession.sharedSession()
    request.HTTPMethod = "POST"
    do {
        request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(params, options: [])
    } catch _ as NSError {
        request.HTTPBody = nil
    }
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("application/json", forHTTPHeaderField: "Accept")
    
    let task = session.dataTaskWithRequest(request) {
        (data, response, error) -> Void in
        Debug.printl("HTTP Error: \(error)", sender: "helpers")
        Debug.printl("HTTP Response: \(response)", sender: "helpers")
        if error != nil {
            callback("", 0, error!.localizedDescription)
        } else {
            let dataResult = NSString(data: data!, encoding: NSASCIIStringEncoding)!
            let responseResult = response as! NSHTTPURLResponse
            let statusCode = responseResult.statusCode
            callback(dataResult as String, statusCode, nil)
        }
    }
    task.resume()
}

// Patch request with JSON params
func httpPatch(params: Dictionary<String, String>, request: NSMutableURLRequest!, callback: (String, Int, String?) -> Void) {
    if checkDuplicate(params, request: request) {
        return
    }
    let session = NSURLSession.sharedSession()
    request.HTTPMethod = "PATCH"
    do {
        request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(params, options: [])
    } catch _ as NSError {
        request.HTTPBody = nil
    }
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("application/json", forHTTPHeaderField: "Accept")
    
    let task = session.dataTaskWithRequest(request) {
        (data, response, error) -> Void in
        Debug.printl("HTTP Error: \(error)", sender: "helpers")
        Debug.printl("HTTP Response: \(response)", sender: "helpers")
        if error != nil {
            callback("", 0, error!.localizedDescription)
        } else {
            let dataResult = NSString(data: data!, encoding: NSASCIIStringEncoding)!
            let responseResult = response as! NSHTTPURLResponse
            let statusCode = responseResult.statusCode
            callback(dataResult as String, statusCode, nil)
        }
    }
    task.resume()
}

// Delete request
func httpDelete(params: Dictionary<String, String>, request: NSMutableURLRequest!, callback: (String, Int, String?) -> Void) {
    if checkDuplicate(params, request: request) {
        return
    }
    let session = NSURLSession.sharedSession()
    request.HTTPMethod = "DELETE"
    do {
        request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(params, options: [])
    } catch _ as NSError {
        request.HTTPBody = nil
    }
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("application/json", forHTTPHeaderField: "Accept")
    
    let task = session.dataTaskWithRequest(request) {
        (data, response, error) -> Void in
        Debug.printl("HTTP Error: \(error)", sender: "helpers")
        Debug.printl("HTTP Response: \(response)", sender: "helpers")
        if error != nil {
            callback("", 0, error!.localizedDescription)
        } else {
            let dataResult = NSString(data: data!, encoding: NSASCIIStringEncoding)!
            let responseResult = response as! NSHTTPURLResponse
            let statusCode = responseResult.statusCode
            callback(dataResult as String, statusCode, nil)
        }
    }
    task.resume()
}

// Get request
func httpGet(request: NSMutableURLRequest!, callback: (String, Int, String?) -> Void) {
    let session = NSURLSession.sharedSession()
    request.HTTPMethod = "GET"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    
    let task = session.dataTaskWithRequest(request) {
        (data, response, error) -> Void in
        Debug.printl("HTTP Error: \(error)", sender: "helpers")
        Debug.printl("HTTP Response: \(response)", sender: "helpers")
        if error != nil {
            callback("", 0, error!.localizedDescription)
        } else {
            let dataResult = NSString(data: data!, encoding: NSASCIIStringEncoding)!
            let responseResult = response as! NSHTTPURLResponse
            let statusCode = responseResult.statusCode
            callback(dataResult as String, statusCode, nil)
        }
    }
    task.resume()
}*/
