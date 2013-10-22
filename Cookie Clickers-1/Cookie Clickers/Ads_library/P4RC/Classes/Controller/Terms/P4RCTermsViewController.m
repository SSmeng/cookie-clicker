//
//  P4RCTermsViewController.m
//  P4RCIntegrationSample
//
//  Created by Artem Stepanenko on 6/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "P4RCTermsViewController.h"
#import "P4RCTermsView.h"


@interface P4RCTermsViewController () <P4RCTermsViewDelegate>

@property (nonatomic, retain) P4RCTermsView *termsView;

@end


@implementation P4RCTermsViewController

@synthesize termsView;

@dynamic delegate;

- (void)dealloc 
{
    [termsView release];
    [super dealloc];
}

- (void)loadView
{
    [super loadView];
    [self setTermsView:[[[P4RCTermsView alloc] initWithFrame:[[self view] frame]] autorelease]];
    [[self termsView] setDelegate:self];
    [self setView:[self termsView]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[self termsView] startAutorotate];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[self termsView] stopAutorotate];
}

#pragma mark - P4RCTermsViewDelegate

- (void)termsViewDidPressSignUp:(P4RCTermsView *)sender
{
    [[self delegate] termsViewControllerDidPressSignUp:self];
}

@end
