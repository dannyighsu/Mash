//
//  Objective-C.h
//  Mash
//
//  Created by Danny Hsu on 7/15/15.
//  Copyright (c) 2015 Mash. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <EZAudio/EZAudio.h>

@interface Wrappers: NSObject

+ (void)getWaveform:(EZAudioFile*) audioFile audioPlot:(EZAudioPlotGL*) audioPlot;

@end