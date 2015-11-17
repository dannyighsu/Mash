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
    @IBOutlet weak var userLabel: UIButton!
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
    var id: Int = 0
    var audioFile: EZAudioFile? = nil
    var userid: Int = 0
    
    convenience init(frame: CGRect, instruments: [String], titleText: String) {
        self.init(frame: frame)
        self.instruments = instruments
        self.titleText = titleText
    }

    convenience init(frame: CGRect, recid: Int, userid: Int, instruments: [String], instrumentFamilies: [String], titleText: String, bpm: Int, trackURL: String, user: String, format: String) {
        self.init(frame: frame)
        self.instruments = instruments
        self.id = recid
        self.userid = userid
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
        let data = self.audioFile!.getWaveformData()
        self.audioPlot.updateBuffer(data.buffers[0], withBufferSize: data.bufferSize)
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
