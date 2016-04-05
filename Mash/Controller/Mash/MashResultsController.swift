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

class MashResultsController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate, AudioModuleDelegate {
    
    @IBOutlet weak var trackTable: UITableView!
    var results: [Track] = []
    var allResults: [Track] = []
    var projectRecordings: [Track] = []
    var projectPlayers: [AVAudioPlayer] = []
    var audioPlayer: AVAudioPlayer? = nil
    var playerTimer: NSTimer? = nil
    var currTrackID: Int = 0
    var downloadedTracks: Set<Int> = Set<Int>()
    var audioModule: AudioModule = AudioModule()
    var currentTrackURL: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.trackTable.delegate = self
        self.trackTable.dataSource = self
        self.audioModule.delegate = self
        
        let track = UINib(nibName: "Track", bundle: nil)
        self.trackTable.registerNib(track, forCellReuseIdentifier: "Track")
        
        for track in projectRecordings {
            self.projectPlayers.append(try! AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: track.trackURL)))
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.setHidesBackButton(false, animated: false)
        self.navigationItem.title = "Results"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: #selector(MashResultsController.done(_:)))
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationItem.setHidesBackButton(true, animated: false)
        self.navigationItem.rightBarButtonItem = nil
        if self.audioPlayer != nil {
            self.audioPlayer?.stop()
        }
        for audioPlayer in self.projectPlayers {
            audioPlayer.stop()
        }
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
        track.userLabel.setTitle(track.userText, forState: .Normal)
        track.bpm = trackData.bpm
        track.format = trackData.format
        track.userid = trackData.userid
        track.id = trackData.id
        track.instrumentFamilies = trackData.instrumentFamilies
        track.instruments = trackData.instruments
        track.trackURL = filePathString(getS3Key(track))
        if !self.downloadedTracks.contains(indexPath.row) {
            track.activityView.startAnimating()
            download(getS3WaveformKey(track), url: filePathURL(getS3WaveformKey(track)), bucket: waveform_bucket) {
                (result) in
                dispatch_async(dispatch_get_main_queue()) {
                    track.activityView.stopAnimating()
                    if result != nil {
                        track.staticAudioPlot.image = UIImage(contentsOfFile: filePathString(getS3WaveformKey(track)))
                    } else {
                        track.staticAudioPlot.image = UIImage(named: "waveform_static")
                    }
                }
            }
        }
        
        track.instrumentImage.image = findImage(self.results[indexPath.row].instrumentFamilies)
        track.addButton.addTarget(self, action: #selector(MashResultsController.add(_:)), forControlEvents: UIControlEvents.TouchDown)
        return track
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 75.0
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let track = self.trackTable.cellForRowAtIndexPath(indexPath) as! Track

        track.activityView.startAnimating()
        download(getS3Key(track), url: NSURL(fileURLWithPath: track.trackURL), bucket: track_bucket) {
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
    
    // Audio Module Delegate
    func audioFileDidFinishConverting(trackid: Int) {
        self.audioPlayer = try? AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: self.currentTrackURL))
        self.audioPlayer!.play()
        if self.playerTimer != nil {
            self.playerTimer!.invalidate()
        }
        self.playerTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(MashResultsController.play(_:)), userInfo: nil, repeats: true)
        self.currTrackID = trackid
        for player in self.projectPlayers {
            player.play()
        }
    }
    
    func loadNextData() {
        let currentNumResults = self.results.count
        if currentNumResults == self.allResults.count {
            return
        }
        for i in currentNumResults...currentNumResults + 15 {
            if i > self.allResults.count - 1 {
                break
            }
            self.results.append(self.allResults[i])
        }
        self.trackTable.reloadData()
    }
    
    func playTracks(track: Track) {
        if self.projectPlayers[0].playing {
            self.stopPlaying(nil)
        }
        
        if track.bpm != self.projectRecordings[0].bpm {
            let shiftAmount: Float = Float(self.projectRecordings[0].bpm) / Float(track.bpm)
            let newName = "new_\(track.id)"
            let newTrackURL = self.audioModule.timeShift(track.id, url: NSURL(fileURLWithPath: track.trackURL), newName: newName, shiftAmount: shiftAmount)
            track.trackURL = newTrackURL
            self.currentTrackURL = newTrackURL
            track.bpm = self.projectRecordings[0].bpm
        } else {
            self.audioPlayer = try? AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: track.trackURL))
            self.audioPlayer!.play()
            if self.playerTimer != nil {
                self.playerTimer!.invalidate()
            }
            self.playerTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(MashResultsController.play(_:)), userInfo: nil, repeats: true)
            self.currTrackID = track.id
            for player in self.projectPlayers {
                player.play()
            }
        }
    }
    
    func stopPlaying(sender: AnyObject?) {
        self.audioPlayer!.stop()
        for i in 0 ..< self.projectPlayers.count {
            self.projectPlayers[i].stop()
            self.projectPlayers[i].currentTime = 0
        }
    }
    
    func play(sender: NSTimer) {
        if self.audioPlayer!.currentTime >= (self.audioPlayer!.duration / 2) || self.audioPlayer!.currentTime > 10.0 {
            sendPlayRequest(self.currTrackID)
            sender.invalidate()
        }
    }
    
    func add(sender: UIButton) {
        let track = sender.superview?.superview?.superview as! Track
        ProjectViewController.importTracks([track], navigationController: self.navigationController, storyboard: self.storyboard)
        sendPushNotification(track.userid, message: "You've just been mashed!")
    }
    
    func done(sender: AnyObject?) {
        var index = 0
        for i in 0...self.navigationController!.viewControllers.count {
            if self.navigationController!.viewControllers[i] as? MashViewController != nil {
                index = i
                break
            }
        }
        self.navigationController!.viewControllers.removeAtIndex(index)
        self.navigationController?.popViewControllerAnimated(true)
    }
    
}
