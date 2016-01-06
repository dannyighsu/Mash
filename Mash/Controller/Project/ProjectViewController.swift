//
//  ProjectViewController.swift
//  Mash-iOS
//
//  Created by Danny Hsu on 11/23/14.
//  Copyright (c) 2015 Mash. All rights reserved.
//

import UIKit
import AVFoundation

class ProjectViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, PlayerDelegate, MetronomeDelegate, ChannelDelegate, AudioModuleDelegate {

    @IBOutlet var tracks: UITableView!
    @IBOutlet weak var header: UIView!
    @IBOutlet weak var titleButton: UIButton!
    var data: [Track] = []
    var audioPlayer: ProjectPlayer? = nil
    var toolsTap: UITapGestureRecognizer? = nil
    var mixerShowing: Bool = false
    var activityView: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
    var metronome: Metronome = Metronome.createView()
    var bpm: Int = 120
    var audioModule: AudioModule = AudioModule()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set up table options
        self.tracks.delegate = self
        self.tracks.dataSource = self
        self.tracks.backgroundColor = offWhite()
        self.tracks.tableFooterView = UIView(frame: CGRectZero)
        self.tracks.separatorColor = darkBlueTranslucent()
        self.tracks.allowsSelection = false

        // Register nibs
        let nib = UINib(nibName: "Channel", bundle: nil)
        self.tracks.registerNib(nib, forCellReuseIdentifier: "Channel")
        let header = UINib(nibName: "ProjectTools", bundle: nil)
        self.tracks.registerNib(header, forHeaderFooterViewReuseIdentifier: "ProjectTools")
        let player = UINib(nibName: "ProjectPlayer", bundle: nil)
        self.tracks.registerNib(player, forHeaderFooterViewReuseIdentifier: "ProjectPlayer")
        let addbar = UINib(nibName: "ProjectAddBar", bundle: nil)
        self.tracks.registerNib(addbar, forCellReuseIdentifier: "ProjectAddBar")
        
        self.view.addSubview(self.activityView)
        
        self.metronome.delegate = self
        self.audioModule.delegate = self
        
        var view = NSBundle.mainBundle().loadNibNamed("ProjectPlayer", owner: nil, options: nil)
        let head = view[0] as! ProjectPlayer
        head.tempoLabel.keyboardType = .NumberPad
        head.volumeSlider.tintColor = lightBlue()
        self.audioPlayer = head
        self.audioPlayer?.delegate = self
        self.tracks.tableHeaderView = head
        
