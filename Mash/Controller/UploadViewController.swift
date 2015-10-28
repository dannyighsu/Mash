//
//  UploadViewController.swift
//  Mash-iOS
//
//  Created by Danny Hsu on 3/31/15.
//  Copyright (c) 2015 Mash. All rights reserved.
//

import Foundation
import UIKit

class UploadViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIAlertViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var instrumentsCollection: UICollectionView!
    @IBOutlet weak var audioPlot: EZAudioPlot!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    var recording: EZAudioFile? = nil
    var bpm: Int? = nil
    var audioPlayer: AVAudioPlayer? = nil
    var timeSignature: String? = nil
    var instruments: [String] = []
    var activityView: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
    var cellWidth: CGFloat = 75.0
    var currFamilySelection: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        self.instrumentsCollection.delegate = self
        self.instrumentsCollection.dataSource = self
        self.instrumentsCollection.backgroundColor = darkGray()
        self.instrumentsCollection.allowsMultipleSelection = true // check for multi instr
        self.instrumentsCollection.collectionViewLayout = CollectionViewLayout()
        let cell = UINib(nibName: "InstrumentCell", bundle: nil)
        self.instrumentsCollection.registerNib(cell, forCellWithReuseIdentifier: "InstrumentCell")
        
        self.doneButton.addTarget(self, action: "checkInput:", forControlEvents: UIControlEvents.TouchDown)
        self.cancelButton.addTarget(self, action: "cancel:", forControlEvents: UIControlEvents.TouchDown)
        
        self.audioPlayer = try? AVAudioPlayer(contentsOfURL: recording!.url)
        
        self.view.addSubview(self.activityView)
        self.activityView.center = self.view.center
        
        self.audioPlot.color = lightBlue()
        self.audioPlot.backgroundColor = darkGray()
        self.audioPlot.plotType = .Buffer
        self.audioPlot.shouldFill = true
        self.audioPlot.shouldMirror = true
        self.audioPlot.gain = 2.0
        let data = self.recording!.getWaveformData()
        self.audioPlot.updateBuffer(data.buffers[0], withBufferSize: data.bufferSize)
        self.cellWidth = UIScreen.mainScreen().bounds.size.width / 2 - 4.0
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
        if collectionView == self.instrumentsCollection {
            return instrumentArray.count
        } else {
            return 0
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = self.instrumentsCollection.dequeueReusableCellWithReuseIdentifier("InstrumentCell", forIndexPath: indexPath) as! InstrumentCell
        if collectionView == self.instrumentsCollection {
            cell.instrument = Array(instrumentArray.keys)[indexPath.row]
            cell.instrumentImage.image = findImage([cell.instrument])
            cell.instrumentLabel.text = cell.instrument
            cell.backgroundColor = offWhite()
        }
        return cell
    }

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = self.instrumentsCollection.cellForItemAtIndexPath(indexPath) as! InstrumentCell
        self.instruments.append(cell.instrument)
        cell.layer.borderColor = lightGray().CGColor
        cell.layer.borderWidth = 5.0
    }
    
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = self.instrumentsCollection.cellForItemAtIndexPath(indexPath) as! InstrumentCell
        if collectionView == self.instrumentsCollection {
            if self.instruments.count != 0 {
                for i in 0...self.instruments.count - 1 {
                    if self.instruments[i] == cell.instrument {
                        self.instruments.removeAtIndex(i)
                        break
                    }
                }
            }
        }
        cell.layer.borderWidth = 0.0
    }
    
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: self.cellWidth, height: self.cellWidth)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 6.0
    }
    
    // Picker View Delegate
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return instrumentArray[self.currFamilySelection]!.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return instrumentArray[self.currFamilySelection]![row]
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // Pre-Upload Checks
    func checkInput(sender: AnyObject?) {
        // Check if title exists, if not, send alert.
        if self.titleTextField.text!.isEmpty {
            let alert = UIAlertView(title: "Invalid Title", message: "Please Name Your Track", delegate: self, cancelButtonTitle: "OK")
            alert.show()
            return
        }
        if self.instruments.count == 0 {
            let alert = UIAlertView(title: "Invalid Tag", message: "Please select an instrument", delegate: self, cancelButtonTitle: "Ok")
            alert.show()
            return
        }
        
        self.uploadAction()
    }
    
    // Upload Methods
    func uploadAction() {
        let request = RecordingUploadRequest()
        request.userid = UInt32(currentUser.userid!)
        request.loginToken = currentUser.loginToken
        request.title = "\(self.titleTextField.text!)"
        request.bpm = 0
        request.bar = 0
        request.key = "X"
        request.familyArray = NSMutableArray(array: self.instruments)
        request.instrumentArray = []
        request.genreArray = []
        request.subgenreArray = []
        request.feel = 0
        request.solo = true
        request.format = ".m4a"
        
        server.recordingUploadWithRequest(request) {
            (response, error) in
            if error != nil {
                Debug.printl("Error: \(error)", sender: nil)
                raiseAlert("Track name exists already.")
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    self.activityView.stopAnimating()
                    let key = "\(currentUser.userid!)~~\(response.recid).m4a"
                    upload(key, url: self.recording!.url, bucket: track_bucket)
                    self.finish(Int(response.recid))
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
        track.titleText = self.titleTextField.text!
        let waveform = takeShotOfView(self.audioPlot)
        UIImageJPEGRepresentation(waveform, 1.0)!.writeToFile(filePathString(getS3WaveformKey(track)), atomically: true)
        upload(getS3WaveformKey(track), url: filePathURL(getS3WaveformKey(track)), bucket: waveform_bucket)
    }
    
    func finish(recid: Int) {
        let track = Track(frame: CGRectZero, recid: recid, userid: currentUser.userid!, instruments: [], instrumentFamilies: self.instruments, titleText: self.titleTextField.text!, bpm: self.bpm!, trackURL: "\(currentUser.userid!)~~\(recid).m4a", user: NSUserDefaults.standardUserDefaults().valueForKey("username") as! String, format: ".m4a")
        self.saveWaveform(track)
        
        self.navigationController?.popViewControllerAnimated(true)
        let tabbarcontroller = self.navigationController?.viewControllers[2] as! TabBarController
        tabbarcontroller.selectedIndex = getTabBarController("dashboard")
        

    }
    
    func cancel(sender: AnyObject?) {
        self.navigationController?.popViewControllerAnimated(true)
    }

}
