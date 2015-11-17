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
    var data: [HomeCell] = []
    var displayData: [HomeCell] = []
    var activityView: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
    var audioPlayer: AVAudioPlayer? = nil
    
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
        self.activityFeed.frame = self.view.frame
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
        return self.displayData.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100.0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.activityFeed.dequeueReusableCellWithIdentifier("HomeCell") as! HomeCell
        cell.eventLabel.text = self.displayData[indexPath.row].eventText
        cell.userLabel.setTitle(self.displayData[indexPath.row].userText, forState: .Normal)
        cell.timeLabel.text = self.displayData[indexPath.row].timeText
        cell.user = self.displayData[indexPath.row].user
        cell.track = self.displayData[indexPath.row].track
        cell.timeLabel.text = parseTimeStamp(cell.timeLabel.text!)
        self.displayData[indexPath.row].user!.setProfilePic(cell.profileImage)
        cell.profileImage.contentMode = UIViewContentMode.ScaleAspectFill
        cell.profileImage.layer.cornerRadius = cell.profileImage.frame.size.width / 2
        cell.profileImage.layer.borderWidth = 0.5
        cell.profileImage.layer.masksToBounds = true
        cell.userLabel.addTarget(self, action: "getUser:", forControlEvents: UIControlEvents.TouchUpInside)
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! HomeCell
        cell.activityView.startAnimating()
        download(getS3Key(cell.track!), url: filePathURL(cell.track!.trackURL), bucket: track_bucket) {
            (result) in
            if result != nil {
                dispatch_async(dispatch_get_main_queue()) {
                    cell.activityView.stopAnimating()
                    do {
                        try self.audioPlayer = AVAudioPlayer(contentsOfURL: filePathURL(cell.track!.trackURL))
                        self.audioPlayer!.play()
                    } catch _ as NSError {
                        Debug.printl("Error downloading track", sender: self)
                    }
                }
            }
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == self.displayData.count - 1 {
            self.loadNextData()
        }
    }

    // Auxiliary methods
    func getUser(sender: UIButton) {
        let cell = sender.superview?.superview?.superview as! HomeCell
        let user = User()
        user.handle = cell.userLabel.titleLabel!.text
        user.userid = cell.user!.userid
        User.getUser(user, storyboard: self.storyboard!, navigationController: self.navigationController!)
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
        let currentNumResults = self.displayData.count
        if currentNumResults == self.data.count {
            return
        }
        for i in currentNumResults...currentNumResults + 15 {
            if i > self.data.count - 1 {
                break
            }
            self.displayData.append(self.data[i])
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
        Debug.printl("Going to Search", sender: self)
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
                self.updateActivity(response)
            }
        }
    }
    
    func updateActivity(response: FeedResponse) {
        self.data = []
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
                
                let track = Track(frame: CGRectZero, recid: Int(recording.recid), userid: Int(recording.userid),instruments: recording.instrumentArray.copy() as! [String], instrumentFamilies: recording.familyArray.copy() as! [String], titleText: recording.title, bpm: Int(recording.bpm), trackURL: getS3Key(Int(recording.userid), recid: Int(recording.recid), format: recording.format), user: recording.handle, format: recording.format, time: time)
                
                let cell = HomeCell(frame: CGRectZero, eventText: title, userText: user, timeText: time, user: follower, track: track)
                self.data.append(cell)
                if i < DEFAULT_DISPLAY_AMOUNT {
                    self.displayData.append(cell)
                }
            }
        }
        
        dispatch_async(dispatch_get_main_queue()) {
            self.activityFeed.reloadData()
            self.activityView.stopAnimating()
        }
        /*self.data = []
        var activity = data["feed"] as! NSArray
        for item in activity {
            let type = item["type"] as! String
            if type == "follow" {
                let follower = item["following_handle"] as! String
                let followed = item["followed_handle"] as! String
                let event = "\(follower) followed \(followed)."
                let time = item["timestamp"] as! String
                var user = User()
                user.handle = follower
                user.profilePicKey = "\(user.handle!)~~profile_pic.jpg"
                let cell = HomeCell(frame: CGRectZero, eventText: event, userText: follower, timeText: time, user: user)
                self.data.append(cell)
            } else if type == "recording" {
                let user = item["following_handle"] as! String
                let recording = item["recording_name"] as! String
                let time = item["timestamp"] as! String
                let event = "\(recording)"
                var follower = User()
                follower.handle = user
                follower.profilePicKey = "\(follower.handle!)~~profile_pic.jpg"
                let cell = HomeCell(frame: CGRectZero, eventText: event, userText: user, timeText: time, user: follower)
                self.data.append(cell)
            }
        }
        self.activityFeed.reloadData()
        self.activityView.stopAnimating()*/
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

