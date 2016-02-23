//
//  TrackCellConfigurator.swift
//  Mash
//
//  Created by Andy Lee on 2016.02.19.
//  Copyright © 2016 Mash. All rights reserved.
//

import Foundation

class TrackCellConfigurator : CellConfigurator {
    var track: Track?
    
    init(track: Track) {
        self.track = track;
    }
    
    override func configure(cell: AnyObject, viewController: UIViewController) {
        let trackCell = cell as! Track
        
        trackCell.title.text = self.track!.titleText
        trackCell.instrumentImage.image = findImage(self.track!.instrumentFamilies)
        trackCell.userLabel.setTitle(trackCell.userText, forState: .Normal)
        
        trackCell.addButton.addTarget(viewController, action: "addTrack:", forControlEvents: UIControlEvents.TouchUpInside)
        
        if ((self.track!.staticAudioPlotImage) != nil) {
            trackCell.staticAudioPlot.image = self.track!.staticAudioPlotImage
        } else {
            configureAudioPlot(trackCell);
        }
    }
    
    func configureAudioPlot(cell: Track) {
        // Set the placeholder image before the download
        cell.staticAudioPlot.image = UIImage(named: "waveform_static")
        cell.activityView.startAnimating()
        download(getS3WaveformKey(self.track!), url: NSURL(fileURLWithPath: self.track!.trackURL), bucket: waveform_bucket) {
            (result) in
            dispatch_async(dispatch_get_main_queue()) {
                cell.activityView.stopAnimating()
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