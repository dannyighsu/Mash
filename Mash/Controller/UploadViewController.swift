//
//  UploadViewController.swift
//  Mash-iOS
//
//  Created by Danny Hsu on 3/31/15.
//  Copyright (c) 2015 Mash. All rights reserved.
//

import Foundation
import UIKit
import EZAudio

class UploadViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIAlertViewDelegate {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var instrumentsCollection: UICollectionView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var doneButton: UIButton!
    var recording: EZAudioFile? = nil
    var bpm: Int? = nil
    var instruments: [String] = []
    var audioPlayer: AVAudioPlayer? = nil
    var timeSignature: String? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        self.instrumentsCollection.delegate = self
        self.instrumentsCollection.dataSource = self
        let cell = UINib(nibName: "InstrumentCell", bundle: nil)
        self.instrumentsCollection.registerNib(cell, forCellWithReuseIdentifier: "InstrumentCell")
        // self.instrumentsCollection.allowsMultipleSelection = true // uncheck for multi instr
        
        self.doneButton.addTarget(self, action: "checkInput:", forControlEvents: UIControlEvents.TouchDown)
        
        self.audioPlayer = AVAudioPlayer(contentsOfURL: recording!.url(), error: nil)
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return instrumentArray.count
    }

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = self.instrumentsCollection.cellForItemAtIndexPath(indexPath) as! InstrumentCell
        self.instruments.append(cell.instrument)
        cell.layer.borderColor = UIColor.whiteColor().CGColor
        cell.layer.borderWidth = 1.0
    }
    
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        let instr = cell as! InstrumentCell
        instr.instrument = Array(instrumentArray.keys)[indexPath.row]
        instr.instrumentImage.image = findImage([instr.instrument])
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = self.instrumentsCollection.dequeueReusableCellWithReuseIdentifier("InstrumentCell", forIndexPath: indexPath) as! InstrumentCell
        return cell
    }
    
    func checkInput(sender: AnyObject?) {
        // Check if title exists, if not, send alert.
        if self.titleTextField.text.isEmpty {
            let alert = UIAlertView(title: "Invalid Title", message: "Please Name Your Track", delegate: self, cancelButtonTitle: "OK")
            alert.show()
            return
        }
        if self.instruments.count == 0 {
            let alert = UIAlertView(title: "Invalid Tag", message: "Please select an instrument", delegate: self, cancelButtonTitle: "Ok")
            alert.show()
            return
        }
        
        let username = NSUserDefaults.standardUserDefaults().valueForKey("username") as! String
        let passwordHash = hashPassword(keychainWrapper.myObjectForKey("v_Data") as! String)
        
        checkForDuplicate(username, passwordHash: passwordHash)
    }
    
    // Upload file to bucket, then post information to server
    func uploadAction() {
        // Bucket upload
        var urlString = self.recording?.url()
        upload(self.titleTextField.text + ".m4a", urlString!, track_bucket)
        
        // Post data to server
        let username = NSUserDefaults.standardUserDefaults().valueForKey("username") as! String
        let passwordHash = hashPassword(keychainWrapper.myObjectForKey("v_Data") as! String)
        var request = NSMutableURLRequest(URL: NSURL(string: "\(db)/upload")!)
        var instrumentString = String(stringInterpolationSegment: self.instruments)
        instrumentString = instrumentString.substringWithRange(Range<String.Index>(start: advance(instrumentString.startIndex, 1), end: advance(instrumentString.endIndex, -1)))
        var params: [String: String] = ["username": username, "password_hash": passwordHash, "song_name": self.titleTextField.text, "bpm": "0", "bar": "0", "key": "0", "instrument": instrumentString, "family": "", "genre": "", "subgenre": "", "feel": "0", "effects": "", "theme": "", "solo": "0", "format": ".m4a"]
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
                    dispatch_async(dispatch_get_main_queue()) {
                        self.finish()
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
    
    func checkForDuplicate(username: String, passwordHash: String) {
        var request = NSMutableURLRequest(URL: NSURL(string: "\(db)/search/recording")!)
        var params: [String: String] = ["username": username, "password_hash": passwordHash, "query_name": username, "song_name": self.titleTextField.text]
        httpPost(params,request) {
            (data, statusCode, error) -> Void in
            var duplicate = false
            if error != nil {
                Debug.printl("Error: \(error)", sender: self)
            } else {
                if statusCode == HTTP_SUCCESS_WITH_MESSAGE {
                    if count(data) > 22 {
                        duplicate = true
                    }
                } else if statusCode == HTTP_SERVER_ERROR {
                    duplicate = true
                }
            }
            if !duplicate {
                self.uploadAction()
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    let alert = UIAlertView(title: "Track exists.", message: "Please choose a different title.", delegate: self, cancelButtonTitle: "Ok")
                    alert.show()
                }
            }
        }
    }
    
    func finish() {
        let taggingController = self.storyboard?.instantiateViewControllerWithIdentifier("TaggingViewController") as! TaggingViewController
        taggingController.track = Track(frame: CGRectZero, instruments: self.instruments, titleText: self.titleTextField.text, bpm: self.bpm!, trackURL: self.recording!.url().absoluteString! as String, user: NSUserDefaults.standardUserDefaults().valueForKey("username") as! String, format: ".m4a")
        taggingController.track?.instrumentFamilies += self.instruments
        var index = 0
        for i in 0...self.navigationController!.viewControllers.count {
            if self.navigationController!.viewControllers[i] as? UploadViewController != nil {
                index = i
                break
            }
        }
        
        self.navigationController?.pushViewController(taggingController, animated: true)
        self.navigationController!.viewControllers.removeAtIndex(index)
        taggingController.time = self.timeSignature!
        taggingController.bpm = String(self.bpm!)

    }

}
