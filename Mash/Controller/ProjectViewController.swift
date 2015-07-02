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

class ProjectViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate {

    @IBOutlet var tracks: UITableView!
    var data: [Track] = []
    var audioPlayers: [AVAudioPlayer] = []
    var header: UITableViewHeaderFooterView? = nil
    var tap: UITapGestureRecognizer? = nil
    var toolsShowing: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set up table options
        self.tracks.delegate = self
        self.tracks.dataSource = self

        // Register nibs
        let nib = UINib(nibName: "ProjectTrack", bundle: nil)
        self.tracks.registerNib(nib, forCellReuseIdentifier: "ProjectTrack")
        let header = UINib(nibName: "ProjectHeaderView", bundle: nil)
        self.tracks.registerNib(header, forHeaderFooterViewReuseIdentifier: "ProjectHeaderView")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.parentViewController?.navigationItem.title = "Your Project"
        if self.tracks != nil {
            self.tracks.reloadData()
        }
        self.tap = UITapGestureRecognizer(target: self, action: "showTools:")
        self.navigationController?.navigationBar.addGestureRecognizer(tap!)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.removeGestureRecognizer(tap!)
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ProjectTrack") as! ProjectTrack
        let trackData = self.data[indexPath.row]
        cell.trackTitle.text = trackData.titleText
        cell.instrumentImage.image = findImage(self.data[indexPath.row].instruments)
        cell.track = trackData
        return cell
    }

    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! ProjectHeaderView
        header.playButton.contentMode = UIViewContentMode.ScaleAspectFit
        let tap = UITapGestureRecognizer(target: self, action: "playTracks:")
        header.playButton.addGestureRecognizer(tap)
        header.optionsButton.addTarget(self, action: "showPreferences:", forControlEvents: UIControlEvents.TouchDown)
    }

    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterViewWithIdentifier("ProjectHeaderView") as! ProjectHeaderView
        self.header = header
        self.header?.hidden = true
        return header
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 75.0
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let trackNumber = indexPath.row
        if trackNumber >= self.audioPlayers.count {
            return
        }
        let player = self.audioPlayers[trackNumber]
        let track = self.tracks.cellForRowAtIndexPath(indexPath) as! ProjectTrack
        if player.volume == 0.0 {
            player.volume = 1.0
            track.speakerImage.image = UIImage(named: "speaker")
        } else {
            player.volume = 0.0
            track.speakerImage.image = UIImage(named: "speaker_2")
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
            self.audioPlayers.removeAtIndex(indexPath.row)
        }
    }

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
    
    func playTracks(sender: AnyObject?) {
        if (self.audioPlayers.count > 0 && self.audioPlayers[0].playing) {
            self.stopPlaying()
            return
        }
        for (var i = 0; i < self.audioPlayers.count; i++) {
            self.audioPlayers[i].play()
        }
        let header = self.tracks.headerViewForSection(0) as! ProjectHeaderView
        header.playButton.image = UIImage(named: "Play_2")
    }
    
    func stopPlaying() {
        for (var i = 0; i < self.audioPlayers.count; i++) {
            self.audioPlayers[i].stop()
            self.audioPlayers[i].currentTime = 0
        }
        if (self.tracks != nil && self.tracks.headerViewForSection(0) != nil) {
            let header = self.tracks.headerViewForSection(0) as! ProjectHeaderView
            header.playButton.image = UIImage(named: "Play")
        }
    }
    
    func mash() {
        if (self.data.count == 0) {
            var alert = UIAlertView(title: "Error", message: "You have no tracks in your project.", delegate: self, cancelButtonTitle: "OK")
            alert.show()
            return
        }
        let controller = self.storyboard?.instantiateViewControllerWithIdentifier("MashViewController") as! MashViewController
        controller.recording = self.data[0]
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    // Raise alert for save project
    func saveAlert() {
        var alert = UIAlertView(title: "Saving your Mash", message: "Please enter a name for your track.", delegate: self, cancelButtonTitle: "Cancel", otherButtonTitles: "Done")
        alert.alertViewStyle = UIAlertViewStyle.PlainTextInput
        alert.show()
    }
    
    func save(name: String) -> Bool {
        var directory = applicationDocumentsDirectory()
        var nextClipTime: CMTime = kCMTimeZero
        var composition: AVMutableComposition = AVMutableComposition()
        for (var i = 0; i < self.data.count; i++) {
            var track: Track = self.data[i]
            
            var compositionTrack: AVMutableCompositionTrack = composition.addMutableTrackWithMediaType(AVMediaTypeAudio, preferredTrackID: CMPersistentTrackID())
            var asset: AVAsset = AVURLAsset(URL: NSURL(fileURLWithPath: track.trackURL), options: nil)
            var tracks: NSArray = asset.tracksWithMediaType(AVMediaTypeAudio)
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
        upload(name, NSURL(fileURLWithPath: url)!, track_bucket)
        
        // Post data to server
        let username = NSUserDefaults.standardUserDefaults().valueForKey("username") as! String
        let passwordHash = hashPassword(keychainWrapper.myObjectForKey("v_Data") as! String)
        var instruments: [String] = []
        for track in self.data {
            for instr in track.instruments {
                instruments.append(instr)
            }
        }
        var instrumentString = String(stringInterpolationSegment: instruments)
        var request = NSMutableURLRequest(URL: NSURL(string: "\(db)/upload")!)
        var params: [String: String] = ["username": username, "password_hash": passwordHash, "song_name": name, "bpm": "0", "bar": "0", "key": "0", "instrument": instrumentString, "family": "", "genre": "", "subgenre": "", "feel": "0", "effects": "", "theme": "", "solo": "0", "format": ".m4a"]

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
    
    func addTracks(sender: AnyObject?) {
        Debug.printl("Pushing new searchcontroller.", sender: self)
        let controller = self.storyboard?.instantiateViewControllerWithIdentifier("SearchViewController") as! SearchViewController
        self.navigationController?.pushViewController(controller, animated: false)
    }
    
    func removeTrack(sender: UISwipeGestureRecognizer?) {
        let track = sender?.view as! ProjectTrack
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

    // Raise Alert for New Project
    func confirmNewProject() {
        let alert = UIAlertView(title: "Create a New Project?", message: "You Will Lose Any Unsaved Changes", delegate: self, cancelButtonTitle: "Cancel", otherButtonTitles: "OK")
        alert.show()
    }
    
    // Create New Project
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
    
    func showTools(sender: AnyObject?) {
        if !self.toolsShowing {
            Debug.printl("Showing tools", sender: self)
            self.header?.hidden = false
            UIView.animateWithDuration(0.3, animations: { self.header!.frame.size.height = 60 }) {
                (finished: Bool) in
                self.toolsShowing = true
            }
        } else {
            Debug.printl("Hiding tools", sender: self)
            UIView.animateWithDuration(0.3, animations: { self.header!.frame.size.height = 0 }) {
                (finished: Bool) in
                self.header?.hidden = true
                self.toolsShowing = false
            }
        }
    }
    
    func showPreferences(sender: AnyObject?) {
        let controller = self.storyboard?.instantiateViewControllerWithIdentifier("ProjectPreferencesViewController") as! ProjectPreferencesViewController
        controller.projectView = self
        self.navigationController?.pushViewController(controller, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
