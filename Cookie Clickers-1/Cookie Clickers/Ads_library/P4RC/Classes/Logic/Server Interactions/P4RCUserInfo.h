//
//  P4RCUserInfo.h
//  ConstaPad
//
//  Created by Artem Stepanenko on 9/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface P4RCUserInfo : NSObject
{
	NSString *email_;
	NSInteger userID_;
	NSInteger userSource_;
	NSInteger userType_;
	NSString *firstName_;
	NSString *lastName_;
	BOOL userAcceptedTerms_;
	NSInteger profileCompletitionPercent_;
	NSString *userAvatarURL_;
	NSInteger totalP4RCPoints_;
	BOOL fbPublishAllowed_;
	NSInteger authStatus_;
	NSString *securityObject_;
}

@property (nonatomic, copy) NSString *email;
@property (nonatomic, assign) NSInteger userID;
@property (nonatomic, assign) NSInteger userSource;
@property (nonatomic, assign) NSInteger userType;
@property (nonatomic, copy) NSString *firstName;
@property (nonatomic, copy) NSString *lastName;
@property (nonatomic, assign) BOOL userAcceptedTerms;
@property (nonatomic, assign) NSInteger profileCompletitionPercent;
@property (nonatomic, copy) NSString *userAvatarURL;
@property (nonatomic, assign) NSInteger totalP4RCPoints;
@property (nonatomic, assign) BOOL fbPublishAllowed;
@property (nonatomic, assign) NSInteger authStatus;
@property (nonatomic, copy) NSString *securityObject;

@end
