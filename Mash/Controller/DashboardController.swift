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
    var user: User = currentUser
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tracks.delegate = self
        self.tracks.dataSource = self
        self.tracks.backgroundColor = darkGray()
        self.tracks.separatorStyle = .None
        
        // Register profile and track nibs
        let profile = UINib(nibName: "Profile", bundle: nil)
        self.tracks.registerNib(profile, forHeaderFooterViewReuseIdentifier: "Profile")

        let track = UINib(nibName: "Track", bundle: nil)
        self.tracks.registerNib(track, forCellReuseIdentifier: "Track")
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.Plain, target:nil, action:nil)

        // Check if this is tab bar profile
        if self.tabBarController != nil {
            self.user = currentUser
        } else {
            // FIXME: hacky
            self.view.frame = self.navigationController!.view.frame
            self.view.backgroundColor = darkGray()
            self.tracks.frame = self.navigationController!.view.frame
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if self.user != currentUser {
            self.parentViewController?.navigationItem.setHidesBackButton(false, animated: false)
            self.navigationItem.title = "Profile"
        } else {
            self.parentViewController?.navigationItem.title = "Profile"
            User.updateSelf(self)
        }
        self.retrieveTracks()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        let value = UIInterfaceOrientation.Portrait.rawValue
        UIDevice.currentDevice().setValue(value, forKey: "orientation")
        var editButton = UIBarButtonItem(barButtonSystemItem: .Edit, target: self, action: "goToSettings:")
        
        if self.user.userid != currentUser.userid {
            var following: Bool = false
            for u in userFollowing {
                if u.handle! == self.user.handle! {
                    following = true
                }
            }
            if following {
                editButton = UIBarButtonItem(title: "Unfollow", style: .Plain, target: self, action: "unfollow:")
            } else {
                editButton = UIBarButtonItem(title: "Follow", style: .Plain, target: self, action: "follow:")
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
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let track = tableView.dequeueReusableCellWithIdentifier("Track", forIndexPath: indexPath) as! Track
        let index = indexPath.row
        track.backgroundColor = UIColor.clearColor()
        track.instrumentImage.backgroundColor = UIColor.clearColor()
        track.userLabel.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        track.title.textColor = UIColor.whiteColor()
        track.title.text = self.data[index].titleText
        track.userid = self.data[index].userid
        track.id = self.data[index].id
        track.titleText = track.title.text!
        track.format = self.data[index].format
        track.userText = self.data[index].userText
        track.userLabel.setTitle(track.userText, forState: .Normal)
        track.instruments = self.data[index].instruments
        track.instrumentFamilies = self.data[index].instrumentFamilies
        track.trackURL = self.data[index].trackURL
        track.bpm = self.data[index].bpm
        track.instrumentImage.image = findImageWhite(track.instrumentFamilies)
        track.instrumentImage.backgroundColor = UIColor.clearColor()
        track.addButton.addTarget(self, action: "addTrack:", forControlEvents: UIControlEvents.TouchDown)
        track.activityView.startAnimating()
        
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
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! Profile
        
        header.profilePic.contentMode = UIViewContentMode.ScaleAspectFill
        header.profilePic.layer.cornerRadius = header.profilePic.frame.size.width / 2
        header.profilePic.layer.borderWidth = 1.0
        header.profilePic.layer.borderColor = UIColor.whiteColor().CGColor
        header.profilePic.layer.masksToBounds = true
        
        header.followerCount.layer.borderWidth = 0.2
        header.followingCount.layer.borderWidth = 0.2
        header.trackCount.layer.borderWidth = 0.2
        //header.descriptionLabel.layer.borderWidth = 0.2
        
        header.editButton.setTitle(self.user.display_name(), forState: .Normal)
        // TODO: implement
        header.locationButon.setTitle(self.user.handle!, forState: .Normal)
        
        let tap1 = UITapGestureRecognizer(target: self, action: "goToFollowers:")
        header.followerCount.addGestureRecognizer(tap1)
        let tap2 = UITapGestureRecognizer(target: self, action: "goToFollowing:")
        header.followingCount.addGestureRecognizer(tap2)
        
        self.user.setBannerPic(header.bannerImage)
        self.user.setProfilePic(header.profilePic)
        header.followerCount.text = "  \(self.user.followers!)\n  FOLLOWERS"
        header.followingCount.text = "  \(self.user.following!)\n  FOLLOWING"
        header.trackCount.text = "  \(self.user.tracks!)\n  TRACKS"
        //header.descriptionLabel.text = "  \(self.user.userDescription!)"
        
        // Add gradient to banner
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = header.bounds
        gradient.colors = [UIColor.clearColor().CGColor, UIColor.clearColor().CGColor, darkGray().CGColor]
        header.bannerImage.layer.insertSublayer(gradient, atIndex: 0)
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = self.tracks.dequeueReusableHeaderFooterViewWithIdentifier("Profile") as! Profile
        return header
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 240.0
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 75.0
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let track = self.tracks.cellForRowAtIndexPath(indexPath) as! Track
        
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
                    Debug.printl("Playing track \(track.titleText)", sender: self)
                }
            }
        }
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        self.stopPlaying()
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if self.user != currentUser {
            return
        }
        if editingStyle == UITableViewCellEditingStyle.Delete {
            self.deleteTrack(self.data[indexPath.row], indexPath: indexPath)
        }
    }

    // Track management
    func retrieveTracks() {
        let request = UserRequest()
        request.userid = UInt32(currentUser.userid!)
        request.loginToken = currentUser.loginToken
        request.queryUserid = UInt32(self.user.userid!)
        
        server.userRecordingsWithRequest(request) {
            (response, error) in
            if error != nil {
                Debug.printl("Error: \(error)", sender: nil)
            } else {
                self.updateTable(response)
            }
        }
        
        /*
        var request = NSMutableURLRequest(URL: NSURL(string: "\(db)/retrieve/recording")!)
        var params = ["handle": handle, "password_hash": passwordHash, "query_name": self.user.handle!] as Dictionary
        httpPost(params, request) {
            (data, statusCode, error) -> Void in
            if error != nil {
                Debug.printl("Error: \(error)", sender: self)
            } else {
                // Check status codes
                if statusCode == HTTP_ERROR {
                    Debug.printl("HTTP Error: \(error)", sender: self)
                } else if statusCode == HTTP_WRONG_MEDIA {
                    
                } else if statusCode == HTTP_SUCCESS_WITH_MESSAGE {
                    var error: NSError? = nil
                    var response: AnyObject? = NSJSONSerialization.JSONObjectWithData(data.dataUsingEncoding(NSUTF8StringEncoding)!, options: NSJSONReadingOptions.AllowFragments, error: &error)
                    self.updateTable(response as! NSDictionary)
                } else if statusCode == HTTP_SERVER_ERROR {
                    Debug.printl("Internal server error.", sender: self)
                } else {
                    Debug.printl("Unrecognized status code from server: \(statusCode)", sender: self)
                }
            }
        }*/
    }

    func updateTable(data: UserRecordingsResponse) {
        self.data = []
        for t in data.recArray! {
            let track = t as! RecordingResponse
            let instruments = NSArray(array: track.instrumentArray)
            let families = NSArray(array: track.familyArray)
            let format = track.format
            var url = "\(self.user.userid!)~~\(track.recid)\(format!)"
            let recid = Int(track.recid)
            url = filePathString(url)
            
            let trackData = Track(frame: CGRectZero, recid: recid, userid: self.user.userid!, instruments: instruments as! [String], instrumentFamilies: families as! [String], titleText: track.title, bpm: Int(track.bpm), trackURL: url, user: self.user.handle!, format: track.format!)
            
            self.data.append(trackData)
        }
        dispatch_async(dispatch_get_main_queue()) {
            self.tracks.reloadData()
        }
    }
    
    func addTrack(sender: UIButton) {
        let track = sender.superview!.superview!.superview as! Track
        ProjectViewController.importTracks([track], navigationController: self.navigationController, storyboard: self.storyboard)
        if self.tabBarController != nil {
            let tabBarController = self.navigationController?.viewControllers[2] as! UITabBarController
            tabBarController.selectedIndex = getTabBarController("project")
        } else {
            raiseAlert("Track added.")
        }
    }
    
    func deleteTrack(track: Track, indexPath: NSIndexPath) {
        let request = RecordingRequest()
        request.loginToken = currentUser.loginToken
        request.userid = UInt32(currentUser.userid!)
        request.recid = UInt32(track.id)
        
        server.recordingDeleteWithRequest(request) {
            (response, error) in
            if error != nil {
                Debug.printl("\(error)", sender: nil)
            } else {
                deleteFromBucket("\(currentUser.userid!)~~\(track.id)\(track.format)", bucket: track_bucket)
                dispatch_async(dispatch_get_main_queue()) {
                    self.data.removeAtIndex(indexPath.row)
                    self.tracks.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Left)
                }
            }
        }
        /*
        let passwordHash = hashPassword(keychainWrapper.myObjectForKey("v_Data") as! String)
        let handle = currentUser.handle!
        var request = NSMutableURLRequest(URL: NSURL(string: "\(db)/delete/recordings")!)
        var params = ["handle": handle, "password_hash": passwordHash, "song_name": track.titleText] as Dictionary
        httpDelete(params, request) {
            (data, statusCode, error) -> Void in
            if error != nil {
                Debug.printl("Error: \(error)", sender: self)
            } else {
                // Check status codes
                if statusCode == HTTP_ERROR {
                    Debug.printl("HTTP Error: \(error)", sender: self)
                } else if statusCode == HTTP_WRONG_MEDIA {
                    
                } else if statusCode == HTTP_SUCCESS_WITH_MESSAGE {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.data.removeAtIndex(indexPath.row)
                        self.tracks.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Left)
                    }
                } else if statusCode == HTTP_SERVER_ERROR {
                    Debug.printl("Internal server error.", sender: self)
                } else {
                    Debug.printl("Unrecognized status code from server: \(statusCode)", sender: self)
                }
            }
        }*/
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
    
    // Profile edititing
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
        for (var i = photoResults.count - 1; i >= 0; i--) {
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
                upload("\(currentUser.userid!)~~profile_pic.jpg", url: NSURL(fileURLWithPath: path), bucket: profile_bucket)
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
                upload("\(currentUser.userid!)~~banner.jpg", url: NSURL(fileURLWithPath: path), bucket: banner_bucket)
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
        /*
        var request = NSMutableURLRequest(URL: NSURL(string: "\(db)/update/user")!)
        var params = ["handle": handle!, "password_hash": passwordHash, inputType: input] as Dictionary
        httpPatch(params, request) {
            (data, statusCode, error) -> Void in
            if error != nil {
                Debug.printl("Error: \(error)", sender: self)
            } else {
                // Check status codes
                if statusCode == HTTP_ERROR {
                    Debug.printl("HTTP Error: \(error)", sender: self)
                } else if statusCode == HTTP_WRONG_MEDIA {
                    
                } else if statusCode == HTTP_SUCCESS_WITH_MESSAGE {
                    User.updateSelf(self)
                } else if statusCode == HTTP_SERVER_ERROR {
                    Debug.printl("Internal server error.", sender: self)
                } else {
                    Debug.printl("Unrecognized status code from server: \(statusCode)", sender: self)
                }
            }
        }*/
    }
    
    func follow(sender: UIButton) {
        self.user.follow(nil)
        if self.user == currentUser {
            self.parentViewController?.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Unfollow", style: .Plain, target: self, action: "unfollow:")
        } else {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Unfollow", style: .Plain, target: self, action: "unfollow:")
        }
    }
    
    func unfollow(sender: UIButton) {
        self.user.unfollow(nil)
        if self.user == currentUser {
            self.parentViewController?.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Follow", style: .Plain, target: self, action: "follow:")
        } else {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Follow", style: .Plain, target: self, action: "follow:")
        }
    }
    
    func logout() {
        NSUserDefaults.standardUserDefaults().removeObjectForKey("hasLoginKey")
        NSUserDefaults.standardUserDefaults().removeObjectForKey("username")
        Debug.printl("User has successfully logged out - popping to root view controller.", sender: self)
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    func delete() {
        let request = UserRequest()
        request.loginToken = currentUser.loginToken
        request.userid = UInt32(currentUser.userid!)
        // FIXME: remove this line later
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
        /*
        let passwordHash = hashPassword(keychainWrapper.myObjectForKey("v_Data") as! String)
        let handle = currentUser.handle
        var request = NSMutableURLRequest(URL: NSURL(string: "\(db)/delete/user")!)
        var params = ["handle": handle!, "password_hash": passwordHash] as Dictionary
        httpDelete(params, request) {
            (data, statusCode, error) -> Void in
            if error != nil {
                Debug.printl("Error: \(error)", sender: self)
            } else {
                // Check status codes
                if statusCode == HTTP_ERROR {
                    Debug.printl("HTTP Error: \(error)", sender: self)
                } else if statusCode == HTTP_WRONG_MEDIA {
                    
                } else if statusCode == HTTP_SUCCESS_WITH_MESSAGE {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.logout()
                    }
                } else if statusCode == HTTP_SERVER_ERROR {
                    Debug.printl("Internal server error.", sender: self)
                } else {
                    Debug.printl("Unrecognized status code from server: \(statusCode)", sender: self)
                }
            }
        }*/
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
