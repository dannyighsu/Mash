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

func sendLikeRequest(trackid: Int) {
    let request = RecordingRequest()
    request.loginToken = currentUser.loginToken
    request.userid = UInt32(currentUser.userid!)
    request.recid = UInt32(trackid)
    
    server.recordingLikeWithRequest(request) {
        (response, error) in
        if error != nil {
            Debug.printl(error, sender: "helpers")
        }
    }
}