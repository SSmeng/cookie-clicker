//
//  P4RCTermsView.m
//  P4RCIntegrationSample
//
//  Created by Artem Stepanenko on 6/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "P4RCTermsView.h"
#import "server.h"
#import "P4RCServerConfig.h"

#define MARGIN      10


@interface P4RCTermsView ()

- (void)signUpDidPress:(id)sender;

@end


@implementation P4RCTermsView

@dynamic delegate;

- (void)dealloc
{
    [termsWebView release];
    [signUpButton release];
    [super dealloc];
}

- (id)initWithFrame:(CGRect)theFrame
{
    self = [super initWithFrame:theFrame];
    if (self)
    {
        // sign up
        signUpButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
        [[signUpButton titleLabel] setFont:[UIFont boldSystemFontOfSize:14]];
        [signUpButton setTitle:@"Back" forState:UIControlStateNormal];
        [signUpButton setTitleColor:[UIColor colorWithRed:0.24f green:0.67f blue:0.75f alpha:1] forState:UIControlStateNormal];
        [signUpButton setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
        [signUpButton addTarget:self action:@selector(signUpDidPress:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:signUpButton];
        // terms
        termsWebView = [[UIWebView alloc] initWithFrame:CGRectZero];
        [termsWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[P4RCServerConfig termsOfUseAddress]]]];
        [scrollView addSubview:termsWebView];
    }
    return self;
}

- (void)updateWithOrientation:(UIInterfaceOrientation)orientation
{
    [super updateWithOrientation:orientation];
    // sign up
    [signUpButton sizeToFit];
    [signUpButton setFrame:CGRectMake(([scrollView bounds].size.width - [signUpButton bounds].size.width) / 2, MARGIN, [signUpButton bounds].size.width, [signUpButton bounds].size.height)];
    // terms
    [termsWebView setFrame:CGRectMake(0, 0, [scrollView bounds].size.width, [scrollView bounds].size.height)];
        
    [self setScrollContentHeight:([termsWebView frame].origin.y + [termsWebView frame].size.height + MARGIN)];
    [self updateScrollOffsetForOrientation:orientation];
}

#pragma mark - Private

- (void)signUpDidPress:(id)sender
{
    [[self delegate] termsViewDidPressSignUp:self];
}

@end
