//
//  Use this file to import your target's public headers that you would like to expose to Swift.
//

#import "KeychainWrapper.h"
#import "Objective-C.h"

@interface AudioModule : NSObject

+(NSString *) timeShift:(NSURL *)url newName: (NSString*)newName amountToShift: (float)shiftAmount;
+(NSString *) pitchShift:(NSURL *)url newName: (NSString*)newName amountToShift: (int)shiftAmount;

@end