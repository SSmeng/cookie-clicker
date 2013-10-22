//
//  P4RCTermsView.h
//  P4RCIntegrationSample
//
//  Created by Artem Stepanenko on 6/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "P4RCBaseSplashView.h"


@class P4RCTermsView;

@protocol P4RCTermsViewDelegate <P4RCBaseSplashViewDelegate>

- (void)termsViewDidPressSignUp:(P4RCTermsView *)sender;

@end


@interface P4RCTermsView : P4RCBaseSplashView
{
    UIButton *signUpButton;
    UIWebView *termsWebView;
}

@property (nonatomic, assign) id<P4RCTermsViewDelegate> delegate;

@end
