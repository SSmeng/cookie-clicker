//
//  P4RCSignInViewController.h
//  P4RCIntegrationSample
//
//  Created by Artem Stepanenko on 5/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "P4RCBaseViewController.h"
#import "P4RCUserInfo.h"


@class P4RCSignInViewController;

@protocol P4RCSignInViewControllerDelegate <P4RCBaseViewControllerDelegate>

- (void)signInViewControllerDidAuthorize:(P4RCSignInViewController *)sender;
- (void)signInViewController:(P4RCSignInViewController *)sender didReceiveUserInfo:(P4RCUserInfo *)userInfo;
- (void)signInViewControllerDidPressSignUp:(P4RCSignInViewController *)sender;
- (void)signInViewControllerDidPressReset:(P4RCSignInViewController *)sender;
- (void)signInViewControllerDidPressClose:(P4RCSignInViewController *)sender;

@end


@class P4RCSignInView;

@interface P4RCSignInViewController : P4RCBaseViewController
{
    P4RCSignInView *signInView;
}

@property (nonatomic, assign) id<P4RCSignInViewControllerDelegate> delegate;

@end
