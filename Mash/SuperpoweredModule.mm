//
//  C++-Bridging-Header.m
//  Mash
//
//  Created by Danny Hsu on 7/21/15.
//  Copyright (c) 2015 Mash. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Mash-Bridging-Header.h"
#include "SuperpoweredDecoder.h"
#include "SuperpoweredSimple.h"
#include "SuperpoweredRecorder.h"
#include "SuperpoweredTimeStretching.h"
#include "SuperpoweredAudioBuffers.h"

@implementation SuperpoweredModule {
    
    SuperpoweredDecoder *decoder;
    
}

-(id) init {
    self = [super init];
    return self;
}

-(void) superpoweredDecoder {
    decoder = new SuperpoweredDecoder();
}

@end
