//
//  SuperpoweredModule.mm
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

@implementation SuperpoweredAudioModule {
    SuperpoweredDecoder *decoder;
}

-(id) init {
    self = [super init];
    return self;
}

+(NSString *) timeShift:(NSURL *)url newName: (NSString*)newName amountToShift: (float)shiftAmount {
    SuperpoweredDecoder *decoder = new SuperpoweredDecoder();
    const char *error = decoder->open([[url path] UTF8String], false, 0, 0);
    if (error) {
        NSLog(@"Error opening file: %s", error);
        delete decoder;
        return @"";
    }
    // Instantiate variable-sized buffer chains, 1MB memory max
    SuperpoweredAudiobufferPool *bufferPool = new SuperpoweredAudiobufferPool(4, 1024 * 1024);
    SuperpoweredTimeStretching *timeStretcher = new SuperpoweredTimeStretching(bufferPool, decoder->samplerate);
    timeStretcher->setRateAndPitchShift(shiftAmount, 0);
    
    SuperpoweredAudiopointerList *output = new SuperpoweredAudiopointerList(bufferPool);
    short int *intBuffer = (short int*)malloc(decoder->samplesPerFrame * 2 * sizeof(short int) + 16384);
    
    NSString *outputFilePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.m4a", newName]];
    FILE *fd = createWAV(outputFilePath.fileSystemRepresentation, decoder->samplerate, 2);
    
    while (true) {
        unsigned int samplesDecoded = decoder->samplesPerFrame;
        if (decoder->decode(intBuffer, &samplesDecoded) == SUPERPOWEREDDECODER_ERROR) {
            break;
        }
        if (samplesDecoded < 1) {
            break;
        }
        
        // Create input buffer for time stretcher
        SuperpoweredAudiobufferlistElement inputBuffer;
        bufferPool->createSuperpoweredAudiobufferlistElement(&inputBuffer, decoder->samplePosition, samplesDecoded * 8);
        
        // Convert 16-bit ints to 32-bit floats
        SuperpoweredShortIntToFloat(intBuffer, bufferPool->floatAudio(&inputBuffer), samplesDecoded);
        inputBuffer.endSample = samplesDecoded;
        
        timeStretcher->process(&inputBuffer, output);
        
        // Check for output
        if (output->makeSlice(0, output->sampleLength)) {
            while (true) {
                float *outputAudio = NULL;
                int samples = 0;
                if (!output->nextSliceItem(&outputAudio, &samples)) {
                    break;
                }
                SuperpoweredFloatToShortInt(outputAudio, intBuffer, samples);
                fwrite(intBuffer, 1, samples * 4, fd);
            }
            output->clear();
        }
    }
    NSLog(@"File converted to destination path %@.", outputFilePath);
    delete decoder;
    delete timeStretcher;
    delete output;
    delete bufferPool;
    free(intBuffer);
    return outputFilePath;
}

+(NSString *) pitchShift:(NSURL *)url newName: (NSString*)newName amountToShift: (int)shiftAmount {
    SuperpoweredDecoder *decoder = new SuperpoweredDecoder();
    const char *error = decoder->open([[url path] UTF8String], false, 0, 0);
    if (error) {
        NSLog(@"Error opening file: %s", error);
        delete decoder;
        return @"";
    }
    // Instantiate variable-sized buffer chains, 1MB memory max
    SuperpoweredAudiobufferPool *bufferPool = new SuperpoweredAudiobufferPool(4, 1024 * 1024);
    SuperpoweredTimeStretching *timeStretcher = new SuperpoweredTimeStretching(bufferPool, decoder->samplerate);
    timeStretcher->setRateAndPitchShift(0, shiftAmount);
    
    SuperpoweredAudiopointerList *output = new SuperpoweredAudiopointerList(bufferPool);
    short int *intBuffer = (short int*)malloc(decoder->samplesPerFrame * 2 * sizeof(short int) + 16384);
    
    NSString *outputFilePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.m4a", newName]];
    FILE *fd = createWAV(outputFilePath.fileSystemRepresentation, decoder->samplerate, 2);
    
    while (true) {
        unsigned int samplesDecoded = decoder->samplesPerFrame;
        if (decoder->decode(intBuffer, &samplesDecoded) == SUPERPOWEREDDECODER_ERROR) {
            break;
        }
        if (samplesDecoded < 1) {
            break;
        }
        
        // Create input buffer for time stretcher
        SuperpoweredAudiobufferlistElement inputBuffer;
        bufferPool->createSuperpoweredAudiobufferlistElement(&inputBuffer, decoder->samplePosition, samplesDecoded * 8);
        
        // Convert 16-bit ints to 32-bit floats
        SuperpoweredShortIntToFloat(intBuffer, bufferPool->floatAudio(&inputBuffer), samplesDecoded);
        inputBuffer.endSample = samplesDecoded;
        
        timeStretcher->process(&inputBuffer, output);
        
        // Check for output
        if (output->makeSlice(0, output->sampleLength)) {
            while (true) {
                float *outputAudio = NULL;
                int samples = 0;
                if (!output->nextSliceItem(&outputAudio, &samples)) {
                    break;
                }
                SuperpoweredFloatToShortInt(outputAudio, intBuffer, samples);
                fwrite(intBuffer, 1, samples * 4, fd);
            }
            output->clear();
        }
    }
    NSLog(@"File converted to destination path %@.", outputFilePath);
    delete decoder;
    delete timeStretcher;
    delete output;
    delete bufferPool;
    free(intBuffer);
    return outputFilePath;
}

