//
//  Use this file to import your target's public headers that you would like to expose to Swift.
//

#import "KeychainWrapper.h"
#import "Objective-C.h"
#import "AWSCore/AWSCore.h"
#import "AWSS3/AWSS3.h"
#import "FBSDKCoreKit/FBSDKCoreKit.h"
#import "FBSDKLoginKit/FBSDKLoginKit.h"
#import "FBSDKShareKit/FBSDKShareKit.h"
#import "Buglife/Buglife.h"
#import "EZAudio/EZAudio.h"
#import <CommonCrypto/CommonDigest.h>
#import "CustomIOSAlertView.h"
#import "Mashservice.pbobjc.h"
#import "Mashservice.pbrpc.h"
#import "LoadBalancer.pbobjc.h"
#import "LoadBalancer.pbrpc.h"
#import <Optimizely/Optimizely.h>
#import "Flurry.h"
#import "TPAACAudioConverter.h"
#import "Branch.h"

@interface SuperpoweredAudioModule : NSObject

+(NSString *) timeShift:(NSURL *)url newName: (NSString*)newName amountToShift: (float)shiftAmount;
+(NSString *) pitchShift:(NSURL *)url newName: (NSString*)newName amountToShift: (int)shiftAmount;
+(void) convertToM4A:(NSURL *)url writeToPath: (NSString *)fileLocation;

@end