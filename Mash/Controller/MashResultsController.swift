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

class MashResultsController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate {
    
    @IBOutlet weak var trackTable: UITableView!
    var results: [Track] = []
    var allResults: [Track] = []
    var projectRecordings: [Track] = []
    var projectPlayers: [AVAudioPlayer] = []
    var audioPlayer: AVAudioPlayer? = nil
    var downloadedTracks: Set<Int> = Set<Int>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.trackTable.delegate = self
        self.trackTable.dataSource = self
        
        let track = UINib(nibName: "Track", bundle: nil)
        self.trackTable.registerNib(track, forCellReuseIdentifier: "Track")
        let profile = UINib(nibName: "MashResultsHeaderView", bundle: nil)
        self.trackTable.registerNib(profile, forHeaderFooterViewReuseIdentifier: "MashResultsHeaderView")
        
        for track in projectRecordings {
            self.projectPlayers.append(AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: track.trackURL), error: nil))
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBarHidden = true
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBarHidden = false
    }
    
    // Table View Delegate
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.results.count
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == self.results.count - 1 {
            self.loadNextData()
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let track = tableView.dequeueReusableCellWithIdentifier("Track") as! Track
        let trackData = self.results[indexPath.row]
        track.titleText = trackData.titleText
        track.userText = trackData.userText
        track.title.text = track.titleText
        track.userLabel.text = track.userText
        track.bpm = trackData.bpm
        track.format = trackData.format
        track.trackURL = filePathString(getS3Key(track))
        if !contains(self.downloadedTracks, indexPath.row) {
            track.activityView.startAnimating()
            download(getS3WaveformKey(track), filePathURL(getS3WaveformKey(track)), waveform_bucket) {
                (result) in
                dispatch_async(dispatch_get_main_queue()) {
                    track.activityView.stopAnimating()
                    if result != nil {
                        track.staticAudioPlot.image = UIImage(contentsOfFile: filePathString(getS3WaveformKey(track)))
                    }
                }
            }
        }
        
        track.instrumentImage.image = findImage(self.results[indexPath.row].instrumentFamilies)
        track.addButton.addTarget(self, action: "done:", forControlEvents: UIControlEvents.TouchDown)
        return track
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 75.0
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50.0
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let track = self.trackTable.cellForRowAtIndexPath(indexPath) as! Track

        track.activityView.startAnimating()
        download(getS3Key(track), NSURL(fileURLWithPath: track.trackURL)!, track_bucket) {
            (result) in
            dispatch_async(dispatch_get_main_queue()) {
                track.activityView.stopAnimating()
                if result != nil {
                    track.generateWaveform()
                    self.playTracks(track)
                }
            }
        }
        self.downloadedTracks.insert(indexPath.row)
        
        Debug.printl("Playing track \(track.titleText)", sender: self)
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        if self.projectPlayers[0].playing {
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
    
    func loadNextData() {
        var currentNumResults = self.results.count - 1
        if currentNumResults == self.allResults.count - 1 {
            return
        }
        for i in currentNumResults...currentNumResults + 15 {
            if i >= self.allResults.count {
                break
            }
            self.results.append(self.allResults[i])
        }
        self.trackTable.reloadData()
    }
    
    func playTracks(track: Track) {
        let header = self.trackTable.headerViewForSection(0) as! MashResultsHeaderView
        if self.projectPlayers[0].playing {
            self.stopPlaying(nil)
        }
        
        if track.bpm != self.projectRecordings[0].bpm {
            var shiftAmount: Float = Float(self.projectRecordings[0].bpm) / Float(track.bpm)
            let newURL = AudioModule.timeShift(NSURL(fileURLWithPath: track.trackURL), newName: "new_\(track.titleText)", amountToShift: shiftAmount)
            track.trackURL = newURL
            track.bpm = self.projectRecordings[0].bpm
        }
        
        var error: NSError? = nil
        self.audioPlayer = AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: track.trackURL), error: nil)
        self.audioPlayer!.play()
        for player in self.projectPlayers {
            player.play()
        }
    }
    
    func stopPlaying(sender: AnyObject?) {
        self.audioPlayer!.stop()
        for (var i = 0; i < self.projectPlayers.count; i++) {
            self.projectPlayers[i].stop()
            self.projectPlayers[i].currentTime = 0
            let header = self.trackTable.headerViewForSection(0) as! MashResultsHeaderView
        }
    }
    
    func cancel(sender: AnyObject?) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func done(sender: UIButton) {
        var track = sender.superview?.superview?.superview as! Track
        let project = returnProjectView(self.navigationController!) as ProjectViewController!
        ProjectViewController.importTracks([track], navigationController: self.navigationController, storyboard: self.storyboard)
        self.navigationController?.popViewControllerAnimated(true)
    }
    
}
