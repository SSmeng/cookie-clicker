//
//  P4RCSignUpViewController.m
//  P4RCIntegrationSample
//
//  Created by Artem Stepanenko on 5/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "P4RCSignUpViewController.h"
#import "P4RCSignUpView.h"
#import "ServerGateway.h"
#import "P4RCUtils.h"

#define SUCCESS_ALERT_TAG       6010
#define FAILED_ALERT_TAG        6011


@interface P4RCSignUpViewController () <P4RCSignUpViewDelegate, UIAlertViewDelegate, ReceiverProtocol>

@property (nonatomic, retain) P4RCSignUpView *signUpView;

@end


@implementation P4RCSignUpViewController

@synthesize signUpView;
@dynamic delegate;

- (void)dealloc
{
    [signUpView release];
    [super dealloc];
}

- (void)loadView
{
    [super loadView];
    [self setSignUpView:[[[P4RCSignUpView alloc] initWithFrame:[[self view] frame]] autorelease]];
    [[self signUpView] setDelegate:self];
    [self setView:[self signUpView]];
}

- (void)viewDidUnload
{
    [self setSignUpView:nil];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[self signUpView] startAutorotate];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[self signUpView] stopAutorotate];
}

#pragma mark - P4RCSignUpViewDelegate

- (void)signUpView:(P4RCSignUpView *)sender signUpDidPressWithFirstName:(NSString *)firstName lastName:(NSString *)lastName email:(NSString *)email confirmedEmail:(NSString *)confirmedEmail password:(NSString *)password verifiedPassword:(NSString *)verifiedPassword acceptedTerms:(BOOL)acceptedTerms
{
    if (IS_STRING_EMPTY(firstName))
    {
        [[[[UIAlertView alloc] initWithTitle:@"Error Message" message:@"Please enter First Name." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] autorelease] show];
    }
    else if (IS_STRING_EMPTY(lastName))
    {
        [[[[UIAlertView alloc] initWithTitle:@"Error Message" message:@"Please enter Last Name." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] autorelease] show];
    }
    else if (IS_STRING_EMPTY(email))
    {
        [[[[UIAlertView alloc] initWithTitle:@"Error Message" message:@"Please enter Email address." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] autorelease] show];
    }
    else if (IS_STRING_EMPTY(confirmedEmail))
    {
        [[[[UIAlertView alloc] initWithTitle:@"Error Message" message:@"Please enter Confirm email address." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] autorelease] show];
    }
    else if ([email isEqualToString:confirmedEmail] == NO)
    {
        [[[[UIAlertView alloc] initWithTitle:@"Error Message" message:@"Email addresses do not match." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] autorelease] show];
    }
    else if (IS_STRING_EMPTY(password))
    {
        [[[[UIAlertView alloc] initWithTitle:@"Error Message" message:@"Please enter Password." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] autorelease] show];
    }
    else if ([password length] < 6)
    {
        [[[[UIAlertView alloc] initWithTitle:@"Error Message" message:@"Password is too short. It should be at least 6 characters long." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] autorelease] show];
    }
    else if (IS_STRING_EMPTY(verifiedPassword))
    {
        [[[[UIAlertView alloc] initWithTitle:@"Error Message" message:@"Please enter Verify Password." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] autorelease] show];
    }
    else if ([password isEqualToString:verifiedPassword] == NO)
    {
        [[[[UIAlertView alloc] initWithTitle:@"Error Message" message:@"Passwords do not match." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] autorelease] show];
    }
    else if (acceptedTerms == NO)
    {
        [[[[UIAlertView alloc] initWithTitle:@"Error Message" message:@"Please accept terms and conditions." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] autorelease] show];
    }
    else
    {
        [self startWaiting:YES];
        [[ServerGateway sharedInstance] signUpUserWithFirstName:NOT_NIL_STRING(firstName) lastName:NOT_NIL_STRING(lastName) password:NOT_NIL_STRING(password) email:NOT_NIL_STRING(email) userAcceptedTerms:acceptedTerms forReceiver:self];
    }
}

- (void)signUpViewDidPressCancel:(P4RCSignUpView *)sender
{
    [[self delegate] signUpViewControllerDidPressCancel:self];
}

- (void)signUpViewDidPressTermsAndConditions:(P4RCSignUpView *)sender
{
    [[self delegate] signUpViewControllerDidPressTermsAndConditions:self];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([alertView tag] == FAILED_ALERT_TAG)
    {
        if (buttonIndex == 0)
        {
            [[self delegate] signUpViewControllerDidFailRegistration:self];
        }
        else if (buttonIndex == 1)
        {
            // do nothing
        }
    }
}

#pragma mark - ReceiverProtocol

- (void)signingUpCompleteWithSuccess:(BOOL)success userInfo:(P4RCUserInfo *)userInfo error:(NSError *)error
{
    [self stopWaiting:YES];
    
    if (error == nil)
    {
        [[self delegate] signUpViewControllerDidRegister:self];
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
            alertView = [[[UIAlertView alloc] initWithTitle:@"Registration was failed" message:[error localizedDescription] delegate:self cancelButtonTitle:@"Close" otherButtonTitles:@"Retry", nil] autorelease];
        }
        [alertView setTag:FAILED_ALERT_TAG];
        [alertView show];
    }
}

@end
