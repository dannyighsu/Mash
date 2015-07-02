//
//  ProjectPreferencesViewController.swift
//  Mash-iOS
//
//  Created by Danny Hsu on 6/21/15.
//  Copyright (c) 2015 Mash. All rights reserved.
//

import Foundation
import UIKit

class ProjectPreferencesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var preferencesTable: UITableView!
    var projectView: ProjectViewController? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.preferencesTable.delegate = self
        self.preferencesTable.dataSource = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBarHidden = false
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "cell")
        if indexPath.row == 0 {
            cell.textLabel!.text = "New Project"
        } else if indexPath.row == 1 {
            cell.textLabel!.text = "Mash"
        } else {
            cell.textLabel!.text = "Save"
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 0 {
            self.navigationController?.popViewControllerAnimated(true)
            self.projectView?.confirmNewProject()
        } else if indexPath.row == 1 {
            self.navigationController?.popViewControllerAnimated(true)
            self.projectView?.mash()
        } else {
            self.navigationController?.popViewControllerAnimated(true)
            self.projectView?.saveAlert()
        }
    }
    
}
