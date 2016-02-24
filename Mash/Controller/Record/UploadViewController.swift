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
    var activityView: ActivityView = ActivityView.createView()
    var cellWidth: CGFloat = 75.0
    var currFamilySelection: String = ""
    var titleText: String? = nil
    var recid: Int? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        self.instrumentsCollection.delegate = self
        self.instrumentsCollection.dataSource = self
        self.instrumentsCollection.backgroundColor = UIColor.whiteColor()
        self.instrumentsCollection.allowsMultipleSelection = true // check for multi instr
        self.instrumentsCollection.collectionViewLayout = CollectionViewLayout()
        let cell = UINib(nibName: "InstrumentCell", bundle: nil)
        self.instrumentsCollection.registerNib(cell, forCellWithReuseIdentifier: "InstrumentCell")
        
        self.doneButton.addTarget(self, action: "checkInput:", forControlEvents: UIControlEvents.TouchDown)
        self.cancelButton.addTarget(self, action: "cancel:", forControlEvents: UIControlEvents.TouchDown)
        
        self.audioPlayer = try? AVAudioPlayer(contentsOfURL: recording!.url)
        
        self.activityView.setText("Uploading...")
        self.view.addSubview(self.activityView)
        self.activityView.center = self.view.center
        
        self.audioPlot.color = lightBlue()
        self.audioPlot.backgroundColor = UIColor.clearColor()
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
        self.navigationItem.title = "Tag Your Track"
        if self.titleText != nil {
            self.titleTextField.text = self.titleText
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if self.instruments.count > 0 {
            let instrumentsToAdd = self.instruments
            self.instruments = []
            for instrument in instrumentsToAdd {
                let indexPath = NSIndexPath(forRow: findInstrument(instrument), inSection: 0)
                self.instrumentsCollection.selectItemAtIndexPath(indexPath, animated: false, scrollPosition: .Bottom)
                self.collectionView(self.instrumentsCollection, didSelectItemAtIndexPath: indexPath)
            }
        }
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
    
    // Alert View Delegate
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if alertView.title == "Success!" {
            if buttonIndex == 0 {
                self.finish()
            } else {
                self.mashFinish()
            }
        }
    }
    
    // Pre-Upload Checks
    func checkInput(sender: AnyObject?) {
        let title = self.titleTextField.text
        // Check if title exists, if not, send alert.
        if title!.isEmpty {
            let alert = UIAlertView(title: "Invalid Title", message: "Please Name Your Track", delegate: self, cancelButtonTitle: "OK")
            alert.show()
            return
        }
        if self.instruments.count == 0 {
            let alert = UIAlertView(title: "Invalid Tag", message: "Please select an instrument", delegate: self, cancelButtonTitle: "Ok")
            alert.show()
            return
        }
        
        // Check for disallowed characters in title
        let regex = try! NSRegularExpression(pattern: ".*~~.*", options: [])
        let matches = regex.numberOfMatchesInString(title!, options: [], range: NSMakeRange(0, title!.characters.count))
        if matches > 0 {
            raiseAlert("Invalid characters in title.")
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
        request.bpm = UInt32(self.bpm!)
        request.bar = UInt32(timeSigStringToInt(self.timeSignature!))
        request.key = "X"
        request.familyArray = NSMutableArray(array: self.instruments)
        request.instrumentArray = []
        request.genreArray = []
        request.subgenreArray = []
        request.feel = 0
        request.solo = true
        request.format = ".m4a"
        
        self.activityView.startAnimating()
        
        server.recordingUploadWithRequest(request) {
            (response, error) in
            if error != nil {
                Debug.printl("Error: \(error)", sender: nil)
                if error.code == 13 {
                    raiseAlert("Track name exists already.")
                } else {
                    if !testing {
                        Flurry.logError("\(error.code)", message: "Unknown Error", error: error)
                        raiseAlert("There was an issue with your upload. Please try again.")
                    }
                }
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    self.activityView.stopAnimating()
                    let key = "\(currentUser.userid!)~~\(response.recid).m4a"
                    upload(key, url: self.recording!.url, bucket: track_bucket) {
                        (result) in
                        if result != nil {
                            dispatch_async(dispatch_get_main_queue()) {
                                self.recid = Int(response.recid)
                                if self.navigationController is RootNavigationController {
                                    let alert = UIAlertView(title: "Success!", message: "Would you like to mash your new sound?", delegate: self, cancelButtonTitle: "No", otherButtonTitles: "Yes")
                                    alert.show()
                                } else {
                                    self.finish()
                                }
                            }
                        } else {
                            self.deleteTrack(response.recid)
                            raiseAlert("There was an issue with your upload. Please try again.")
                        }
                    }
                }
            }
        }
    }
    
    func deleteTrack(recid: UInt32) {
        let request = RecordingRequest()
        request.recid = recid
        
        server.recordingDeleteWithRequest(request) {
            (response, error) in
            if error != nil {
                raiseAlert("There was a problem uploading your track.")
            } else {
                raiseAlert("An unknown error occurred.")
                if !testing {
                    Flurry.logError("\(error.code)", message: "Unknown error", error: error)
                }
            }
        }
    }
    
    func saveWaveform(track: Track) {
        track.titleText = self.titleTextField.text!
        UIGraphicsBeginImageContext(self.audioPlot.bounds.size)
        self.audioPlot.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        let imageData = UIImagePNGRepresentation(image)
        imageData!.writeToFile(filePathString(getS3WaveformKey(track)), atomically: true)
        upload(getS3WaveformKey(track), url: filePathURL(getS3WaveformKey(track)), bucket: waveform_bucket)
    }
    
    func finish() {
        if !testing {
            Flurry.logEvent("Recording_Upload", withParameters: ["userid": currentUser.userid!, "instrument": self.instruments])
        }
        
        let track = Track(frame: CGRectZero, recid: self.recid!, userid: currentUser.userid!, instruments: [], instrumentFamilies: self.instruments, titleText: self.titleTextField.text!, bpm: self.bpm!, timeSignature: timeSigStringToInt(self.timeSignature!), trackURL: "\(currentUser.userid!)~~\(recid).m4a", user: currentUser.handle!, format: ".m4a", time: "Just now", playCount: 0, likeCount: 0, mashCount: 0, liked: false)
        self.saveWaveform(track)
        
        self.navigationController?.popViewControllerAnimated(true)
        if self.navigationController is RootNavigationController {
            let tabbarcontroller = self.navigationController?.viewControllers[2] as! TabBarController
            tabbarcontroller.selectedIndex = getTabBarController("dashboard")
        }
    }
    
    func mashFinish() {
        if !testing {
            Flurry.logEvent("Recording_Upload", withParameters: ["userid": currentUser.userid!, "instrument": self.instruments])
        }
        
        let track = Track(frame: CGRectZero, recid: self.recid!, userid: currentUser.userid!, instruments: [], instrumentFamilies: self.instruments, titleText: self.titleTextField.text!, bpm: self.bpm!, timeSignature: timeSigStringToInt(self.timeSignature!), trackURL: "\(currentUser.userid!)~~\(recid).m4a", user: NSUserDefaults.standardUserDefaults().valueForKey("username") as! String, format: ".m4a", time: "Just now", playCount: 0, likeCount: 0, mashCount: 0, liked: false)
        self.saveWaveform(track)
        
        self.navigationController?.popViewControllerAnimated(false)
        if self.navigationController is RootNavigationController {
            ProjectViewController.importTracks([track], navigationController: self.navigationController, storyboard: self.storyboard)
        }
    }
    
    func cancel(sender: AnyObject?) {
        self.navigationController?.popViewControllerAnimated(true)
    }

}
