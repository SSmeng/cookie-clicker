//
//  P4RCBaseSplashView.m
//  P4RCIntegrationSample
//
//  Created by Artem Stepanenko on 5/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "P4RCBaseSplashView.h"

#define MARGIN      10


@interface P4RCBaseSplashView ()

@property (nonatomic, retain) UIImageView *hintPortraitImageView;
@property (nonatomic, retain) UIImageView *hintLandscapeImageView;
@property (nonatomic, retain) UIImageView *currentHintImageView;
@property (nonatomic, retain) UITextField *selectedTextField;
@property (nonatomic, assign) id<P4RCBaseSplashViewDelegate> delegate;

- (void)closeDidPress:(id)sender;
- (CGFloat)keyboardHeightForOrientation:(UIInterfaceOrientation)orientation;
- (void)updateScrollFrame;
- (void)updateScrollFrameForOrientation:(UIInterfaceOrientation)orientation;

@end


@implementation P4RCBaseSplashView

@synthesize hintPortraitImageView,
            hintLandscapeImageView,
            currentHintImageView,
            selectedTextField,
            delegate;

- (void)dealloc {
    delegate = nil;
    [scrollView release];
    [closeButton release];
    [hintPortraitImageView release];
    [hintLandscapeImageView release];
    [currentHintImageView release];
    [selectedTextField release];
    [super dealloc];
}

- (id)initWithFrame:(CGRect)theFrame {
    self = [super initWithFrame:theFrame];
    if (self) {
        [self setBackgroundColor:[UIColor whiteColor]];
        // scroll view
        scrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
        [scrollView setAlwaysBounceVertical:NO];
        [scrollView setAlwaysBounceHorizontal:NO];
        [scrollView setBackgroundColor:[UIColor clearColor]];
        [self addSubview:scrollView];
        // hints
        // portrait
        UIImage *hintPortraitImage = [UIImage imageNamed:[self backImageNameForPortraitOrientation]];
        hintPortraitImageView = [[UIImageView alloc] initWithImage:hintPortraitImage];
        [hintPortraitImageView setFrame:CGRectMake(0, 0, [hintPortraitImage size].width, [hintPortraitImage size].height)];
        // landscape
        UIImage *hintLandscapeImage = [UIImage imageNamed:[self backImageNameForLandscapeOrientation]];
        hintLandscapeImageView = [[UIImageView alloc] initWithImage:hintLandscapeImage];
        [hintLandscapeImageView setFrame:CGRectMake(0, 0, [hintLandscapeImage size].width, [hintLandscapeImage size].height)];
        [self setCurrentHintImageView:hintPortraitImageView];
        [self addSubview:[self currentHintImageView]];
        // close
        closeButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
        [closeButton addTarget:self action:@selector(closeDidPress:) forControlEvents:UIControlEventTouchUpInside];
        UIImage *closeImage = [UIImage imageNamed:@"P4RC.bundle/x_button.png"];
        [closeButton setImage:closeImage forState:UIControlStateNormal];
        [closeButton setFrame:CGRectMake(0, 0, [closeImage size].width + 2 * MARGIN, [closeImage size].height + 2 * MARGIN)];
        [self addSubview:closeButton];
    }
    return self;
}

- (NSString *)backImageNameForPortraitOrientation
{
    return @"P4RC.bundle/splash_portrait_header.png";
}

- (NSString *)backImageNameForLandscapeOrientation
{
    return @"P4RC.bundle/splash_landscape_header.png";
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self setSelectedTextField:textField];
    
    [self updateScrollFrame];
    [self updateScrollContentSize];
    [self updateScrollOffset];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self setSelectedTextField:nil];
    [self updateScrollFrame];
    if (shouldScrollBack == YES)
    {
        [self updateScrollOffset];
    }
    else
    {
        shouldScrollBack = YES;
    }
}

#pragma mark - Protected

- (void)updateWithOrientation:(UIInterfaceOrientation)orientation
{
    [super updateWithOrientation:orientation];
    [scrollView setFrame:CGRectMake(0, 82, [self bounds].size.width, [self bounds].size.height - 82)];
    [closeButton setFrame:CGRectMake([self bounds].size.width - [closeButton bounds].size.width, 0, [closeButton bounds].size.width, [closeButton bounds].size.height)];
    [self bringSubviewToFront:closeButton];
    
    [[self currentHintImageView] removeFromSuperview];
    [self setCurrentHintImageView:(UIInterfaceOrientationIsLandscape(orientation) ? [self hintLandscapeImageView] : [self hintPortraitImageView])];
    [self insertSubview:[self currentHintImageView] atIndex:0];
}

- (void)orientationDidChange:(UIInterfaceOrientation)orientation
{
    [super orientationDidChange:orientation];
}

- (CGFloat)keyboardHeightForOrientation:(UIInterfaceOrientation)orientation
{
    CGFloat keyboardHeight = 0;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        if (UIInterfaceOrientationIsPortrait(orientation))
        {
            keyboardHeight = 0;
        }
        else
        {
            keyboardHeight = 128;
        }
    }
    else
    {
        if (UIInterfaceOrientationIsPortrait(orientation))
        {
            keyboardHeight = 216;
        }
        else
        {
            keyboardHeight = 162;
        }
    }
    return keyboardHeight;
}

- (BOOL)isAnyTextFieldEditing
{
    return NO;
}

- (void)updateScrollContentSize
{
    [scrollView setContentSize:CGSizeMake([self frame].size.width, 0)];
    CGFloat maxBottom = 0;
    UIView *maxSubview = nil;
    for (UIView  *subview in [scrollView subviews])
    {
        CGFloat bottom = [subview frame].origin.y + [subview frame].size.height;
        if (bottom > maxBottom)
        {
            maxBottom = bottom;
            [maxSubview autorelease];
            maxSubview = [subview retain];
        }
    }
    
    [self setScrollContentHeight:maxBottom + MARGIN];
}

- (void)setScrollContentHeight:(CGFloat)height
{
    [scrollView setContentSize:CGSizeMake([self frame].size.width, height)];
}

- (void)updateScrollOffset
{
    [self updateScrollOffsetForOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
}

- (void)updateScrollOffsetForOrientation:(UIInterfaceOrientation)orientation
{
    CGFloat keyboardHeight = [self keyboardHeightForOrientation:orientation];
    CGFloat topHeight = (UIInterfaceOrientationIsPortrait(orientation) ? [self frame].size.height : [self frame].size.width) - keyboardHeight;
    CGFloat offset = 0;
    if (selectedTextField == nil)
    {
        offset = 0;
    }
    else
    {
        offset = [scrollView frame].origin.y + [selectedTextField frame].origin.y + [selectedTextField frame].size.height - topHeight + MARGIN;
    }
    
    offset = (offset < 0 ? 0 : offset);
    
    [scrollView setContentOffset:CGPointMake(0, offset) animated:NO];
    
    [self updateScrollFrameForOrientation:orientation];
}

#pragma mark - Private

- (void)updateScrollFrame
{
    [self updateScrollFrameForOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
}

- (void)updateScrollFrameForOrientation:(UIInterfaceOrientation)orientation
{
    [scrollView setFrame:CGRectMake(0, 82, [self bounds].size.width, [self bounds].size.height - 82 - ([self isAnyTextFieldEditing] ? [self keyboardHeightForOrientation:orientation] : 0))];
}

- (void)closeDidPress:(id)sender
{
    [[self delegate] baseSplashViewDidPressClose:self];
}

@end
