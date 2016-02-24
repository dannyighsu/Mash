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

class SearchViewController: UITableViewController, UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating, UITextFieldDelegate {

    var completionTableView: UITableView? = nil
    var searchController: UISearchController?
    var audioPlayer: AVAudioPlayer? = nil
    var playerTimer: NSTimer? = nil
    var activityView: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
    // Holds the configurators for the currently displayed search results
    var searchResultConfigurators: [AnyObject] = []
    // Holds the configurators for all search results
    var allSearchResultConfigurators: [AnyObject] = []
    // Holds current suggestion results
    var suggestions: [[String]] = []
    var tags: [[String]] = []
    var scope: Int = 0
    var currTrackID: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize search controller
        self.searchController = UISearchController(searchResultsController: nil)
        self.searchController!.searchResultsUpdater = self
        self.searchController!.delegate = self
        self.searchController!.searchBar.delegate = self
        self.searchController!.searchBar.scopeButtonTitles = ["Recording", "User"]
        self.searchController!.dimsBackgroundDuringPresentation = false
        
        self.view.addSubview(self.activityView)
        self.activityView.center = self.view.center
        
        // Initialize completion table view
        self.completionTableView = UITableView(frame: self.view.frame, style: UITableViewStyle.Plain)
        self.completionTableView!.delegate = self
        self.completionTableView!.dataSource = self
        self.completionTableView!.scrollEnabled = true
        self.completionTableView!.backgroundColor = UIColor.whiteColor()
        self.completionTableView!.hidden = true
        self.view.addSubview(self.completionTableView!)
        
        // Register nibs
        let track = UINib(nibName: "Track", bundle: nil)
        self.tableView.registerNib(track, forCellReuseIdentifier: "Track")
        let user = UINib(nibName: "User", bundle: nil)
        self.tableView.registerNib(user, forCellReuseIdentifier: "User")
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorStyle = .None
        
