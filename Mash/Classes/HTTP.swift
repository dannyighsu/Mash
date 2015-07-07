//
//  HTTP.swift
//  Mash
//
//  Created by Danny Hsu on 7/7/15.
//  Copyright (c) 2015 Mash. All rights reserved.
//

import Foundation
import UIKit

// Previous request parameters for duplicate requests
var previousRequest: NSMutableURLRequest? = nil
var previousRequestTime = CFAbsoluteTimeGetCurrent()

func checkDuplicate(params: Dictionary<String, String>, request: NSMutableURLRequest!) -> Bool {
    var result = false
    var timeDifference = CFAbsoluteTimeGetCurrent() - previousRequestTime
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
    if checkDuplicate(params, request) {
        return
    }
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
    if checkDuplicate(params, request) {
        return
    }
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
    if checkDuplicate(params, request) {
        return
    }
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
