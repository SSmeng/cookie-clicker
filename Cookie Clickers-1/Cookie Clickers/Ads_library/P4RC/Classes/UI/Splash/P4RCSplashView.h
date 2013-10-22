//
//  P4RCSplashView.h
//  P4RCIntegrationSample
//
//  Created by Artem Stepanenko on 5/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "P4RCBaseSplashView.h"


@class P4RCSplashView;

@protocol P4RCSplashViewDelegate <P4RCBaseSplashViewDelegate>

- (void)splashViewDidPressFacebook:(P4RCSplashView *)sender userAcceptedTerms:(BOOL)userAcceptedTerms;
- (void)splashViewDidPressNoThanks:(P4RCSplashView *)sender;
- (void)splashViewDidPressNotAFacebookUserDidPress:(P4RCSplashView *)sender;
- (void)splashViewDidPressTermsAndConditions:(P4RCSplashView *)sender;

@end

@class P4RCCheckButton;
@class P4RCCellView;

@interface P4RCSplashView : P4RCBaseSplashView
{
    UIButton *facebookButton;
    UIButton *notAFacebookUserButton;
    UIButton *noThanksButton;
    
    UILabel *firstTitleLabel;
    UILabel *secondTitleLabel;
    
    P4RCCellView *earnPointsCellView;
    P4RCCellView *redeemPointsCellView;
    
    P4RCCheckButton *checkButton;
    
    UILabel *firstLineTermsLabel;
    UIButton *secondLineTermsButton;
}

@property (nonatomic, assign) id<P4RCSplashViewDelegate> delegate;

@end
