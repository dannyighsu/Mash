//
//  SearchViewController.swift
//  Mash-iOS
//
//  Created by Danny Hsu on 3/2/15.
//  Copyright (c) 2015 Mash. All rights reserved.
//

import Foundation
import UIKit

class SearchViewController: UITableViewController, UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating {
   
    var searchResults: [Track] = []
    var searchController: UISearchController?
    
    // Array for Testing Purposes
    var searchItems: [String] = ["T", "Th", "The", "Thes", "These", "TheSe", "THESE", "ab", "abc", "abcd"]
    
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
        let tap = UITapGestureRecognizer(target: self, action: "addTrack:")
        track.addButton.addGestureRecognizer(tap)
        track.titleText = searchResults[index].titleText
        track.title.text = searchResults[index].titleText
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Track", forIndexPath: indexPath) as! Track
        return cell
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 75.0
    }
    
    func searchController(controller: UISearchController, shouldReloadTableForSearchString searchString: String!) -> Bool {
        self.searchTextFilter(searchString)
        return true
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        self.back(nil)
    }

    func searchTextFilter(searchText: String) {
        let results = self.searchItems.filter({(track: String) -> Bool in
            let match = track.rangeOfString(searchText)
            return match != nil
        })
        for (var i = 0; i < results.count; i++) {
            self.searchResults.append(Track(frame: CGRectZero, instruments: ["multiple"], titleText: results[i]))
        }
        /*let username = NSUserDefaults.standardUserDefaults().valueForKey("username") as! String
        let passwordHash = hashPassword(keychainWrapper.myObjectForKey("v_Data") as! String)
        var request = NSMutableURLRequest(URL: NSURL(string: "\(db)/retrieve?username=\(username)&password_hash=\(passwordHash)&song_name=harp")!)
        httpGet(request) {
            (data, statusCode, error) -> Void in
            if error != nil {
                Debug.printl("Error: \(error)")
                return
            } else {
                // Check status codes
                if statusCode == HTTP_ERROR {
                    Debug.printl("Error: \(error)")
                    return
                } else if statusCode == HTTP_WRONG_MEDIA {
                    return
                } else if statusCode == HTTP_SUCCESS_WITH_MESSAGE {
                    Debug.printl("Data: \(data)")
                    return
                } else {
                    Debug.printl("Unrecognized status code from server: \(statusCode)")
                    return
                }
            }
        }*/
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        let searchString = self.searchController?.searchBar.text
        self.searchTextFilter(searchString!)
        self.tableView.reloadData()
    }
    
    func addTrack(sender: AnyObject?) {
        
    }
    
    func back(sender: AnyObject?) {
        self.navigationController?.popViewControllerAnimated(false)
    }
    
}
