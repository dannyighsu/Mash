//
//  Track.swift
//  Mash-iOS
//
//  Created by Danny Hsu on 2/28/15.
//  Copyright (c) 2015 Mash. All rights reserved.
//

import Foundation
import UIKit

class Track: UITableViewCell, EZAudioFileDelegate {
    
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var instrumentImage: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var audioPlot: EZAudioPlot!
    @IBOutlet weak var staticAudioPlot: UIImageView!
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    var instruments: [String] = []
    var instrumentFamilies: [String] = []
    var titleText: String = ""
    var userText: String = ""
    var trackURL: String = ""
    var bpm: Int = 0
    var format: String = ""
    var audioFile: EZAudioFile? = nil
    
    convenience init(frame: CGRect, instruments: [String], titleText: String) {
        self.init(frame: frame)
        self.instruments = instruments
        self.titleText = titleText
    }

    convenience init(frame: CGRect, instruments: [String], instrumentFamilies: [String], titleText: String, bpm: Int, trackURL: String, user: String, format: String) {
        self.init(frame: frame)
        self.instruments = instruments
        self.instrumentFamilies = instrumentFamilies
        self.titleText = titleText
        self.trackURL = trackURL
        self.bpm = bpm
        self.userText = user
        self.format = format
    }
    
    // Should only be called in the completion block of a download function.
    func generateWaveform() {
        self.staticAudioPlot.hidden = true
        self.audioPlot.color = lightBlue()
        
        // FIXME: figure out why this is called before file finishes download and remove the hacky shit below
        while !NSFileManager.defaultManager().fileExistsAtPath(self.trackURL) {
            NSThread.sleepForTimeInterval(0.1)
        }
        self.audioFile = EZAudioFile(URL: NSURL(fileURLWithPath: self.trackURL), delegate: self)
        self.audioPlot.plotType = .Buffer
        self.audioPlot.shouldFill = true
        self.audioPlot.shouldMirror = true
        self.audioPlot.gain = 2.0
        var data = self.audioFile!.getWaveformData()
        self.audioPlot.updateBuffer(data.buffers[0], withBufferSize: data.bufferSize)
    }
    
    class func mixTracks(name: String, tracks: [Track], completion: (exportSession: AVAssetExportSession?) -> ()) {
        var directory = applicationDocumentsDirectory()
        var nextClipTime: CMTime = kCMTimeZero
        var composition: AVMutableComposition = AVMutableComposition()
        
        // Create track assets and insert into composition
        for (var i = 0; i < tracks.count; i++) {
            var track: Track = tracks[i]
            
            var compositionTrack: AVMutableCompositionTrack = composition.addMutableTrackWithMediaType(AVMediaTypeAudio, preferredTrackID: CMPersistentTrackID(kCMPersistentTrackID_Invalid))
            var asset: AVAsset = AVURLAsset(URL: NSURL(fileURLWithPath: track.trackURL), options: nil)
            var tracks: NSArray = asset.tracksWithMediaType(AVMediaTypeAudio)
            
            // Check if tracks are valid
            if tracks.count == 0 {
                completion(exportSession: nil)
                return
            }
            
            var clip: AVAssetTrack = tracks.objectAtIndex(0) as! AVAssetTrack
            compositionTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, asset.duration), ofTrack: clip, atTime: kCMTimeZero, error: nil)
        }
        
        // Export composition
        var newTrack = filePathString("\(current_user.handle!)~~\(name).m4a")
        if NSFileManager.defaultManager().fileExistsAtPath(newTrack) {
            NSFileManager.defaultManager().removeItemAtPath(newTrack, error: nil)
        }
        var exportSession: AVAssetExportSession? = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetAppleM4A)
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
