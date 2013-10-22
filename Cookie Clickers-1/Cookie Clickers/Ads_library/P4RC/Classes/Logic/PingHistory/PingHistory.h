//
//  PingHistory.h
//  P4RCIntegrationSample
//
//  Created by Kostiantyn Zamiesov on 10/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

@protocol P4RCPingHistoryDelegate <NSObject>

- (void)didSuccessfullPing;

@end

@interface PingHistory : NSObject

@property (nonatomic, assign) id<P4RCPingHistoryDelegate> delegate;

- (void)logStartLevelForGameRefId:(NSString*)gameRefId;

@end
