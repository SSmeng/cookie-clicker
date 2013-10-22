//
//  P4RCBaseSplashView.h
//  P4RCIntegrationSample
//
//  Created by Artem Stepanenko on 5/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "P4RCAutorotatableView.h"


@class P4RCBaseSplashView;

@protocol P4RCBaseSplashViewDelegate

- (void)baseSplashViewDidPressClose:(P4RCBaseSplashView *)sender;

@end


@interface P4RCBaseSplashView : P4RCAutorotatableView <UITextFieldDelegate> {
    @private
    UIButton *closeButton;
    
    @protected
    UIScrollView *scrollView;
    UIImageView *hintPortraitImageView;
    UIImageView *hintLandscapeImageView;
    UIImageView *currentHintImageView;
    UITextField *selectedTextField;
    
    BOOL shouldScrollBack;
    
    id<P4RCBaseSplashViewDelegate> delegate;
}

- (NSString *)backImageNameForPortraitOrientation;
- (NSString *)backImageNameForLandscapeOrientation;
// protected
- (void)updateScrollContentSize;
- (void)setScrollContentHeight:(CGFloat)height;
- (void)updateScrollOffset;
- (void)updateScrollOffsetForOrientation:(UIInterfaceOrientation)orientation;
- (CGFloat)keyboardHeightForOrientation:(UIInterfaceOrientation)orientation;
- (BOOL)isAnyTextFieldEditing;

@end
