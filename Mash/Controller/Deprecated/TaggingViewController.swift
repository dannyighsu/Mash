//
//  TaggingViewController.swift
//  Mash-iOS
//
//  Created by Danny Hsu on 6/12/15.
//  Copyright (c) 2015 Mash. All rights reserved.
//

import Foundation
import UIKit

class TaggingViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var tempoField: UITextField!
    @IBOutlet weak var keyField: UITextField!
    @IBOutlet weak var genreField: UITextField!
    @IBOutlet weak var subgenreField: UITextField!
    @IBOutlet weak var instrumentField: UITextField!
    @IBOutlet weak var timeField: UITextField!
    @IBOutlet weak var doneButton: UIButton!
    var track: Track? = nil
    var bpm: String? = nil
    var time: String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let keyPicker = UIPickerView(frame: self.view.frame)
        keyPicker.delegate = self
        keyPicker.dataSource = self
        self.keyField.inputView = keyPicker
        let genrePicker = UIPickerView(frame: self.view.frame)
        genrePicker.delegate = self
        genrePicker.dataSource = self
        self.genreField.inputView = genrePicker
        let subgenrePicker = UIPickerView(frame: self.view.frame)
        subgenrePicker.delegate = self
        subgenrePicker.dataSource = self
        self.subgenreField.inputView = subgenrePicker
        let timePicker = UIPickerView(frame: self.view.frame)
        timePicker.delegate = self
        timePicker.dataSource = self
        self.timeField.inputView = timePicker
        let instrPicker = UIPickerView(frame: self.view.frame)
        instrPicker.delegate = self
        instrPicker.dataSource = self
        self.instrumentField.inputView = instrPicker
        self.tempoField.keyboardType = UIKeyboardType.NumberPad
        self.tempoField.delegate = self
        self.tempoField.becomeFirstResponder()
        self.doneButton.addTarget(self, action: #selector(TaggingViewController.finish(_:)), forControlEvents: UIControlEvents.TouchDown)
        self.tempoField.text = self.bpm
        self.timeField.text = self.time
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    func finish() {
        let tabBarController = self.navigationController?.viewControllers[1] as! UITabBarController
        let project = tabBarController.viewControllers![getTabBarController("project")] as! ProjectViewController
        
        project.data.append(self.track!)
        project.tracks?.reloadData()
        
        Debug.printl("Adding track with \(track?.instruments) named \(track?.titleText) to project view", sender: self)
        for _ in (1 ..< self.navigationController!.viewControllers.count).reverse() {
            self.navigationController?.popViewControllerAnimated(true)
        }
        tabBarController.selectedViewController = project
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if textField == self.tempoField {
            if Int(textField.text!) > 200 {
                textField.text = "200"
            } else if Int(textField.text!) < 40 {
                textField.text = "40"
            }
        }
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == self.keyField.inputView {
            return keysArray.count
        } else if pickerView == self.genreField.inputView {
            return genreArray.count
        } else if pickerView == self.subgenreField.inputView {
            let genre = self.genreField.text
            if genre!.characters.count > 0 {
                return genreArray[genre!]!.count
            }
            return 1
        } else if pickerView == self.instrumentField.inputView {
            let instrumentFamily = self.track!.instrumentFamilies[0] // Fix this for multi instr
            return instrumentArray[instrumentFamily]!.count
        } else {
            return timeSignatureArray.count
        }
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == self.keyField.inputView {
            return keysArray[row]
        } else if pickerView == self.genreField.inputView {
            return Array(genreArray.keys)[row]
        } else if pickerView == self.subgenreField.inputView {
            let genre = self.genreField.text
            if genre!.characters.count > 0 {
                var subgenres = genreArray[genre!]
                return subgenres![row]
            }
            return ""
        } else if pickerView == self.instrumentField.inputView {
            let instrumentFamily = self.track!.instrumentFamilies[0] // Fix this for multi instr
            return instrumentArray[instrumentFamily]![row]
        } else {
            return timeSignatureArray[row]
        }
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == self.keyField.inputView {
            self.keyField.text = keysArray[row]
        } else if pickerView == self.genreField.inputView {
            self.genreField.text = Array(genreArray.keys)[row]
        } else if pickerView == self.subgenreField.inputView {
            let genre = self.genreField.text
            if genre!.characters.count > 0 {
                var subgenres = genreArray[genre!]
                self.subgenreField.text = subgenres![row]
            } else {
                self.subgenreField.text = ""
            }
        } else if pickerView == self.instrumentField.inputView {
            let instrumentFamily = self.track!.instrumentFamilies[0] // Fix this for multi instr
            self.instrumentField.text = instrumentArray[instrumentFamily]![row]
        } else {
            self.timeField.text = timeSignatureArray[row]
        }
    }

    func finish(sender: AnyObject?) {
        let request = RecordingUpdateRequest()
        request.userid = UInt32(currentUser.userid!)
        request.loginToken = currentUser.loginToken
        request.recid = UInt32(self.track!.id)
        request.title = "\(self.track!.titleText)"
        request.instrumentArray = [self.instrumentField.text!]
        request.genreArray = [self.genreField.text!]
        request.subgenreArray = [self.subgenreField.text!]
        
        server.recordingUpdateWithRequest(request) {
            (response, error) in
            if error != nil {
                Debug.printl("Error: \(error)", sender: nil)
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    self.navigationController?.popViewControllerAnimated(true)
                    let tabbarcontroller = self.navigationController?.viewControllers[2] as! TabBarController
                    tabbarcontroller.selectedIndex = getTabBarController("dashboard")
                }
            }
        }
        
        /*
        let passwordHash = hashPassword(keychainWrapper.myObjectForKey("v_Data") as! String)
        let handle = currentUser.handle
        var request = NSMutableURLRequest(URL: NSURL(string: "\(db)/update/recording")!)
        var time = split(self.timeField.text!) {$0 == "/"}
        if count(time[1]) == 1 {
            time[1] = "0" + time[1]
        }
        var timeString = time[0] + time[1]
        var params = ["handle": handle!, "password_hash": passwordHash, "song_name": "\(self.track!.titleText)", "new_bar": timeString, "new_bpm": self.tempoField.text!, "new_key": self.keyField.text!, "new_instrument": "{\(self.instrumentField.text!)}", "new_genre": "{\(self.genreField.text!)}", "new_subgenre": "{\(self.subgenreField.text!)}"] as Dictionary
        httpPatch(params, request) {
            (data, statusCode, error) -> Void in
            if error != nil {
                Debug.printl("Error: \(error)", sender: self)
            } else {
                // Check status codes
                if statusCode == HTTP_ERROR {
                    Debug.printl("HTTP Error: \(error)", sender: self)
                } else if statusCode == HTTP_WRONG_MEDIA {
                    
                } else if statusCode == HTTP_SUCCESS_WITH_MESSAGE {
                    var error: NSError? = nil
                    var response: AnyObject? = NSJSONSerialization.JSONObjectWithData(data.dataUsingEncoding(NSUTF8StringEncoding)!, options: NSJSONReadingOptions.AllowFragments, error: &error)
                } else if statusCode == HTTP_SERVER_ERROR {
                    Debug.printl("Internal server error.", sender: self)
                } else {
                    Debug.printl("Unrecognized status code from server: \(statusCode)", sender: self)
                }
            }
        }
        self.navigationController?.popViewControllerAnimated(true)
        let tabbarcontroller = self.navigationController?.viewControllers[2] as! TabBarController
        tabbarcontroller.selectedIndex = getTabBarController("dashboard")
        */
    }
    
}
