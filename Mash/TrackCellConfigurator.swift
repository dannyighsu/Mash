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
    
    override func configure(cell: UITableViewCell, viewController: UIViewController) {
        let trackCell = cell as! Track
        
        trackCell.title.text = track!.titleText
        trackCell.instrumentImage.image = findImage(track!.instrumentFamilies)
        trackCell.userLabel.setTitle(trackCell.userText, forState: .Normal)
        
        trackCell.addButton.addTarget(viewController, action: "addTrack:", forControlEvents: UIControlEvents.TouchDown)
        
        configureAudioPlot(trackCell);
    }
    
    func configureAudioPlot(cell: Track) {
        download(getS3WaveformKey(self.track!), url: NSURL(fileURLWithPath: self.track!.trackURL), bucket: waveform_bucket) {
            (result) in
            dispatch_async(dispatch_get_main_queue()) {
                if result != nil {
                    cell.staticAudioPlot.image = UIImage(contentsOfFile: filePathString(getS3WaveformKey(self.track!)))
                } else {
                    cell.staticAudioPlot.image = UIImage(named: "waveform_static")
                }
            }
        }
    }
}