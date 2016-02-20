//
//  ViewController.swift
//  Mash-iOS
//
//  Created by Danny Hsu on 2/24/15.
//  Copyright (c) 2015 Mash. All rights reserved.
//

import UIKit
import AVFoundation

class HomeTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var activityFeed: UITableView!
    var activityData: [HomeCell] = []
    var globalData: [HomeCell] = []
    var displayData: [HomeCellConfigurator] = []
    var activityView: ActivityView = ActivityView.make()
    var audioPlayer: AVAudioPlayer? = nil
    var playerTimer: NSTimer? = nil
    var currTrackID: Int = 0
    var tabControlBar: TabControlBar? = nil
    var currentScope: Int = 0
    var previousTableYOffset: CGFloat = 0.0
    var tabBarHidden: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set up table
        self.activityFeed.delegate = self
        self.activityFeed.dataSource = self
        self.activityFeed.separatorColor = offWhite()
        self.activityFeed.backgroundColor = offWhite()
        
        self.view.addSubview(self.activityView)
        self.activityView.center = self.view.center
        
        // Home cell and header registration
        let nib = UINib(nibName: "HomeCell", bundle: nil)
        self.activityFeed.registerNib(nib, forCellReuseIdentifier: "HomeCell")
        let buffer = UINib(nibName: "BufferCell", bundle: nil)
        self.activityFeed.registerNib(buffer, forCellReuseIdentifier: "BufferCell")
        let head = UINib(nibName: "TabControlBar", bundle: nil)
        self.activityFeed.registerNib(head, forHeaderFooterViewReuseIdentifier: "TabControlBar")
        let header = self.activityFeed.dequeueReusableHeaderFooterViewWithIdentifier("TabControlBar") as! TabControlBar
        header.scopeTab.addTarget(self, action: "didChangeScope:", forControlEvents: .ValueChanged)
        header.scopeTab.selectedSegmentIndex = 0
        self.tabControlBar = header
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .Light))
        blurView.frame = header.bounds
        blurView.contentView.backgroundColor = UIColor(red: 240, green: 240, blue: 240, alpha: 0.7)
        header.insertSubview(blurView, atIndex: 0)
        self.activityFeed.tableHeaderView = header

        // Pull to refresh
        /*self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to Refresh")
        self.refreshControl.addTarget(self, action: "refreshActivity:", forControlEvents: UIControlEvents.ValueChanged)
        self.activityFeed.addSubview(self.refreshControl) */
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.parentViewController?.navigationItem.title = "Mash"
        self.retrieveActivity()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.parentViewController?.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Search, target: self, action: "goToSearch:")
        /*if UIDevice.currentDevice().systemVersion.compare("9.0") == NSComparisonResult.OrderedAscending {
            self.activityView.frame = CGRect(x: self.activityView.frame.minX + self.navigationController!.navigationBar.frame.size.height, y: self.activityView.frame.minY, width: self.activityView.frame.width, height: self.activityView.frame.height)
        }*/
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        if self.audioPlayer != nil && self.audioPlayer!.playing {
            self.audioPlayer!.stop()
        }
        self.parentViewController?.navigationItem.rightBarButtonItem = nil
    }
    
    // TableView delegate
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return self.displayData.count
        } else {
            return 1
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 250.0
        } else {
            return 35
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = self.activityFeed.dequeueReusableCellWithIdentifier("HomeCell")!
            let configurator = self.displayData[indexPath.row]
            configurator.configure(cell)
            return cell
        } else {
            let cell = self.activityFeed.dequeueReusableCellWithIdentifier("BufferCell")!
            cell.backgroundColor = UIColor.clearColor()
            return cell
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            let cell = tableView.cellForRowAtIndexPath(indexPath) as! HomeCell
            self.playTrack(cell)
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        } else {
            return
        }
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            if indexPath.row == self.displayData.count - 1 {
                self.loadNextData()
            }
        }
    }
    
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        if indexPath.section == 0 {
            return indexPath
        } else {
            return nil
        }
    }
    
    // Scope tab
    func didChangeScope(sender: UISegmentedControl) {
        self.currentScope = sender.selectedSegmentIndex
        if self.currentScope == 0 {
            if self.activityData.count > 0 {
                for i in 0...DEFAULT_DISPLAY_AMOUNT {
                    if i == self.activityData.count {
                        break
                    }
                    let activityData = self.activityData[i]
                    let configurator = HomeCellConfigurator(activity: activityData)
                    self.displayData.append(configurator)
                }
            } else {
                retrieveActivity()
                return
            }
        } else {
            if self.globalData.count > 0 {
                for i in 0...DEFAULT_DISPLAY_AMOUNT {
                    if i == self.globalData.count {
                        break
                    }
                    let activityData = self.globalData[i]
                    let configurator = HomeCellConfigurator(activity: activityData)
                    self.displayData.append(configurator)
                }
            } else {
                retrieveGlobal()
                return
            }
        }
        self.activityFeed.reloadData()
    }

    // Auxiliary methods
    func getUser(sender: UIButton) {
        let cell = sender.superview?.superview?.superview as! HomeCell
        let user = User()
        user.handle = cell.userLabel.titleLabel!.text
        user.userid = cell.user!.userid
        User.getUser(user, storyboard: self.storyboard!, navigationController: self.navigationController!)
    }
    
    func play(sender: NSTimer) {
        if self.audioPlayer!.currentTime >= (self.audioPlayer!.duration / 2) || self.audioPlayer!.currentTime > 10.0 {
            sendPlayRequest(self.currTrackID)
            sender.invalidate()
        }
    }
    
    func playButton(sender: UIButton) {
        var cell = sender.superview
        while cell != nil && !(cell is HomeCell) {
            cell = cell!.superview
        }
        let homecell = cell as! HomeCell
        self.playTrack(homecell)
    }
    
    func playTrack(cell: HomeCell) {
        download(getS3Key(cell.track!), url: NSURL(fileURLWithPath: cell.track!.trackURL), bucket: track_bucket) {
            (result) in
            if result != nil {
                dispatch_async(dispatch_get_main_queue()) {
                    do {
                        try self.audioPlayer = AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: cell.track!.trackURL))
                        self.audioPlayer!.play()
                        if self.playerTimer != nil {
                            self.playerTimer!.invalidate()
                        }
                        self.playerTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "play:", userInfo: nil, repeats: true)
                        self.currTrackID = cell.track!.id
                    } catch _ as NSError {
                        Debug.printl("Error downloading track", sender: self)
                    }
                }
            }
        }
    }
    
    func like(sender: UIButton) {
        var cell = sender.superview
        while cell != nil && !(cell is HomeCell) {
            cell = cell!.superview
        }
        let homecell = cell as! HomeCell
        sendLikeRequest(homecell.track!.id) {
            (success) in
            if success {
                sender.setImage(UIImage(named: "liked"), forState: .Normal)
            }
        }
    }
    
    func add(sender: UIButton) {
        var cell = sender.superview
        while cell != nil && !(cell is HomeCell) {
            cell = cell!.superview
        }
        let homecell = cell as! HomeCell
        ProjectViewController.importTracks([homecell.track!], navigationController: self.navigationController!, storyboard: self.storyboard!)
    }
    
    // Check if project view exists in memory, if not, create one.
    func showProjectView() {
        let count = (self.navigationController?.viewControllers.count)! as Int
        for (var i = 0; i < count; i++) {
            let controller = self.navigationController?.viewControllers[i] as? ProjectViewController
            if controller != nil {
                Debug.printl("Showing Project View", sender: self)
                self.navigationController?.viewControllers.removeAtIndex(i)
                self.navigationController?.pushViewController(controller!, animated: true)
                return
            }
        }
        Debug.printl("Creating new Project View", sender: self)
        let projectview = self.storyboard?.instantiateViewControllerWithIdentifier("ProjectViewController") as! ProjectViewController
        self.navigationController?.pushViewController(projectview, animated: true)
    }
    
    func loadNextData() {
        var data: [HomeCell]
        if self.currentScope == 0 {
            data = self.activityData
        } else {
            data = self.globalData
        }
        let currentNumResults = self.displayData.count
        if currentNumResults == data.count {
            return
        }
        for i in currentNumResults...currentNumResults + 15 {
            if i > data.count - 1 {
                break
            }
            
            let configurator = HomeCellConfigurator(activity: data[i])
            self.displayData.append(configurator)
        }
        self.activityFeed.reloadData()
    }
    
    /*// Request recent activity from db, display on table
    func refreshActivity(sender: AnyObject) {
        Debug.printl("feed refresh requested")
        self.refreshControl.endRefreshing()
    }*/

    // Push search page up
    func goToSearch(sender: AnyObject?) {
        let search = self.storyboard?.instantiateViewControllerWithIdentifier("SearchViewController") as! SearchViewController
        self.navigationController?.pushViewController(search, animated: false)
    }

    func retrieveActivity() {
        self.activityView.startAnimating()
        let request = FeedRequest()
        request.user = UserRequest()
        request.user.userid = UInt32(currentUser.userid!)
        request.user.loginToken = currentUser.loginToken
        
        server.feedWithRequest(request) {
            (response, error) in
            if error != nil {
                Debug.printl("Error: \(error)", sender: nil)
            } else {
                self.updateActivity(response, scope: 0)
            }
        }
    }
    
    func retrieveGlobal() {
        self.activityView.startAnimating()
        let request = FeedRequest()
        request.user = UserRequest()
        request.user.userid = UInt32(currentUser.userid!)
        request.user.loginToken = currentUser.loginToken
        
        server.globalFeedWithRequest(request) {
            (response, error) in
            if error != nil {
                Debug.printl("Error: \(error)", sender: nil)
            } else {
                self.updateActivity(response, scope: 1)
            }
        }
    }
    
    func updateActivity(response: FeedResponse, scope: Int) {
        var data: [HomeCell]
        if scope == 0 {
            data = self.activityData
        } else {
            data = self.globalData
        }
        data = []
        self.displayData = []
        
        if response.storyArray.count != 0 {
            for i in 0...response.storyArray.count - 1 {
                let recording = response.storyArray[i] as! RecordingResponse
                let user = recording.handle
                let title = recording.title
                let time = recording.uploaded
                let userid = recording.userid
                
                let follower = User()
                follower.handle = user
                follower.userid = Int(userid)
                
                let track = Track(frame: CGRectZero, recid: Int(recording.recid), userid: Int(recording.userid), instruments: recording.instrumentArray.copy() as! [String], instrumentFamilies: recording.familyArray.copy() as! [String], titleText: recording.title, bpm: Int(recording.bpm), trackURL: filePathString("\(userid)~~\(Int(recording.recid)).\(recording.format)"), user: recording.handle, format: recording.format, time: time, playCount: Int(recording.playCount), likeCount: Int(recording.likeCount), mashCount: Int(recording.likeCount))
                
                let activityData = HomeCell(frame: CGRectZero, eventText: title, userText: user, timeText: time, user: follower, track: track)
                data.append(activityData)
                if i < DEFAULT_DISPLAY_AMOUNT {
                    let configurator = HomeCellConfigurator(activity: activityData)
                    self.displayData.append(configurator)
                }
            }
        }
        
        dispatch_async(dispatch_get_main_queue()) {
            self.activityFeed.reloadData()
            self.activityView.stopAnimating()
        }
    }

}

