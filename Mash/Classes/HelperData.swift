//
//  Helper Data.swift
//  Mash-iOS
//
//  Created by Danny Hsu on 6/18/15.
//  Copyright (c) 2015 Mash. All rights reserved.
//

import Foundation
import UIKit

// Helper objects
let db: String = "http://54.152.179.223:5010"
let hostAddress: String = "http://localhost:50051"
let serverClient: MashService = MashService(host: hostAddress)
var keychainWrapper: KeychainWrapper = KeychainWrapper()
var currentUser = User()
var userFollowing: [User] = []
let track_bucket: String = "mash1-tracks"
let profile_bucket: String = "mash-profiles"
let banner_bucket: String = "mash-banners"
let waveform_bucket: String = "mash-trackwaveforms"
let DEFAULT_DISPLAY_AMOUNT = 15

// Returns light blue
func lightBlue() -> UIColor {
    return UIColor(red: (70/255), green: (202/255), blue: (229/255), alpha: 1.0)
}

// Returns light gray
func lightGray() -> UIColor {
    return UIColor(red: (154/255), green: (154/255), blue: (154/255), alpha: 1.0)
}

// Returns dark gray
func darkGray() -> UIColor {
    return UIColor(red: (54/255), green: (54/255), blue: (54/255), alpha: 1.0)
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
    "Brass": ["", "French Horn", "Trombone", "Trumpet", "Tuba"],
    "Woodwinds": ["", "Saxophone", "Flute", "Piccolo", "Oboe", "English Horn", "Bassoon", "Clarinet", "Harmonia", "Accordians"],
    "Percussion": ["", "Electronic", "Cajon", "Drum Kit", "Triangle", "Xylophone", "Snare", "Bass Drum", "Vibraphone", "Marimba", "Bongo", "Tamborine", "Darbuka"],
    "Electronic": ["", "Turntables", "Sample", "Synth Lead", "Synth Bass", "Synth Pad", "Synthesizer"],
    "Strings": ["", "Violin", "Voila", "Cello", "Ukulele", "Harp", "Sitar", "Banjo", "Lyre", "Upright Bass", "Mandolin"],
    "Guitar": ["", "Acoustic Guitar", "Electric Guitar", "Bass Guitar"],
    "Keyboard": ["", "Synthesizer", "Piano", "Organ", "Electric Piano"],
    "Other": ["", "Other"]
]

// Lists all genres
var genreArray: [String: [String]] = [
    "Blues": ["", "Blues Rock", "Acoustic Blues", "Classic Blues"],
    "Country": ["", "Bluegrass", "Country Folk", "Country_Rock", "Cowboy"],
    "EDM/Electronic": ["", "House", "Trance", "Trap", "Electro", "Hard Style", "Ambient", "Dub Step", "Electronica", "Experimental"],
    "Hip-Hop/Rap": ["", "Rap"],
    "Jazz": ["", "Swing", "Bebop", "Big Band", "Contemporary Jazz", "Ragtime", "Slow Jazz", "Latin Jazz", "Bossa Nova"],
    "Rock": ["", "Alternative Rock", "Metal", "Punk Rock", "HardRock", "Psychedelic", "Southern Rock", "Indie Rock", "Acoustic Rock", "Folk Rock", "Experimental Rock"],
    "R&B/Soul": ["", "Contemporary R&B", "Disco", "Soul", "Funk", "Motown"],
    "Classical": ["", "Chamber Music", "Boroque", "Avant-Garde", "Orchestral", "Opera", "Modern"],
    "Pop": ["", "K-Pop", "Dance Pop", "Britpop", "Pop/Rock"],
    "World": ["", "Reggae", "African", "Indian", "Brazillin", "Arabic", "Mexican", "Latin"],
    "Other": ["", "Other"]
]

// Lists all time signatures
var timeSignatureArray: [String] = [
    "None", "2/4", "3/4", "4/4", "5/4", "3/8", "6/8", "7/8"
]
