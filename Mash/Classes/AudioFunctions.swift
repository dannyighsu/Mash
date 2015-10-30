//
//  AudioFunctions.swift
//  Mash
//
//  Created by Danny Hsu on 10/29/15.
//  Copyright © 2015 Mash. All rights reserved.
//

import Foundation
import AVFoundation

func trimAudio(inputFile: NSURL, outputFile: NSURL, startTime: Float, endTime: Float, callback: (result: Bool) -> Void) {
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
