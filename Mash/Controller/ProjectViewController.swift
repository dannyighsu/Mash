//
//  ProjectViewController.swift
//  Mash-iOS
//
//  Created by Danny Hsu on 11/23/14.
//  Copyright (c) 2015 Mash. All rights reserved.
//

import UIKit
import AVFoundation
import EZAudio

class ProjectViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, PlayerDelegate, MetronomeDelegate, ChannelDelegate {

    @IBOutlet var tracks: UITableView!
    var data: [Track] = []
    var audioPlayer: ProjectPlayer? = nil
    var toolsTap: UITapGestureRecognizer? = nil
    var mixerShowing: Bool = false
    var activityView: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
    var metronome: Metronome = Metronome.createView()
    var bpm: Int = 120

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set up table options
        self.tracks.delegate = self
        self.tracks.dataSource = self
        self.tracks.backgroundColor = offWhite()
        self.tracks.separatorStyle = .SingleLine
        self.tracks.tableFooterView = UIView(frame: CGRectZero)

        // Register nibs
        let nib = UINib(nibName: "Channel", bundle: nil)
        self.tracks.registerNib(nib, forCellReuseIdentifier: "Channel")
        let header = UINib(nibName: "ProjectTools", bundle: nil)
        self.tracks.registerNib(header, forHeaderFooterViewReuseIdentifier: "ProjectTools")
        let player = UINib(nibName: "ProjectPlayer", bundle: nil)
        self.tracks.registerNib(player, forHeaderFooterViewReuseIdentifier: "ProjectPlayer")
        
        self.view.addSubview(self.activityView)
        self.activityView.center = self.view.center
        
        self.metronome.delegate = self
        
