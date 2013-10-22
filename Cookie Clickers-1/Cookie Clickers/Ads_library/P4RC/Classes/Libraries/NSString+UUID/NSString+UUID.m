//
//  NSString+UUID.m
//  P4RCIntegrationSample
//
//  Created by Dmitry Utenkov on 06.11.12.
//
//

#import "NSString+UUID.h"

@implementation NSString (UUID)

+ (NSString*)generateUuidString {
    CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
    
    // create a new CFStringRef (toll-free bridged to NSString)
    // that you own
    NSString *uuidString = (NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuid);
    
    // release the UUID
    CFRelease(uuid);
    
    // transfer ownership of the string
    // to the autorelease pool
    return [uuidString autorelease];
}

@end
