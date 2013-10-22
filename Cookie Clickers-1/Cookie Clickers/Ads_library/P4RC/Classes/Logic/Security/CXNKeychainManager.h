//
//  CXNKeychainManager.h
//  CXN
//
//  Created by Igor Ishchenko on 23.07.10.
//  Copyright 2010 nix. All rights reserved.
//

#import <Foundation/Foundation.h>

// service code to store in iPhone keychain
#define SERVICE_CODE @"P4RC"

//! Manager for iPhone KeyChain. Singleton because it cannot be mocked otherwise
@interface CXNKeychainManager : NSObject 

// Returns shared instance of keychain manager
+ (CXNKeychainManager*)sharedInstance;

//! Returns key for database encryption for specified site. If key doesn't exist, generates it and adds to keychain
- (NSString*)keyForSiteWithCode:(NSString*)theSiteCode;


@end
