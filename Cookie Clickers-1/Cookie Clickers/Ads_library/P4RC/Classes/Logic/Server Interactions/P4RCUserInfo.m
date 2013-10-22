//
//  P4RCUserInfo.m
//  ConstaPad
//
//  Created by Artem Stepanenko on 9/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "P4RCUserInfo.h"


@implementation P4RCUserInfo

@synthesize email = email_,
			userID = userID_,
			userSource = userSource_,
			userType = userType,
			firstName = firstName_,
			lastName = lastName_,
			userAcceptedTerms = userAcceptedTerms_,
			profileCompletitionPercent = profileCompletitionPercent_,
			userAvatarURL = userAvatarURL_,
			totalP4RCPoints = totalP4RCPoints_,
			fbPublishAllowed = fbPublishAllowed_,
			authStatus = authStatus_,
			securityObject = securityObject_;

- (void)dealloc
{
	[email_ release];
	[firstName_ release];
	[lastName_ release];
	[userAvatarURL_ release];
	[securityObject_ release];
	[super dealloc];
}

@end
