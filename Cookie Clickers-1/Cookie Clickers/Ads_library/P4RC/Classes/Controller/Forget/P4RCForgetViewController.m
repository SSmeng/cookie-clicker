//
//  P4RCForgetViewController.m
//  P4RCIntegrationSample
//
//  Created by Artem Stepanenko on 6/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "P4RCForgetViewController.h"
#import "P4RCForgetView.h"
#import "ServerGateway.h"
#import "P4RCUtils.h"

#define RESET_SUCCESS_ALERT_TAG         3012


@interface P4RCForgetViewController () <P4RCForgetViewDelegate, ReceiverProtocol, UIAlertViewDelegate>

@property (nonatomic, retain) P4RCForgetView *forgetView;

@end


@implementation P4RCForgetViewController

@synthesize forgetView;

@dynamic delegate;

- (void)dealloc
{
    [forgetView release];
    [super dealloc];
}

- (void)loadView
{
    [super loadView];
    [self setForgetView:[[[P4RCForgetView alloc] initWithFrame:[[self view] frame]] autorelease]];
    [[self forgetView] setDelegate:self];
    [self setView:[self forgetView]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[self forgetView] startAutorotate];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[self forgetView] stopAutorotate];
}

#pragma mark - P4RCForgetViewDelegate

- (void)forgetView:(P4RCForgetView *)sender didPressSubmitWithEmail:(NSString *)email
{
    if (IS_STRING_EMPTY(email) || ([P4RCUtils validateEmail:email] == NO))
    {
        [[[[UIAlertView alloc] initWithTitle:@"Error Message" message:@"Please enter Valid Email address." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] autorelease] show];
    }
    else
    {
        [self startWaiting:YES];
        [[ServerGateway sharedInstance] forgotPasswordWithEmail:email forReceiver:self];
    }
}

#pragma mark - ReceiverProtocol

- (void)forgotPasswordCompleteWithError:(NSError *)error
{
    [self stopWaiting:YES];
    
    UIAlertView *alertView;
    
    if (error != nil)
    {
        if ([error code] == 408)
        {
            alertView = [P4RCUtils internetIsNotAvailableAlert];
        }
        else
        {
            NSString *errorString = ([error code] == 101 ? @"Email Address does not exist in our system. Please try with another email address." : [error localizedDescription]);
            alertView = [[[UIAlertView alloc] initWithTitle:@"Error Message" message:errorString delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] autorelease];
        }
    }
    else
    {
        alertView = [[[UIAlertView alloc] initWithTitle:nil message:@"Password Reset e-mail has been sent to your registered email address. Please check your email account." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] autorelease];
        [alertView setTag:RESET_SUCCESS_ALERT_TAG];
    }
    [alertView show];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([alertView tag] == RESET_SUCCESS_ALERT_TAG)
    {
        [[self delegate] forgetViewControllerDidSendPasswordSuccessfully:self];
    }
}

@end
