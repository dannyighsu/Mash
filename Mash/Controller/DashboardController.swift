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
import EZAudio
import Photos

class DashboardController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate {
    
    @IBOutlet var tracks: UITableView!
    var data: [Track] = []
    var audioPlayer: AVAudioPlayer? = nil
    var user: User = current_user
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tracks.delegate = self
        self.tracks.dataSource = self
        
        // Register profile and track nibs
        let profile = UINib(nibName: "Profile", bundle: nil)
        self.tracks.registerNib(profile, forHeaderFooterViewReuseIdentifier: "Profile")

        let track = UINib(nibName: "Track", bundle: nil)
        self.tracks.registerNib(track, forCellReuseIdentifier: "Track")
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.Plain, target:nil, action:nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if self.user != current_user {
            self.parentViewController?.navigationItem.setHidesBackButton(false, animated: false)
            self.navigationItem.title = self.user.display_name()
        } else {
            self.parentViewController?.navigationItem.title = self.user.display_name()
        }
        self.retrieveTracks()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        let value = UIInterfaceOrientation.Portrait.rawValue
        UIDevice.currentDevice().setValue(value, forKey: "orientation")
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        if self.audioPlayer != nil {
            self.audioPlayer!.stop()
        }
        self.parentViewController?.navigationItem.setHidesBackButton(true, animated: false)
    }
    
    override func supportedInterfaceOrientations() -> Int {
        return Int(UIInterfaceOrientationMask.Portrait.rawValue)
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
        track.backgroundColor = offWhite()
        track.title.text = self.data[index].titleText
        track.titleText = track.title.text!
        track.format = self.data[index].format
        track.userText = self.data[index].userText
        track.userLabel.text = track.userText
        track.instruments = self.data[index].instruments
        track.trackURL = self.data[index].trackURL
        track.bpm = self.data[index].bpm
        track.instrumentImage.image = findImage(track.instrumentFamilies)
        track.addButton.addTarget(self, action: "addTrack:", forControlEvents: UIControlEvents.TouchDown)
        return track
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        let track = cell as! Track
        let index = indexPath.row
        track.activityView.startAnimating()
        download(getS3Key(track), filePathURL(track.titleText + track.format), track_bucket) {
            (result) in
            dispatch_async(dispatch_get_main_queue()) {
                track.generateWaveform()
                track.activityView.stopAnimating()
            }
        }
    }
    
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! Profile
        
        header.profilePic.contentMode = UIViewContentMode.ScaleAspectFit
        header.profilePic.layer.cornerRadius = header.profilePic.frame.size.width / 2
        header.profilePic.layer.borderWidth = 1.0
        header.profilePic.layer.masksToBounds = true
        
        header.followerCount.layer.borderWidth = 0.2
        header.followingCount.layer.borderWidth = 0.2
        header.trackCount.layer.borderWidth = 0.2
        header.descriptionLabel.layer.borderWidth = 0.2
        
        if self.user.handle != current_user.handle {
            var following: Bool = false
            for u in user_following {
                if u.handle! == self.user.handle! {
                    following = true
                }
            }
            if following {
                header.editButton.setTitle("Unfollow", forState: UIControlState.Normal)
                header.editButton.backgroundColor = lightGray()
                header.editButton.addTarget(self, action: "unfollow:", forControlEvents: UIControlEvents.TouchUpInside)
            } else {
                header.editButton.setTitle("Follow", forState: UIControlState.Normal)
                header.editButton.backgroundColor = lightBlue()
                header.editButton.addTarget(self, action: "follow:", forControlEvents: UIControlEvents.TouchUpInside)
            }
            header.editButton.titleLabel!.textAlignment = .Center
        } else {
            header.editButton.setTitle("Edit Profile", forState: UIControlState.Normal)
            header.editButton.addTarget(self, action: "goToSettings:", forControlEvents: UIControlEvents.TouchUpInside)
        }
        
        let tap1 = UITapGestureRecognizer(target: self, action: "goToFollowers:")
        header.followerCount.addGestureRecognizer(tap1)
        let tap2 = UITapGestureRecognizer(target: self, action: "goToFollowing:")
        header.followingCount.addGestureRecognizer(tap2)
        
        self.user.banner_pic(header.bannerImage)
        self.user.profile_pic(header.profilePic)
        var followers = NSMutableAttributedString(string: "  \(self.user.followers!)\n  FOLLOWERS")
        header.followerCount.attributedText = followers
        var following = NSMutableAttributedString(string: "  \(self.user.following!)\n  FOLLOWING")
        header.followingCount.attributedText = following
        var tracks = NSMutableAttributedString(string: "  \(self.user.tracks!)\n  TRACKS")
        header.trackCount.attributedText = tracks
        header.descriptionLabel.text = "  \(self.user.user_description!)"
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
        
        // FIXME: hacky
        var i = 0
        while !NSFileManager.defaultManager().fileExistsAtPath(track.trackURL) {
            Debug.printnl("waiting...")
            NSThread.sleepForTimeInterval(0.5)
            if i == 5 {
                raiseAlert("Error", self, "Unable to play track.")
                return
            }
            i += 1
        }
        self.audioPlayer = AVAudioPlayer(contentsOfURL: filePathURL(track.titleText + track.format), error: nil)
        self.audioPlayer!.play()
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        Debug.printl("Playing track \(track.titleText)", sender: self)
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        self.stopPlaying()
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if self.user != current_user {
            return
        }
        if editingStyle == UITableViewCellEditingStyle.Delete {
            self.deleteTrack(self.data[indexPath.row], indexPath: indexPath)
        }
    }

    // Track management
    func retrieveTracks() {
        let passwordHash = hashPassword(keychainWrapper.myObjectForKey("v_Data") as! String)
        let handle = NSUserDefaults.standardUserDefaults().valueForKey("username") as! String
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
        }
    }

    func updateTable(data: NSDictionary) {
        self.data = []
        var tracks = data["recordings"] as! NSArray
        for t in tracks {
            var dict = t as! NSDictionary
            var instruments = dict["instrument"] as! NSArray
            var instrument = ""
            if instruments.count != 0 {
                instrument = instruments[0] as! String
            }
            var families = dict["family"] as! NSArray
            var family = ""
            if families.count != 0 {
                family = families[0] as! String
            }
            var url = (dict["song_name"] as! String) + (dict["format"] as! String)
            url = filePathString(url)
            
            var track = Track(frame: CGRectZero, instruments: [instrument], instrumentFamilies: [family], titleText: dict["song_name"] as! String, bpm: dict["bpm"] as! Int, trackURL: url, user: dict["handle"] as! String, format: dict["format"] as! String)
            
            self.data.append(track)
        }
        dispatch_async(dispatch_get_main_queue()) {
            self.tracks.reloadData()
        }
    }
    
    func addTrack(sender: UIButton) {
        let track = sender.superview!.superview!.superview as! Track
        ProjectViewController.importTracks([track], navigationController: self.navigationController, storyboard: self.storyboard)
        let tabBarController = self.navigationController?.viewControllers[2] as! UITabBarController
        tabBarController.selectedIndex = getTabBarController("project")
    }
    
    func deleteTrack(track: Track, indexPath: NSIndexPath) {
        let passwordHash = hashPassword(keychainWrapper.myObjectForKey("v_Data") as! String)
        let handle = current_user.handle!
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
        }
    }

    // Alert view delegate
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if alertView.title == "Change Display Name" {
            if buttonIndex == 1 {
                self.update(alertView.textFieldAtIndex(0)!.text, inputType: "new_display_name")
            }
        } else if alertView.title == "Are you Sure?" {
            if buttonIndex == 1 {
                self.delete()
            }
        }
    }
    
    func deleteUser() {
        var alert = UIAlertView(title: "Are you Sure?", message: "Delete your account?", delegate: self, cancelButtonTitle: "No", otherButtonTitles: "Yes")
        alert.show()
    }
    
    // Profile edititing
    func fetchPhotos(type: String) {
        var photoResults = PHAsset.fetchAssetsWithMediaType(PHAssetMediaType.Image, options: nil)
        /*var userAlbumOptions = PHFetchOptions.new()
        userAlbumOptions.predicate = NSPredicate(format: "estimatedAssetCount > 0")
        var userAlbums = PHAssetCollection.fetchAssetCollectionsWithType(PHAssetCollectionType.Album, subtype: PHAssetCollectionSubtype.Any, options: userAlbumOptions)
        
        userAlbums.enumerateObjectsUsingBlock() {
            (collection, idx, stop) in
            Debug.printl("album title \(collection.localizedTitle)", sender: self)
        }*/
        let controller = self.storyboard?.instantiateViewControllerWithIdentifier("ImageViewController") as! ImageViewController
        controller.data = photoResults
        controller.type = type
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func changeProfilePic() {
        self.fetchPhotos("profile")
    }
    
    func updateProfilePic(photo: PHAsset) {
        let manager = PHImageManager.defaultManager()
        photo.requestContentEditingInputWithOptions(nil) {
            (contentInput, info) in
            var imageURL = contentInput.fullSizeImageURL
            self.update("\(current_user.handle!)~~profile_pic.jpg", inputType: "new_profile_pic_link")
            upload("\(current_user.handle!)~~profile_pic.jpg", imageURL, profile_bucket)
        }
    }
    
    func changeBanner() {
        self.fetchPhotos("banner")
    }
    
    func updateBanner(photo: PHAsset) {
        let manager = PHImageManager.defaultManager()
        photo.requestContentEditingInputWithOptions(nil) {
            (contentInput, info) in
            var imageURL = contentInput.fullSizeImageURL
            self.update("\(current_user.handle!)~~banner.jpg", inputType: "new_banner_pic_link")
            upload("\(current_user.handle!)~~banner.jpg", imageURL, banner_bucket)
        }
    }
    
    func changeName() {
        var alert = UIAlertView(title: "Change Display Name", message: "Enter a new name.", delegate: self, cancelButtonTitle: "Cancel", otherButtonTitles: "Done")
        alert.alertViewStyle = UIAlertViewStyle.PlainTextInput
        alert.show()
    }
    
    func stopPlaying() {
        if self.audioPlayer!.playing {
            self.audioPlayer!.stop()
        }
    }
    
    func update(input: String, inputType: String) {
        let passwordHash = hashPassword(keychainWrapper.myObjectForKey("v_Data") as! String)
        let handle = current_user.handle
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
        }
    }
    
    func follow(sender: UIButton) {
        self.user.follow(nil)
    }
    
    func unfollow(sender: UIButton) {
        self.user.unfollow(nil)
    }
    
    func logout() {
        NSUserDefaults.standardUserDefaults().removeObjectForKey("hasLoginKey")
        NSUserDefaults.standardUserDefaults().removeObjectForKey("username")
        Debug.printl("User has successfully logged out - popping to root view controller.", sender: self)
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    func delete() {
        let passwordHash = hashPassword(keychainWrapper.myObjectForKey("v_Data") as! String)
        let handle = current_user.handle
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
