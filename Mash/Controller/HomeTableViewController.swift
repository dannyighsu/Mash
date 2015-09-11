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
    var activityView: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set up table
        self.activityFeed.delegate = self
        self.activityFeed.dataSource = self
        self.activityFeed.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
        
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
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.parentViewController?.navigationItem.rightBarButtonItem = nil
    }
    
    // TableView delegate
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100.0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.activityFeed.dequeueReusableCellWithIdentifier("HomeCell") as! HomeCell
        cell.eventLabel.text = self.data[indexPath.row].eventText
        cell.userLabel.text = self.data[indexPath.row].userText
        cell.timeLabel.text = self.data[indexPath.row].timeText
        cell.timeLabel.text = cell.timeLabel.text!.substringWithRange(Range<String.Index>(start: cell.timeLabel.text!.startIndex, end: advance(cell.timeLabel.text!.endIndex, -13)))
        self.data[indexPath.row].user!.setProfilePic(cell.profileImage)
        cell.profileImage.contentMode = UIViewContentMode.ScaleAspectFit
        cell.profileImage.layer.cornerRadius = cell.profileImage.frame.size.width / 2
        cell.profileImage.layer.borderWidth = 0.5
        cell.profileImage.layer.masksToBounds = true
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! HomeCell
        var user = User()
        user.handle = cell.userLabel.text
        User.getUser(user, storyboard: self.storyboard!, navigationController: self.navigationController!)
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == self.data.count - 1 {
            self.loadNextData()
        }
    }
    
    func loadNextData() {
        
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
        var request = FeedRequest()
        request.userid = UInt32(currentUser.userid!)
        request.loginToken = currentUser.loginToken
        
        serverClient.feedWithRequest(request) {
            (response, error) in
            if error != nil {
                Debug.printl("Error: \(error)", sender: nil)
            } else {
                self.updateActivity(response)
            }
        }
    }
    
    func updateActivity(response: FeedResponse) {
        for item in response.storyArray {
            let story = item as! FeedResponse_Story
            let recording = story.recStory.recording
            let user = recording.handle
            let title = recording.title
            let time = recording.uploaded
            let id = recording.recid
            var follower = User()
            follower.handle = user
            follower.userid = Int(recording.userid)
            let cell = HomeCell(frame: CGRectZero, eventText: title, userText: user, timeText: time, user: follower)
            self.data.append(cell)
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

