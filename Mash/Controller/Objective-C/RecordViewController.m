//
//  RecordViewController.m
//  Mash
//
//  Created by Eeshan Agarwal on 3/14/15.
//  Copyright (c) 2015 UC Berkeley (Eeshan Agarwal). All rights reserved.
//

#import "RecordViewController.h"
#import "Mash_iOS-Swift.h"

@interface RecordViewsController ()
@property (weak, nonatomic) IBOutlet UILabel *initialLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *pauseLabel;
@property (nonatomic,strong) AVAudioPlayer *audioPlayer;
@property (nonatomic,weak) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;

@end

@implementation RecordViewsController

int currentTime;
@synthesize audioPlot;
@synthesize microphone;
@synthesize playButton;
@synthesize recorder;

#pragma mark - Initialization
-(id)init {
    self = [super init];
    if(self){
        [self initializeViewController];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if(self){
        [self initializeViewController];
    }
    return self;
}

#pragma mark - Initialize View Controller Here
-(void)initializeViewController {
    self.microphone = [EZMicrophone microphoneWithDelegate:self];
}

#pragma mark - Customize the Audio Plot
-(void)viewDidLoad {

    [super viewDidLoad];
    [self.audioPlot setHidden:YES];
    [self.pauseLabel setHidden:YES];
    [self.playButton setHidden:YES];
    [self.playButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.playButton setTitle:@"Play" forState:UIControlStateNormal];
    [self setTimer];

    [self.timeLabel setText:[NSString stringWithFormat:@"%d", 3]];

    self.playButton.center = self.view.center;

    [self.playButton addTarget:self action:@selector(returnHome) forControlEvents:UIControlEventTouchUpInside];
    [self.saveButton addTarget:self action:@selector(upload) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mart - Timer Code
-(void) setTimer{
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(tick:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
    currentTime = 0;
}

-(void) upload {
    [self.microphone stopFetchingAudio];
    self.isRecording = NO;
    [self.recorder closeAudioFile];
    [self.pauseLabel setHidden:YES];
    UploadViewController *uploadController = [self.storyboard instantiateViewControllerWithIdentifier:@"UploadViewController"];
    uploadController.recording = self.audioFile;
    [self.navigationController pushViewController:uploadController animated:true];
}

-(void) returnHome {
    [self.navigationController popViewControllerAnimated:true];
}

-(void) tick: (NSTimer*) timer
{
    currentTime++;
    int labelText = 3 - currentTime;
    [self.timeLabel setText:[NSString stringWithFormat:@"%d", labelText]];
    if (currentTime == 3) {
        currentTime = 0;
        [self.timeLabel setHidden: YES];
        [self.initialLabel setHidden:YES];
        
        [self setRecorder];
        [timer invalidate];
    }
}

-(void) setRecorder{
    [self.audioPlot setHidden:NO];
    self.pauseLabel.alpha = 0.0f;
    [self.pauseLabel setHidden: NO];
    
    [UIView animateWithDuration:4.0f delay: 2.0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
        self.pauseLabel.alpha = 1.0f;
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:2.0 delay: 0 options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionAutoreverse|UIViewAnimationOptionRepeat animations:^{
            self.pauseLabel.transform = CGAffineTransformMakeScale(1.2, 1.2);
            
        } completion:^(BOOL finished) {
        }];
    }];
    
    
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(screenTapped)];
    [self.view addGestureRecognizer:tapGesture];
    
    self.audioPlot.color = [UIColor whiteColor];
    
    self.audioPlot.backgroundColor           = [UIColor colorWithRed: (242/255.0f) green: (197/255.0f) blue: (117/255.0f) alpha: 1];
    self.audioPlot.plotType        = EZPlotTypeRolling;
    self.audioPlot.shouldFill      = YES;
    self.audioPlot.shouldMirror    = YES;
    self.audioPlot.gain = 2.0f;
    
    self.recorder = [EZRecorder recorderWithDestinationURL:[self testFilePathURL]
                                              sourceFormat:self.microphone.audioStreamBasicDescription
                                       destinationFileType:EZRecorderFileTypeM4A];
    
    [self.microphone startFetchingAudio];
    self.isRecording = YES;
    self.playButton.hidden = YES;
    NSLog(@"File written to application sandbox's documents directory: %@",[self testFilePathURL]);
}

-(void) screenTapped
{
    for (UIGestureRecognizer *recognizer in self.view.gestureRecognizers) {
        [self.view removeGestureRecognizer:recognizer];
    }

    [self.microphone stopFetchingAudio];
    self.isRecording = NO;
    [self.recorder closeAudioFile];
    [self.pauseLabel setHidden:YES];
    self.playButton.alpha = 0.0f;
    
    [self.playButton setHidden: NO];
    
    [UIView animateWithDuration:1.0f delay: 0.0f options:UIViewAnimationOptionAllowUserInteraction animations:^{
        self.playButton.alpha = 1.0f;
    } completion:^(BOOL finished) {
    }];
    self.microphone = nil;
    self.recorder = nil;
    
    [self openFileWithFilePathURL:[self testFilePathURL]];
}

- (IBAction)playFile:(id)sender {
    
    
    if( ![[EZOutput sharedOutput] isPlaying] ){
        if( self.eof ){
            [self.audioFile seekToFrame:0];
        }
        [EZOutput sharedOutput].outputDataSource = self;
        [[EZOutput sharedOutput] startPlayback];
    }
    else {
        [EZOutput sharedOutput].outputDataSource = nil;
        [[EZOutput sharedOutput] stopPlayback];
    }
   
}

-(void)seekToFrame:(id)sender {
    [self.audioFile seekToFrame:(SInt64)[(UISlider*)sender value]];
}



-(void)openFileWithFilePathURL:(NSURL*)filePathURL {
    
    // Stop playback
    [self.audioPlot clear];
    [[EZOutput sharedOutput] stopPlayback];
    [EZOutput sharedOutput].outputDataSource = nil;
    self.audioFile          = [EZAudioFile audioFileWithURL:filePathURL];
    self.eof                = NO;
    [[EZOutput sharedOutput] setAudioStreamBasicDescription:self.audioFile.clientFormat];
    self.audioPlot.gain = 2.0f;
    self.audioFile.audioFileDelegate      = self;
    // Plot the whole waveform
    self.audioPlot.plotType        = EZPlotTypeRolling;
    self.audioPlot.shouldFill      = YES;
    self.audioPlot.shouldMirror    = YES;
    [self.audioFile getWaveformDataWithCompletionBlock:^(float *waveformData, UInt32 length) {
        [self.audioPlot updateBuffer:waveformData withBufferSize:length];
    }];
   
}



#pragma mark - EZAudioFileDelegate
-(void)audioFile:(EZAudioFile *)audioFile
       readAudio:(float **)buffer
  withBufferSize:(UInt32)bufferSize
withNumberOfChannels:(UInt32)numberOfChannels {
    dispatch_async(dispatch_get_main_queue(), ^{
        if( [EZOutput sharedOutput].isPlaying )
        {
            [self.audioPlot updateBuffer:buffer[0] withBufferSize:bufferSize];
        }
    });
}



#pragma mark - EZOutputDataSource
-(void)output:(EZOutput *)output shouldFillAudioBufferList:(AudioBufferList *)audioBufferList withNumberOfFrames:(UInt32)frames
{
    if( self.audioFile )
    {
        UInt32 bufferSize;
        [self.audioFile readFrames:frames
                   audioBufferList:audioBufferList
                        bufferSize:&bufferSize
                               eof:&_eof];
        if( _eof )
        {
            [self seekToFrame:0];
        }
    }
}

-(AudioStreamBasicDescription)outputHasAudioStreamBasicDescription:(EZOutput *)output {
    return self.audioFile.clientFormat;
}



#pragma mark - EZMicrophoneDelegate

-(void)microphone:(EZMicrophone *)microphone
 hasAudioReceived:(float **)buffer
   withBufferSize:(UInt32)bufferSize
withNumberOfChannels:(UInt32)numberOfChannels {
   
    dispatch_async(dispatch_get_main_queue(),^{
        [self.audioPlot updateBuffer:buffer[0] withBufferSize:bufferSize];
    });
}

-(void)microphone:(EZMicrophone *)microphone
    hasBufferList:(AudioBufferList *)bufferList
   withBufferSize:(UInt32)bufferSize
withNumberOfChannels:(UInt32)numberOfChannels {
    
    if( self.isRecording ){
        [self.recorder appendDataFromBufferList:bufferList
                                 withBufferSize:bufferSize];
    }
    
}

#pragma mark - Utility
-(NSArray*)applicationDocuments {
    return NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
}

-(NSString*)applicationDocumentsDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}

-(NSURL*)testFilePathURL {
    return [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@",
                                   [self applicationDocumentsDirectory],
                                   kAudioFilePath]];
}


@end
