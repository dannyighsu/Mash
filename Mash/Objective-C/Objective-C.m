//
//  Objective-C.m
//  Mash
//
//  Created by Danny Hsu on 7/15/15.
//  Copyright (c) 2015 Mash. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Objective-C.h"

@implementation Wrappers

+ (void)getWaveform:(EZAudioFile *)audioFile audioPlot:(EZAudioPlotGL *)audioPlot {
    [audioFile getWaveformDataWithCompletionBlock:^(float **waveformData, int length)
     {
         [audioPlot updateBuffer:waveformData[0]
                           withBufferSize:length];
     }];
}

@end
