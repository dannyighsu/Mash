
//
//  DashboardController.swift
//  Mash-iOS
//
//  Created by Danny Hsu on 2/28/15.
//  Copyright (c) 2015 Mash. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import Photos
import QuartzCore

class DashboardController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate {
    
    @IBOutlet var tracks: UITableView!
    var data: [Track] = []
    var audioPlayer: AVAudioPlayer? = nil
    var playerTimer: NSTimer? = nil
    var currTrackID: Int = 0
    var user: User = currentUser
    var activityView: ActivityView = ActivityView.createView()
    var header: Profile? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tracks.delegate = self
        self.tracks.dataSource = self
        self.tracks.backgroundColor = offWhite()
        self.tracks.separatorStyle = .None
        
        // Register profile and track nibs
        let profile = UINib(nibName: "Profile", bundle: nil)
        self.tracks.registerNib(profile, forHeaderFooterViewReuseIdentifier: "Profile")

        let track = UINib(nibName: "ProfileTrack", bundle: nil)
        self.tracks.registerNib(track, forCellReuseIdentifier: "ProfileTrack")
        
        let buffer = UINib(nibName: "BufferCell", bundle: nil)
        self.tracks.registerNib(buffer, forCellReuseIdentifier: "BufferCell")
        
        self.view.addSubview(self.activityView)
        self.activityView.center = self.view.center
        self.activityView.setText("Fetching your sounds")
        self.activityView.titleLabel.sizeToFit()
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.Plain, target:nil, action:nil)

        // Check if this is tab bar profile
        if self.tabBarController != nil {
            self.user = currentUser
        } else {
            self.view.frame = self.navigationController!.view.frame
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.user != currentUser {
            self.parentViewController!.navigationItem.setHidesBackButton(false, animated: false)
            self.navigationItem.title = "Profile"
        } else {
            self.parentViewController!.navigationItem.title = "Profile"
            User.updateSelf(self)
        }
        self.retrieveTracks()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        let value = UIInterfaceOrientation.Portrait.rawValue
        UIDevice.currentDevice().setValue(value, forKey: "orientation")
        var editButton = UIBarButtonItem(title: "Settings", style: .Plain, target: self, action: #selector(DashboardController.goToSettings(_:)))
        
        if self.user.userid != currentUser.userid {
            var following: Bool = false
            for u in userFollowing {
                if u.handle! == self.user.handle! {
                    following = true
                }
            }
            if following {
                editButton = UIBarButtonItem(title: "Unfollow", style: .Plain, target: self, action: #selector(DashboardController.unfollow(_:)))
            } else {
                editButton = UIBarButtonItem(title: "Follow", style: .Plain, target: self, action: #selector(DashboardController.follow(_:)))
            }
        }
        if self.user == currentUser {
            self.parentViewController?.navigationItem.rightBarButtonItem = editButton
        } else {
            self.navigationItem.rightBarButtonItem = editButton
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        if self.audioPlayer != nil {
            self.audioPlayer!.stop()
        }
        self.parentViewController?.navigationItem.setHidesBackButton(true, animated: false)
        if self.user == currentUser {
            self.parentViewController?.navigationItem.rightBarButtonItem = nil
        } else {
            self.navigationItem.rightBarButtonItem = nil
        }
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    
    // Table View Delegate
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 0
        } else if section == 1 {
            return self.data.count
        } else {
            return 1
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 1 {
            let track = tableView.dequeueReusableCellWithIdentifier("ProfileTrack", forIndexPath: indexPath) as! ProfileTrack
            let index = indexPath.row
            track.backgroundColor = UIColor.whiteColor()
            track.instrumentImage.backgroundColor = UIColor.clearColor()
            track.title.textColor = UIColor.blackColor()
            track.title.text = self.data[index].titleText
            track.userid = self.data[index].userid
            track.id = self.data[index].id
            track.titleText = track.title.text!
            track.format = self.data[index].format
            track.userText = self.data[index].userText
            track.instruments = self.data[index].instruments
            track.instrumentFamilies = self.data[index].instrumentFamilies
            track.trackURL = self.data[index].trackURL
            track.bpm = self.data[index].bpm
            track.instrumentImage.image = findImage(track.instrumentFamilies)
            track.instrumentImage.backgroundColor = UIColor.clearColor()
            track.dateLabel.text = parseTimeStamp(self.data[index].time)
            track.addButton.addTarget(self, action: #selector(DashboardController.addTrack(_:)), forControlEvents: UIControlEvents.TouchDown)
            track.activityView.startAnimating()
            track.track = self.data[index]
            track.likeCount.text = "\(self.data[index].likeCount)"
            track.playCount.text = "\(self.data[index].playCount)"
            
            download(getS3WaveformKey(track), url: filePathURL(getS3WaveformKey(track)), bucket: waveform_bucket) {
                (result) in
                dispatch_async(dispatch_get_main_queue()) {
                    track.activityView.stopAnimating()
                }
                if result != nil {
                    dispatch_async(dispatch_get_main_queue()) {
                        track.staticAudioPlot.image = UIImage(contentsOfFile: filePathString(getS3WaveformKey(track)))
                    }
                } else {
                    dispatch_async(dispatch_get_main_queue()) {
                        track.staticAudioPlot.image = UIImage(named: "waveform_static")
                    }
                }
            }
            return track
        } else if indexPath.section == 2 {
            let cell = self.tracks.dequeueReusableCellWithIdentifier("BufferCell")!
            cell.backgroundColor = UIColor.clearColor()
            cell.selectionStyle = .None
            cell.userInteractionEnabled = false
            return cell
        }
        return UITableViewCell(style: .Default, reuseIdentifier: nil)
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            let header = self.tracks.dequeueReusableHeaderFooterViewWithIdentifier("Profile") as! Profile
            self.header = header
            header.profilePic.contentMode = UIViewContentMode.ScaleAspectFill
            header.profilePic.layer.cornerRadius = header.profilePic.frame.size.width / 2
            header.profilePic.layer.borderWidth = 1.0
            header.profilePic.layer.borderColor = UIColor.whiteColor().CGColor
            header.profilePic.layer.masksToBounds = true
            
            header.followerCount.layer.borderWidth = 0.2
            header.followingCount.layer.borderWidth = 0.2
            header.trackCount.layer.borderWidth = 0.2
            
            let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .Light))
            blurView.frame = header.informationView.bounds
            blurView.contentView.backgroundColor = lightGrayTranslucent()
            header.informationView.insertSubview(blurView, atIndex: 0)
            
            header.editButton.setTitle(self.user.displayName(), forState: .Normal)
            // TODO: implement
            header.locationButton.setTitle(self.user.handle!, forState: .Normal)
            
            let tap1 = UITapGestureRecognizer(target: self, action: #selector(DashboardController.goToFollowers(_:)))
            header.followerCount.addGestureRecognizer(tap1)
            let tap2 = UITapGestureRecognizer(target: self, action: #selector(DashboardController.goToFollowing(_:)))
            header.followingCount.addGestureRecognizer(tap2)
            
            self.user.setBannerPic(header.bannerImage)
            self.user.setProfilePic(header.profilePic)
            header.followerCount.text = "    \(self.user.followers!)\n    FOLLOWERS"
            header.followingCount.text = "    \(self.user.following!)\n    FOLLOWING"
            header.trackCount.text = "    \(self.user.tracks!)\n    TRACKS"
            
            return header
        }
        return nil
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 240.0
        }
        return 0.0
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 1 {
            return 100.0
        } else if indexPath.section == 2 {
            return 35.0
        }
        return 0.0
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 1 {
            let track = self.tracks.cellForRowAtIndexPath(indexPath) as! ProfileTrack
            if self.audioPlayer != nil && self.audioPlayer!.playing {
                self.audioPlayer!.stop()
            } else {
                track.activityView.startAnimating()
                download(getS3Key(track), url: NSURL(fileURLWithPath: track.trackURL), bucket: track_bucket) {
                    (result) in
                    dispatch_async(dispatch_get_main_queue()) {
                        track.activityView.stopAnimating()
                        tableView.deselectRowAtIndexPath(indexPath, animated: true)
                        if result != nil {
                            track.generateWaveform()
                            self.audioPlayer = try? AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: track.trackURL))
                            self.audioPlayer!.play()
                            self.currTrackID = track.id
                            if self.playerTimer != nil {
                                self.playerTimer!.invalidate()
                            }
                            self.playerTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(DashboardController.play(_:)), userInfo: nil, repeats: true)
                            Debug.printl("Playing track \(track.titleText)", sender: self)
                        }
                    }
                }

            }
        }
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        self.stopPlaying()
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 1 {
            if self.user != currentUser {
                return
            }
            if editingStyle == UITableViewCellEditingStyle.Delete {
                self.deleteTrack(self.data[indexPath.row], indexPath: indexPath)
            }
        }
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if indexPath.section == 1 {
            if self.user != currentUser {
                return false
            }
        }
        return true
    }
    
    // Button targets
    func addTrack(sender: UIButton) {
        let trackData = sender.superview!.superview!.superview as! ProfileTrack
        var track: Track? = nil
        for t in self.data {
            if t.id == trackData.id {
                track = t
            }
        }
        ProjectViewController.importTracks([track!])
    }

    // Track management
    func retrieveTracks() {
        let request = UserRequest()
        request.userid = UInt32(currentUser.userid!)
        request.loginToken = currentUser.loginToken
        request.queryUserid = UInt32(self.user.userid!)
        self.activityView.startAnimating()
        
        server.userRecordingsWithRequest(request) {
            (response, error) in
            if error != nil {
                Debug.printl("Error: \(error)", sender: nil)
            } else {
                self.updateTable(response)
            }
        }
    }

    func updateTable(data: UserRecordingsResponse) {
        self.data = []
        for t in data.recArray! {
            let rec = t as! RecordingResponse
            let instruments = NSArray(array: rec.instrumentArray)
            let families = NSArray(array: rec.familyArray)
            let format = rec.format
            var url = "\(self.user.userid!)~~\(rec.recid)\(format!)"
            let recid = Int(rec.recid)
            url = filePathString(url)
            
            let trackData = Track(frame: CGRectZero, recid: recid, userid: self.user.userid!, instruments: instruments as! [String], instrumentFamilies: families as! [String], titleText: rec.title, bpm: Int(rec.bpm), timeSignature: Int(rec.bar), trackURL: url, user: self.user.handle!, format: rec.format!, time: rec.uploaded, playCount: Int(rec.playCount), likeCount: Int(rec.likeCount), mashCount: Int(rec.likeCount), liked: rec.liked)
            
            self.data.append(trackData)
        }
        dispatch_async(dispatch_get_main_queue()) {
            self.tracks.reloadSections(NSIndexSet(index: 1), withRowAnimation: .None)
            self.activityView.stopAnimating()
        }
    }
    
    func deleteTrack(track: Track, indexPath: NSIndexPath) {
        let request = RecordingRequest()
        request.loginToken = currentUser.loginToken
        request.userid = UInt32(currentUser.userid!)
        request.recid = UInt32(track.id)
        self.activityView.startAnimating()
        
        server.recordingDeleteWithRequest(request) {
            (response, error) in
            if error != nil {
                Debug.printl("\(error)", sender: nil)
            } else {
                deleteFromBucket("\(currentUser.userid!)~~\(track.id)\(track.format)", bucket: track_bucket)
                dispatch_async(dispatch_get_main_queue()) {
                    self.data.removeAtIndex(indexPath.row)
                    self.activityView.stopAnimating()
                    self.tracks.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Left)
                }
            }
        }
    }
    
    func play(sender: NSTimer) {
        if self.audioPlayer!.currentTime >= (self.audioPlayer!.duration / 2) || self.audioPlayer!.currentTime > 10.0 {
            sendPlayRequest(self.currTrackID)
            sender.invalidate()
        }
    }

    // Alert view delegate
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if alertView.title == "Change Display Name" {
            if buttonIndex == 1 {
                self.update(alertView.textFieldAtIndex(0)!.text!, inputType: "name")
            }
        } else if alertView.title == "Are you Sure?" {
            if buttonIndex == 1 {
                self.delete()
            }
        }
    }
    
    func deleteUser() {
        let alert = UIAlertView(title: "Are you Sure?", message: "Delete your account?", delegate: self, cancelButtonTitle: "No", otherButtonTitles: "Yes")
        alert.show()
    }

    // Profile editing
    func fetchPhotos(type: String) {
        let photoResults = PHAsset.fetchAssetsWithMediaType(PHAssetMediaType.Image, options: nil)
        /*var userAlbumOptions = PHFetchOptions.new()
        userAlbumOptions.predicate = NSPredicate(format: "estimatedAssetCount > 0")
        var userAlbums = PHAssetCollection.fetchAssetCollectionsWithType(PHAssetCollectionType.Album, subtype: PHAssetCollectionSubtype.Any, options: userAlbumOptions)
        
        userAlbums.enumerateObjectsUsingBlock() {
            (collection, idx, stop) in
            Debug.printl("album title \(collection.localizedTitle)", sender: self)
        }*/
        let controller = self.storyboard?.instantiateViewControllerWithIdentifier("ImageViewController") as! ImageViewController
        var data: [PHAsset] = []
        for i in (0..<photoResults.count).reverse() {
            data.append(photoResults[i] as! PHAsset)
        }
        controller.data = data
        controller.type = type
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func changeProfilePic() {
        self.fetchPhotos("profile")
    }
    
    func updateProfilePic(photo: PHAsset) {
        let path = filePathString("\(currentUser.userid!)~~profile_pic.jpg")
        let phManager = PHImageManager.defaultManager()
        let options = PHImageRequestOptions()
        phManager.requestImageDataForAsset(photo, options: options) {
            (imageData, datUTI, orientation, info) in
            if let newData: NSData = imageData {
                newData.writeToFile(path, atomically: true)
                upload("\(currentUser.userid!)~~profile_pic.jpg", url: NSURL(fileURLWithPath: path), bucket: profile_bucket) {
                    (result) in
                    self.user.setProfilePic(self.header!.profilePic)
                }
            }
        }
        
        /*photo.requestContentEditingInputWithOptions(nil) {
            (contentInput, info) in
            let imageURL = contentInput!.fullSizeImageURL
            upload("\(currentUser.handle!)~~profile_pic.jpg", url: imageURL!, bucket: profile_bucket)
        }*/
    }
    
    func changeBanner() {
        self.fetchPhotos("banner")
    }
    
    func updateBanner(photo: PHAsset) {
        let path = filePathString("\(currentUser.userid!)~~banner.jpg")
        let phManager = PHImageManager.defaultManager()
        let options = PHImageRequestOptions()
        phManager.requestImageDataForAsset(photo, options: options) {
            (imageData, datUTI, orientation, info) in
            if let newData: NSData = imageData {
                newData.writeToFile(path, atomically: true)
                upload("\(currentUser.userid!)~~banner.jpg", url: NSURL(fileURLWithPath: path), bucket: banner_bucket) {
                    (result) in
                    self.user.setBannerPic(self.header!.bannerImage)
                }
            }
        }
        
        /*photo.requestContentEditingInputWithOptions(nil) {
            (contentInput, info) in
            let imageURL = contentInput!.fullSizeImageURL
            upload("\(currentUser.handle!)~~banner.jpg", url: imageURL!, bucket: banner_bucket)
        }*/
    }
    
    func changeName() {
        let alert = UIAlertView(title: "Change Display Name", message: "Enter a new name.", delegate: self, cancelButtonTitle: "Cancel", otherButtonTitles: "Done")
        alert.alertViewStyle = UIAlertViewStyle.PlainTextInput
        alert.show()
    }
    
    func stopPlaying() {
        if self.audioPlayer != nil && self.audioPlayer!.playing {
            self.audioPlayer!.stop()
        }
    }
    
    func update(input: String, inputType: String) {
        let request = UserUpdateRequest()
        request.userid = UInt32(currentUser.userid!)
        request.loginToken = currentUser.loginToken
        switch (inputType) {
            case "name":
                request.name = input
            case "userDescription":
                request.userDescription = input
            case "email":
                request.email = input
            case "passwordHash":
                request.passwordHash = input
            default:
                Debug.printl("Error in update, input type is \(inputType)", sender: nil)
                return
        }
        server.userUpdateWithRequest(request) {
            (response, error) in
            if error != nil {
                Debug.printl("Error: \(error)", sender: nil)
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    User.updateSelf(self)
                }
            }
        }
    }
    
    func follow(sender: UIButton) {
        self.user.follow(nil)
        if self.user == currentUser {
            self.parentViewController?.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Unfollow", style: .Plain, target: self, action: #selector(DashboardController.unfollow(_:)))
        } else {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Unfollow", style: .Plain, target: self, action: #selector(DashboardController.unfollow(_:)))
        }
    }
    
    func unfollow(sender: UIButton) {
        self.user.unfollow(nil)
        if self.user == currentUser {
            self.parentViewController?.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Follow", style: .Plain, target: self, action: #selector(DashboardController.follow(_:)))
        } else {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Follow", style: .Plain, target: self, action: #selector(DashboardController.follow(_:)))
        }
    }
    
    func logout() {
        NSUserDefaults.standardUserDefaults().removeObjectForKey("hasLoginKey")
        NSUserDefaults.standardUserDefaults().removeObjectForKey("username")
        Debug.printl("User has successfully logged out - popping to root view controller.", sender: self)
        NSUserDefaults.standardUserDefaults().removeObjectForKey("hasFacebookLoginToken")
        NSUserDefaults.standardUserDefaults().removeObjectForKey("facebookID")
        NSUserDefaults.standardUserDefaults().removeObjectForKey("facebookLoginToken")
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    func delete() {
        let request = UserRequest()
        request.loginToken = currentUser.loginToken
        request.userid = UInt32(currentUser.userid!)
        request.queryUserid = UInt32(currentUser.userid!)
        
        server.userDeleteWithRequest(request) {
            (response, error) in
            if error != nil {
                Debug.printl("Error: \(error)", sender: nil)
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    self.logout()
                }
            }
        }
    }
    
    // Segues
    func goToDirectUpload(sender: AnyObject?) {
        let upload = self.storyboard?.instantiateViewControllerWithIdentifier("DirectUploadViewController") as! DirectUploadViewController
        self.navigationController?.pushViewController(upload, animated: true)
    }
    
    func goToSettings(sender: AnyObject?) {
        let settings = self.storyboard?.instantiateViewControllerWithIdentifier("SettingsViewController") as! SettingsViewController
        settings.profile = self
        self.navigationController?.pushViewController(settings, animated: true)
    }
    
    func goToFollowers(sender: AnyObject?) {
        let controller = self.storyboard?.instantiateViewControllerWithIdentifier("FollowingViewController") as! FollowingViewController
        controller.user = self.user
        controller.type = "followers"
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func goToFollowing(sender: AnyObject?) {
        let controller = self.storyboard?.instantiateViewControllerWithIdentifier("FollowingViewController") as! FollowingViewController
        controller.user = self.user
        controller.type = "following"
        self.navigationController?.pushViewController(controller, animated: true)
    }

}
