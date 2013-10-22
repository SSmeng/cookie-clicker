//
//  P4RCWaitView.m
//  P4RCIntegrationSample
//
//  Created by Artem Stepanenko on 5/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "P4RCWaitView.h"

#define ANIMATION_DURATION      0.4f
#define SHOW_ANIMATION_KEY      @"showAnimationKey"
#define HIDE_ANIMATION_KEY      @"hideAnimationKey"


@interface P4RCWaitView ()

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context;

@end


@implementation P4RCWaitView

- (void)dealloc
{
    [activityIndicatorView release];
    [super dealloc];
}

- (id)initWithFrame:(CGRect)theFrame
{
    self = [super initWithFrame:theFrame];
    if (self)
    {
        [self setBackgroundColor:[UIColor colorWithRed:0.6f green:0.6f blue:0.6f alpha:0.4f]];
        
        activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [activityIndicatorView setHidesWhenStopped:YES];
        [self addSubview:activityIndicatorView];
    }
    return self;
}

- (void)showAnimated:(BOOL)animated parentView:(UIView *)parentView
{
    [parentView addSubview:self];
    [self setFrame:[parentView bounds]];
    [activityIndicatorView startAnimating];
    if (animated == YES)
    {
        [self setAlpha:0];
        [UIView beginAnimations:SHOW_ANIMATION_KEY context:NULL];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
        [UIView setAnimationDuration:ANIMATION_DURATION];
        [self setAlpha:1];
        [UIView commitAnimations];
    }
}

- (void)hideAnimated:(BOOL)animated
{
    if (animated == YES)
    {
        [self setAlpha:1];
        [UIView beginAnimations:HIDE_ANIMATION_KEY context:NULL];
        [UIView setAnimationDuration:ANIMATION_DURATION];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
        [self setAlpha:0];
        [UIView commitAnimations];
    }
    else
    {
        [self removeFromSuperview];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [activityIndicatorView setCenter:CGPointMake([self bounds].size.width / 2, [self bounds].size.height / 2)];
}

#pragma mark - Private

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    if ([animationID isEqualToString:SHOW_ANIMATION_KEY] == YES)
    {
        // do nothing
    }
    else if ([animationID isEqualToString:HIDE_ANIMATION_KEY] == YES)
    {
        [self removeFromSuperview];
    }
}

@end
