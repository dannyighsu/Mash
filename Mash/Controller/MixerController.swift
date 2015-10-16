//
//  MixerController.swift
//  Mash
//
//  Created by Danny Hsu on 7/28/15.
//  Copyright (c) 2015 Mash. All rights reserved.
//

import Foundation
import UIKit

class MixerController: UIViewController, UITableViewDelegate, UITableViewDataSource, MixerChannelDelegate {
    
    var mixer: UITableView = UITableView(frame: CGRectZero, style: UITableViewStyle.Plain)
    var audioPlayer: ProjectPlayer
    
    // Should never be called
    required init?(coder aDecoder: NSCoder) {
        self.audioPlayer = ProjectPlayer()
        super.init(coder: aDecoder)
    }
    
    convenience init(coder aDecoder: NSCoder, audioPlayer: ProjectPlayer) {
        self.init(coder: aDecoder)!
        self.audioPlayer = audioPlayer
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(self.mixer)
        self.mixer.frame = self.view.frame
        let cell = UINib(nibName: "MixerChannel", bundle: nil)
        self.mixer.registerNib(cell, forCellReuseIdentifier: "MixerChannel")
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    // Table View Delegate
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.audioPlayer.audioPlayers.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MixerChannel") as! MixerChannel
        cell.trackNumber = indexPath.row
        return cell
    }
    
    // Mixer Channel Delegate
    func volumeSliderDidChange(channel: MixerChannel, value: Float, trackNumber: Int) {
        self.audioPlayer.audioPlayers[trackNumber].volume = value
    }
    
}