        var view = NSBundle.mainBundle().loadNibNamed("ProjectPlayer", owner: nil, options: nil)
        let head = view[0] as! ProjectPlayer
        self.audioPlayer = head
        self.audioPlayer?.delegate = self
        self.tracks.tableHeaderView = head
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        /*self.parentViewController?.navigationItem.setRightBarButtonItem(UIBarButtonItem(title: "Tools", style: UIBarButtonItemStyle.Plain, target: self, action: "showTools:"), animated: false)
        self.parentViewController?.navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "STHeitiSC-Light", size: 15)!, NSForegroundColorAttributeName: UIColor.whiteColor()], forState: UIControlState.Normal)*/
        let value = UIInterfaceOrientation.LandscapeRight.rawValue
        UIDevice.currentDevice().setValue(value, forKey: "orientation")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBarHidden = true
        self.view.frame = self.tabBarController!.view.frame
        /*self.parentViewController?.navigationItem.title = "Your Project"*/
        /*self.navigationController?.navigationBar.addGestureRecognizer(self.toolsTap!)*/
        if self.tracks != nil {
            self.tracks.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.None)
            self.metronome.setTempo(self.bpm)
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBarHidden = false
        /*self.navigationController?.navigationBar.removeGestureRecognizer(self.toolsTap!)
        self.parentViewController?.navigationItem.setRightBarButtonItem(nil, animated: false)*/
        self.audioPlayer!.stop()
        if self.metronome.isPlaying {
            self.metronome.toggle(nil)
        }
    }
    
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    override func supportedInterfaceOrientations() -> Int {
        return Int(UIInterfaceOrientationMask.LandscapeRight.rawValue)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    // TableView delegate
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Channel") as! Channel
        let trackData = self.data[indexPath.row]
        cell.trackTitle.text = trackData.titleText
        cell.instrumentImage.image = findImage(self.data[indexPath.row].instrumentFamilies)
        cell.track = trackData
        cell.backgroundColor = lightGray()
        cell.trackNumber = indexPath.row
        cell.delegate = self
        cell.generateWaveform()
        return cell
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 85.0
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            let trackNumber = indexPath.row
            if trackNumber >= self.audioPlayer!.audioPlayers.count {
                return
            }
            var muted = self.audioPlayer!.muteTrack(trackNumber)
            let track = self.tracks.cellForRowAtIndexPath(indexPath) as! Channel
            if muted {
                track.speakerButton.setImage(UIImage(named: "speaker_white_2"), forState: UIControlState.Normal)
            } else {
                track.speakerButton.setImage(UIImage(named: "speaker_white"), forState: UIControlState.Normal)
            }
        }
        tableView.cellForRowAtIndexPath(indexPath)?.selected = false
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            self.data.removeAtIndex(indexPath.row)
            self.tracks.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Left)
            self.audioPlayer!.audioPlayers.removeAtIndex(indexPath.row)
        }
    }
    
    // AlertView delegate
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if alertView.title == "Create a New Project?" {
            if buttonIndex == 1 {
                self.newProject()
            }
        } else if alertView.title == "Saving your Mash" {
            if buttonIndex == 1 {
                var title = alertView.textFieldAtIndex(0)!.text
                self.save(title)
            }
        }
    }
    
    func saveAlert() {
        var alert = UIAlertView(title: "Saving your Mash", message: "Please enter a name for your track.", delegate: self, cancelButtonTitle: "Cancel", otherButtonTitles: "Done")
        alert.alertViewStyle = UIAlertViewStyle.PlainTextInput
        alert.show()
    }
    
    // Player Delegate
    func showTools() {
        let controller = self.storyboard?.instantiateViewControllerWithIdentifier("ProjectPreferencesViewController") as! ProjectPreferencesViewController
        controller.projectView = self
        self.navigationController?.pushViewController(controller, animated: true)
    }

    func showMixer() {
        if !self.mixerShowing {
        
        } else {
            
        }
    }
    
    func addTracks() {
        Debug.printl("Pushing new searchcontroller.", sender: self)
        let controller = self.storyboard?.instantiateViewControllerWithIdentifier("SearchViewController") as! SearchViewController
        self.navigationController?.pushViewController(controller, animated: false)
    }
    
    func toggleMetronome() {
        self.metronome.muteAudio(nil)
    }
    
    func didPressPlay(audioPlayer: ProjectPlayer) {
        self.metronome.toggle(nil)
    }
    
    func didStopPlaying(audioPlayer: ProjectPlayer) {
        if self.metronome.isPlaying {
            self.metronome.toggle(nil)
        }
    }

    // Metronome Delegate
    func tick(metronome: Metronome) {
        
    }
    
    // Channel Delegate
    func channelVolumeDidChange(channel: Channel, number: Int, value: Float) {
        self.audioPlayer!.audioPlayers[number].volume = value
    }
    
    // Save methods
    func save(name: String) -> Bool {
        var directory = applicationDocumentsDirectory()
        var nextClipTime: CMTime = kCMTimeZero
        var composition: AVMutableComposition = AVMutableComposition()
        for (var i = 0; i < self.data.count; i++) {
            var track: Track = self.data[i]
            
            var compositionTrack: AVMutableCompositionTrack = composition.addMutableTrackWithMediaType(AVMediaTypeAudio, preferredTrackID: CMPersistentTrackID())
            var asset: AVAsset = AVURLAsset(URL: NSURL(fileURLWithPath: track.trackURL), options: nil)
            var tracks: NSArray = asset.tracks
            var clip: AVAssetTrack = tracks.objectAtIndex(0) as! AVAssetTrack
            compositionTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, asset.duration), ofTrack: clip, atTime: kCMTimeZero, error: nil)
        }
        
        var exportSession: AVAssetExportSession? = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetAppleM4A)
        if (exportSession == nil) {
            return false
        }
        var newTrack = directory.stringByAppendingPathComponent(name + ".m4a")
        exportSession?.outputURL = NSURL(fileURLWithPath: newTrack)
        exportSession?.outputFileType = AVFileTypeAppleM4A
        exportSession?.exportAsynchronouslyWithCompletionHandler() {
            if exportSession?.status == AVAssetExportSessionStatus.Completed {
                Debug.printl("File export of track \(name) completed", sender: self)
                self.uploadAction(newTrack, name: name + ".m4a")
            } else if exportSession?.status == AVAssetExportSessionStatus.Failed {
                Debug.printl("File export failed.", sender: self)
            } else {
                Debug.printl("File export status: \(exportSession?.status)", sender: self)
            }
        }
        
        return true
    }
    
    func uploadAction(url: String, name: String) {
        upload("\(current_user.handle!)~~\(name).m4a", NSURL(fileURLWithPath: url)!, track_bucket)
        
        // Post data to server
        let handle = NSUserDefaults.standardUserDefaults().valueForKey("username") as! String
        let passwordHash = hashPassword(keychainWrapper.myObjectForKey("v_Data") as! String)
        var instruments: [String] = []
        var families: [String] = []

        for track in self.data {
            for instr in track.instruments {
                instruments.append(instr)
            }
            for fam in track.instrumentFamilies {
                families.append(fam)
            }
        }
        var instrumentString = String(stringInterpolationSegment: instruments)
        instrumentString = instrumentString.substringWithRange(Range<String.Index>(start: advance(instrumentString.startIndex, 1), end: advance(instrumentString.endIndex, -1)))
        var familyString = String(stringInterpolationSegment: families)
        familyString = familyString.substringWithRange(Range<String.Index>(start: advance(familyString.startIndex, 1), end: advance(familyString.endIndex, -1)))
        
        var request = NSMutableURLRequest(URL: NSURL(string: "\(db)/upload")!)
        var params: [String: String] = ["handle": handle, "password_hash": passwordHash, "title": name, "bpm": "0", "bar": "0", "key": "0", "instrument": "{\(instrumentString)}", "family": "{\(familyString)}", "genre": "{}", "subgenre": "{}", "feel": "0", "solo": "0", "format": ".m4a"]

        httpPost(params, request) {
            (data, statusCode, error) -> Void in
            if error != nil {
                Debug.printl("Error: \(error)", sender: self)
                return
            } else {
                // Check status codes
                if statusCode == HTTP_ERROR {
                    Debug.printl("Error: \(error)", sender: self)
                    return
                } else if statusCode == HTTP_WRONG_MEDIA {
                    return
                } else if statusCode == HTTP_SUCCESS {
                    dispatch_async(dispatch_get_main_queue()) {
                        var alert = UIAlertView(title: "Success!", message: "Your Mash has been Saved.", delegate: self, cancelButtonTitle: "OK")
                        alert.show()
                    }
                    Debug.printl("Data: \(data)", sender: self)
                    return
                } else {
                    Debug.printl("Unrecognized status code from server: \(statusCode)", sender: self)
                    return
                }
            }
        }
    }
    
    // Track management
    func removeTrack(sender: UISwipeGestureRecognizer?) {
        let track = sender?.view as! Channel
        var trackIndex: Int? = nil
        Debug.printl("Removing track \(track)", sender: self)
        for (var i = 0; i < self.data.count; i++) {
            if self.data[i].titleText == track.trackTitle.text {
                self.data.removeAtIndex(i)
                trackIndex = i
            }
        }

        self.tracks.reloadData()
    }
    
    func playTracks(sender: AnyObject?) {
        if self.audioPlayer!.audioPlayers.count == 0 {
            return
        }
        if (self.audioPlayer!.audioPlayers.count > 0) {
            self.audioPlayer!.stop()
            return
        }
        self.audioPlayer!.play()
    }
    
    func mash() {
        if (self.data.count == 0) {
            var alert = UIAlertView(title: "Error", message: "You have no tracks in your project.", delegate: self, cancelButtonTitle: "OK")
            alert.show()
            return
        }
        let controller = self.storyboard?.instantiateViewControllerWithIdentifier("MashViewController") as! MashViewController
        for track in self.data {
            controller.recordings.append(track)
        }
        self.navigationController?.pushViewController(controller, animated: true)
    }

    // New Project
    func confirmNewProject() {
        let alert = UIAlertView(title: "Create a New Project?", message: "You Will Lose Any Unsaved Changes", delegate: self, cancelButtonTitle: "Cancel", otherButtonTitles: "OK")
        alert.show()
    }
    
    func newProject() {
        Debug.printl("Creating new project view", sender: self)
        let thisController = self
        var projectViewIndex = getTabBarController("project")
        let tabBarController = self.navigationController?.viewControllers[2] as! TabBarController
        var newTabBarController: NSMutableArray = NSMutableArray()
        newTabBarController.addObjectsFromArray(tabBarController.viewControllers!)
        let newProjectView = self.storyboard?.instantiateViewControllerWithIdentifier("ProjectViewController") as! ProjectViewController
        newTabBarController.replaceObjectAtIndex(projectViewIndex, withObject: newProjectView)
        tabBarController.setViewControllers(newTabBarController as [AnyObject], animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
