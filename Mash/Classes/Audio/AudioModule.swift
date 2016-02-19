//
//  AudioFunctions.swift
//  Mash
//
//  Created by Danny Hsu on 10/29/15.
//  Copyright © 2015 Mash. All rights reserved.
//

import Foundation
import AVFoundation

@objc protocol AudioModuleDelegate {
    
    optional func audioFileDidFinishConverting(trackid: Int)
    
}

class AudioConverter: TPAACAudioConverter {
    
    var trackid: Int = 0
    
}

@objc class AudioModule: NSObject, TPAACAudioConverterDelegate {
    
    var delegate: AudioModuleDelegate? = nil
    
    convenience init(delegate: AudioModuleDelegate) {
        self.init()
        self.delegate = delegate
    }
    
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
        var compositionTracks: [AVMutableCompositionTrack] = []
        
        // Create track assets and insert into composition
        var maxDuration: CMTime = kCMTimeZero
        for (var i = 0; i < tracks.count; i++) {
            let track: Track = tracks[i]
            
            let compositionTrack: AVMutableCompositionTrack = composition.addMutableTrackWithMediaType(AVMediaTypeAudio, preferredTrackID: CMPersistentTrackID(kCMPersistentTrackID_Invalid))
            compositionTracks.append(compositionTrack)
            let asset: AVAsset = AVURLAsset(URL: NSURL(fileURLWithPath: track.trackURL), options: nil)
            let tracks: NSArray = asset.tracksWithMediaType(AVMediaTypeAudio)
            
            // Check if tracks are valid
            if tracks.count == 0 {
                completion(exportSession: nil)
                return
            }
            
            let clip: AVAssetTrack = tracks.objectAtIndex(0) as! AVAssetTrack
            maxDuration = max(maxDuration, asset.duration)
            do {
                try compositionTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, asset.duration), ofTrack: clip, atTime: kCMTimeZero)
            } catch _ {
                completion(exportSession: nil)
                return
            }
        }
        
        // Loop shorter tracks
        for (var i = 0; i < compositionTracks.count; i++) {
            let track = compositionTracks[i]
            let trackDuration: CMTime = track.asset!.duration
            var totalDuration: CMTime = track.asset!.duration
            let compositionTrack: AVMutableCompositionTrack = composition.addMutableTrackWithMediaType(AVMediaTypeAudio, preferredTrackID: CMPersistentTrackID(kCMPersistentTrackID_Invalid))
            let asset: AVAsset = AVURLAsset(URL: NSURL(fileURLWithPath: tracks[i].trackURL))
            let tracks: NSArray = asset.tracksWithMediaType(AVMediaTypeAudio)
            let clip: AVAssetTrack = tracks.objectAtIndex(0) as! AVAssetTrack
            
            while totalDuration + trackDuration <= maxDuration {
                do {
                    try compositionTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, asset.duration), ofTrack: clip, atTime: totalDuration)
                } catch let error as NSError {
                    Debug.printl(error, sender: nil)
                    completion(exportSession: nil)
                    return
                }
                totalDuration = CMTimeMakeWithSeconds(CMTimeGetSeconds(totalDuration) + CMTimeGetSeconds(trackDuration), totalDuration.timescale)
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
    
    func timeShift(trackid: Int, url: NSURL, newName: NSString, shiftAmount: Float) -> String {
        let tempresult = SuperpoweredAudioModule.timeShift(url, newName: newName as String, amountToShift: shiftAmount)
        let result = filePathString("\(newName).m4a")
        let converter = AudioConverter(delegate: self, source: tempresult, destination: result)
        converter.trackid = trackid
        converter.start()
        
        return result
    }
    
    func AACAudioConverter(converter: TPAACAudioConverter!, didFailWithError error: NSError!) {
        raiseAlert("There was an issue adding the track. Please try again.")
    }
    
    func AACAudioConverterDidFinishConversion(converter: TPAACAudioConverter!) {
        Debug.printl("Audio file converted.", sender: nil)
        let audioConverter = converter as! AudioConverter
        self.delegate?.audioFileDidFinishConverting?(audioConverter.trackid)
    }
}


