//
//  PingHistory.m
//  P4RCIntegrationSample
//
//  Created by Kostiantyn Zamiesov on 10/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PingHistory.h"
#import "ServerGateway.h"
#import "P4RCCacheManager.h"

@interface PingHistory () <ReceiverProtocol>

@property (nonatomic, retain) NSDate *lastSuccessfullPingDate;

@end

@implementation PingHistory

@synthesize lastSuccessfullPingDate;
@synthesize delegate;

- (void)dealloc {
    delegate = nil;
    [super dealloc];
}

- (id)init {
    self = [super init];
    if (self) {
        [self setLastSuccessfullPingDate:[[NSUserDefaults standardUserDefaults] objectForKey:@"pingDate"]];
        if (lastSuccessfullPingDate == nil) {
            [self setLastSuccessfullPingDate:[NSDate dateWithTimeIntervalSince1970:0]];
        }
    }
    return self;
}

- (void)logStartLevelForGameRefId:(NSString*)gameRefId {
    NSTimeInterval period = -1*[lastSuccessfullPingDate timeIntervalSinceNow];
    if (period > 24*60*60) {
        [[ServerGateway sharedInstance] logEventForGameRefId:gameRefId securityObject:[P4RCCacheManager sessionId] forReceiver:self];
    }
}

- (void)eventLogged {
    [self setLastSuccessfullPingDate:[NSDate date]];
    [[NSUserDefaults standardUserDefaults] setObject:lastSuccessfullPingDate forKey:@"pingDate"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [delegate didSuccessfullPing];
}

- (void)eventLoggingFailWithError:(NSError*)error {
}

@end
