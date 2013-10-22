//
//  P4RCSplashViewController.h
//  P4RCIntegrationSample
//
//  Created by Artem Stepanenko on 5/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "P4RCBaseViewController.h"
#import "ServerGateway.h"


@class P4RCSplashViewController;
@class P4RCUserInfo;

@protocol P4RCSplashViewControllerDelegate <P4RCBaseViewControllerDelegate>

- (void)splashViewControllerDidPressNoThanks:(P4RCSplashViewController *)sender;
- (void)splashViewControllerDidPressNotAFacebookUser:(P4RCSplashViewController *)sender;
- (void)splashViewController:(P4RCSplashViewController *)sender didAuthorizeViaFacebookWithUserInfo:(P4RCUserInfo *)userInfo sessionId:(NSString *)sessionId error:(NSError *)error;
- (void)splashViewControllerDidPressTermsAndConditions:(P4RCSplashViewController *)sender;

@end

@class P4RCSplashView;

@interface P4RCSplashViewController : P4RCBaseViewController <ReceiverProtocol>
{
    P4RCSplashView *splashView;
}

@property (nonatomic, assign) id<P4RCSplashViewControllerDelegate> delegate;

@end
