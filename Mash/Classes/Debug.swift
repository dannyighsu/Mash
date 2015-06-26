//
//  Debug.swift
//  Mash-iOS
//
//  Created by Danny Hsu on 3/22/15.
//  Copyright (c) 2015 Mash. All rights reserved.
//

import Foundation

// CHANGE TO FALSE FOR RELEASE
let debug: Bool = true

class Debug {
    
    class func printnl(input: String) {
        if debug {
            print(input)
        }
    }
    
    class func printl(input: AnyObject?, sender: AnyObject?) {
        if !debug {
            return
        }
        if input == nil {
            println("nil")
        } else if sender == nil {
            println(input!)
        } else {
            var output = input as? String
            if output == nil {
                println(input)
            } else {
                println(output! as String + " sent from \(sender)")
            }
        }
    }
    
}