        self.titleButton.addTarget(self, action: "changeTitle:", forControlEvents: UIControlEvents.TouchUpInside)
        self.titleButton.setTitle("My Project", forState: UIControlState.Normal)
        let swipe = UISwipeGestureRecognizer(target: self, action: "dismiss:")
        swipe.direction = .Down
        self.header.addGestureRecognizer(swipe)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if self.tracks != nil {
            self.tracks.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.None)
            self.metronome.setTempo(self.bpm)
        }
        
        let player = self.tracks.tableHeaderView as! ProjectPlayer
        player.tempoLabel.text = "\(self.bpm)"
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        // Force landscape
        //let value = UIInterfaceOrientation.LandscapeRight.rawValue
        //UIDevice.currentDevice().setValue(value, forKey: "orientation")
        self.activityView.center = self.view.center
        self.audioPlayer!.resetPlayers()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.audioPlayer!.stop()
        self.navigationItem.titleView = nil
        if self.metronome.isPlaying {
            self.metronome.toggle(nil)
        }
    }
    
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func dismiss(sender: UISwipeGestureRecognizer) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // TableView delegate
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return self.data.count
        } else {
            return 1
        }
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("Channel") as! Channel
            let trackData = self.data[indexPath.row]
            cell.trackTitle.text = trackData.titleText
            cell.instrumentImage.image = findImage(self.data[indexPath.row].instrumentFamilies)
            cell.track = trackData
            cell.trackNumber = indexPath.row
            cell.delegate = self
            
            cell.generateWaveform()
            cell.audioPlot.color = lightBlue()
            cell.audioPlot.layer.cornerRadius = 4.0
            cell.audioPlot.clipsToBounds = true
            cell.audioPlot.backgroundColor = darkBlueTranslucent()

            cell.content.layer.cornerRadius = 4.0
            cell.backgroundColor = UIColor.clearColor()
            
            let trans = CGAffineTransformMakeRotation(CGFloat(M_PI * -0.5))
            cell.volumeSlider.transform = trans
            cell.volumeSlider.minimumTrackTintColor = UIColor.blackColor()
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("ProjectAddBar") as! ProjectAddBar
            cell.addButton.layer.cornerRadius = 4.0
            cell.addButton.addTarget(self, action: "mash", forControlEvents: UIControlEvents.TouchUpInside)
            cell.backgroundColor = UIColor.clearColor()
            return cell
        }
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 85.0
        } else {
            return 44.0
        }
    }
    
    /*func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            let trackNumber = indexPath.row
            if trackNumber >= self.audioPlayer!.audioPlayers.count {
                return
            }
        }
        tableView.cellForRowAtIndexPath(indexPath)?.selected = false
    }*/
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if indexPath.section == 0 {
            return true
        } else {
            return false
        }
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            self.data.removeAtIndex(indexPath.row)
            
            self.tracks.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Left)
            
            // Update indices of channels
            if self.data.count > 1 && indexPath.row < self.data.count {
                for _ in indexPath.row + 1...self.data.count {
                    let channel = tableView.cellForRowAtIndexPath(indexPath) as! Channel
                    channel.trackNumber! -= 1
                }
            }
            
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
                let title = alertView.textFieldAtIndex(0)!.text
                self.titleButton.setTitle(title, forState: UIControlState.Normal)
                self.uploadSavedTrack(title!)
            }
        } else if alertView.title == "Sharing your Mash" {
            if buttonIndex == 1 {
                let title = alertView.textFieldAtIndex(0)!.text
                self.titleButton.setTitle(title, forState: UIControlState.Normal)
                rootTabBarController!.tabBarButton!.tapButton.setTitle(title, forState: .Normal)
                self.shareTrack(title!)
            }
        } else if alertView.title == "Name Your Track" {
            if buttonIndex == 1 {
                let title = alertView.textFieldAtIndex(0)!.text
                self.titleButton.setTitle(title, forState: UIControlState.Normal)
                rootTabBarController!.tabBarButton!.tapButton.setTitle(title, forState: .Normal)
            }
        }
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
        self.mash()
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
    
    func tempoLabelDidEndEditing(textField: UITextField) {
        if self.audioPlayer!.isPlaying {
            self.audioPlayer!.stop()
        }
        var newBPM = Int(textField.text!)!
        if newBPM < 40 {
            newBPM = 40
        } else if newBPM > 220 {
            newBPM = 220
        }
        
        self.activityView.startAnimating()
        textField.text = "\(newBPM)"
        self.bpm = newBPM
        self.timeShiftAll(self.bpm)
    }
    
    // Track management
    func removeTrack(sender: UISwipeGestureRecognizer?) {
        let track = sender?.view as! Channel
        Debug.printl("Removing track \(track)", sender: self)
        for (var i = 0; i < self.data.count; i++) {
            if self.data[i].titleText == track.trackTitle.text {
                self.data.removeAtIndex(i)
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

    // Metronome Delegate
    func tick(metronome: Metronome) {
        
    }
    
    // Channel Delegate
    func channelVolumeDidChange(channel: Channel, number: Int, value: Float) {
        self.audioPlayer!.audioPlayers[number].volume = value
    }
    
    // Preferences methods
    func changeTitle(sender: AnyObject?) {
        let alert = UIAlertView(title: "Name Your Track", message: "", delegate: self, cancelButtonTitle: "Cancel", otherButtonTitles: "Ok")
        alert.alertViewStyle = UIAlertViewStyle.PlainTextInput
        alert.textFieldAtIndex(0)?.text = self.titleButton.titleLabel?.text
        alert.show()
    }
    
    func save() {
        if self.data.count < 1 {
            raiseAlert("Oops!", delegate: self, message: "There must be a track in your project to save.")
            return
        }
        if !testing {
            Flurry.logEvent("Project_Save", withParameters: ["userid": currentUser.userid!, "numTracks": self.data.count])
        }
        let alert = UIAlertView(title: "Saving your Mash", message: "Please enter a name for your track.", delegate: self, cancelButtonTitle: "Cancel", otherButtonTitles: "Done")
        alert.alertViewStyle = UIAlertViewStyle.PlainTextInput
        alert.textFieldAtIndex(0)?.text = self.titleButton.titleLabel?.text
        alert.show()
    }
    
    func uploadSavedTrack(name: String) -> Bool {
        // Mix audio
        AudioModule.mixTracks(name, tracks: self.data) {
            (exportSession) in
            if exportSession == nil || exportSession!.status == AVAssetExportSessionStatus.Failed {
                raiseAlert("Error exporting file.", delegate: self)
            } else {
                Debug.printl("File export of track \(name) completed", sender: self)
                self.uploadAction(exportSession!.outputURL!, name: name)
            }
        }
        
        return true
    }
    
    func share() {
        if self.data.count < 1 {
            raiseAlert("Oops!", delegate: self, message: "There must be a track in your project to share.")
            return
        }
        if !testing {
            Flurry.logEvent("Project_Share", withParameters: ["userid": currentUser.userid!, "numTracks": self.data.count])
        }
        let alert = UIAlertView(title: "Sharing your Mash", message: "Please enter a name for your track.", delegate: self, cancelButtonTitle: "Cancel", otherButtonTitles: "Done")
        alert.alertViewStyle = UIAlertViewStyle.PlainTextInput
        alert.textFieldAtIndex(0)?.text = self.titleButton.titleLabel?.text
        alert.show()
    }
    
    func shareTrack(name: String) {
        AudioModule.mixTracks(name, tracks: self.data) {
            (exportSession) in
            if exportSession == nil || exportSession!.status == AVAssetExportSessionStatus.Failed {
                raiseAlert("Error exporting file.", delegate: self)
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    let sharingObjects = [filePathURL("\(currentUser.userid!)~~\(name).m4a")]
                    let activityController = UIActivityViewController(activityItems: sharingObjects, applicationActivities: nil)
                    self.presentViewController(activityController, animated: true, completion: nil)
                }
            }
        }
    }
    
    func mash() {
        if (self.data.count == 0) {
            let alert = UIAlertView(title: "Error", message: "You have no tracks in your project.", delegate: self, cancelButtonTitle: "OK")
            alert.show()
            return
        }
        let controller = self.storyboard?.instantiateViewControllerWithIdentifier("MashViewController") as! MashViewController
        for track in self.data {
            controller.recordings.append(track)
        }
        self.navigationController?.pushViewController(controller, animated: true)
    }

    func confirmNewProject() {
        let alert = UIAlertView(title: "Create a New Project?", message: "You Will Lose Any Unsaved Changes", delegate: self, cancelButtonTitle: "Cancel", otherButtonTitles: "OK")
        alert.show()
    }
    
    func newProject() {
        Debug.printl("Creating new project view", sender: self)
        
        let newProjectView = self.storyboard!.instantiateViewControllerWithIdentifier("ProjectViewController") as! ProjectViewController
        currentProject = newProjectView
        self.navigationController?.popViewControllerAnimated(false)
        self.navigationController?.pushViewController(newProjectView, animated: false)
        /*
        let tabBarController = self.navigationController?.viewControllers[2] as! TabBarController
        tabBarController.viewControllers!.removeAtIndex(getTabBarController(("project")))
        tabBarController.viewControllers!.insert(newProjectView, atIndex: getTabBarController("project"))
        tabBarController.selectedIndex = getTabBarController("project")*/
    }
    
    // Audio Module Delegate
    func audioFileDidFinishConverting(trackid: Int) {
        for i in 0...self.audioPlayer!.tracks.count - 1 {
            if self.audioPlayer!.tracks[i].id == trackid {
                self.audioPlayer?.resetPlayer(i)
                self.activityView.stopAnimating()
                return
            }
        }
        
        self.audioPlayer?.addTrack(self.data[self.audioPlayer!.tracks.count])
        self.activityView.stopAnimating()
    }
    
    // Helpers
    func timeShiftAll(bpm: Int) {
        self.activityView.startAnimating()
        for track in self.data {
            let shiftAmount: Float = Float(self.bpm) / Float(track.bpm)
            let newName = "new_\(track.id)"
            let newTrackURL = self.audioModule.timeShift(track.id, url: NSURL(fileURLWithPath: track.trackURL), newName: newName, shiftAmount: shiftAmount)
            track.trackURL = newTrackURL
            track.bpm = self.bpm
        }
    }
    
    func uploadAction(url: NSURL, name: String) {
        // Post data to server
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
        instrumentString = instrumentString.substringWithRange(Range<String.Index>(start: instrumentString.startIndex.advancedBy(1), end: instrumentString.endIndex.advancedBy(-1)))
        var familyString = String(stringInterpolationSegment: families)
        familyString = familyString.substringWithRange(Range<String.Index>(start: familyString.startIndex.advancedBy(1), end: familyString.endIndex.advancedBy(-1)))
        
        let request = RecordingUploadRequest()
        request.userid = UInt32(currentUser.userid!)
        request.loginToken = currentUser.loginToken
        request.title = name
        request.bpm = 0
        request.bar = 0
        request.key = "C"
        request.instrumentArray = [instrumentString]
        request.familyArray = [familyString]
        request.genreArray = []
        request.subgenreArray = []
        request.feel = 0
        request.solo = true
        request.format = ".m4a"
        
        server.recordingUploadWithRequest(request) {
            (response, error) in
            if error != nil {
                Debug.printl("Error: \(error)", sender: nil)
                dispatch_async(dispatch_get_main_queue()) {
                    self.activityView.stopAnimating()
                    if error.code == 13 {
                        raiseAlert("Error", delegate: self, message: "Track exists.")
                    } else {
                        raiseAlert("Error occurred. \(error.code)")
                    }
                }
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    let id = Int(response.recid)
                    upload("\(currentUser.userid!)~~\(id).m4a", url: url, bucket: track_bucket)
                    
                    // FIXME: Using waveform of first track for now
                    let waveformKey = "\(currentUser.userid!)~~\(id)_waveform.jpg"
                    upload(waveformKey, url: filePathURL("\(currentUser.userid!)~~\(self.data[0].id)_waveform.jpg"), bucket: waveform_bucket)
                    let alert = UIAlertView(title: "Success!", message: "Your Mash has been Saved.", delegate: self, cancelButtonTitle: "OK")
                    alert.show()
                }
            }
        }
    }
    
    class func importTracks(tracks: [Track], navigationController: UINavigationController?, storyboard: UIStoryboard?) {
        /*var project: ProjectViewController? = nil
        let tabBarController = navigationController?.viewControllers[2] as! UITabBarController
        
        for (var i = 0; i < tabBarController.viewControllers!.count; i++) {
            let controller = tabBarController.viewControllers![i] as? ProjectViewController
            if controller != nil {
                Debug.printl("Using existing project view controller", sender: "helpers")
                project = controller
                break
            }
        }*/
        
        if currentProject == nil {
            raiseAlert("You have not created a project yet.")
            return
        }
        
        let project: ProjectViewController? = currentProject
        
        // If this is the first track, set the project's bpm
        if project!.data.count == 0 {
            project!.bpm = tracks[0].bpm
        }
        
        // Download new tracks asynchronously
        project!.activityView.startAnimating()
        
        for track in tracks {
            let URL = NSURL(fileURLWithPath: track.trackURL)
            download(getS3Key(track), url: URL, bucket: track_bucket) {
                (result) in
                
                if track.bpm != project!.bpm {
                    let shiftAmount: Float = Float(project!.bpm) / Float(track.bpm)
                    let newName = "new_\(track.id)"
                    
                    project!.audioModule.delegate = project
                    let newTrackURL = project!.audioModule.timeShift(track.id, url: NSURL(fileURLWithPath: track.trackURL), newName: newName, shiftAmount: shiftAmount)
                    track.trackURL = newTrackURL
                    track.bpm = project!.bpm
                    
                    Debug.printl("Adding track with \(track.instrumentFamilies), url \(track.trackURL) named \(track.titleText) to project view", sender: "helpers")
                    project?.data.append(track)
                    dispatch_async(dispatch_get_main_queue()) {
                        if project?.tracks != nil {
                            project!.tracks.reloadData()
                            project!.activityView.stopAnimating()
                        }
                    }
                } else {
                    Debug.printl("Adding track with \(track.instrumentFamilies), url \(track.trackURL) named \(track.titleText) to project view", sender: "helpers")
                    project?.data.append(track)
                    
                    // Create audio player
                    let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
                    dispatch_async(dispatch_get_global_queue(priority, 0)) {
                        while project!.audioPlayer == nil {
                            NSThread.sleepForTimeInterval(0.1)
                        }
                        project!.audioPlayer!.addTrack(track)
                        dispatch_async(dispatch_get_main_queue()) {
                            project!.activityView.stopAnimating()
                            project!.tracks.reloadData()
                        }
                    }
                }
            }
        }
        raiseAlert("Sound added to project.")
    }

}
