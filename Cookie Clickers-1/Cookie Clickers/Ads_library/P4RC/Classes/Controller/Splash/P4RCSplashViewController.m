//
//  P4RCSplashViewController.m
//  P4RCIntegrationSample
//
//  Created by Artem Stepanenko on 5/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "P4RCSplashViewController.h"
#import "P4RCSplashView.h"
#import "P4RCUserInfo.h"
#import "P4RCCacheManager.h"
#import "P4RCUtils.h"
#import "FacebookSDK.h"


@interface P4RCSplashViewController () <P4RCSplashViewDelegate>

@property (nonatomic, retain) P4RCSplashView *splashView;

@end

@implementation P4RCSplashViewController

@synthesize splashView;
@dynamic delegate;

- (void)dealloc
{
    [splashView release];
    [super dealloc];
}

- (void)loadView
{
    [super loadView];
    [self setSplashView:[[[P4RCSplashView alloc] initWithFrame:[[self view] frame]] autorelease]];
    [[self splashView] setDelegate:self];
    [self setView:[self splashView]];
}

- (void)viewDidUnload
{
    [self setSplashView:nil];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[self splashView] startAutorotate];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[self splashView] stopAutorotate];
}

#pragma mark - P4RCSplashViewDelegate

- (void)splashViewDidPressFacebook:(P4RCSplashView *)sender userAcceptedTerms:(BOOL)userAcceptedTerms
{

    if (userAcceptedTerms == YES)
    {
        [[FBSession activeSession] closeAndClearTokenInformation];

        NSArray *permissions = [[NSArray alloc] initWithObjects:
                                @"email",
                                @"publish_stream",
                                nil];
        FBSession *fbSession = [[FBSession alloc] initWithPermissions:permissions];
        [FBSession setActiveSession:fbSession];
        [fbSession release];
        [permissions release];
        
        [[FBSession activeSession] openWithBehavior:FBSessionLoginBehaviorForcingWebView completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
            switch (status) {
                case FBSessionStateOpen:
                    [[ServerGateway sharedInstance] signInUserWithFBAccessToken:[[FBSession activeSession] accessToken]  andExpirationDate:[[FBSession activeSession] expirationDate] forReceiver:self];
                    
                    break;
                case FBSessionStateClosedLoginFailed:
                    if ([[error.userInfo objectForKey:@"com.facebook.sdk:ErrorLoginFailedReason"] rangeOfString:@"ErrorLoginNotCancelled"].location != NSNotFound ) {
                        [[P4RCUtils internetIsNotAvailableAlert] show];
                    }
                    [[FBSession activeSession] closeAndClearTokenInformation];
                    break;
                default:
                    break;
            }
        }];
        
    }
    else
    {
        [[[[UIAlertView alloc] initWithTitle:@"Error Message" message:@"Please accept terms and conditions." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] autorelease] show];
    }
}

- (void)splashViewDidPressNoThanks:(P4RCSplashView *)sender
{
    [[self delegate] splashViewControllerDidPressNoThanks:self];
}

- (void)splashViewDidPressNotAFacebookUserDidPress:(P4RCSplashView *)sender
{
    [[self delegate] splashViewControllerDidPressNotAFacebookUser:self];
}

- (void)splashViewDidPressTermsAndConditions:(P4RCSplashView *)sender
{
    [[self delegate] splashViewControllerDidPressTermsAndConditions:self];
}

#pragma mark - ReceiverProtocol

- (void)signingInCompleteWithSuccess:(BOOL)success sessionToken:(NSString *)token authStatus:(NSInteger)status userInfo:(P4RCUserInfo *)userInfo error:(NSError *)error
{
    [[self delegate] splashViewController:self didAuthorizeViaFacebookWithUserInfo:userInfo sessionId:token error:error];
}

@end
