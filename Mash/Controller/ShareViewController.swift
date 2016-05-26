//
//  ShareViewController.swift
//  Mash
//
//  Created by Danny Hsu on 5/9/16.
//  Copyright © 2016 Mash. All rights reserved.
//

import Foundation
import UIKit

class ShareViewController: UIViewController, FBSDKAppInviteDialogDelegate {
    
    @IBOutlet weak var inviteButton: UIButton!
    var completion: () -> Void = {}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Skip", style: .Plain, target: self, action: #selector(ShareViewController.skip))
    }
    
    @IBAction func inviteButtonPressed(sender: AnyObject) {
        // Create Facebook invite view
        Branch.getInstance().getShortURLWithParams([:], andChannel: "facebook", andFeature: "app_invite") {
            (url, error) in
            let inviteDialog = FBSDKAppInviteDialog()
            inviteDialog.delegate = self
            if inviteDialog.canShow() {
                inviteDialog.content = FBSDKAppInviteContent()
                inviteDialog.content.appLinkURL = NSURL(string: url)
                inviteDialog.content.appInvitePreviewImageURL = NSURL(string: "https://s3.amazonaws.com/mash-utility-objects/icon1024.png")
                inviteDialog.show()
            }
        }
    }
    
    func appInviteDialog(appInviteDialog: FBSDKAppInviteDialog!, didCompleteWithResults results: [NSObject : AnyObject]!) {
        self.completion()
    }
    
    func appInviteDialog(appInviteDialog: FBSDKAppInviteDialog!, didFailWithError error: NSError!) {
        self.completion()
    }
    
    func skip() {
        self.completion()
    }
    
}
