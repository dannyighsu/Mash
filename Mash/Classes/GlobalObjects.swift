//
//  GlobalObjects.swift
//  Mash
//
//  Created by Danny Hsu on 2/1/16.
//  Copyright © 2016 Mash. All rights reserved.
//

import Foundation
import UIKit

let loadBalancerAddress: String = "http://52.27.78.119:5010"
let loadBalancer: LoadBalancer = LoadBalancer(host: loadBalancerAddress)
let track_bucket: String = "mash1-tracks"
let profile_bucket: String = "mash-profiles"
let banner_bucket: String = "mash-banners"
let waveform_bucket: String = "mash-trackwaveforms"
let DEFAULT_DISPLAY_AMOUNT = 15
var hostAddress: String = "nil"
var server: MashService = MashService(host: hostAddress)
var serverTimer: NSTimer = NSTimer()
var keychainWrapper: KeychainWrapper = KeychainWrapper()
var currentUser = User()
var userFollowing: [User] = []
var currentProject: UINavigationController? = nil
var rootTabBarController: TabBarController? = nil
var rootNavigationController: RootNavigationController? = nil
var mainStoryboard: UIStoryboard? = nil
var deviceNotificationToken: String = ""
var projectNotification: QuickActivityView = QuickActivityView.createView()
