//
//  SearchViewController.swift
//  Mash-iOS
//
//  Created by Danny Hsu on 3/2/15.
//  Copyright (c) 2015 Mash. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class SearchViewController: UITableViewController, UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating {
   
    var searchController: UISearchController?
    var audioPlayer: AVAudioPlayer? = nil
    var activityView: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
    // Holds current search results
    var searchResults: [AnyObject] = []
    // Holds all search results
    var allResults: [AnyObject] = []
    // Current search scope
    var scope: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Initialize search controller
        self.searchController = UISearchController(searchResultsController: nil)
        self.searchController!.searchResultsUpdater = self
        self.searchController!.delegate = self
        self.searchController!.searchBar.delegate = self
        self.searchController!.searchBar.scopeButtonTitles = ["Recording", "User"]
        
        self.view.addSubview(self.activityView)
        self.activityView.center = self.view.center
        
        // Register nibs
        let track = UINib(nibName: "Track", bundle: nil)
        self.tableView.registerNib(track, forCellReuseIdentifier: "Track")
        let user = UINib(nibName: "User", bundle: nil)
        self.tableView.registerNib(user, forCellReuseIdentifier: "User")
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.tableView.tableHeaderView = self.searchController?.searchBar
        self.definesPresentationContext = true
        self.searchController?.searchBar.sizeToFit()
        self.searchController?.searchBar.setShowsCancelButton(true, animated: false)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.setHidesBackButton(true, animated: false)
        self.navigationController?.navigationBarHidden = true
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        if self.audioPlayer != nil {
            self.audioPlayer!.stop()
        }
        self.navigationController?.navigationBarHidden = false
    }
    
    // Table View Delegate
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.searchResults.count
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == self.searchResults.count - 1 {
            self.loadNextData()
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if self.scope == 0 {
            let track = self.tableView.dequeueReusableCellWithIdentifier("Track", forIndexPath: indexPath) as! Track
            let trackData = self.searchResults[indexPath.row] as! Track
            track.title.text = trackData.titleText
            track.titleText = track.title.text!
            track.instruments = trackData.instruments
            track.instrumentFamilies = trackData.instrumentFamilies
            track.trackURL = trackData.trackURL
            track.instrumentImage.image = findImage(track.instrumentFamilies)
            track.addButton.addTarget(self, action: "addTrack:", forControlEvents: UIControlEvents.TouchDown)
            track.titleText = trackData.titleText
            track.title.text = trackData.titleText
            track.userText = trackData.userText
            track.userLabel.text = track.userText
            track.format = trackData.format
            track.bpm = trackData.bpm
            track.activityView.startAnimating()
            download(getS3WaveformKey(track), filePathURL(getS3WaveformKey(track)), waveform_bucket) {
                (result) in
                if result != nil {
                    track.staticAudioPlot.image = UIImage(contentsOfFile: filePathString(getS3WaveformKey(track)))
                }
            }
            return track
        } else {
            let user = self.tableView.dequeueReusableCellWithIdentifier("User", forIndexPath: indexPath) as! User
            let userData = self.searchResults[indexPath.row] as! User
            user.handle = userData.handle
            user.username = userData.username
            user.profile_pic_key = "\(user.handle)~~profile_pic.jpg"
            user.updateDisplays()
            return user
        }
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 75.0
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if self.audioPlayer != nil {
            self.audioPlayer!.stop()
        }
        if self.scope == 0 {
            var track = self.tableView.cellForRowAtIndexPath(indexPath) as! Track
            download(getS3Key(track), NSURL(fileURLWithPath: track.trackURL)!, track_bucket) {
                (result) in
                dispatch_async(dispatch_get_main_queue()) {
                    track.generateWaveform()
                    track.activityView.stopAnimating()
                    self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
                    self.audioPlayer = AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: track.trackURL), error: nil)
                    self.audioPlayer!.play()
                }
            }
        } else {
            let user = self.tableView.cellForRowAtIndexPath(indexPath) as! User
            User.getUser(user, storyboard: self.storyboard!, navigationController: self.navigationController!)
            self.tableView.cellForRowAtIndexPath(indexPath)!.selected = false
        }
    }
    
    func loadNextData() {
        var currentNumResults = self.searchResults.count - 1
        if currentNumResults == self.allResults.count - 1 {
            return
        }
        for i in currentNumResults...currentNumResults + 15 {
            if i >= self.allResults.count {
                break
            }
            self.searchResults.append(self.allResults[i])
        }
        self.tableView.reloadData()
    }
    
    // Search Controller
    func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        self.scope = selectedScope
        self.searchResults = []
        self.tableView.reloadData()
    }
    
    func searchController(controller: UISearchController, shouldReloadTableForSearchString searchString: String!) -> Bool {
        if searchString == "" {
            return false
        }
        return true
    }
    
    func didDismissSearchController(searchController: UISearchController) {
        searchController.searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        let searchString = self.searchController?.searchBar.text
        if searchString == "" {
            return
        }
        self.searchTextFilter(searchString!)
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        self.back(nil)
    }

    func searchTextFilter(searchText: String) {
        let handle = NSUserDefaults.standardUserDefaults().valueForKey("username") as! String
        let passwordHash = hashPassword(keychainWrapper.myObjectForKey("v_Data") as! String)
        var request: NSMutableURLRequest
        var params: Dictionary<String, String>
        let scope = self.scope
        if scope == 0 {
            request = NSMutableURLRequest(URL: NSURL(string: "\(db)/search/recording")!)
            params = ["handle": handle, "password_hash": passwordHash, "song_name": searchText] as Dictionary
        } else {
            request = NSMutableURLRequest(URL: NSURL(string: "\(db)/search/user")!)
            params = ["handle": handle, "password_hash": passwordHash, "user_id": "\(current_user.userid!)", "query_name": searchText] as Dictionary
        }
        self.activityView.startAnimating()
        httpPost(params, request) {
            (data, statusCode, error) -> Void in
            if error != nil {
                Debug.printl("Error: \(error)", sender: self)
                return
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    self.activityView.stopAnimating()
                }
                // Check status codes
                if statusCode == HTTP_ERROR {
                    Debug.printl("Error: \(error)", sender: self)
                } else if statusCode == HTTP_WRONG_MEDIA {
                } else if statusCode == HTTP_SUCCESS_WITH_MESSAGE {
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        var error: NSError? = nil
                        var response: AnyObject? = NSJSONSerialization.JSONObjectWithData(data.dataUsingEncoding(NSUTF8StringEncoding)!, options: NSJSONReadingOptions.AllowFragments, error: &error)
                        if scope == 0 {
                            self.updateResults(response as! NSDictionary)
                        } else {
                            self.updateUserResults(response as! NSDictionary)
                        }
                    }
                } else {
                    Debug.printl("Unrecognized status code from server: \(statusCode)", sender: self)
                }
            }
        }
    }
    
    func updateResults(data: NSDictionary) {
        self.allResults = []
        self.searchResults = []
        var tracks = data["recordings"] as! NSArray
        for i in 0...tracks.count - 1 {
            var dict = tracks[i] as! NSDictionary
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
            
            self.allResults.append(track)
            if i < DEFAULT_DISPLAY_AMOUNT {
                self.searchResults.append(track)
            }
        }
        self.tableView.reloadData()
    }
    
    func updateUserResults(data: NSDictionary) {
        self.searchResults = []
        self.allResults = []
        var users = data["users"] as! NSArray
        for i in 0...users.count - 1 {
            var dict = users[i] as! NSDictionary
            var user = User()
            user.handle = dict["handle"] as? String
            user.username = dict["name"] as? String
            user.profile_pic_key = "\(user.handle)~~profile_pic.jpg"
            self.allResults.append(user)
            if i < DEFAULT_DISPLAY_AMOUNT {
                self.searchResults.append(user)
            }
        }
        self.tableView.reloadData()
    }
    
    func addTrack(sender: UIButton) {
        var track = sender.superview?.superview?.superview as! Track
        ProjectViewController.importTracks([track], navigationController: self.navigationController, storyboard: self.storyboard)
        let tabBarController = self.navigationController?.viewControllers[2] as! TabBarController
        tabBarController.selectedIndex = getTabBarController("project")
        self.back(nil)
    }
    
    func back(sender: AnyObject?) {
        self.navigationController?.popViewControllerAnimated(false)
    }
    
}
