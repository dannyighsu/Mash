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
    var audioPlayer:AVAudioPlayer = AVAudioPlayer()
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
        self.navigationController?.navigationBarHidden = true
        self.retrieveTracks()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data.count
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if cell is Track {
            cell.backgroundColor = offWhite()
            let index = indexPath.row
            let track = cell as! Track
            track.title.text = self.data[index].titleText
            track.titleText = track.title.text!
            track.format = self.data[index].format
            track.userText = self.data[index].userText
            track.userLabel.text = track.userText
            track.instruments = self.data[index].instruments
            track.trackURL = self.data[index].trackURL
            track.instrumentImage.image = findImage(track.instruments)
            track.addButton.addTarget(self, action: "addTrack:", forControlEvents: UIControlEvents.TouchDown)
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
        
        if self.user.username != current_user.username {
            
            var following: Bool = false
            for u in user_following {
                if u.username! == self.user.username! {
                    following = true
                }
            }
            if following {
                header.editButton.titleLabel!.text = "Unfollow"
                header.editButton.backgroundColor = lightGray()
                header.editButton.addTarget(self, action: "unfollow:", forControlEvents: UIControlEvents.TouchDown)
            } else {
                header.editButton.titleLabel!.text = "Follow"
                header.editButton.backgroundColor = lightBlue()
                header.editButton.addTarget(self, action: "follow:", forControlEvents: UIControlEvents.TouchDown)
            }
        } else {
            header.editButton.addTarget(self, action: "goToSettings:", forControlEvents: UIControlEvents.TouchDown)
        }
        
        let tap1 = UITapGestureRecognizer(target: self, action: "goToFollowers:")
        header.followerCount.addGestureRecognizer(tap1)
        let tap2 = UITapGestureRecognizer(target: self, action: "goToFollowing:")
        header.followingCount.addGestureRecognizer(tap2)
        
        header.username.text = self.user.display_name()
        header.bannerImage.image = self.user.banner_pic()
        header.profilePic.image = self.user.profile_pic()
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
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Track", forIndexPath: indexPath) as! Track
        return cell
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 295.0
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 75.0
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let track = self.tracks.cellForRowAtIndexPath(indexPath) as! Track
        
        download(track.titleText + track.format, filePathURL(track.titleText + track.format), track_bucket)
        
        while !NSFileManager.defaultManager().fileExistsAtPath(filePathString(track.titleText + track.format)) {
            Debug.printnl("waiting...")
            NSThread.sleepForTimeInterval(0.5)
        }
        NSThread.sleepForTimeInterval(0.5)
        
        self.audioPlayer = AVAudioPlayer(contentsOfURL: filePathURL(track.titleText + track.format), error: nil)
        self.audioPlayer.play()
        Debug.printl("Playing track \(track.titleText)", sender: self)
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        self.stopPlaying()
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            self.deleteTrack(self.data[indexPath.row], indexPath: indexPath)
        }
    }

    func stopPlaying() {
        if self.audioPlayer.playing {
            self.audioPlayer.stop()
        }
    }

    // Pull user tracks from API
    func retrieveTracks() {
        let passwordHash = hashPassword(keychainWrapper.myObjectForKey("v_Data") as! String)
        let username = NSUserDefaults.standardUserDefaults().valueForKey("username") as! String
        var request = NSMutableURLRequest(URL: NSURL(string: "\(db)/search/recording")!)
        var params = ["username": username, "password_hash": passwordHash, "query_name": self.user.username!] as Dictionary
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
    
    // Download track to play
    func playTrack() {
        download("Harp.aif", NSURL(fileURLWithPath: NSString(format: "%@/%@", applicationDocumentsDirectory(), "EZAudioTest.m4a") as String)!, track_bucket)
    }
    
    // Update table with track data
    func updateTable(data: NSDictionary) {
        self.data = []
        var tracks = data["recordings"] as! NSArray
        for t in tracks {
            var dict = t as! NSDictionary
            var instruments = dict["instrument"] as! NSArray
            var url = (dict["song_name"] as! String) + (dict["format"] as! String)
            url = filePathString(url)
            var track = Track(frame: CGRectZero, instruments: [instruments[0] as! String], titleText: dict["song_name"] as! String, bpm: 120, trackURL: url, user: dict["username"] as! String, format: dict["format"] as! String)
            self.data.append(track)
        }
        dispatch_async(dispatch_get_main_queue()) {
            self.tracks.reloadData()
        }
    }
    
    // Add selected track to project
    func addTrack(sender: UIButton) {
        let track = sender.superview!.superview!.superview as! Track
        importTracks([track], self.navigationController, self.storyboard)
        let tabBarController = self.navigationController?.viewControllers[2] as! UITabBarController
        tabBarController.selectedIndex = getTabBarController("project")
    }
    
    // Delete track from db
    func deleteTrack(track: Track, indexPath: NSIndexPath) {
        let passwordHash = hashPassword(keychainWrapper.myObjectForKey("v_Data") as! String)
        let username = current_user.username!
        var request = NSMutableURLRequest(URL: NSURL(string: "\(db)/delete/recordings")!)
        var params = ["username": username, "password_hash": passwordHash, "song_name": track.titleText] as Dictionary
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
    
    func fetchPhotos() {
        var photoResults = PHAsset.fetchAssetsWithMediaType(PHAssetMediaType.Image, options: nil)
        var userAlbumOptions = PHFetchOptions.new()
        userAlbumOptions.predicate = NSPredicate(format: "estimatedAssetCount > 0")
        var userAlbums = PHAssetCollection.fetchAssetCollectionsWithType(PHAssetCollectionType.Album, subtype: PHAssetCollectionSubtype.Any, options: userAlbumOptions)
        userAlbums.enumerateObjectsUsingBlock() {
            (collection, idx, stop) in
            Debug.printl("album title \(collection.localizedTitle)", sender: self)
        }
    }
    
    // Change profile picture
    func changeProfilePic() {
        
    }
    
    // Change banner
    func changeBanner() {
        
    }
    
    // Change display name
    func changeName() {
        var alert = UIAlertView(title: "Change Display Name", message: "Enter a new name.", delegate: self, cancelButtonTitle: "Cancel", otherButtonTitles: "Done")
        alert.alertViewStyle = UIAlertViewStyle.PlainTextInput
        alert.show()
    }
    
    func update(input: String, inputType: String) {
        let passwordHash = hashPassword(keychainWrapper.myObjectForKey("v_Data") as! String)
        let username = current_user.username
        var request = NSMutableURLRequest(URL: NSURL(string: "\(db)/update/user")!)
        var params = ["username": username!, "password_hash": passwordHash, inputType: input] as Dictionary
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
                    var error: NSError? = nil
                    var response: AnyObject? = NSJSONSerialization.JSONObjectWithData(data.dataUsingEncoding(NSUTF8StringEncoding)!, options: NSJSONReadingOptions.AllowFragments, error: &error)
                } else if statusCode == HTTP_SERVER_ERROR {
                    Debug.printl("Internal server error.", sender: self)
                } else {
                    Debug.printl("Unrecognized status code from server: \(statusCode)", sender: self)
                }
            }
        }
    }

    // Push settings page up
    func goToSettings(sender: AnyObject?) {
        let settings = self.storyboard?.instantiateViewControllerWithIdentifier("SettingsViewController") as! SettingsViewController
        settings.profile = self
        self.navigationController?.pushViewController(settings, animated: true)
    }
    
    func goToFollowers(sender: AnyObject?) {
        let controller = self.storyboard?.instantiateViewControllerWithIdentifier("FollowingViewController") as! FollowingViewController
        controller.data = getUserFollowers(self.user)
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func goToFollowing(sender: AnyObject?) {
        let controller = self.storyboard?.instantiateViewControllerWithIdentifier("FollowingViewController") as! FollowingViewController
        controller.data = getUserFollowing(self.user)
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func follow(sender: UIButton) {
        
    }
    
    func unfollow(sender: UIButton) {
        
    }
    
    // Push direct upload page up
    func goToDirectUpload(sender: AnyObject?) {
        let upload = self.storyboard?.instantiateViewControllerWithIdentifier("DirectUploadViewController") as! DirectUploadViewController
        self.navigationController?.pushViewController(upload, animated: true)
    }
    
    // Delete user alert
    func deleteUser() {
        var alert = UIAlertView(title: "Are you Sure?", message: "Delete your account?", delegate: self, cancelButtonTitle: "No", otherButtonTitles: "Yes")
        alert.show()
    }
    
    // Delete user from db
    func delete() {
        let passwordHash = hashPassword(keychainWrapper.myObjectForKey("v_Data") as! String)
        let username = current_user.username
        var request = NSMutableURLRequest(URL: NSURL(string: "\(db)/delete/user")!)
        var params = ["username": username!, "password_hash": passwordHash] as Dictionary
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
    
    // Log out
    func logout() {
        NSUserDefaults.standardUserDefaults().removeObjectForKey("hasLoginKey")
        NSUserDefaults.standardUserDefaults().removeObjectForKey("username")
        Debug.printl("User has successfully logged out - popping to root view controller.", sender: self)
        self.navigationController?.popToRootViewControllerAnimated(true)
    }

}
