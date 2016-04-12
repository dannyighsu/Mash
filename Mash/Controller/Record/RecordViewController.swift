//
//  RecordViewController.swift
//  Mash
//
//  Created by Danny Hsu on 7/13/15.
//  Copyright (c) 2015 Mash. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class RecordViewController: UIViewController, EZMicrophoneDelegate, EZAudioPlayerDelegate, EZAudioFileDelegate, EZOutputDelegate, MetronomeDelegate, CustomIOSAlertViewDelegate, UIAlertViewDelegate {
    
    @IBOutlet weak var audioPlot: EZAudioPlotGL!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var audioPlotBar: UIView!
    @IBOutlet weak var volumeButton: UIButton!
    @IBOutlet weak var tempoButton: UIButton!
    @IBOutlet weak var timeButton: UIButton!
    @IBOutlet weak var metronomeButton: UIButton!
    @IBOutlet weak var lowerContentView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!

    var microphone: EZMicrophone? = nil
    var player: EZAudioPlayer? = nil
    var audioFile: EZAudioFile? = nil
    var recorder: EZRecorder? = nil
    var recording: Bool = false
    var recordingStartTime: NSDate = NSDate()
    var metronome: Metronome? = nil
    var beat: Int = 5
    var totalBeats: Int = 0
    var beatLabel: UILabel? = nil
    var countoffView: UIView? = nil
    var tempoAlert: UIAlertView? = nil
    var timeAlert: UIAlertView? = nil
    var muted: Bool = false
    var activityView: ActivityView = ActivityView.createView()
    var coverView: UIView = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.coverView = UIView(frame: CGRect(x: self.view.frame.minX, y: self.view.frame.minY, width: self.view.frame.size.width, height: self.view.frame.size.height))
        self.coverView.backgroundColor = UIColor.clearColor()
        self.activityView.setText("Logging In...")
        self.activityView.center = CGPoint(x: self.coverView.center.x, y: self.coverView.center.y - 30.0)
        self.coverView.addSubview(self.activityView)
        self.tabBarController!.view.addSubview(self.coverView)
        self.activityView.startAnimating()
        
        // Set up metronome
        let metronome = Metronome.createView()
        metronome.delegate = self
        metronome.backgroundColor = lightGray()
        self.metronome = metronome

        // Configure EZAudio
        self.audioPlot.backgroundColor = darkBlueTranslucent()
        self.audioPlot.color = lightBlue()
        self.drawBufferPlot()
        
        self.microphone = EZMicrophone(delegate: self)
        self.microphone?.startFetchingAudio()
        
        // Button targets
        self.playButton.addTarget(self, action: #selector(RecordViewController.play(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.recordButton.addTarget(self, action: #selector(RecordViewController.record(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.volumeButton.addTarget(self, action: #selector(RecordViewController.showVolume(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.timeButton.addTarget(self, action: #selector(RecordViewController.showTime(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.tempoButton.addTarget(self, action: #selector(RecordViewController.showTempo(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.metronomeButton.addTarget(self, action: #selector(RecordViewController.muteMetronome(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        // Request server address synchronously
        self.requestServerAddress()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        let value = UIInterfaceOrientation.Portrait.rawValue
        UIDevice.currentDevice().setValue(value, forKey: "orientation")
        
        // Set up nav buttons
        self.parentViewController?.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(RecordViewController.save(_:)))
        self.parentViewController?.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Clear", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(RecordViewController.clear(_:)))
        self.navigationController?.navigationBar.tintColor = UIColor.blackColor()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.parentViewController?.navigationItem.title = "Record"
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.stopAll()
        self.parentViewController?.navigationItem.rightBarButtonItem = nil
        self.parentViewController?.navigationItem.leftBarButtonItem = nil
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    
    // Button methods
    func record(sender: AnyObject?) {
        // Load AVAudioSession
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
        } catch let error1 as NSError {
            Debug.printl("Error setting up session: \(error1.localizedDescription)", sender: self)
        }
        do {
            try session.setActive(true)
        } catch let error1 as NSError {
            Debug.printl("Error setting session active: \(error1.localizedDescription)", sender: self)
        }
        
        do {
            try session.overrideOutputAudioPort(AVAudioSessionPortOverride.Speaker)
        } catch let error1 as NSError {
            Debug.printl("\(error1.localizedDescription)", sender: self)
            raiseAlert("Error setting up audio.")
        }
        
        if !testing {
            Flurry.logEvent("User_Recording", withParameters: ["userid": currentUser.userid!])
        }
        if self.player != nil && self.player!.isPlaying {
            self.stop(nil)
        }
        if !self.recording {
            self.invalidateButtons()
            self.prepareRecording()
        } else {
            self.stopRecording()
            self.validateButtons()
            NSThread.sleepForTimeInterval(0.3)
            self.play(nil)
        }
    }
    
    func play(sender: AnyObject?) {
        if self.audioFile == nil {
            return
        }
        if self.player!.isPlaying {
            self.player!.pause()
            UIView.transitionWithView(self.playButton.imageView!, duration: 0.3, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: { self.playButton.setImage(UIImage(named: "Play_2"), forState: .Normal) }, completion: nil)
        } else if !self.player!.isPlaying {
            self.player!.play()
            UIView.transitionWithView(self.playButton.imageView!, duration: 0.3, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: { self.playButton.setImage(UIImage(named: "Pause_2"), forState: .Normal) }, completion: nil)
        }
    }
    
    func stop(sender: AnyObject?) {
        if self.player != nil {
            self.player!.seekToFrame(0)
            self.player!.pause()
            self.player!.currentTime = 0
            UIView.transitionWithView(self.playButton.imageView!, duration: 0.3, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: { self.playButton.setImage(UIImage(named: "Play_2"), forState: .Normal) }, completion: nil)
        }
    }
    
    func clear(sender: AnyObject?) {
        if self.player != nil && self.player!.isPlaying {
            self.player!.pause()
        }
        if self.recording {
            self.record(nil)
        }
        self.player = nil
        self.audioFile = nil
        self.recorder = nil
        self.microphone!.startFetchingAudio()
        self.drawBufferPlot()
        self.timeLabel.text = "00:00"
        self.totalBeats = 0
    }
    
    func save(sender: AnyObject?) {
        if self.player == nil || self.audioFile == nil {
            return
        }
        let controller = self.storyboard?.instantiateViewControllerWithIdentifier("UploadViewController") as! UploadViewController
        
        // Trim the file
        let outputString = filePathString("track_to_upload.m4a")
        let outputURL = NSURL(fileURLWithPath: outputString)
        if NSFileManager.defaultManager().fileExistsAtPath(outputString) {
            try! NSFileManager.defaultManager().removeItemAtPath(outputString)
        }
        let startTime = 0.0
        let endBeats = self.totalBeats - (self.totalBeats % self.metronome!.timeSignature[0])
        let endTime = (Double(endBeats) / self.metronome!.getTempo()) * 60.0
        
        AudioModule.trimAudio(self.audioFile!.url, outputFile: outputURL, startTime: startTime, endTime: endTime) {
            (result) in
            if !result {
                Debug.printl("Error trimming track.", sender: nil)
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    if !testing {
                        Flurry.logEvent("Recording_Save", withParameters: ["userid": currentUser.userid!, "duration": self.audioFile!.duration])
                    }
                    controller.recording = EZAudioFile(URL: outputURL)
                    controller.bpm = Int(60.0 / Double(self.metronome!.duration))
                    controller.timeSignature = self.metronome!.timeSigField.text
                    self.navigationController?.pushViewController(controller, animated: true)
                }
            }
        }
    }
    
    // Slider methods
    func volumeDidChange(sender: UISlider) {
        if self.metronome != nil {
            self.metronome!.tickPlayer!.volume = sender.value
            self.metronome!.tockPlayer!.volume = sender.value
        }
    }
    
    // Auxiliary methods
    func prepareRecording() {
        let view = UIView(frame: self.view.frame)
        view.backgroundColor = UIColor(red: 40, green: 40, blue: 40, alpha: 0.6)
        view.alpha = 0.0
        
        self.beat = self.metronome!.timeSignature[0] + 1
        let beatLabel = UILabel(frame: view.frame)
        beatLabel.font = UIFont(name: "STHeitiSC-Light", size: 100)
        beatLabel.textColor = UIColor.blackColor()
        beatLabel.text = "\(self.beat)"
        beatLabel.textAlignment = NSTextAlignment.Center
        
        self.beatLabel = beatLabel
        view.addSubview(beatLabel)
        beatLabel.center = view.center
        self.countoffView = view
        self.view.addSubview(view)
        self.metronome!.toggle(nil)
        
        UIView.animateWithDuration(0.3, animations: { view.alpha = 1.0 })
    }
    
    func stopAll() {
        if self.player != nil && self.player!.isPlaying {
            self.stop(nil)
        }
        if self.recording {
            self.record(nil)
        }
    }
    
    func stopRecording() {
        self.metronome?.toggle(nil)
        self.microphone?.stopFetchingAudio()
        self.recorder?.closeAudioFile()
        self.openAudio()
        self.recording = false
        UIView.transitionWithView(self.recordButton.imageView!, duration: 0.5, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: { self.recordButton.setImage(UIImage(named: "Record_button"), forState: .Normal) }, completion: nil)
    }
    
    func drawRollingPlot() {
        self.audioPlot.clear()
        self.audioPlotBar.hidden = false
        self.audioPlot.plotType = EZPlotType.Rolling
        self.audioPlot.shouldFill = true
        self.audioPlot.shouldMirror = true
        self.audioPlot.gain = 6.0
    }
    
    func drawBufferPlot() {
        self.audioPlot.clear()
        self.audioPlotBar.hidden = true
        self.audioPlot.plotType = EZPlotType.Buffer
        self.audioPlot.shouldFill = false
        self.audioPlot.shouldMirror = false
        self.audioPlot.gain = 1.0
    }
    
    func openAudio() {
        self.audioFile = EZAudioFile(URL: filePathURL(nil), delegate: self)
        self.player = EZAudioPlayer(audioFile: self.audioFile)
        self.player!.delegate = self
        let data = self.audioFile!.getWaveformData()
        self.audioPlot.updateBuffer(data.buffers[0], withBufferSize: data.bufferSize)
    }
    
    func invalidateButtons() {
        self.playButton.userInteractionEnabled = false
    }
    
    func validateButtons() {
        self.playButton.userInteractionEnabled = true
    }
    
    // Custom alert view delegate
    func customIOS7dialogButtonTouchUpInside(alertView: AnyObject!, clickedButtonAtIndex buttonIndex: Int) {
        self.metronome!.toggle(MetronomeManualTrigger())
        alertView.close()
    }
    
    func alertView(alertView: UIAlertView, didDismissWithButtonIndex buttonIndex: Int) {
        if alertView.title == "Set Time Signature" {
            self.metronome!.textFieldDidEndEditing(alertView.textFieldAtIndex(0)!)
            self.timeButton.setTitle(alertView.textFieldAtIndex(0)!.text, forState: .Normal)
        } else if alertView.title == "Set Tempo" {
            self.metronome!.textFieldDidEndEditing(alertView.textFieldAtIndex(0)!)
            self.tempoButton.setTitle(alertView.textFieldAtIndex(0)!.text, forState: .Normal)
        } else if alertView.title == "Version is oudated. Please update." {
            exit(0)
        }
    }
    
    func showVolume(sender: UIButton) {
        self.stopAll()
        
        let slider = ExtUISlider(frame: CGRectZero)
        slider.addTarget(self, action: #selector(RecordViewController.volumeDidChange(_:)), forControlEvents: UIControlEvents.ValueChanged)
        slider.value = self.metronome!.tickPlayer!.volume
        
        let title = UILabel(frame: CGRectZero)
        title.text = "Set Volume"
        title.textAlignment = NSTextAlignment.Center
        
        let metronomeView = CustomIOSAlertView(frame: CGRectZero)
        metronomeView.buttonTitles = ["Close"]
        metronomeView.addSubview(title)
        metronomeView.addSubview(slider)
        metronomeView.delegate = self
        metronomeView.show()

        title.frame = CGRect(x: 0.0, y: 0.0, width: 100.0, height: 30.0)
        title.center = CGPoint(x: metronomeView.center.x, y: metronomeView.center.y - 40.0)
        slider.frame = CGRect(x: metronomeView.frame.midX, y: metronomeView.frame.midY, width: metronomeView.frame.width/1.5, height: 3.0)
        slider.center = metronomeView.center
        slider.tintColor = lightBlue()
        metronomeView.bringSubviewToFront(title)
        metronomeView.bringSubviewToFront(slider)
        self.metronome!.toggle(MetronomeManualTrigger())
    }
    
    func showTime(sender: UIButton) {
        self.stopAll()
        
        if self.timeAlert == nil {
            let alert = UIAlertView(title: "Set Time Signature", message: "", delegate: self, cancelButtonTitle: "OK")
            alert.alertViewStyle = .PlainTextInput
            alert.textFieldAtIndex(0)?.textAlignment = .Center
            alert.textFieldAtIndex(0)?.text = self.timeButton.titleLabel?.text
            self.metronome!.externalTimeSigFieldEdit(alert.textFieldAtIndex(0)!)
            for i in 0...timeSignatureArray.count-1 {
                if timeSignatureArray[i] == self.timeButton.titleLabel!.text! {
                    self.metronome!.picker!.selectRow(i, inComponent: 0, animated: true)
                }
            }
            self.timeAlert = alert
            alert.show()
        } else {
            self.timeAlert!.show()
        }
    }
    
    func showTempo(sender: UIButton) {
        self.stopAll()
        
        if self.tempoAlert == nil {
            let alert = UIAlertView(title: "Set Tempo", message: "", delegate: self, cancelButtonTitle: "OK")
            alert.alertViewStyle = .PlainTextInput
            alert.textFieldAtIndex(0)?.textAlignment = .Center
            alert.textFieldAtIndex(0)?.text = self.tempoButton.titleLabel?.text
            alert.textFieldAtIndex(0)?.keyboardType = .NumberPad
            self.metronome!.externalTempoFieldEdit(alert.textFieldAtIndex(0)!)
            alert.show()
            self.tempoAlert = alert
        } else {
            self.tempoAlert!.show()
        }
    }
    
    // Microphone Delegate
    func microphone(microphone: EZMicrophone!, hasAudioReceived buffer: UnsafeMutablePointer<UnsafeMutablePointer<Float>>, withBufferSize bufferSize: UInt32, withNumberOfChannels numberOfChannels: UInt32) {
        dispatch_async(dispatch_get_main_queue()) {
            [weak self] in
            self?.audioPlot.updateBuffer(buffer[0], withBufferSize: bufferSize)
            if self != nil && self!.recording {
                let time = self!.recordingStartTime.timeIntervalSinceNow * -1
                var secondText = String(stringInterpolationSegment: Int(time))
                if time < 10.0 {
                    secondText = "0\(secondText)"
                }
                var milliText = String(stringInterpolationSegment: time % 1)
                milliText = milliText.substringWithRange(Range<String.Index>(milliText.startIndex.advancedBy(2) ..< milliText.startIndex.advancedBy(4)))
                self!.timeLabel.text = "\(secondText):\(milliText)"
            }
        }
    }
    
    func microphone(microphone: EZMicrophone!, hasBufferList bufferList: UnsafeMutablePointer<AudioBufferList>, withBufferSize bufferSize: UInt32, withNumberOfChannels numberOfChannels: UInt32) {
        dispatch_async(dispatch_get_main_queue()) {
            [weak self] in
            if self == nil {
                return
            }
            if self!.recording {
                self?.recorder?.appendDataFromBufferList(bufferList, withBufferSize: bufferSize)
            }
        }
    }
    
    // EZAudioPlayer Delegate
    func audioPlayer(audioPlayer: EZAudioPlayer!, updatedPosition framePosition: Int64, inAudioFile audioFile: EZAudioFile!) {
        dispatch_async(dispatch_get_main_queue()) {
            let time = audioPlayer.currentTime
            if time == 0 {
                self.timeLabel.text = "00:00"
                if self.audioFile != nil {
                    //self.play(nil)
                    self.playButton.setImage(UIImage(named: "Play_2"), forState: .Normal)
                }
                return
            }
            var secondText = String(stringInterpolationSegment: Int(time))
            if time < 10.0 {
                secondText = "0\(secondText)"
            }
            var milliText = String(stringInterpolationSegment: time % 1)
            milliText = milliText.substringWithRange(Range<String.Index>(milliText.startIndex.advancedBy(2) ..< milliText.startIndex.advancedBy(4)))
            self.timeLabel.text = "\(secondText):\(milliText)"
        }
    }
    
    // EZAudioFile Delegate
    func audioFile(audioFile: EZAudioFile!, readAudio buffer: UnsafeMutablePointer<UnsafeMutablePointer<Float>>, withBufferSize bufferSize: UInt32, withNumberOfChannels numberOfChannels: UInt32) {
        dispatch_async(dispatch_get_main_queue()) {
            [weak self] in
            self?.audioPlot.updateBuffer(buffer[0], withBufferSize: bufferSize)
        }
    }
    
    // Metronome Delegate
    func tick(metronome: Metronome) {
        self.totalBeats += 1
        if self.beat > 1 {
            self.beat -= 1
            if self.beatLabel != nil {
                self.beatLabel!.text = "\(self.beat)"
            }
        } else if self.beat == 1 {
            // Start recording
            self.drawRollingPlot()
            self.recorder = EZRecorder(URL: filePathURL(nil), clientFormat: self.microphone!.audioStreamBasicDescription(), fileType: EZRecorderFileType.M4A)
            self.microphone?.startFetchingAudio()
            self.recordingStartTime = NSDate()
            self.recording = true
            self.totalBeats = 0
            self.beat = 0
            UIView.transitionWithView(self.recordButton.imageView!, duration: 0.5, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: { self.recordButton.setImage(UIImage(named: "Record_stop"), forState: .Normal) }, completion: nil)
            UIView.animateWithDuration(0.3, animations: { self.countoffView!.alpha = 0.0 }) {
                (completed: Bool) in
                self.countoffView?.removeFromSuperview()
            }
        }
    }
    
    func muteMetronome(sender: UIButton) {
        self.metronome!.muteAudio(nil)
        if self.muted {
            sender.setImage(UIImage(named: "metronome_2"), forState: .Normal)
            self.muted = false
        } else {
            sender.setImage(UIImage(named: "metronome_gray"), forState: .Normal)
            self.muted = true
        }
    }
    
    // Login methods
    // Retrieve server IP
    func requestServerAddress() {
        if localServer {
            hostAddress = "http://localhost:5010"
            server = MashService(host: hostAddress)
            Debug.printl("Using local IP", sender: nil)
            self.checkVersion()
        } else {
            let request = ServerAddressRequest()
            let rand = arc4random()
            request.userid = rand
            let serverRequestGroup = dispatch_group_create()
            dispatch_group_enter(serverRequestGroup)
            loadBalancer.getServerAddressWithRequest(request) {
                (response, error) in
                dispatch_group_leave(serverRequestGroup)
                if error != nil {
                    Debug.printl("Error retrieving IP address: \(error)", sender: nil)
                    dispatch_async(dispatch_get_main_queue()) {
                        raiseAlert("An unknown error occured.")
                    }
                } else {
                    hostAddress = "http://\(response.ipAddress):5010"
                    server = MashService(host: hostAddress)
                    Debug.printl("Received IP address \(hostAddress) from load balancer.", sender: nil)
                }
            }
            dispatch_group_notify(serverRequestGroup, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
                dispatch_async(dispatch_get_main_queue()) {
                    self.checkVersion()
                }
            }
        }
    }
    
    // Check version
    func checkVersion() {
        // Check if version is supported
        let version = NSBundle.mainBundle().infoDictionary?["CFBundleShortVersionString"] as! String
        let request = VersionRequest()
        request.version = version
        
        server.versionWithRequest(request) {
            (response, error) in
            if error != nil {
                Debug.printl("Error: \(error)", sender: nil)
            } else {
                if response.outdated {
                    raiseAlert("Version is oudated. Please update.", delegate: self)
                } else {
                    self.checkLogin()
                }
            }
        }
    }
    
    // Check for login key
    func checkLogin() {
        let hasLoginKey = NSUserDefaults.standardUserDefaults().boolForKey("hasLoginKey")
        if hasLoginKey == true {
            let handle = NSUserDefaults.standardUserDefaults().valueForKey("username") as! String
            let password = keychainWrapper.myObjectForKey("v_Data") as! String
            Debug.printl("Attempting to log in with username \(handle) and password \(password)", sender: self)
            self.authenticate(handle, password: password)
        } else {
            self.navigationController?.popToRootViewControllerAnimated(false)
        }
    }
    
    func authenticate(handle: String, password: String) {
        let passwordHash = hashPassword(password)
        let request = SignInRequest()
        request.passwordHash = passwordHash
        // Check for username/email
        var regex: NSRegularExpression?
        do {
            regex = try NSRegularExpression(pattern: ".*@.*", options: [])
        } catch _ as NSError {
            regex = nil
        }
        let matches = regex?.numberOfMatchesInString(handle, options: [], range: NSMakeRange(0, handle.characters.count))
        
        if matches > 0 {
            request.email = handle
        } else {
            request.handle = handle
        }

        server.signInWithRequest(request) {
            (response, error) in
            if error != nil {
                Debug.printl("Error: \(error)", sender: nil)
                self.navigationController?.popToRootViewControllerAnimated(true)
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    self.activityView.stopAnimating()
                    self.coverView.removeFromSuperview()
                    if !testing {
                        Flurry.setUserID("\(response.userid)")
                    }
                }
                Debug.printl("Logged in successfully.", sender: self)
                currentUser = User()
                currentUser.handle = response.handle
                currentUser.loginToken = response.loginToken
                currentUser.userid = Int(response.userid)
                currentUser.followers = "\(response.followersCount)"
                currentUser.following = "\(response.followingCount)"
                currentUser.tracks = "\(response.trackCount)"
                currentUser.userDescription = response.userDescription
                
                self.completeLogin(handle, password: password)
            }
        }
    }
    
    func completeLogin(handle: String, password: String) {
        let hasLoginKey = NSUserDefaults.standardUserDefaults().boolForKey("hasLoginKey")
        if !hasLoginKey {
            self.saveLoginItems(handle, password: password)
        } else {
            if (NSUserDefaults.standardUserDefaults().valueForKey("username") as? String != handle || keychainWrapper.myObjectForKey("v_Data") as? String != password) {
                Debug.printl("Updating saved username and password", sender: self)
                self.saveLoginItems(handle, password: password)
            }
        }
        User.getUsersFollowing()
        sendTokenRequest()
    }
    
    func saveLoginItems(handle: String, password: String) {
        Debug.printl("Saving user " + handle + " to NSUserDefaults.", sender: self)
        NSUserDefaults.standardUserDefaults().setValue(handle, forKey: "username")
        keychainWrapper.mySetObject(password, forKey: kSecValueData)
        keychainWrapper.writeToKeychain()
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: "hasLoginKey")
        NSUserDefaults.standardUserDefaults().synchronize()
    }

}
