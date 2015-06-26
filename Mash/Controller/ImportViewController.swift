//
//  ImportViewController.swift
//  Mash-iOS
//
//  Created by Danny Hsu on 4/9/15.
//  Copyright (c) 2015 Mash. All rights reserved.
//

import Foundation
import UIKit

class ImportViewController: UITableViewController {

    @IBOutlet var tracks: UITableView!
    var data: [Track] = []
    var tracksToAdd: [Track] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let track = UINib(nibName: "Track", bundle: nil)
        self.tracks.registerNib(track, forCellReuseIdentifier: "Track")
        let header = UINib(nibName: "ImportHeaderView", bundle: nil)
        self.tracks.registerNib(header, forHeaderFooterViewReuseIdentifier: "ImportHeaderView")
        
        self.data.append(Track(frame: CGRectZero, instruments: ["sample"], titleText: "Harp", bpm: 120, trackURL: "Harp", user: "Danny", format: ".m4a"))
        self.data.append(Track(frame: CGRectZero, instruments: ["drums"], titleText: "Spacious Set", bpm: 120, trackURL: "Spacious Set", user: "Danny", format: ".m4a"))
        self.data.append(Track(frame: CGRectZero, instruments: ["strings"], titleText: "Basses Legato", bpm: 120, trackURL: "Basses Legato", user: "Danny", format: ".m4a"))
        self.data.append(Track(frame: CGRectZero, instruments: ["vocals"], titleText: "Female Chorus", bpm: 120, trackURL: "Female Chorus", user: "Danny", format: ".m4a"))
        self.data.append(Track(frame: CGRectZero, instruments: ["strings"], titleText: "Violins", bpm: 120, trackURL: "Violins 1", user: "Danny", format: ".m4a"))
    }

    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let head = tableView.dequeueReusableHeaderFooterViewWithIdentifier("ImportHeaderView") as! ImportHeaderView
        head.addButton.addTarget(self, action: "addAllTracks:", forControlEvents: UIControlEvents.TouchDown)
        let tap = UITapGestureRecognizer(target: self, action: "search:")
        head.addGestureRecognizer(tap)
        return head
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let i = indexPath.row
        let track = self.tracks.dequeueReusableCellWithIdentifier("Track") as! Track
        track.instruments = self.data[i].instruments
        track.titleText = self.data[i].titleText
        track.title.text = track.titleText
        track.instrumentImage.image = findImage(track.instruments)
        track.trackURL = self.data[i].trackURL
        let tap = UITapGestureRecognizer(target: self, action: "addTrack:")
        track.addButton.addGestureRecognizer(tap)
        return track
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data.count
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let track = self.tracks.cellForRowAtIndexPath(indexPath) as! Track
        if (track.accessoryType == UITableViewCellAccessoryType.Checkmark) {
            track.accessoryType = UITableViewCellAccessoryType.None
            for (var i = 0; i < self.tracksToAdd.count; i++) {
                if track == self.tracksToAdd[i] {
                    self.tracksToAdd.removeAtIndex(i)
                    break
                }
            }
        } else {
            track.accessoryType = UITableViewCellAccessoryType.Checkmark
            self.tracksToAdd.append(track)
        }
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50.0
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 75.0
    }

    func addTrack(sender: UITapGestureRecognizer) {
        let track = sender.view?.superview?.superview as! Track
        importTracks([track], self.navigationController, self.storyboard)
        self.navigationController?.popViewControllerAnimated(true)
    }

    func addAllTracks(sender: AnyObject?) {
        importTracks(self.tracksToAdd, self.navigationController, self.storyboard)
        self.navigationController?.popViewControllerAnimated(true)
    }

}
