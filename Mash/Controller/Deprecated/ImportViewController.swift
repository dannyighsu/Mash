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
    }

    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let head = tableView.dequeueReusableHeaderFooterViewWithIdentifier("ImportHeaderView") as! ImportHeaderView
        head.addButton.addTarget(self, action: #selector(ImportViewController.addAllTracks(_:)), forControlEvents: UIControlEvents.TouchDown)
        /*let tap = UITapGestureRecognizer(target: self, action: Selector("search:"))
        head.addGestureRecognizer(tap)*/
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
        let tap = UITapGestureRecognizer(target: self, action: #selector(ImportViewController.addTrack(_:)))
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
            for i in 0 ..< self.tracksToAdd.count {
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
        ProjectViewController.importTracks([track])
        self.navigationController?.popViewControllerAnimated(true)
    }

    func addAllTracks(sender: AnyObject?) {
        ProjectViewController.importTracks(self.tracksToAdd)
        self.navigationController?.popViewControllerAnimated(true)
    }

}
