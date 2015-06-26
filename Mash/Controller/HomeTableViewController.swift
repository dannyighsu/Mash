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
    var data: [Track] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set up table
        self.activityFeed.delegate = self
        self.activityFeed.dataSource = self
        self.activityFeed.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
        
        // Home cell and header registration
        let nib = UINib(nibName: "HomeCell", bundle: nil)
        self.activityFeed.registerNib(nib, forCellReuseIdentifier: "HomeCell")
        let header = UINib(nibName: "HomeHeaderView", bundle: nil)
        self.activityFeed.registerNib(header, forHeaderFooterViewReuseIdentifier: "HomeHeaderView")

        // Pull to refresh
        /*self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to Refresh")
        self.refreshControl.addTarget(self, action: "refreshActivity:", forControlEvents: UIControlEvents.ValueChanged)
        self.activityFeed.addSubview(self.refreshControl) */
        
        self.retrieveTracks()
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = self.activityFeed.dequeueReusableHeaderFooterViewWithIdentifier("HomeHeaderView") as! HomeHeaderView
        return header
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60.0
    }
    
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! HomeHeaderView
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100.0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.activityFeed.dequeueReusableCellWithIdentifier("HomeCell") as! HomeCell
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        Debug.printl("Selected cell #\(indexPath.row)", sender: self)
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        let track = cell as! HomeCell
        track.Event.text = self.data[indexPath.row].titleText
        track.User.text = "Danny"
        track.profileImage.image = UIImage(named: "logo")
        track.profileImage.contentMode = UIViewContentMode.ScaleAspectFit
        track.profileImage.layer.cornerRadius = track.profileImage.frame.size.width / 2
        track.profileImage.layer.borderWidth = 0.5
        track.profileImage.layer.masksToBounds = true
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
        self.navigationController?.pushViewController(search, animated: true)
    }

    func retrieveTracks() {
        self.data.append(Track(frame: CGRectZero, instruments: ["sample"], titleText: "Harp", bpm: 120, trackURL: "Harp", user: "Danny", format: ".m4a"))
        self.data.append(Track(frame: CGRectZero, instruments: ["drums"], titleText: "Spacious Set", bpm: 120, trackURL: "Spacious Set", user: "Danny", format: ".m4a"))
        self.data.append(Track(frame: CGRectZero, instruments: ["strings"], titleText: "Basses Legato", bpm: 120, trackURL: "Basses Legato", user: "Danny", format: ".m4a"))
        self.data.append(Track(frame: CGRectZero, instruments: ["vocals"], titleText: "Female Chorus", bpm: 120, trackURL: "Female Chorus", user: "Danny", format: ".m4a"))
        self.data.append(Track(frame: CGRectZero, instruments: ["strings"], titleText: "Violins", bpm: 120, trackURL: "Violins 1", user: "Danny", format: ".m4a"))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

