//
//  Remote_Functions.swift
//  Mash
//
//  Created by Danny Hsu on 1/30/16.
//  Copyright © 2016 Mash. All rights reserved.
//

import Foundation

func sendPlayRequest(trackid: Int) {
    let request = RecordingRequest()
    request.loginToken = currentUser.loginToken
    request.userid = UInt32(currentUser.userid!)
    request.recid = UInt32(trackid)
    
    server.recordingPlayWithRequest(request) {
        (response, error) in
        if error != nil {
            Debug.printl(error, sender: "helpers")
        }
    }
}

func sendLikeRequest(queryUserId: Int, trackid: Int, trackName: String, completion: (success: Bool) -> Void) {
    let request = RecordingRequest()
    request.loginToken = currentUser.loginToken
    request.userid = UInt32(currentUser.userid!)
    request.recid = UInt32(trackid)
    
    server.recordingLikeWithRequest(request) {
        (response, error) in
        if error != nil {
            Debug.printl(error, sender: "helpers")
            completion(success: false)
        }
        sendPushNotification(queryUserId, message: "\(currentUser.handle!) just liked your sound \(trackName)!")
        completion(success: true)
    }
}

func sendUnlikeRequest(trackid: Int, completion: (success: Bool) -> Void) {
    let request = RecordingRequest()
    request.loginToken = currentUser.loginToken
    request.userid = UInt32(currentUser.userid!)
    request.recid = UInt32(trackid)
    
    server.recordingUnlikeWithRequest(request) {
        (response, error) in
        if error != nil {
            Debug.printl(error, sender: "helpers")
            completion(success: false)
        }
        completion(success: true)
    }
}

func sendTokenRequest() {
    let request = DeviceRequest()
    request.userid = UInt32(currentUser.userid!)
    request.loginToken = currentUser.loginToken
    request.deviceToken = deviceNotificationToken
    
    server.userDeviceWithRequest(request) {
        (response, error) in
        if error != nil {
            Debug.printl(error, sender: "helpers")
            // TODO: Add a direct link to notification center
            if !testing {
                Flurry.logError("\(error.code)", message: "Device token registration invalid: \(error)", error: error)
            }
        }
    }
}

func sendPushNotification(userid: Int, message: String) {
    let request = APNServerRequest()
    request.userid = UInt32(currentUser.userid!)
    request.loginToken = currentUser.loginToken!
    request.queryUserid = UInt32(userid)
    request.message = message
    server.aPNSendWithRequest(request) {
        (response, error) in
        if error != nil {
            Debug.printl("Error sending push notification: \(error)", sender: nil)
            if !testing {
                Flurry.logError("\(error.code)", message: "Error sending push notification", error: error)
            }
        }
        Debug.printl(response, sender: nil)
    }
}

func sendReportRequest(message: String?, trackid: Int) {
    if message == nil {
        raiseAlert("You must enter a reason for your report.")
        return
    }
    let request = ReportRecRequest()
    request.userid = UInt32(currentUser.userid!)
    request.loginToken = currentUser.loginToken
    request.recid = UInt32(trackid)
    request.message = message
    
    server.reportRecordingWithRequest(request) {
        (responser, error) in
        if error != nil {
            Debug.printl("Error sending recording report: \(error).", sender: nil)
        } else {
            raiseAlert("Thank you", message: "We will review your report as soon as possible.")
        }
    }
}