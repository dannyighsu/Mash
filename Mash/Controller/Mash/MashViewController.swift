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
    var instrumentCellConfigurators: [InstrumentCellConfigurator] = []
    var instruments: [String] = []
    var activityView: ActivityView = ActivityView.make()
    var cellWidth: CGFloat = 75.0
    
    // Testing
    // var audioPlayer: AVAudioPlayer? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for instrument in Array(instrumentArray.keys) {
            self.instrumentCellConfigurators.append(InstrumentCellConfigurator(instrument: instrument))
        }
        
        self.instrumentsCollection.delegate = self
        self.instrumentsCollection.dataSource = self
        let cell = UINib(nibName: "InstrumentCell", bundle: nil)
        self.instrumentsCollection.registerNib(cell, forCellWithReuseIdentifier: "InstrumentCell")
        self.instrumentsCollection.backgroundColor = darkGray()
        
        self.activityView.center = self.view.center
        self.view.addSubview(self.activityView)
        self.activityView.titleLabel.text = "Mashing..."
        
        self.cellWidth = UIScreen.mainScreen().bounds.size.width / 2 - 4.0
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.Plain, target:nil, action:nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "Mash an Instrument"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Go", style: .Plain, target: self, action: "done")
        self.navigationItem.setHidesBackButton(false, animated: false)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationItem.setHidesBackButton(true, animated: false)
        self.navigationItem.rightBarButtonItem = nil
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.instrumentCellConfigurators.count
    }
    
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {

    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = self.instrumentsCollection.dequeueReusableCellWithReuseIdentifier("InstrumentCell", forIndexPath: indexPath)
        let configurator = self.instrumentCellConfigurators[indexPath.item]
        configurator.configure(cell, viewController: self)
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! InstrumentCell
        let configurator = self.instrumentCellConfigurators[indexPath.item]
        configurator.highlightCellSelection(cell, isSelected: true)
        
        if !self.instruments.contains(configurator.instrument) {
            self.instruments.append(configurator.instrument)
        }
    }
    
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! InstrumentCell
        let configurator = self.instrumentCellConfigurators[indexPath.item]
        configurator.highlightCellSelection(cell, isSelected: false)
        
        // @TODO: @andy: isn't there something you can call to remove a String from an Array?
        for i in 0...self.instruments.count - 1 {
            if self.instruments[i] == cell.instrument {
                self.instruments.removeAtIndex(i)
                break
            }
        }
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: self.cellWidth, height: self.cellWidth)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 6.0
    }
    
    // Download mash files
    func done() {
        let request = RecordingRequest()
        request.userid = UInt32(currentUser.userid!)
        request.loginToken = currentUser.loginToken
        request.family = self.instruments[0]
        request.recid = UInt32(self.recordings[0].id)
        self.activityView.startAnimating()
        server.recordingMashWithRequest(request) {
            (response, error) in
            if error != nil {
                Debug.printl("Error: \(error)", sender: self)
                raiseAlert("No results found.")
                dispatch_async(dispatch_get_main_queue()) {
                    self.activityView.stopAnimating()
                }
            } else {
                self.finish(response)
            }
        }
    }
    
    func finish(response: Recordings) {
        let controller = self.storyboard?.instantiateViewControllerWithIdentifier("MashResultsController") as! MashResultsController
        controller.projectRecordings = self.recordings
        if response.recordingArray.count != 0 {
            for i in 0...response.recordingArray.count - 1 {
                let rec = response.recordingArray[i] as! RecordingResponse
                let track = Track(frame: CGRectZero, recid: Int(rec.recid), userid: Int(rec.userid), instruments: rec.instrumentArray.copy() as! [String], instrumentFamilies: rec.familyArray.copy() as! [String], titleText: rec.title, bpm: Int(rec.bpm), trackURL: getS3Key(Int(rec.userid), recid: Int(rec.recid), format: rec.format), user: rec.handle, format: rec.format, time: rec.uploaded, playCount: Int(rec.playCount), likeCount: Int(rec.likeCount), mashCount: Int(rec.likeCount))
                let configurator = TrackCellConfigurator(track: track)
                if i < DEFAULT_DISPLAY_AMOUNT {
                    controller.resultConfigurators.append(configurator)
                }
                controller.allResultConfigurators.append(configurator)
            }
        } else {
            raiseAlert("No results found.")
            return
        }
        /*var index = 0
        for i in 0...self.navigationController!.viewControllers.count {
            if self.navigationController!.viewControllers[i] as? MashViewController != nil {
                index = i
                break
            }
        }
        self.navigationController!.viewControllers.removeAtIndex(index)*/
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func cancel(sender: AnyObject?) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
}

