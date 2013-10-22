//
//  P4RCServerConfig.h
//  FakeGame
//
//  Created by Artem Stepanenko on 3/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

@interface P4RCServerConfig : NSObject

+ (NSString *)serverHostWithoutPort;
+ (NSString *)serverHost;
+ (void)setServerHost:(NSString *)serverHost;   // should be set without http or https and slash at the end
+ (NSString *)serverHost;
+ (NSString *)serverAddress;
+ (NSString *)apiKey;
+ (void)setApiKey:(NSString *)apiKey;
+ (NSString *)termsOfUseAddress;

@end
