//
//  AWSS3.swift
//  Mash
//
//  Created by Danny Hsu on 11/7/15.
//  Copyright © 2015 Mash. All rights reserved.
//

import Foundation

// Download from S3 bucket
func download(key: String, url: NSURL, bucket: String) {
    if NSFileManager.defaultManager().fileExistsAtPath(url.path!) {
        return
    }
    let request: AWSS3TransferManagerDownloadRequest = AWSS3TransferManagerDownloadRequest.init()
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
    let request: AWSS3TransferManagerDownloadRequest = AWSS3TransferManagerDownloadRequest.init()
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
    let request: AWSS3TransferManagerUploadRequest = AWSS3TransferManagerUploadRequest.init()
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
            Debug.printl("File uploaded successfully: \(uploadOutput)", sender: "helpers")
        }
        return nil
    }
}

func upload(key: String, url: NSURL, bucket: String, completion: (result: AWSS3TransferManagerUploadOutput?) -> Void) {
    let request: AWSS3TransferManagerUploadRequest = AWSS3TransferManagerUploadRequest.init()
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
            Debug.printl("File uploaded successfully", sender: "helpers")
            completion(result: uploadOutput)
        }
        return nil
    }
}

// Delete item from S3 bucket
func deleteFromBucket(key: String, bucket: String) {
    let request: AWSS3DeleteObjectRequest = AWSS3DeleteObjectRequest.init()
    request.bucket = bucket
    request.key = key
    
    let s3 = AWSS3.defaultS3()
    s3.deleteObject(request).continueWithBlock() {
        (task: AWSTask!) -> AnyObject! in
        if task.error != nil {
            Debug.printl("Error: \(task.error)", sender: "helpers")
            return nil
        } else {
            Debug.printl("File deleted successfully: \(task.result)", sender: "helpers")
            return nil
        }
    }
}

// Returns AWSS3 bucket name
func getS3Key(userid: Int, recid: Int, format: String) -> String {
    return "\(userid)~~\(recid)\(format)"
}

func getS3Key(track: Track) -> String {
    return "\(track.userid)~~\(track.id)\(track.format)"
}

func getS3Key(track: ProfileTrack) -> String {
    return "\(track.userid)~~\(track.id)\(track.format)"
}

// Returns AWSS3 waveform bucket name
func getS3WaveformKey(track: Track) -> String {
    return "\(track.userid)~~\(track.id)_waveform.png"
}

func getS3WaveformKey(track: ProfileTrack) -> String {
    return "\(track.userid)~~\(track.id)_waveform.png"
}