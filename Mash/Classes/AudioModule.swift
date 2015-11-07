//
//  AudioFunctions.swift
//  Mash
//
//  Created by Danny Hsu on 10/29/15.
//  Copyright © 2015 Mash. All rights reserved.
//

import Foundation
import AVFoundation

class Audio {
    
    class func trimAudio(inputFile: NSURL, outputFile: NSURL, startTime: Double, endTime: Double, callback: (result: Bool) -> Void) {
        let asset = AVAsset(URL: inputFile)
        let session = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetAppleM4A)
        
        if session == nil {
            Debug.printl("Failed to create asset export session.", sender: nil)
            callback(result: false)
            return
        }
        
        let start = CMTimeMake(Int64(floor(startTime * 100)), 100)
        let end = CMTimeMake(Int64(ceil(endTime * 100)), 100)
        let exportTimeRange = CMTimeRangeFromTimeToTime(start, end)
        
        session!.outputURL = outputFile
        session!.outputFileType = AVFileTypeAppleM4A
        session!.timeRange = exportTimeRange
        
        session!.exportAsynchronouslyWithCompletionHandler() {
            if session!.status == AVAssetExportSessionStatus.Completed {
                callback(result: true)
            } else {
                Debug.printl("Failed to convert file", sender: nil)
                callback(result: false)
            }
        }
    }
    
    class func mixTracks(name: String, tracks: [Track], completion: (exportSession: AVAssetExportSession?) -> ()) {
        let composition: AVMutableComposition = AVMutableComposition()
        
        // Create track assets and insert into composition
        for (var i = 0; i < tracks.count; i++) {
            let track: Track = tracks[i]
            
            let compositionTrack: AVMutableCompositionTrack = composition.addMutableTrackWithMediaType(AVMediaTypeAudio, preferredTrackID: CMPersistentTrackID(kCMPersistentTrackID_Invalid))
            let asset: AVAsset = AVURLAsset(URL: NSURL(fileURLWithPath: track.trackURL), options: nil)
            let tracks: NSArray = asset.tracksWithMediaType(AVMediaTypeAudio)
            
            // Check if tracks are valid
            if tracks.count == 0 {
                completion(exportSession: nil)
                return
            }
            
            let clip: AVAssetTrack = tracks.objectAtIndex(0) as! AVAssetTrack
            do {
                try compositionTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, asset.duration), ofTrack: clip, atTime: kCMTimeZero)
            } catch _ {
            }
        }
        
        // Export composition
        let newTrack = filePathString("\(currentUser.userid!)~~\(name).m4a")
        if NSFileManager.defaultManager().fileExistsAtPath(newTrack) {
            do {
                try NSFileManager.defaultManager().removeItemAtPath(newTrack)
            } catch _ {
            }
        }
        let exportSession: AVAssetExportSession? = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetAppleM4A)
        if (exportSession == nil) {
            completion(exportSession: nil)
            return
        }
        exportSession?.outputURL = NSURL(fileURLWithPath: newTrack)
        exportSession?.outputFileType = AVFileTypeAppleM4A
        exportSession?.exportAsynchronouslyWithCompletionHandler() {
            completion(exportSession: exportSession!)
        }
        
    }
}


