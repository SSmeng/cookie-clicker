//
//  P4RCUtils.m
//  ConstaPad
//
//  Created by Artem Stepanenko on 11/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "P4RCUtils.h"
#import "P4RCServerConfig.h"
#include <netinet/in.h>


@interface P4RCUtils ()



@end


@implementation P4RCUtils

static P4RCUtils *sharedInstance = nil;

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self)
    {

    }
    return self;
}

+ (P4RCUtils *)sharedInstance
{
    if (sharedInstance == nil)
    {
        sharedInstance = [[self alloc] init];
    }
    return sharedInstance;
}



+ (P4RCDeviceType)deviceType
{
    if ([UIScreen mainScreen].scale == 2.f && [UIScreen mainScreen].bounds.size.height == 568.0f)
    {
        return P4RCDeviceTypeIPhone5;
    }
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        return P4RCDeviceTypeIPad;
    }
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        return P4RCDeviceTypeIPhone;
    }
    
    return P4RCDeviceTypeUndefined;
}

+ (NSString *)deviceTypeString
{
	NSString *deviceModel = [[UIDevice currentDevice] model];
	if ([deviceModel rangeOfString:@"iPad"].location != NSNotFound)
	{
		return @"IPAD";
	}
	else if ([deviceModel rangeOfString:@"iPhone"].location != NSNotFound)
	{
		return @"IPHONE";
	}
	else
	{
		return @"IPOD";
	}
}


+ (NSString *)pathToFileWithName:(NSString *)fileName
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); 
	NSString *documentsDirectoryPath = [paths objectAtIndex:0];
	return [documentsDirectoryPath stringByAppendingPathComponent:fileName];
}

+ (UIAlertView *)internetIsNotAvailableAlert
{
    return [[[UIAlertView alloc] initWithTitle:@"P4RC Service is unreachable. Please make sure your network connection is enabled." message:nil delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] autorelease];
}
+ (BOOL)validateEmail:(NSString *)candidate {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"; 
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex]; 
    return [emailTest evaluateWithObject:candidate];
}

@end
