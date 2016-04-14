//
//  SettingsViewController.swift
//  Mash-iOS
//
//  Created by Danny Hsu on 3/22/15.
//  Copyright (c) 2015 Mash. All rights reserved.
//

import Foundation
import UIKit

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var settingsTable: UITableView!
    var profile: DashboardController? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        self.settingsTable.delegate = self
        self.settingsTable.dataSource = self
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else if section == 1 {
            return 3
        } else if section == 2 {
            return 1
        }
        return 0
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 {
            return "Profile"
        } else if section == 2 {
            return ""
        }
        return nil
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "cell")
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                cell.textLabel!.text = "Log Out"
            }
        } else if indexPath.section == 1 {
            if indexPath.row == 0 {
                cell.textLabel!.text = "Change Profile Picture"
            } else if indexPath.row == 1 {
                cell.textLabel!.text = "Change Banner Photo"
            } else if indexPath.row == 2 {
                cell.textLabel!.text = "Change Display Name"
            }
        } else if indexPath.section == 2 {
            if indexPath.row == 0 {
                cell.textLabel!.text = "Delete this Account"
                cell.backgroundColor = UIColor.redColor()
                cell.textLabel!.textColor = UIColor.whiteColor()
            }
        }
        return cell
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                self.logout()
            }
        } else if indexPath.section == 1 {
            self.navigationController?.popViewControllerAnimated(true)
            if indexPath.row == 0 {
                self.profile!.changeProfilePic()
            } else if indexPath.row == 1 {
                self.profile!.changeBanner()
            } else if indexPath.row == 2 {
                self.profile!.changeName()
            }
        } else if indexPath.section == 2 {
            if indexPath.row == 0 {
                self.profile!.deleteUser()
            }
            self.navigationController?.popViewControllerAnimated(true)
        }
    }

    // Log out
    func logout() {
        let request = UserRequest()
        request.loginToken = currentUser.loginToken
        request.userid = UInt32(currentUser.userid!)
        
        server.signOutWithRequest(request) {
            (response, error) in
            if error != nil {
                Debug.printl("Error: \(error)", sender: self)
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    NSUserDefaults.standardUserDefaults().removeObjectForKey("hasLoginKey")
                    NSUserDefaults.standardUserDefaults().removeObjectForKey("hasFacebookLoginToken")
                    NSUserDefaults.standardUserDefaults().removeObjectForKey("facebookID")
                    NSUserDefaults.standardUserDefaults().removeObjectForKey("facebookLoginToken")
                    Debug.printl("User has successfully logged out - popping to root view controller.", sender: self)
                    self.navigationController?.popToRootViewControllerAnimated(true)
                }
            }
        }
    }

}
