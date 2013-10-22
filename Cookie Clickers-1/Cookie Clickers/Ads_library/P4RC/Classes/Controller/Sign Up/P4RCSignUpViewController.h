//
//  P4RCSignUpViewController.h
//  P4RCIntegrationSample
//
//  Created by Artem Stepanenko on 5/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "P4RCBaseViewController.h"


@class P4RCSignUpViewController;

@protocol P4RCSignUpViewControllerDelegate <P4RCBaseViewControllerDelegate>

- (void)signUpViewControllerDidPressCancel:(P4RCSignUpViewController *)sender;
- (void)signUpViewControllerDidRegister:(P4RCSignUpViewController *)sender;
- (void)signUpViewControllerDidFailRegistration:(P4RCSignUpViewController *)sender;
- (void)signUpViewControllerDidPressTermsAndConditions:(P4RCSignUpViewController *)sender;

@end


@class P4RCSignUpView;

@interface P4RCSignUpViewController : P4RCBaseViewController
{
    P4RCSignUpView *signUpView;
}

@property (nonatomic, assign) id<P4RCSignUpViewControllerDelegate> delegate;

@end
