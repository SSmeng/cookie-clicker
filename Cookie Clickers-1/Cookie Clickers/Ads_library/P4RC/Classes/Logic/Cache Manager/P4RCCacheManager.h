//
//  P4RCCacheManager.h
//  ConstaPad
//
//  Created by Artem Stepanenko on 8/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

@interface P4RCCacheManager : NSObject

+ (NSString *)sessionId;
+ (void)setSessionId:(NSString *)sessionId;
+ (void)setCookieWithSessionId:(NSString *)sessionId;
+ (NSHTTPCookie *)sessionIdCookie;
+ (void)setSessionIdCookie:(NSHTTPCookie *)cookie;
+ (void)setLastLevelPlayed:(NSInteger)level;
+ (NSInteger)lastLevelPlayed;

@end
