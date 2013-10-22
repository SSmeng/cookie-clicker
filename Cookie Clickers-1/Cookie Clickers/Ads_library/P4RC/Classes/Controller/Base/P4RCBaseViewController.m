//
//  P4RCBaseViewController.m
//  P4RCIntegrationSample
//
//  Created by Artem Stepanenko on 5/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "P4RCBaseViewController.h"
#import "P4RCWaitView.h"
#import "P4RCBaseSplashView.h"


@interface P4RCBaseViewController ()

@property (nonatomic, readonly) P4RCWaitView *waitView;

@end


@implementation P4RCBaseViewController

@synthesize waitView,
            delegate;

- (void)dealloc
{
    delegate = nil;
    [waitView release];
    [super dealloc];
}

- (void)startWaiting:(BOOL)animated
{
    [[self waitView] showAnimated:animated parentView:[self view]];
}

- (void)stopWaiting:(BOOL)animated
{
    [[self waitView] hideAnimated:animated];
}

#pragma mark - Private

- (P4RCWaitView *)waitView
{
    if (waitView == nil)
    {
        waitView = [[P4RCWaitView alloc] init];
    }
    return waitView;
}

#pragma mark - P4RCBaseSplashViewDelegate

- (void)baseSplashViewDidPressClose:(P4RCBaseSplashView *)sender {
    [[self delegate] baseViewControllerDidPressClose:self];
}

@end
