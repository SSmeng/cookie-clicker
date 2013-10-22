//
//  P4RCCacheManager.m
//  ConstaPad
//
//  Created by Artem Stepanenko on 8/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "P4RCCacheManager.h"
#import "P4RCServerConfig.h"

#define SESSION_STORAGE_NAME	@"P4RCSession.plist"

#define SESSION_ID_KEY			@"sessionId"
#define SESSION_ID_COOKIE_KEY	@"sessionIdCookie"
#define LAST_LEVEL_PLAYED		@"lastLevelPlayed"


@implementation P4RCCacheManager

#pragma mark -
#pragma mark Private

+ (NSString *)sessionStoragePath
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); 
	NSString *documentsDirectoryPath = [paths objectAtIndex:0];
	return [documentsDirectoryPath stringByAppendingPathComponent:SESSION_STORAGE_NAME];
}

+ (NSObject *)sessionObjectByKey:(NSString *)key
{
	NSDictionary *sessionDictionary = [NSDictionary dictionaryWithContentsOfFile:[self sessionStoragePath]];
	if (sessionDictionary == nil)
	{
		return nil;
	}
	
	return [sessionDictionary objectForKey:key];
}

+ (void)setSessionObject:(NSObject *)object withKey:(NSString *)key
{
	NSString *path = [self sessionStoragePath];
	NSMutableDictionary *sessionDictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
	if (sessionDictionary == nil)
	{
		sessionDictionary = [[NSMutableDictionary alloc] init];
	}
	[sessionDictionary setObject:object forKey:key];
	[[NSDictionary dictionaryWithDictionary:sessionDictionary] writeToFile:path atomically:YES];
	[sessionDictionary release];
}

#pragma mark -
#pragma mark Public

+ (NSString *)sessionId
{
	NSString *sessionId = (NSString *)[self sessionObjectByKey:SESSION_ID_KEY];
	return (sessionId == nil) || ([sessionId isEqualToString:@""] == YES) ? nil : sessionId;
}

+ (void)setSessionId:(NSString *)sessionId
{
	[self setSessionObject:(sessionId ? sessionId : @"") withKey:SESSION_ID_KEY];
}

+ (NSHTTPCookie *)sessionIdCookie
{
	NSDictionary *cookieProperties = (NSDictionary *)[self sessionObjectByKey:SESSION_ID_COOKIE_KEY];

	return ((cookieProperties == nil) || ([cookieProperties isEqualToDictionary:[NSDictionary dictionary]])) ? nil : [NSHTTPCookie cookieWithProperties:cookieProperties];
}

+ (void)setCookieWithSessionId:(NSString *)sessionId
{
    NSHTTPCookie *cookie = [[NSHTTPCookie alloc] initWithProperties:[NSDictionary dictionaryWithObjectsAndKeys:sessionId, NSHTTPCookieValue, @"p4rcSessionId", NSHTTPCookieName, [P4RCServerConfig serverHostWithoutPort], NSHTTPCookieDomain, @"/", NSHTTPCookiePath, [NSNumber numberWithBool:NO], @"sessionOnly", nil]];
    
    [self setSessionIdCookie:cookie];
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
    [cookie release];
}

+ (void)setSessionIdCookie:(NSHTTPCookie *)cookie
{
	NSDictionary *properties = cookie ? [cookie properties] : [NSDictionary dictionary];
	[self setSessionObject:properties withKey:SESSION_ID_COOKIE_KEY];
}

+ (void)setLastLevelPlayed:(NSInteger)level
{
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:level] forKey:LAST_LEVEL_PLAYED];
}

+ (NSInteger)lastLevelPlayed
{
	return [(NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:LAST_LEVEL_PLAYED] integerValue];
}

@end
