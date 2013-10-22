//
//  P4RCUtils.h
//  ConstaPad
//
//  Created by Artem Stepanenko on 11/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "P4RCTypes.h"

#define NOT_NIL_STRING(string)                      (string == nil ? @"" : string)
#define IS_STRING_EMPTY(string)                     ((string == nil) || ([string isEqualToString:@""]))



@interface P4RCUtils : NSObject
{

}

+ (P4RCDeviceType)deviceType;
+ (NSString *)deviceTypeString;
+ (NSString *)pathToFileWithName:(NSString *)fileName;
+ (UIAlertView *)internetIsNotAvailableAlert;
+ (BOOL)validateEmail:(NSString *)candidate;

@end
