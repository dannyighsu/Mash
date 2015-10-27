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
    
    @IBOutlet weak var instrumentsCollection: UICollectionView!
    var recordings: [Track] = []
    var bpm: Int? = nil
    var instruments: [String] = []
    var activityView: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
    var cellWidth: CGFloat = 75.0
    
    // Testing
    // var audioPlayer: AVAudioPlayer? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.instrumentsCollection.delegate = self
        self.instrumentsCollection.dataSource = self
        let cell = UINib(nibName: "InstrumentCell", bundle: nil)
        self.instrumentsCollection.registerNib(cell, forCellWithReuseIdentifier: "InstrumentCell")
        self.instrumentsCollection.backgroundColor = darkGray()
        
        self.activityView.center = self.view.center
        self.view.addSubview(self.activityView)
        self.cellWidth = UIScreen.mainScreen().bounds.size.width / 2 - 4.0
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "Mash an Instrument"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "done")
        self.navigationItem.setHidesBackButton(false, animated: false)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // Testing
        /*var superpowered = SuperpoweredModule()
        superpowered.timeShift(NSURL(fileURLWithPath: self.recordings[0].trackURL), newName: "test")
        
        self.audioPlayer = AVAudioPlayer(contentsOfURL: filePathURL("test.m4a"), error: nil)
        self.audioPlayer!.play()*/
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationItem.setHidesBackButton(true, animated: false)
        self.navigationItem.rightBarButtonItem = nil
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return instrumentArray.count
    }
    
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {

    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = self.instrumentsCollection.dequeueReusableCellWithReuseIdentifier("InstrumentCell", forIndexPath: indexPath) as! InstrumentCell
        /* let screenRect:CGRect = UIScreen.mainScreen().bounds
        let screenWidth:CGFloat = screenRect.size.width
        
        let index = CGFloat(indexPath.row % 3)
        
        cell.frame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y, screenWidth / 3, screenWidth / 3)*/
        let selection = UIImageView(frame: cell.frame)
        selection.layer.borderColor = lightGray().CGColor
        cell.selectedBackgroundView = selection
        cell.instrument = Array(instrumentArray.keys)[indexPath.row]
        cell.instrumentImage.image = findImage([cell.instrument])
        cell.backgroundColor = offWhite()
        cell.instrumentLabel.text = cell.instrument
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = self.instrumentsCollection.cellForItemAtIndexPath(indexPath) as! InstrumentCell
        if !self.instruments.contains(cell.instrument) {
            self.instruments.append(cell.instrument)
        }
        cell.layer.borderColor = lightGray().CGColor
        cell.layer.borderWidth = 5.0
    }
    
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! InstrumentCell
        for i in 0...self.instruments.count - 1 {
            if self.instruments[i] == cell.instrument {
                self.instruments.removeAtIndex(i)
                break
            }
        }
        cell.layer.borderWidth = 0.0
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: self.cellWidth, height: self.cellWidth)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 6.0
    }
    
    // Download mash files
    func done() {
        
        /*
        // Post data to server
        let handle = NSUserDefaults.standardUserDefaults().valueForKey("username") as! String
        let passwordHash = hashPassword(keychainWrapper.myObjectForKey("v_Data") as! String)
        var instrumentString = String(stringInterpolationSegment: instrument)
        instrumentString = instrumentString.substringWithRange(Range<String.Index>(start: instrumentString.startIndex.advancedBy(1), end: instrumentString.endIndex.advancedBy(-1)))
        
        let request = NSMutableURLRequest(URL: NSURL(string: "\(db)/mash")!)
        let params: [String: String] = ["handle": handle, "password_hash": passwordHash, "family": "{\(instrumentString)}"]
        self.activityView.startAnimating()
        httpPost(params, request: request) {
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
                } else if statusCode == HTTP_SUCCESS_WITH_MESSAGE {
                    var response: AnyObject?
                    do {
                        response = try NSJSONSerialization.JSONObjectWithData(data.dataUsingEncoding(NSUTF8StringEncoding)!, options: NSJSONReadingOptions.AllowFragments)
                    } catch _ as NSError {
                        response = nil
                    } catch {
                        fatalError()
                    }
                    dispatch_async(dispatch_get_main_queue()) {
                        self.finish(response as! NSDictionary)
                    }
                    return
                } else {
                    Debug.printl("Unrecognized status code from server: \(statusCode)", sender: self)
                    return
                }
            }
        }*/
    }
    
    func finish(inputData: NSDictionary) {
        let controller = self.storyboard?.instantiateViewControllerWithIdentifier("MashResultsController") as! MashResultsController
        controller.projectRecordings = self.recordings
        let tracks = inputData["recordings"] as! NSArray
        if tracks.count != 0 {
            for i in 0...tracks.count - 1 {
                let dict = tracks[i] as! NSDictionary
                let instruments = dict["instrument"] as! NSArray
                var instrument = ""
                if instruments.count != 0 {
                    instrument = instruments[0] as! String
                }
                let families = dict["family"] as! NSArray
                var family = ""
                if families.count != 0 {
                    family = families[0] as! String
                }
                
                let trackName = dict["song_name"] as! String
                let format = dict["format"] as! String
                let user = dict["handle"] as! String
                var url = "\(user)~~\(trackName)\(format)"
                url = filePathString(url)
                
                let track = Track(frame: CGRectZero, recid: 0, instruments: [instrument], instrumentFamilies: [family], titleText: trackName, bpm: dict["bpm"] as! Int, trackURL: url, user: user, format: format)
                
                controller.allResults.append(track)
                if i < DEFAULT_DISPLAY_AMOUNT {
                    controller.results.append(track)
                }
            }
        }
        
        self.activityView.stopAnimating()
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
        
        controller.projectRecordings = self.recordings
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

