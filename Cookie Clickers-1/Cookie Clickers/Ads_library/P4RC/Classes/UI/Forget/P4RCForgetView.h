//
//  P4RCForgetView.h
//  P4RCIntegrationSample
//
//  Created by Artem Stepanenko on 6/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "P4RCBaseSplashView.h"
#import "P4RCTextField.h"


@class P4RCForgetView;

@protocol P4RCForgetViewDelegate <P4RCBaseSplashViewDelegate>

- (void)forgetView:(P4RCForgetView *)sender didPressSubmitWithEmail:(NSString *)email;

@end


@interface P4RCForgetView : P4RCBaseSplashView
{
    UILabel *hintLabel;
    P4RCTextField *emailTextField;
    UIButton *submitButton;
}

@property (nonatomic, assign) id<P4RCForgetViewDelegate> delegate;

@end
