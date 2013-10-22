//
//  P4RCSignUpView.h
//  P4RCIntegrationSample
//
//  Created by Artem Stepanenko on 5/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "P4RCBaseSplashView.h"


@class P4RCSignUpView;

@protocol P4RCSignUpViewDelegate <P4RCBaseSplashViewDelegate>

- (void)signUpView:(P4RCSignUpView *)sender signUpDidPressWithFirstName:(NSString *)firstName lastName:(NSString *)lastName email:(NSString *)email confirmedEmail:(NSString *)confirmedEmail password:(NSString *)password verifiedPassword:(NSString *)verifiedPassword acceptedTerms:(BOOL)acceptedTerms;
- (void)signUpViewDidPressCancel:(P4RCSignUpView *)sender;
- (void)signUpViewDidPressTermsAndConditions:(P4RCSignUpView *)sender;

@end


@class P4RCCheckButton;
@class P4RCTextField;

@interface P4RCSignUpView : P4RCBaseSplashView
{
    UILabel *hintLabel;
    P4RCTextField *firstNameTextField;
    P4RCTextField *lastNameTextField;
    P4RCTextField *emailTextField;
    P4RCTextField *confirmedEmailTextField;
    P4RCTextField *passwordTextField;
    P4RCTextField *verifiedPasswordTextField;
    
    P4RCCheckButton *checkButton;
    UILabel *firstLineTermsLabel;
    UIButton *secondLineTermsButton;
    
    UIButton *signUpButton;
    UIButton *cancelButton;
    
    UILabel *alreadyHaveLabel;
}

@property (nonatomic, assign) id<P4RCSignUpViewDelegate> delegate;

- (void)clearFields;

@end
