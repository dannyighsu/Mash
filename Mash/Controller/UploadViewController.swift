//
//  UploadViewController.swift
//  Mash-iOS
//
//  Created by Danny Hsu on 3/31/15.
//  Copyright (c) 2015 Mash. All rights reserved.
//

import Foundation
import UIKit

class UploadViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIAlertViewDelegate {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var instrumentsCollection: UICollectionView!
    @IBOutlet weak var audioPlot: EZAudioPlot!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    var recording: EZAudioFile? = nil
    var bpm: Int? = nil
    var instruments: [String] = []
    var audioPlayer: AVAudioPlayer? = nil
    var timeSignature: String? = nil
    var activityView: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)

    override func viewDidLoad() {
        super.viewDidLoad()

        self.instrumentsCollection.delegate = self
        self.instrumentsCollection.dataSource = self
        let cell = UINib(nibName: "InstrumentCell", bundle: nil)
        self.instrumentsCollection.registerNib(cell, forCellWithReuseIdentifier: "InstrumentCell")
        self.instrumentsCollection.allowsMultipleSelection = true // uncheck for multi instr
        
        self.doneButton.addTarget(self, action: "checkInput:", forControlEvents: UIControlEvents.TouchDown)
        self.cancelButton.addTarget(self, action: "cancel:", forControlEvents: UIControlEvents.TouchDown)
        
        self.audioPlayer = AVAudioPlayer(contentsOfURL: recording!.url, error: nil)
        
        self.view.addSubview(self.activityView)
        self.activityView.center = self.view.center
        
        self.audioPlot.color = lightBlue()
        self.audioPlot.backgroundColor = offWhite()
        self.audioPlot.plotType = .Buffer
        self.audioPlot.shouldFill = true
        self.audioPlot.shouldMirror = true
        self.audioPlot.gain = 2.0
        var data = self.recording!.getWaveformData()
        self.audioPlot.updateBuffer(data.buffers[0], withBufferSize: data.bufferSize)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "Name Your Track"
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    // Collection View Delegate
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return instrumentArray.count
    }

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = self.instrumentsCollection.cellForItemAtIndexPath(indexPath) as! InstrumentCell
        if contains(self.instruments, cell.instrument) {
            return
        }
        self.instruments.append(cell.instrument)
        cell.layer.borderColor = darkGray().CGColor
        cell.backgroundColor = lightGray()
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
    
    // Pre-Upload Checks
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
        
        let handle = NSUserDefaults.standardUserDefaults().valueForKey("username") as! String
        let passwordHash = hashPassword(keychainWrapper.myObjectForKey("v_Data") as! String)
        
        checkForDuplicate(handle, passwordHash: passwordHash)
    }
    
    func checkForDuplicate(handle: String, passwordHash: String) {
        var request = NSMutableURLRequest(URL: NSURL(string: "\(db)/retrieve/recording")!)
        var params: [String: String] = ["handle": handle, "password_hash": passwordHash, "query_name": handle, "song_name": self.titleTextField.text]
        self.activityView.startAnimating()
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
                    self.activityView.stopAnimating()
                    let alert = UIAlertView(title: "Track exists.", message: "Please choose a different title.", delegate: self, cancelButtonTitle: "Ok")
                    alert.show()
                }
            }
        }
    }
    
    // Upload Methods
    func uploadAction() {
        var familyString = String(stringInterpolationSegment: self.instruments)
        var request = RecordingUploadRequest()
        request.userid = UInt32(currentUser.userid!)
        request.loginToken = currentUser.loginToken
        request.title = "\(self.titleTextField.text)"
        request.bpm = 0
        request.bar = 0
        request.key = "None"
        request.familyArray = [familyString]
        request.instrumentArray = []
        request.genreArray = []
        request.subgenreArray = []
        request.feel = 0
        request.solo = true
        request.format = ".m4a"
        
        serverClient.recordingUploadWithRequest(request) {
            (response, error) in
            if error != nil {
                Debug.printl("Error: \(error)", sender: nil)
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    self.activityView.stopAnimating()
                    let key = "\(currentUser.handle!)~~\(self.titleTextField).m4a"
                    upload(key, self.recording!.url, track_bucket)
                    self.finish()
                }
            }
        }
        
        /*
        let handle = NSUserDefaults.standardUserDefaults().valueForKey("username") as! String
        let passwordHash = hashPassword(keychainWrapper.myObjectForKey("v_Data") as! String)
        var request = NSMutableURLRequest(URL: NSURL(string: "\(db)/upload")!)
        var instrumentString = String(stringInterpolationSegment: self.instruments)
        instrumentString = instrumentString.substringWithRange(Range<String.Index>(start: advance(instrumentString.startIndex, 1), end: advance(instrumentString.endIndex, -1)))
        var params: [String: String] = ["handle": handle, "password_hash": passwordHash, "title": self.titleTextField.text, "bpm": "0", "bar": "0", "key": "0", "family": "{\(instrumentString)}", "instrument": "{}", "genre": "{}", "subgenre": "{}", "feel": "0", "solo": "0", "format": ".m4a"]
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
                        self.activityView.stopAnimating()
                        let key = "\(currentUser.handle!)~~\(self.titleTextField.text).m4a"
                        upload(key, self.recording!.url, track_bucket)
                        self.finish()
                    }
                    Debug.printl("Data: \(data)", sender: self)
                    return
                } else {
                    Debug.printl("Unrecognized status code from server: \(statusCode)", sender: self)
                    return
                }
            }
        }*/
    }
    
    func saveWaveform(track: Track) {
        track.titleText = self.titleTextField.text
        var waveform = takeShotOfView(self.audioPlot)
        UIImageJPEGRepresentation(waveform, 1.0).writeToFile(filePathString(getS3WaveformKey(track)), atomically: true)
        upload(getS3WaveformKey(track), filePathURL(getS3WaveformKey(track)), waveform_bucket)
    }
    
    func finish() {
        let taggingController = self.storyboard?.instantiateViewControllerWithIdentifier("TaggingViewController") as! TaggingViewController
        taggingController.track = Track(frame: CGRectZero, instruments: [], instrumentFamilies: self.instruments, titleText: self.titleTextField.text, bpm: self.bpm!, trackURL: "\(currentUser.handle!)~~\(self.titleTextField.text!).m4a", user: NSUserDefaults.standardUserDefaults().valueForKey("username") as! String, format: ".m4a")
        self.saveWaveform(taggingController.track!)
        
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
    
    func cancel(sender: AnyObject?) {
        self.navigationController?.popViewControllerAnimated(true)
    }

}
