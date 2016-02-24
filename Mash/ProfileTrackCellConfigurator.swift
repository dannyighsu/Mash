//
//  ProfileTrackCellConfigurator.swift
//  Mash
//
//  Created by Andy Lee on 2016.02.20.
//  Copyright © 2016 Mash. All rights reserved.
//

import Foundation

class ProfileTrackCellConfigurator : TrackCellConfigurator {
    
    override func configure(cell: AnyObject, viewController: UIViewController) {
        let profileTrackCell = cell as! ProfileTrack
        
        profileTrackCell.backgroundColor = UIColor.clearColor()
        profileTrackCell.instrumentImage.backgroundColor = UIColor.clearColor()
        profileTrackCell.title.textColor = UIColor.blackColor()
        profileTrackCell.title.text = self.track!.titleText
        profileTrackCell.instrumentImage.image = findImage(self.track!.instrumentFamilies)
        profileTrackCell.instrumentImage.backgroundColor = UIColor.clearColor()
        profileTrackCell.dateLabel.text = parseTimeStamp(self.track!.time)
        
        profileTrackCell.addButton.addTarget(viewController, action: "addTrack:", forControlEvents: UIControlEvents.TouchUpInside)
        
        if ((self.track!.staticAudioPlot) != nil) {
            profileTrackCell.staticAudioPlot = self.track!.staticAudioPlot
        } else {
            self.configureAudioPlot(profileTrackCell);
        }
    }
    
    // @TODO: @andy: Remove this once we create dedicated models for Track and ProfileTrack, because right now,
    // you can't make ProfileTrack a subclass of Track due to the IBOutlets that can't be overridden.
    func configureAudioPlot(cell: ProfileTrack) {
        // Set the placeholder image before the download
        cell.staticAudioPlot.image = UIImage(named: "waveform_static")
        download(getS3WaveformKey(self.track!), url: filePathURL(getS3WaveformKey(self.track!)), bucket: waveform_bucket) {
            (result) in
            dispatch_async(dispatch_get_main_queue()) {
                if result != nil {
                    // Store the static audio plot in the model
                    self.track!.staticAudioPlotImage = UIImage(contentsOfFile: filePathString(getS3WaveformKey(self.track!)))
                } else {
                    // For now, we will just store the placeholder into the model.
                    // @TODO: @andy: Come up with a way to tell the difference between
                    // getting no audio plot back because there is no audio plot available (don't retry)
                    // and getting no audio plot back because the request failed (in which case, retry).
                    self.track!.staticAudioPlotImage = UIImage(named: "waveform_static")
                }
                
                // Update the cell with the audio plot in the model
                cell.staticAudioPlot.image = self.track!.staticAudioPlotImage
            }
        }
    }
}