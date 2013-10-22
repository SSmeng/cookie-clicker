//
//  P4RCServerConfig.m
//  FakeGame
//
//  Created by Artem Stepanenko on 3/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "P4RCServerConfig.h"
#import "server.h"


@implementation P4RCServerConfig

static NSString *serverHost = nil;
static NSString *apiKey = nil;

+ (NSString *)serverHostWithoutPort
{
    NSString *serverHost = [self serverHost];
    NSRange portRange = [serverHost rangeOfString:@":"];
    if (portRange.location != NSNotFound)
    {
        serverHost = [serverHost substringToIndex:portRange.location];
    }
    return serverHost;
}

+ (NSString *)serverHost
{
    if (serverHost == nil)
    {
        return DEFAULT_SERVER_HOST;
    }
    return serverHost;
}

+ (void)setServerHost:(NSString *)theServerHost
{
    [serverHost autorelease];
    serverHost = [theServerHost copy];
}

+ (NSString *)serverAddress
{
    if (serverHost == nil)
    {
        return DEFAULT_SERVER_ADDRESS;
    }
    return [NSString stringWithFormat:@"http://%@/", serverHost];
}

+ (NSString *)apiKey
{
    if (apiKey == nil)
    {
        return DEFAULT_API_KEY;
    }
    return apiKey;
}

+ (void)setApiKey:(NSString *)theApiKey
{
    [apiKey autorelease];
    apiKey = [theApiKey retain];
}

+ (NSString *)termsOfUseAddress {
    return [NSString stringWithFormat:@"%@termsofuse.html", [self serverAddress]];
}

@end
