//
//  AudioProcessor.swift
//  Mash
//
//  Created by Danny Hsu on 7/21/15.
//  Copyright (c) 2015 Mash. All rights reserved.
//

import Foundation
import UIKit

protocol AudioProcessorDelegate {
    func progressDisplayUpdate()
}

class AudioProcessor: UIViewController {
    
    var delegate: AudioProcessorDelegate? = nil
    //var superpowered: SuperpoweredModule = SuperpoweredModule()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func timeShift(url: NSURL) {
        
    }
    
}
