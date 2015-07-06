//
//  MashResultsController.swift
//  Mash-iOS
//
//  Created by Danny Hsu on 6/19/15.
//  Copyright (c) 2015 Mash. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import EZAudio

class MashResultsController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate {
    
    @IBOutlet weak var trackTable: UITableView!

    var results: [Track] = []
    var recording: Track? = nil
    var audioPlayers: [AVAudioPlayer] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.trackTable.delegate = self
        self.trackTable.dataSource = self
        self.trackTable.separatorStyle = .None
        
        let track = UINib(nibName: "Track", bundle: nil)
        self.trackTable.registerNib(track, forCellReuseIdentifier: "Track")
        let profile = UINib(nibName: "MashResultsHeaderView", bundle: nil)
        self.trackTable.registerNib(profile, forHeaderFooterViewReuseIdentifier: "MashResultsHeaderView")
        
        self.audioPlayers.append(AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: self.recording!.trackURL), error: nil))
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBarHidden = true
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBarHidden = false
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.results.count
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        let track = cell as! Track
        let trackData = self.results[indexPath.row]
        track.titleText = trackData.titleText
        track.userText = trackData.userText
        track.title.text = track.titleText
        track.userLabel.text = track.userText
        track.bpm = trackData.bpm
        track.format = trackData.format
        track.trackURL = filePathString(track.titleText + track.format)
        download("\(track.userText)~~\(track.titleText).\(track.format)", NSURL(fileURLWithPath: track.trackURL)!, track_bucket)

        track.imageView?.image = findImage(self.results[indexPath.row].instrumentFamilies)
        let doneTap = UITapGestureRecognizer(target: self, action: "done:")
        track.addButton.addGestureRecognizer(doneTap)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Track") as! Track
        return cell
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 75.0
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50.0
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let track = self.trackTable.cellForRowAtIndexPath(indexPath) as! Track

        while !NSFileManager.defaultManager().fileExistsAtPath(track.trackURL) {
            Debug.printnl("waiting...")
            NSThread.sleepForTimeInterval(0.5)
        }
        NSThread.sleepForTimeInterval(0.5)
        
        self.playTracks(track)
        Debug.printl("Playing track \(track.titleText)", sender: self)
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        if self.audioPlayers[0].playing {
            self.stopPlaying(nil)
        }
    }
    
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! MashResultsHeaderView
        header.cancelButton.addTarget(self, action: "cancel:", forControlEvents: UIControlEvents.TouchDown)
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = self.trackTable.dequeueReusableHeaderFooterViewWithIdentifier("MashResultsHeaderView") as! MashResultsHeaderView
        return header
    }
    
    func playTracks(track: Track) {
        let header = self.trackTable.headerViewForSection(0) as! MashResultsHeaderView
        if self.audioPlayers.count < 1 {
            return
        }
        if self.audioPlayers[0].playing {
            self.stopPlaying(nil)
        }
        var error: NSError? = nil
        if self.audioPlayers.count == 2 {
            self.audioPlayers.removeAtIndex(1)
        }
        self.audioPlayers.append(AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: track.trackURL), error: &error))
        NSThread.sleepForTimeInterval(0.3)
        self.audioPlayers[0].play()
        self.audioPlayers[1].play()
    }
    
    func stopPlaying(sender: AnyObject?) {
        for (var i = 0; i < self.audioPlayers.count; i++) {
            self.audioPlayers[i].stop()
            self.audioPlayers[i].currentTime = 0
            let header = self.trackTable.headerViewForSection(0) as! MashResultsHeaderView
        }
    }
    
    func cancel(sender: AnyObject?) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func done(sender: AnyObject?) {
        if self.trackTable.indexPathForSelectedRow() == nil {
            let alert = UIAlertView(title: "Error", message: "Please select a track.", delegate: self, cancelButtonTitle: "OK")
            alert.show()
            return
        } else {
            let track = self.results[self.trackTable.indexPathForSelectedRow()!.row]
            let project = returnProjectView(self.navigationController!) as ProjectViewController!
            importTracks([track], self.navigationController, self.storyboard)
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
    
}