+(void) convertToM4A:(NSURL *)url writeToPath: (NSString *)fileLocation {
    // Initialize asset reader
    AVURLAsset *songAsset = [AVURLAsset URLAssetWithURL:url options:nil];
    NSError *error = nil;
    AVAssetReader *assetReader = [AVAssetReader assetReaderWithAsset:songAsset error:&error];
    if (error) {
        NSLog(@"error: %@", error);
        return;
    }
    
    AVAssetReaderOutput *readerOutput = [AVAssetReaderAudioMixOutput assetReaderAudioMixOutputWithAudioTracks: songAsset.tracks audioSettings:nil];
    if (![assetReader canAddOutput:readerOutput]) {
        NSLog(@"cannot add output");
        return;
    }
    [assetReader addOutput:readerOutput];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:fileLocation]) {
        [[NSFileManager defaultManager] removeItemAtPath:fileLocation error:nil];
    }
    NSURL *outputURL = [NSURL fileURLWithPath:fileLocation];
    AVAssetWriter *writer = [AVAssetWriter assetWriterWithURL:outputURL fileType:AVFileTypeCoreAudioFormat error:&error];
    if (error) {
        NSLog(@"error: %@", error);
        return;
    }
    
    AudioChannelLayout channelLayout;
    memset(&channelLayout, 0, sizeof(AudioChannelLayout));
    channelLayout.mChannelLayoutTag = kAudioChannelLayoutTag_Stereo;
    NSDictionary *outputSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithInt:kAudioFormatLinearPCM], AVFormatIDKey,
                                    [NSNumber numberWithFloat:44100.0], AVSampleRateKey,
                                    [NSNumber numberWithInt:2], AVNumberOfChannelsKey,
                                    [NSData dataWithBytes:&channelLayout length:sizeof(AudioChannelLayout)], AVChannelLayoutKey,
                                    [NSNumber numberWithInt:16], AVLinearPCMBitDepthKey,
                                    [NSNumber numberWithBool:NO], AVLinearPCMIsNonInterleaved,
                                    [NSNumber numberWithBool:NO], AVLinearPCMIsFloatKey,
                                    [NSNumber numberWithBool:NO], AVLinearPCMIsBigEndianKey,
                                    nil];
    AVAssetWriterInput *writerInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio outputSettings:outputSettings];
    if (![writer canAddInput:writerInput]) {
        NSLog(@"cannott add writer input");
        return;
    }
    [writer addInput:writerInput];
    writerInput.expectsMediaDataInRealTime = NO;
    [writer startWriting];
    [assetReader startReading];
    AVAssetTrack *track = [songAsset.tracks objectAtIndex:0];
    CMTime startTime = CMTimeMake(0, track.naturalTimeScale);
    [writer startSessionAtSourceTime:startTime];
    
    __block UInt64 convertedByteCount = 0;
    dispatch_queue_t mediaInputQueue = dispatch_queue_create("mediaInputQueue", NULL);
    [writerInput requestMediaDataWhenReadyOnQueue:mediaInputQueue usingBlock: ^ {
        while (writerInput.readyForMoreMediaData) {
            CMSampleBufferRef nextBuffer = [readerOutput copyNextSampleBuffer];
            if (nextBuffer) {
                // Convert next buffer
                [writerInput appendSampleBuffer:nextBuffer];
                convertedByteCount += CMSampleBufferGetTotalSampleSize(nextBuffer);
            } else {
                // Finish conversion
                [writerInput markAsFinished];
                [assetReader cancelReading];
                NSDictionary *outputAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:fileLocation error:nil];
                NSLog(@"File conversion successful: file size is %llu", [outputAttributes fileSize]);
                break;
            }
        }
    }];
}


@end
