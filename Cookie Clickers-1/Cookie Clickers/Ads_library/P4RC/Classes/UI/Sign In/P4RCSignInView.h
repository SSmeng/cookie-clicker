//
//  P4RCSignInView.h
//  P4RCIntegrationSample
//
//  Created by Artem Stepanenko on 5/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "P4RCBaseSplashView.h"


@class P4RCSignInView;

@protocol P4RCSignInViewDelegate <P4RCBaseSplashViewDelegate>

- (void)signInView:(P4RCSignInView *)sender signInDidPressWithUsername:(NSString *)username password:(NSString *)password;
- (void)signInViewDidPressSignUp:(P4RCSignInView *)sender;
- (void)signInViewDidPressReset:(P4RCSignInView *)sender;

@end


@class P4RCTextField;

@interface P4RCSignInView : P4RCBaseSplashView
{
    UILabel *hintLabel;
    P4RCTextField *usernameTextField;
    P4RCTextField *passwordTextField;
    
    UIButton *signInButton;
    UIButton *signUpButton;
    
    UILabel *firstLineHintLabel;
    UILabel *secondLineHintLabel;
    
    UILabel *forgetLabel;
    UIButton *resetButton;
}

@property (nonatomic, assign) id<P4RCSignInViewDelegate> delegate;

- (void)clearFields;

@end
