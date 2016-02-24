//
//  HomeCellConfigurator.swift
//  Mash
//
//  Created by Andy Lee on 2016.02.10.
//  Copyright © 2016 Mash. All rights reserved.
//

import Foundation

class HomeCellConfigurator : CellConfigurator {
    var activity : HomeCell?
    
    init(activity : HomeCell) {
        self.activity = activity;
    }
    
    override func configure(cell: AnyObject, viewController: UIViewController) {
        let homeCell = cell as! HomeCell
        
        // Configure the labels and buttons
        homeCell.trackButton.setTitle(self.activity!.eventText, forState: .Normal)
        homeCell.artistButton.setTitle(self.activity!.userText, forState: .Normal)
        homeCell.userLabel.setTitle(self.activity!.userText, forState: .Normal)
        homeCell.timeLabel.text = parseTimeStamp(self.activity!.timeText!)
        homeCell.playCountLabel.text = "\(self.activity!.track!.playCount)"
        homeCell.likeCountLabel.text = "\(self.activity!.track!.likeCount) likes"
        
        // Setup the background art and profile image
        homeCell.backgroundArt.layer.borderWidth = 0.5
        homeCell.backgroundArt.layer.borderColor = lightGray().CGColor
        homeCell.profileImage.contentMode = UIViewContentMode.ScaleAspectFill
        homeCell.profileImage.layer.cornerRadius = homeCell.profileImage.frame.size.width / 2
        homeCell.profileImage.layer.borderWidth = 0.5
        homeCell.profileImage.layer.masksToBounds = true
        
        // Use the activity's user model to download profile pic and background art
        self.activity!.user!.setProfilePic(homeCell.profileImage)
        self.activity!.user!.setBannerPic(homeCell.backgroundArt)
        
        // Download the cover art (audio plot)
        configureCoverArt(homeCell);
        
        // Set the like button's image to the like's status
        if self.activity!.track!.liked {
            homeCell.likeButton.setImage(UIImage(named: "liked"), forState: .Normal)
        }
        
        // Add button targets
        homeCell.userLabel.addTarget(viewController, action: "getUser:", forControlEvents: .TouchUpInside)
        homeCell.playButton.addTarget(viewController, action: "playButton:", forControlEvents: .TouchUpInside)
        homeCell.artistButton.addTarget(viewController, action: "getUser:", forControlEvents: .TouchUpInside)
        homeCell.likeButton.addTarget(viewController, action: "like:", forControlEvents: .TouchUpInside)
        homeCell.addButton.addTarget(viewController, action: "add:", forControlEvents: .TouchUpInside)
    }
    
    func configureCoverArt(cell: HomeCell) {
        // @TODO: @andy: This call gets very expensive if cells are getting reused often!

        /*
        // Store the audio plot and background view inside the activity model so it gets downloaded once.
        // This should fix the issue of the background art getting darker, since insertSublayer is getting called
        // each time the download completes.
        */
        
        download(getS3WaveformKey(self.activity!.track!),
            url: filePathURL(getS3WaveformKey(self.activity!.track!)),
            bucket: waveform_bucket) {
                (result) in
                dispatch_async(dispatch_get_main_queue()) {
                    if result != nil {
                        cell.audioPlotView.image = UIImage(contentsOfFile: filePathString(getS3WaveformKey(self.activity!.track!)))
                    } else {
                        cell.audioPlotView.image = UIImage(named: "waveform_static")
                    }
                    if cell.backgroundArt.subviews.count == 0 || !(cell.backgroundArt.subviews[0] is UIVisualEffectView) {
                        /*let gradient: CAGradientLayer = CAGradientLayer()
                        gradient.frame = cell.backgroundArt.bounds
                        gradient.colors = [lightGray().CGColor, UIColor.clearColor().CGColor, lightGray().CGColor]
                        cell.backgroundArt.layer.insertSublayer(gradient, atIndex: 0)*/
                        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .Light))
                        blurView.frame = cell.backgroundArt.bounds
                        blurView.alpha = 0.8
                        cell.backgroundArt.insertSubview(blurView, atIndex: 0)
                    }
                }
        }
    }
}