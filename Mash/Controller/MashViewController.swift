//
//  MashViewController.swift
//  Mash-iOS
//
//  Created by Danny Hsu on 6/19/15.
//  Copyright (c) 2015 Mash. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class MashViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIAlertViewDelegate {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var instrumentsCollection: UICollectionView!
    @IBOutlet weak var cancelButton: UIButton!
    var recording: Track? = nil
    var bpm: Int? = nil
    var instruments: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.instrumentsCollection.delegate = self
        self.instrumentsCollection.dataSource = self
        let cell = UINib(nibName: "InstrumentCell", bundle: nil)
        self.instrumentsCollection.registerNib(cell, forCellWithReuseIdentifier: "InstrumentCell")
        self.cancelButton.addTarget(self, action: "cancel:", forControlEvents: UIControlEvents.TouchDown)
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return instrumentArray.count
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = self.instrumentsCollection.cellForItemAtIndexPath(indexPath) as! InstrumentCell
        self.instruments.append(cell.instrument)
        cell.layer.borderColor = UIColor.whiteColor().CGColor
        cell.layer.borderWidth = 1.0
        self.downloadAction([cell.instrument])
    }
    
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        let instr = cell as! InstrumentCell
        instr.instrument = Array(instrumentArray.keys)[indexPath.row]
        instr.instrumentImage.image = findImage([instr.instrument])
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = self.instrumentsCollection.dequeueReusableCellWithReuseIdentifier("InstrumentCell", forIndexPath: indexPath) as! InstrumentCell
        /* let screenRect:CGRect = UIScreen.mainScreen().bounds
        let screenWidth:CGFloat = screenRect.size.width
        
        let index = CGFloat(indexPath.row % 3)
        
        cell.frame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y, screenWidth / 3, screenWidth / 3)*/
        return cell
    }
    
    // Upload file to bucket, then post information to server
    func downloadAction(instrument: [String]) {
        // Bucket upload
        var urlString = self.recording
        download(urlString!.titleText, filePathURL(self.recording!.titleText + ".aif"), track_bucket)
        
        // Post data to server
        let username = NSUserDefaults.standardUserDefaults().valueForKey("username") as! String
        let passwordHash = hashPassword(keychainWrapper.myObjectForKey("v_Data") as! String)
        var instrumentString = String(stringInterpolationSegment: instrument)
        instrumentString = instrumentString.substringWithRange(Range<String.Index>(start: advance(instrumentString.startIndex, 1), end: advance(instrumentString.endIndex, -1)))
        
        var request = NSMutableURLRequest(URL: NSURL(string: "\(db)/mash")!)
        var params: [String: String] = ["username": username, "password_hash": passwordHash, "instrument": instrumentString]
        httpPost(params, request) {
            (data, statusCode, error) -> Void in
            if error != nil {
                Debug.printl("Error: \(error)", sender: self)
                return
            } else {
                // Check status codes
                if statusCode == HTTP_ERROR {
                    Debug.printl("Error: \(error)", sender: self)
                    return
                } else if statusCode == HTTP_WRONG_MEDIA {
                    return
                } else if statusCode == HTTP_SUCCESS {
                    var error: NSError? = nil
                    var response: AnyObject? = NSJSONSerialization.JSONObjectWithData(data.dataUsingEncoding(NSUTF8StringEncoding)!, options: NSJSONReadingOptions.AllowFragments, error: &error)
                    dispatch_async(dispatch_get_main_queue()) {
                        self.finish(response as! NSDictionary)
                    }
                    Debug.printl("Data: \(data)", sender: self)
                    return
                } else {
                    Debug.printl("Unrecognized status code from server: \(statusCode)", sender: self)
                    return
                }
            }
        }
    }
    
    func finish(inputData: NSDictionary) {
        let controller = self.storyboard?.instantiateViewControllerWithIdentifier("MashResultsController") as! MashResultsController
        controller.recording = self.recording
        var tracks = inputData["recordings"] as! NSArray
        for t in tracks {
            var dict = t as! NSDictionary
            var instruments = dict["instrument"] as! NSArray
            var url = (dict["song_name"] as! String) + (dict["format"] as! String)
            var track = Track(frame: CGRectZero, instruments: [instruments[0] as! String], titleText: dict["song_name"] as! String, bpm: 120, trackURL: url, user: dict["username"] as! String, format: dict["format"] as! String)
            controller.results.append(track)
        }
        var index = 0
        for i in 0...self.navigationController!.viewControllers.count {
            if self.navigationController!.viewControllers[i] as? MashViewController != nil {
                index = i
                break
            }
        }
        self.navigationController?.pushViewController(controller, animated: true)
        self.navigationController!.viewControllers.removeAtIndex(index)
    }
    
    func cancel(sender: AnyObject?) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    // For when the stupid instr search is down
    func cheat() {
        let controller = self.storyboard?.instantiateViewControllerWithIdentifier("MashResultsController") as! MashResultsController
        
        controller.recording = self.recording
        var index = 0
        for i in 0...self.navigationController!.viewControllers.count {
            if self.navigationController!.viewControllers[i] as? MashViewController != nil {
                index = i
                break
            }
        }
        self.navigationController?.pushViewController(controller, animated: true)
        self.navigationController?.viewControllers.removeAtIndex(index)
    }
    
}

