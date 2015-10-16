//
//  Objective-C.m
//  Mash
//
//  Created by Danny Hsu on 7/15/15.
//  Copyright (c) 2015 Mash. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Objective-C.h"
#import "Mash-Swift.h"

@implementation Wrappers

+ (NSString *)hexadecimalString: (NSData *) data
{
    /* Returns hexadecimal string of NSData. Empty string if data is empty.   */
    
    const unsigned char *dataBuffer = (const unsigned char *) data;
    
    if (!dataBuffer)
    {
        return [NSString string];
    }
    
    NSUInteger          dataLength  = [data length];
    NSMutableString     *hexString  = [NSMutableString stringWithCapacity:(dataLength * 2)];
    
    for (int i = 0; i < dataLength; ++i)
    {
        [hexString appendFormat:@"%02x", (unsigned int)dataBuffer[i]];
    }
    
    return [NSString stringWithString:hexString];
}

void exceptionHandler(NSException *exception) {
    NSLog(@"App crashed with exception.");
    // Perhaps we can log out here.
    /*
    if currentUser.handle!.characters.count > 0 {
        let request = UserRequest()
        request.loginToken = currentUser.loginToken
        request.userid = UInt32(currentUser.userid!)
        
        server.signOutWithRequest(request) {
            (response, error) in
            if error != nil {
                Debug.printl("Error: \(error)", sender: self)
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    NSUserDefaults.standardUserDefaults().removeObjectForKey("hasLoginKey")
                }
            }
        }
    }*/
}
NSUncaughtExceptionHandler *exceptionHandlerPtr = &exceptionHandler;

@end
