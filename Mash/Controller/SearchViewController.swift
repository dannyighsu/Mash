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
   
    var searchResults: [Track] = []
    var searchController: UISearchController?
    var audioPlayer: AVAudioPlayer? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Initialize search controller
        self.searchController = UISearchController(searchResultsController: nil)
        self.searchController!.searchResultsUpdater = self
        self.searchController!.delegate = self
        self.searchController!.searchBar.delegate = self
        
        // Register nibs
        let track = UINib(nibName: "Track", bundle: nil)
        self.tableView.registerNib(track, forCellReuseIdentifier: "Track")

        // Set searchDisplay properties
        /* let searchDisplay = self.searchController.searchResultsController
        searchDisplay?.rowHeight = 75.0
        searchDisplay?.separatorStyle = .None*/
        
        self.tableView.tableHeaderView = self.searchController?.searchBar
        self.definesPresentationContext = true
        self.searchController?.searchBar.sizeToFit()
        
        self.searchController?.searchBar.setShowsCancelButton(true, animated: true)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        if self.audioPlayer != nil {
            self.audioPlayer!.stop()
        }
        self.navigationController?.navigationBarHidden = false
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.searchResults.count
    }

    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        let index = indexPath.row
        let track = cell as! Track
        track.title.text = self.searchResults[index].titleText
        track.titleText = track.title.text!
        track.instruments = self.searchResults[index].instruments
        track.trackURL = self.searchResults[index].trackURL
        track.instrumentImage.image = findImage(track.instruments)
        track.addButton.addTarget(self, action: "addTrack:", forControlEvents: UIControlEvents.TouchDown)
        track.titleText = searchResults[index].titleText
        track.title.text = searchResults[index].titleText
        track.userText = searchResults[index].userText
        track.userLabel.text = track.userText
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Track", forIndexPath: indexPath) as! Track
        return cell
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 75.0
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if self.audioPlayer != nil {
            self.audioPlayer!.stop()
        }
        var track = tableView.cellForRowAtIndexPath(indexPath) as! Track
        println("download key: \(track.userText)~~\(track.titleText)\(track.format)")
        println("url:\(track.trackURL)")
        download("\(track.userText)~~\(track.titleText)\(track.format)", NSURL(fileURLWithPath: track.trackURL)!, track_bucket)
        while !NSFileManager.defaultManager().fileExistsAtPath(track.trackURL) {
            Debug.printnl("waiting...")
            NSThread.sleepForTimeInterval(0.5)
        }
        NSThread.sleepForTimeInterval(0.5)
        
        self.audioPlayer = AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: track.trackURL), error: nil)
        self.audioPlayer!.play()
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        Debug.printl("Playing track \(track.titleText)", sender: self)
    }
    
    func searchController(controller: UISearchController, shouldReloadTableForSearchString searchString: String!) -> Bool {
        self.searchTextFilter(searchString)
        return true
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        self.back(nil)
    }

    func searchTextFilter(searchText: String) {
        /*let results = self.searchItems.filter({(track: String) -> Bool in
            let match = track.rangeOfString(searchText)
            return match != nil
        })
        for (var i = 0; i < results.count; i++) {
            self.searchResults.append(Track(frame: CGRectZero, instruments: ["multiple"], titleText: results[i]))
        }*/
        let username = NSUserDefaults.standardUserDefaults().valueForKey("username") as! String
        let passwordHash = hashPassword(keychainWrapper.myObjectForKey("v_Data") as! String)
        var request = NSMutableURLRequest(URL: NSURL(string: "\(db)/search/recording")!)
        var params = ["username": username, "password_hash": passwordHash, "song_name": searchText] as Dictionary
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
                } else if statusCode == HTTP_SUCCESS_WITH_MESSAGE {
                    var error: NSError? = nil
                    var response: AnyObject? = NSJSONSerialization.JSONObjectWithData(data.dataUsingEncoding(NSUTF8StringEncoding)!, options: NSJSONReadingOptions.AllowFragments, error: &error)
                    self.updateResults(response as! NSDictionary)
                    return
                } else {
                    Debug.printl("Unrecognized status code from server: \(statusCode)", sender: self)
                    return
                }
            }
        }
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        let searchString = self.searchController?.searchBar.text
        self.searchTextFilter(searchString!)
    }
    
    func updateResults(data: NSDictionary) {
        self.searchResults = []
        var tracks = data["recordings"] as! NSArray
        for t in tracks {
            var dict = t as! NSDictionary
            var instruments = dict["instrument"] as! NSArray
            var instrument = ""
            if instruments.count != 0 {
                instrument = instruments[0] as! String
            }
            var url = (dict["song_name"] as! String) + (dict["format"] as! String)
            url = filePathString(url)
            var track = Track(frame: CGRectZero, instruments: [instrument], titleText: dict["song_name"] as! String, bpm: dict["bpm"] as! Int, trackURL: url, user: dict["username"] as! String, format: dict["format"] as! String)
            self.searchResults.append(track)
        }
        dispatch_async(dispatch_get_main_queue()) {
            self.tableView.reloadData()
        }
        /*var users = data["user"] as! NSArray
        for u in users {
            var dict = u as! NSDictionary
            var user = User(username: data["username"] as? String, altname: data["display_name"] as? String, profile_pic_link: data["profile_pic_link"] as? String, banner_pic_link: data["banner_pic_link"] as? String, followers: String(data["followers"] as! Int), following: String(data["following"] as! Int), tracks: String(data["tracks"] as! Int), description: data["description"] as? String)
            self.searchResults.append(user)
        }
        dispatch_async(dispatch_get_main_queue()) {
            self.tableView.reloadData()
        }*/
    }
    
    func addTrack(sender: UIButton) {
        var track = sender.superview?.superview?.superview as! Track
        importTracks([track], self.navigationController, self.storyboard)
    }
    
    func back(sender: AnyObject?) {
        self.navigationController?.popViewControllerAnimated(false)
    }
    
}
