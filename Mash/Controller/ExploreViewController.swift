//
//  ExploreViewController.swift
//  Mash-iOS
//
//  Created by Danny Hsu on 5/3/15.
//  Copyright (c) 2015 Mash. All rights reserved.
//

import Foundation
import UIKit

class ExploreViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var viewHeader: UIView!
    @IBOutlet weak var exploreDisplay: UITableView!
    var exploreDisplayResults: [Track] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Register track cells for initial search display
        let track = UINib(nibName: "Track", bundle: nil)
        self.exploreDisplay.registerNib(track, forCellReuseIdentifier: "Track")
        /*let header = UINib(nibName: "ExploreHeaderView", bundle: nil)
        self.exploreDisplay.registerNib(header, forHeaderFooterViewReuseIdentifier: "HeaderView")*/

        // Set exploreDisplay properties
        self.exploreDisplay.delegate = self
        self.exploreDisplay.dataSource = self
        self.exploreDisplay.rowHeight = 75.0
        
        self.retrieveDisplayResults()
        
        // Temporary
        self.exploreDisplay.hidden = true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.parentViewController?.navigationItem.title = "Explore"
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.parentViewController?.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Search, target: self, action: "goToSearch:")
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.parentViewController?.navigationItem.rightBarButtonItem = nil
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.exploreDisplayResults.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.exploreDisplay.dequeueReusableCellWithIdentifier("Track") as! Track
        return cell
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if tableView == self.exploreDisplay {
            let result = self.exploreDisplayResults[indexPath.row]
            let track = cell as! Track
            track.title.text = result.titleText
            track.titleText = result.titleText
            track.userText = result.userText
            track.userLabel.text = result.userText
            track.instruments = result.instruments
            track.trackURL = result.trackURL
            track.instrumentImage.image = findImage(result.instruments)
            track.addButton.addTarget(self, action: "addTrack:", forControlEvents: UIControlEvents.TouchDown)
        }
    }
    
    /*func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = self.exploreDisplay.dequeueReusableHeaderFooterViewWithIdentifier("HeaderView") as! ExploreHeaderView
        return header
    }
    
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! ExploreHeaderView
        header.searchButton.contentMode = UIViewContentMode.ScaleAspectFit
        let tap = UITapGestureRecognizer(target: self, action: "goToSearch:")
        header.searchButton.addGestureRecognizer(tap)
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60.0
    }*/
    
    func retrieveDisplayResults() {
        
    }
    
    // Add selected track to project
    func addTrack(sender: UIButton) {
        let track = sender.superview!.superview!.superview as! Track
        importTracks([track], self.navigationController, self.storyboard)
        let tabBarController = self.navigationController?.viewControllers[2] as! UITabBarController
        tabBarController.selectedIndex = getTabBarController("project")
    }

    // Go to search controller
    func goToSearch(sender: AnyObject?) {
        let searchController = self.storyboard?.instantiateViewControllerWithIdentifier("SearchViewController") as! SearchViewController
        self.navigationController?.pushViewController(searchController, animated: false)

        /*UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(0.5)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationTransition(UIViewAnimationTransition.CurlDown, forView: self.navigationController!.view, cache: true)
        UIView.commitAnimations()*/
    }

}
