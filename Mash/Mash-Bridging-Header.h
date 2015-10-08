//
//  Use this file to import your target's public headers that you would like to expose to Swift.
//

#import "KeychainWrapper.h"
#import "Objective-C.h"
#import "AWSCore/AWSCore.h"
#import "AWSS3/AWSS3.h"
#import "FBSDKCoreKit/FBSDKCoreKit.h"
#import "FBSDKLoginKit/FBSDKLoginKit.h"
#import "EZAudio/EZAudio.h"
#import <CommonCrypto/CommonDigest.h>
#import "CustomIOSAlertView/CustomIOSAlertView.h"
#import "Mashservice.pbobjc.h"
#import "Mashservice.pbrpc.h"

@interface AudioModule : NSObject

+(NSString *) timeShift:(NSURL *)url newName: (NSString*)newName amountToShift: (float)shiftAmount;
+(NSString *) pitchShift:(NSURL *)url newName: (NSString*)newName amountToShift: (int)shiftAmount;
+(void) convertToM4A:(NSURL *)url writeToPath: (NSString *)fileLocation;

@end