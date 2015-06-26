//
//  RecordViewController.h
//  Mash
//
//  Created by Eeshan Agarwal on 3/14/15.
//  Copyright (c) 2015 UC Berkeley (Eeshan Agarwal). All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EZAudio/EZAudio.h>
#import <AVFoundation/AVFoundation.h>
#define kAudioFilePath @"EZAudioTest.m4a"

@interface RecordViewsController : UIViewController <AVAudioPlayerDelegate, EZMicrophoneDelegate, EZAudioFileDelegate, EZOutputDataSource>


@property (nonatomic,weak) IBOutlet EZAudioPlotGL *audioPlot;
@property (weak, nonatomic) IBOutlet UIButton *backButton;

@property (nonatomic,assign) BOOL isRecording;


@property (nonatomic,strong) EZMicrophone *microphone;

@property (nonatomic,strong) EZAudioFile *audioFile;
@property (nonatomic,assign) BOOL eof;
@property (nonatomic,strong) EZRecorder *recorder;

-(IBAction)playFile:(id)sender;


-(IBAction)toggleMicrophone:(id)sender;

-(IBAction)toggleRecording:(id)sender;


@end

