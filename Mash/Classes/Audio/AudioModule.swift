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
    
    class func mixTracks(name: String, tracks: [Track], volumes: [Float], completion: (exportSession: AVAssetExportSession?) -> ()) {
        let composition: AVMutableComposition = AVMutableComposition()
        var compositionTracks: [AVMutableCompositionTrack] = []
        var assets: [AVAsset] = []
        var mixes: [AVMutableAudioMixInputParameters] = []
        
        // Create track assets
        var maxDuration: CMTime = kCMTimeZero
        for i in 0 ..< tracks.count {
            let track: Track = tracks[i]
            
            let compositionTrack: AVMutableCompositionTrack = composition.addMutableTrackWithMediaType(AVMediaTypeAudio, preferredTrackID: CMPersistentTrackID(kCMPersistentTrackID_Invalid))
            compositionTracks.append(compositionTrack)
            let asset: AVAsset = AVURLAsset(URL: NSURL(fileURLWithPath: track.trackURL), options: nil)
            assets.append(asset)
            
            let mix = AVMutableAudioMixInputParameters(track: asset.tracks[0])
            mix.setVolume(volumes[i], atTime: kCMTimeZero)
            mix.trackID = asset.tracks[0].trackID
            mixes.append(mix)
            
            maxDuration = max(maxDuration, asset.duration)
        }
        
        // Insert into composition
        for i in 0 ..< tracks.count {
            let compositionTrack = compositionTracks[i]
            let asset: AVAsset = assets[i]
            let trackDuration: CMTime = asset.duration
            var totalDuration: CMTime = kCMTimeZero
            
            // Loop shorter tracks
            while totalDuration + trackDuration <= maxDuration {
                do {
                    let shorterAsset: AVAsset = AVURLAsset(URL: NSURL(fileURLWithPath: tracks[i].trackURL))
                    let tracks: NSArray = shorterAsset.tracksWithMediaType(AVMediaTypeAudio)
                    let clip: AVAssetTrack = tracks.objectAtIndex(0) as! AVAssetTrack
                    try compositionTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, shorterAsset.duration), ofTrack: clip, atTime: totalDuration)
                    
                    let mix = AVMutableAudioMixInputParameters(track: shorterAsset.tracks[0])
                    mix.setVolume(volumes[i], atTime: kCMTimeZero)
                    mix.trackID = asset.tracks[0].trackID
                    mixes.append(mix)
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
        let audioMix = AVMutableAudioMix()
        audioMix.inputParameters = mixes
        exportSession?.audioMix = audioMix
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
        
        return filePathString("\(newName).wav")
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