        self.tableView.tableHeaderView = self.searchController?.searchBar
        self.definesPresentationContext = true
        let cancelButtonAttributes: NSDictionary = [NSForegroundColorAttributeName: lightBlue()]
        UIBarButtonItem.appearance().setTitleTextAttributes(cancelButtonAttributes as? [String : AnyObject], forState: UIControlState.Normal)
        self.searchController?.searchBar.sizeToFit()
        self.searchController?.searchBar.setShowsCancelButton(true, animated: false)
        self.searchController?.searchBar.tintColor = lightBlue()
        self.searchController?.searchBar.barTintColor = offWhite()
        self.searchController!.searchBar.becomeFirstResponder()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.setHidesBackButton(true, animated: false)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        if self.audioPlayer != nil {
            self.audioPlayer!.stop()
        }
        self.navigationItem.title = nil
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    // Table View Delegate
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.tableView {
            return self.searchResultConfigurators.count
        } else {
            return self.suggestions.count
        }
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == self.searchResultConfigurators.count - 1 {
            self.loadNextData()
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if tableView == self.tableView {
            var cell: UITableViewCell? = nil
            if self.scope == 0 {
                cell = self.tableView.dequeueReusableCellWithIdentifier("Track", forIndexPath: indexPath) as! Track

            } else {
                cell = self.tableView.dequeueReusableCellWithIdentifier("User", forIndexPath: indexPath) as! User
            }
            let configurator = self.searchResultConfigurators[indexPath.row] as! CellConfigurator
            configurator.configure(cell!, viewController: self)
            return cell!
        } else {
            let suggestionCell = SuggestionCell(style: UITableViewCellStyle.Default, reuseIdentifier: "SuggestionCell")
            suggestionCell.textLabel!.text = self.suggestions[indexPath.row].first
            suggestionCell.type = self.suggestions[indexPath.row].last!
            return suggestionCell
        }
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if tableView == self.tableView {
            return 75.0
        } else {
            return 50.0
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if tableView == self.tableView {
            if self.audioPlayer != nil {
                self.audioPlayer!.stop()
            }
            if self.scope == 0 {
                let cell = self.tableView.cellForRowAtIndexPath(indexPath) as! Track
                let configurator = self.searchResultConfigurators[indexPath.row] as! TrackCellConfigurator
                
                cell.activityView.startAnimating()
                download(getS3Key(configurator.track!), url: NSURL(fileURLWithPath: configurator.track!.trackURL), bucket: track_bucket) {
                    (result) in
                    dispatch_async(dispatch_get_main_queue()) {
                        cell.activityView.stopAnimating()
                        cell.generateWaveform(configurator.track!.trackURL)
                        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
                        self.audioPlayer = try? AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: configurator.track!.trackURL))
                        self.audioPlayer!.play()
                        if self.playerTimer != nil {
                            self.playerTimer!.invalidate()
                        }
                        self.playerTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "play:", userInfo: nil, repeats: true)
                        self.currTrackID = configurator.track!.id
                    }
                }
            } else {
                let configurator = self.searchResultConfigurators[indexPath.row] as! UserCellConfigurator
                User.getUser(configurator.user!, storyboard: self.storyboard!, navigationController: self.navigationController!)
                self.tableView.cellForRowAtIndexPath(indexPath)!.selected = false
            }
        } else {
            let inputString = self.suggestions[indexPath.row].first!
            let type = self.suggestions[indexPath.row].last!
            
            if self.searchController!.searchBar.text != nil {
                var searchStringArray = searchController!.searchBar.text!.characters.split {$0 == ","}.map(String.init)
                searchStringArray[searchStringArray.count - 1] = inputString
                self.searchController!.searchBar.text = searchStringArray.joinWithSeparator(",") + ","
            } else {
                self.searchController!.searchBar.text = inputString
            }
            self.tags.append([inputString, type])
            self.completionTableView!.hidden = true
        }
    }
    
    func loadNextData() {
        let currentNumResults = self.searchResultConfigurators.count
        if currentNumResults == self.allSearchResultConfigurators.count {
            return
        }
        for i in currentNumResults...currentNumResults + 15 {
            if i > self.allSearchResultConfigurators.count - 1 {
                break
            }
            self.searchResultConfigurators.append(self.allSearchResultConfigurators[i])
        }
        self.tableView.reloadData()
    }
    
    func play(sender: NSTimer) {
        if self.audioPlayer!.currentTime >= (self.audioPlayer!.duration / 2) || self.audioPlayer!.currentTime > 10.0 {
            sendPlayRequest(self.currTrackID)
            sender.invalidate()
        }
    }
    
    // Text Field Delegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        let text = textField.text
        if text == nil {
            return true
        }
        return true
    }
    
    // Search Bar & Controller
    func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        self.scope = selectedScope
        self.searchResultConfigurators = []
        self.completionTableView!.hidden = true
        self.tableView.reloadData()
    }
    
    func searchBar(searchBar: UISearchBar, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if self.scope == 0 {
            // Handle odd case where search text is just ","
            if searchBar.text == "," {
                return true
            }
            
            if range.length == 1 {
                if searchBar.text!.characters.last == "," {
                    var newTags = searchBar.text!.characters.split {$0 == ","}.map(String.init)
                    newTags.removeLast()
                    self.tags.removeLast()
                    if newTags.count == 0 {
                        searchBar.text = ""
                    } else {
                        searchBar.text = newTags.joinWithSeparator(",") + ","
                    }
                    return false
                }
                return true
            } else if self.completionTableView!.hidden == true {
                self.completionTableView!.hidden = false
                self.completionTableView!.center.y = self.view.center.y + (self.searchController!.searchBar.frame.size.height/2)
            }
        }
        return true
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            self.tags = []
        }
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
        let searchStringArray = searchController.searchBar.text!.characters.split {$0 == ","}.map(String.init)
        if searchStringArray.count > 0 {
            let searchString = searchStringArray.last!
            if searchString == "" {
                return
            }
            let re = try! NSRegularExpression(pattern: "\(searchString).*", options: [.CaseInsensitive])
            
            var result: [[String]] = []
            for (familyName, familyArray) in instrumentArray {
                let matches = re.matchesInString(familyName, options: [], range: NSRange(location: 0, length: familyName.characters.count))
                if matches.count > 0 {
                    result.append([familyName, "family"])
                }
                for instr in familyArray {
                    let matches = re.matchesInString(instr, options: [], range: NSRange(location: 0, length: instr.characters.count))
                    if matches.count > 0 {
                        result.append([instr, "instrument"])
                    }
                }
            }
            for (genreName, subgenreArray) in genreArray {
                let matches = re.matchesInString(genreName, options: [], range: NSRange(location: 0, length: genreName.characters.count))
                if matches.count > 0 {
                    result.append([genreName, "genre"])
                }
                for subgenre in subgenreArray {
                    let matches = re.matchesInString(subgenre, options: [], range: NSRange(location: 0, length: subgenre.characters.count))
                    if matches.count > 0 {
                        result.append([subgenre, "subgenre"])
                    }
                }
            }
            self.suggestions = result
            self.completionTableView!.reloadData()
        }
    }
    
    // Search function
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        let searchString = self.searchController?.searchBar.text
        if searchString == "" {
            return
        }
        self.completionTableView!.hidden = true
        if self.scope == 0 {
            self.searchTextFilter()
        } else {
            self.userSearchTextFilter()
        }
    }
    
    // Cancel function
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        self.back(nil)
    }

    func searchTextFilter() {
        self.activityView.startAnimating()
        let request = SearchTagRequest()
        request.userid = UInt32(currentUser.userid!)
        request.loginToken = currentUser.loginToken
        for tag in self.tags {
            let string = tag[0]
            let type = tag[1]
            switch (type) {
                case "instrument":
                    request.instrumentArray.addObject(string)
                case "family":
                    request.familyArray.addObject(string)
                case "genre":
                    request.genreArray.addObject(string)
                case "subgenre":
                    request.subgenreArray.addObject(string)
                default:
                    // FIXME: consider adding a misc search section to request?
                    Debug.printl("Unrecognized search string: \(type): \(string)", sender: self)
            }
        }
        
        if request.instrumentArray.count == 0 && request.familyArray.count == 0 && request.genreArray.count == 0 && request.subgenreArray.count == 0 {
            raiseAlert("Please select tags to search with.")
            return
        }
    
        server.searchTagWithRequest(request) {
            (response, error) in
            if error != nil {
                Debug.printl("Error: \(error)", sender: self)
                if error.code == 14 {
                    raiseAlert("No results found.")
                } else {
                    raiseAlert("Error occured. \(error.code)")
                }
                dispatch_async(dispatch_get_main_queue()) {
                    self.activityView.stopAnimating()
                }
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    self.activityView.stopAnimating()
                    self.updateResults(response)
                }
            }
        }
    }
    
    func userSearchTextFilter() {
        self.activityView.startAnimating()
        let request = UserSearchRequest()
        request.userid = UInt32(currentUser.userid!)
        request.loginToken = currentUser.loginToken
        request.search = self.searchController!.searchBar.text!.lowercaseString
        server.userSearchWithRequest(request) {
            (response, error) in
            if error != nil {
                Debug.printl("Error: \(error)", sender: self)
                if error.code == 14 {
                    raiseAlert("No results found.")
                } else {
                    raiseAlert("Error occured. \(error.code)")
                }
                dispatch_async(dispatch_get_main_queue()) {
                    self.activityView.stopAnimating()
                }
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    self.activityView.stopAnimating()
                    self.updateUserResults(response)
                }
            }
        }
    }
    
    func updateResults(response: Recordings) {
        self.allSearchResultConfigurators = []
        self.searchResultConfigurators = []
        if response.recordingArray.count != 0 {
            for i in 0...response.recordingArray.count - 1 {
                let rec = response.recordingArray[i] as! RecordingResponse
                let track = Track(frame: CGRectZero, recid: Int(rec.recid), userid: Int(rec.userid),instruments: rec.instrumentArray.copy() as! [String], instrumentFamilies: rec.familyArray.copy() as! [String], titleText: rec.title, bpm: Int(rec.bpm), timeSignature: Int(rec.bar), trackURL: filePathString(getS3Key(Int(rec.userid), recid: Int(rec.recid), format: rec.format)), user: rec.handle, format: rec.format, time: rec.uploaded, playCount: Int(rec.playCount), likeCount: Int(rec.likeCount), mashCount: Int(rec.likeCount), liked: rec.liked)
                let configurator = TrackCellConfigurator(track: track)
                self.allSearchResultConfigurators.append(configurator)
                if i < DEFAULT_DISPLAY_AMOUNT {
                    self.searchResultConfigurators.append(configurator)
                }
            }
        } else {
            raiseAlert("No Results Found")
        }
        self.tableView.reloadData()
    }
    
    func updateUserResults(response: UserPreviews) {
        self.allSearchResultConfigurators = []
        self.searchResultConfigurators = []
        if response.userArray.count != 0 {
            for i in 0...response.userArray.count - 1 {
                let data = response.userArray[i] as! UserPreview
                let user = User()
                user.handle = data.handle
                user.username = data.name
                user.userid = Int(data.userid)
                let configurator = UserCellConfigurator(user: user, shouldShowFollowButton: true)
                self.allSearchResultConfigurators.append(configurator)
                if i < DEFAULT_DISPLAY_AMOUNT {
                    self.searchResultConfigurators.append(configurator)
                }
            }
        } else {
            raiseAlert("No Results Found")
        }
        self.tableView.reloadData()
    }
    
    func addTrack(sender: UIButton) {
        let track = sender.superview?.superview?.superview as! Track
        ProjectViewController.importTracks([track], navigationController: self.navigationController, storyboard: self.storyboard)
    }
    
    func back(sender: AnyObject?) {
        self.navigationController?.popViewControllerAnimated(false)
    }
    
}

class SuggestionCell: UITableViewCell {
    var type: String = ""
}
