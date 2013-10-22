//
//  P4RCSignInViewController.m
//  P4RCIntegrationSample
//
//  Created by Artem Stepanenko on 5/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "P4RCSignInViewController.h"
#import "P4RCSignInView.h"
#import "ServerGateway.h"
#import "P4RCUtils.h"
#import "P4RCCacheManager.h"

#define SUCCESS_ALERT_TAG       5010
#define FAILED_ALERT_TAG        5011


@interface P4RCSignInViewController () <P4RCSignInViewDelegate, ReceiverProtocol>

@property (nonatomic, retain) P4RCSignInView *signInView;

@end


@implementation P4RCSignInViewController

@synthesize signInView;
@dynamic delegate;

- (void)dealloc
{
    [signInView release];
    [super dealloc];
}

- (void)loadView
{
    [super loadView];
    [self setSignInView:[[[P4RCSignInView alloc] initWithFrame:[[self view] frame]] autorelease]];
    [[self signInView] setDelegate:self];
    [self setView:[self signInView]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[self signInView] startAutorotate];
    [[self signInView] clearFields];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[self signInView] stopAutorotate];
}

- (void)viewDidUnload
{
    [self setSignInView:nil];
    [super viewDidUnload];
}

#pragma mark - P4RCSignInViewDelegate

- (void)signInView:(P4RCSignInView *)sender signInDidPressWithUsername:(NSString *)username password:(NSString *)password
{
    if (IS_STRING_EMPTY(username))
    {
        [[[[UIAlertView alloc] initWithTitle:@"Error Message" message:@"Please enter Email." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] autorelease] show];
    }
    else if (IS_STRING_EMPTY(password))
    {
        [[[[UIAlertView alloc] initWithTitle:@"Error Message" message:@"Please enter password." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] autorelease] show];
    }
    else
    {
        [self startWaiting:YES];
        [[ServerGateway sharedInstance] signInWithUsername:NOT_NIL_STRING(username) password:NOT_NIL_STRING(password) forReceiver:self];
    }
}

- (void)signInViewDidPressSignUp:(P4RCSignInView *)sender
{
    // TODO
    [[self delegate] signInViewControllerDidPressSignUp:self];
}

- (void)signInViewDidPressReset:(P4RCSignInView *)sender
{
    [[self delegate] signInViewControllerDidPressReset:self];
}

#pragma mark - ReceiverProtocol

- (void)signingInCompleteWithSuccess:(BOOL)success sessionToken:(NSString *)token authStatus:(NSInteger)status userInfo:(P4RCUserInfo *)userInfo error:(NSError *)error
{
    [self stopWaiting:YES];
    
    if (error == nil)
    {
        [[self delegate] signInViewController:self didReceiveUserInfo:userInfo];
        
        NSString *encodedSessionId = [token stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [P4RCCacheManager setSessionId:encodedSessionId];
        [P4RCCacheManager setCookieWithSessionId:encodedSessionId];
        
        [[self delegate] signInViewControllerDidAuthorize:self];
    }
    else
    {
        UIAlertView *alertView;
        if ([error code] == 408)
        {
            alertView = [P4RCUtils internetIsNotAvailableAlert];
        }
        else
        {
            alertView = [[[UIAlertView alloc] initWithTitle:@"Error Message" message:[error localizedDescription] delegate:self cancelButtonTitle:@"Close" otherButtonTitles:@"Retry", nil] autorelease];
        }
        [alertView setTag:FAILED_ALERT_TAG];
        [alertView show];
    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([alertView tag] == FAILED_ALERT_TAG)
    {
        if (buttonIndex == 0)
        {
            [[self delegate] signInViewControllerDidPressClose:self];
        }
        else if (buttonIndex == 1)
        {
            // do nothing
        }
    }
}

@end
