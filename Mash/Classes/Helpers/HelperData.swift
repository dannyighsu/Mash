//
//  Helper Data.swift
//  Mash-iOS
//
//  Created by Danny Hsu on 6/18/15.
//  Copyright (c) 2015 Mash. All rights reserved.
//

import Foundation
import UIKit

// Returns light blue
func lightBlue() -> UIColor {
    return UIColor(red: (70/255), green: (202/255), blue: (229/255), alpha: 1.0)
}

func lightBlueTranslucent() -> UIColor {
    return UIColor(red: (70/255), green: (202/255), blue: (229/255), alpha: 0.7)
}

// Returns light gray
func lightGray() -> UIColor {
    return UIColor(red: (154/255), green: (154/255), blue: (154/255), alpha: 1.0)
}

func lightGrayTranslucent() -> UIColor {
    return UIColor(red: (154/255), green: (154/255), blue: (154/255), alpha: 0.6)
}

// Returns lighter gray
func lighterGray() -> UIColor {
    return UIColor(red: (220/255), green: (220/255), blue: (220/255), alpha: 1.0)
}

// Returns dark gray (bluish)
func darkGray() -> UIColor {
    return UIColor(red: (20/255), green: (20/255), blue: (40/255), alpha: 1.0)
}

func darkBlueTranslucent() -> UIColor {
    return UIColor(red: (20/255), green: (20/255), blue: (40/255), alpha: 0.7)
}

// Returns dark gray
func darkGrayRegular() -> UIColor {
    return UIColor(red: (30/255), green: (30/255), blue: (30/255), alpha: 1.0)
}

// Returns off white
func offWhite() -> UIColor {
    return UIColor(red: (240/255), green: (240/255), blue: (240/255), alpha: 1.0)
}

// Returns purple
func purple() -> UIColor {
    return UIColor(red: (149/255), green: 0, blue: (254/255), alpha: 1.0)
}

// Designates all keys
var keysArray: [String] = [
    "C", "Cm", "C#", "C#m", "D", "Dm", "D#", "D#m", "E", "Em", "F", "Fm", "F#", "F#m", "G", "Gm", "G#", "G#m", "A", "Am", "A#", "A#m", "B", "Bm"
]

// HTTP RESPONSE CODES
let HTTP_SUCCESS = 204
let HTTP_SUCCESS_WITH_MESSAGE = 200
let HTTP_ERROR = 400
let HTTP_WRONG_MEDIA = 415
let HTTP_KEY_IN_USE = 460
let HTTP_AUTH_FAIL = 511
let HTTP_SERVER_ERROR = 500

// Designates instrument families that have corresponding UIImages
var instrumentArray: [String: [String]] = [
    "Vocals": ["", "Beatboxing", "Male", "Female"],
    "Keyboard": ["", "Piano", "Organ", "Electric Piano"],
    "Guitar": ["", "Acoustic Guitar", "Electric Guitar", "Bass Guitar"],
    "Brass": ["", "French Horn", "Trombone", "Trumpet", "Tuba"],
    "Woodwinds": ["", "Saxophone", "Flute", "Piccolo", "Oboe", "English Horn", "Bassoon", "Clarinet", "Harmonica", "Accordion"],
    "Percussion": ["", "Electronic", "Cajon", "Drum Kit", "Triangle", "Snare", "Bass Drum", "Bongo", "Tambourine", "Darbuka"],
    "Tuned_Percussion": ["", "Xylophone", "Vibraphone", "Marimba"],
    "Electronic": ["", "Synth Lead", "Synth Bass", "Synth Pad", "Synth Brass", "Gated Synth", "Other"],
    "Strings": ["", "Violin", "Voila", "Cello", "Ukulele", "Harp", "Sitar", "Banjo", "Lyre", "Upright Bass", "Mandolin"],
    "Other": ["", "Other"]
]

// Lists all genres
var genreArray: [String: [String]] = [
    "Blues": ["", "Blues Rock", "Acoustic Blues", "Classic Blues"],
    "Country": ["", "Bluegrass", "Country Folk", "Country Rock", "Cowboy"],
    "EDM/Electronic": ["", "House", "Trance", "Trap", "Electro", "Hard Style", "Ambient", "Dub Step", "Electronica", "Experimental"],
    "Hip-Hop/Rap": ["", "Rap"],
    "Jazz": ["", "Swing", "Bebop", "Big Band", "Contemporary Jazz", "Ragtime", "Slow Jazz", "Latin Jazz", "Bossa Nova"],
    "Rock": ["", "Alternative Rock", "Metal", "Punk Rock", "HardRock", "Psychedelic", "Southern Rock", "Indie Rock", "Acoustic Rock", "Folk Rock", "Experimental Rock"],
    "R&B/Soul": ["", "Contemporary R&B", "Disco", "Soul", "Funk", "Motown"],
    "Classical": ["", "Chamber Music", "Baroque", "Avant-Garde", "Orchestral", "Opera", "Modern"],
    "Pop": ["", "K-Pop", "Dance Pop", "Britpop", "Pop/Rock"],
    "World": ["", "Reggae", "African", "Indian", "Brazilian", "Arabic", "Mexican", "Latin"],
    "Other": ["", "Other"]
]

// Lists all time signatures
var timeSignatureArray: [String] = [
    "None", "2/4", "3/4", "4/4", "5/4", "3/8", "6/8", "7/8"
]
