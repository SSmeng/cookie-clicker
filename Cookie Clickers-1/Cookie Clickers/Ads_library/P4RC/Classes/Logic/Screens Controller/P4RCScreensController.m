//
//  P4RCScreensController.m
//  P4RCIntegrationSample
//
//  Created by Artem Stepanenko on 5/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "P4RCScreensController.h"
#import "P4RCSplashViewController.h"
#import "P4RCSignInViewController.h"
#import "P4RCSignUpViewController.h"
#import "P4RCForgetViewController.h"
#import "P4RCTermsViewController.h"
#import "P4RCCacheManager.h"
#import "P4RCCacheManager.h"
#import "P4RCUtils.h"
#import "P4RCSplashBackView.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImage+Retina4.h"

#define SPLASH_WIDTH        320
#define SPLASH_HEIGHT       480

#define FB_ALERT_TAG        10001

@interface P4RCScreensController () <P4RCSplashViewControllerDelegate, P4RCSignInViewControllerDelegate, P4RCSignUpViewControllerDelegate, P4RCForgetViewControllerDelegate, P4RCForgetViewControllerDelegate, P4RCTermsViewControllerDelegate>

@property (nonatomic, retain) P4RCSplashBackView *splashBackView;

- (void)pushTermsAndConditions;
- (void)close;

@end


@implementation P4RCScreensController

@synthesize splashViewController;
@synthesize splashBackView;
@synthesize delegate;

- (void)dealloc
{
    [splashBackView release];
    delegate = nil;
    [backView release];
    [splashViewController release];
    [navigationController release];
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self)
    {
        CGFloat width = [[[UIApplication sharedApplication] keyWindow] bounds].size.width;
        CGFloat height = [[[UIApplication sharedApplication] keyWindow] bounds].size.height;
        
        splashViewController = [[P4RCSplashViewController alloc] init];
        [splashViewController setDelegate:self];
        navigationController = [[UINavigationController alloc] initWithRootViewController:splashViewController];
        [[navigationController view] setClipsToBounds:YES];
        [[navigationController view] setFrame:CGRectMake((width - SPLASH_WIDTH) / 2, (height - SPLASH_HEIGHT) / 2, 
                                                         SPLASH_WIDTH, SPLASH_HEIGHT)];
                
        [[navigationController view] setBackgroundColor:[UIColor whiteColor]];
        [navigationController setNavigationBarHidden:YES];
        backView = [[UIView alloc] init];
        backView.userInteractionEnabled = YES;
        [backView setBackgroundColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:0.6f]];
        [backView setFrame:CGRectMake(0, 0, width, height)];
        
        UIImage *image = [UIImage imageNamed:@"P4RC.bundle/splash_back.png"];
        if (([P4RCUtils deviceType] == P4RCDeviceTypeIPhone) || ([P4RCUtils deviceType] == P4RCDeviceTypeIPhone5))
        {
            image = [UIImage imageWithCGImage:image.CGImage scale:image.scale orientation:UIImageOrientationRight];
        }
        UIImageView *backImageView = [[UIImageView alloc] initWithImage:image];
        [backImageView setFrame:[backView bounds]];
        [backView addSubview:backImageView];
        [backImageView release];
        
        if ([P4RCUtils deviceType] == P4RCDeviceTypeIPad)
        {
            self.splashBackView = [[[P4RCSplashBackView alloc] initWithFrame:[backView bounds]] autorelease];
            [backView addSubview:self.splashBackView];
        }
        
        [backView addSubview:[navigationController view]];
    }
    return self;
}

- (void)showSplash
{
    [[[UIApplication sharedApplication] keyWindow] addSubview:backView];
    [self.splashBackView startAutorotate];
}

#pragma mark - P4RCSplashViewControllerDelegate

- (void)splashViewControllerDidPressNoThanks:(P4RCSplashViewController *)sender
{
    [self close];
}

- (void)splashViewControllerDidPressNotAFacebookUser:(P4RCSplashViewController *)sender
{
    P4RCSignInViewController *signInViewController = [[P4RCSignInViewController alloc] init];
    [signInViewController setDelegate:self];
    [navigationController pushViewController:signInViewController animated:YES];
    [signInViewController release];
}

- (void)splashViewController:(P4RCSplashViewController *)sender didAuthorizeViaFacebookWithUserInfo:(P4RCUserInfo *)userInfo sessionId:(NSString *)sessionId error:(NSError *)error
{
    if (error == nil)
    {
        [[self delegate] screensController:self didAuthizeWithUserInfo:userInfo];
        
        NSString *encodedSessionId = [sessionId stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [P4RCCacheManager setSessionId:encodedSessionId];
        [P4RCCacheManager setCookieWithSessionId:encodedSessionId];
        
        [self close];
    }
    else
    {
        if ([error code] == 408)
        {
            [[P4RCUtils internetIsNotAvailableAlert] show];
        }
        else
        {
            [[[[UIAlertView alloc] initWithTitle:@"Error Message" message:[error localizedDescription] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] autorelease] show];
        }
    }
}

- (void)splashViewControllerDidPressTermsAndConditions:(P4RCSplashViewController *)sender
{
    [self pushTermsAndConditions];
}

#pragma mark - P4RCSignInViewControllerDelegate

- (void)signInViewControllerDidAuthorize:(P4RCSignInViewController *)sender
{
    [self close];
}

- (void)signInViewController:(P4RCSignInViewController *)sender didReceiveUserInfo:(P4RCUserInfo *)userInfo
{
    [[self delegate] screensController:self didAuthizeWithUserInfo:userInfo];
}

- (void)signInViewControllerDidPressSignUp:(P4RCSignInViewController *)sender
{
    P4RCSignUpViewController *signUpViewController = [[P4RCSignUpViewController alloc] init];
    [signUpViewController setDelegate:self];
    [navigationController pushViewController:signUpViewController animated:YES];
    [signUpViewController release];
}

- (void)signInViewControllerDidPressReset:(P4RCSignInViewController *)sender
{
    P4RCForgetViewController *forgetViewController = [[P4RCForgetViewController alloc] init];
    [forgetViewController setDelegate:self];
    [navigationController pushViewController:forgetViewController animated:YES];
    [forgetViewController release];
}

- (void)signInViewControllerDidPressClose:(P4RCSignInViewController *)sender
{
    [navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - P4RCSignUpViewControllerDelegate

- (void)signUpViewControllerDidPressCancel:(P4RCSignUpViewController *)sender
{
    [navigationController popViewControllerAnimated:YES];
}

- (void)signUpViewControllerDidRegister:(P4RCSignUpViewController *)sender
{
    [navigationController popViewControllerAnimated:YES];
}

- (void)signUpViewControllerDidFailRegistration:(P4RCSignUpViewController *)sender
{
    [navigationController popViewControllerAnimated:YES];
}

- (void)signUpViewControllerDidPressTermsAndConditions:(P4RCSignUpViewController *)sender
{
    [self pushTermsAndConditions];
}

#pragma mark - P4RCBaseViewControllerDelegate

- (void)baseViewControllerDidPressClose:(P4RCBaseViewController *)sender
{
    [self close];
}

#pragma mark - P4RCForgetViewControllerDelegate

- (void)forgetViewControllerDidSendPasswordSuccessfully:(P4RCForgetViewController *)sender
{
    [navigationController popViewControllerAnimated:YES];
}

#pragma mark - P4RCTermsViewControllerDelegate

- (void)termsViewControllerDidPressSignUp:(P4RCTermsViewController *)sender
{
    [navigationController popViewControllerAnimated:YES];
}

#pragma mark - Private

- (void)pushTermsAndConditions
{
    P4RCTermsViewController *termsViewController = [[P4RCTermsViewController alloc] init];
    [termsViewController setDelegate:self];
    [navigationController pushViewController:termsViewController animated:YES];
    [termsViewController release];
}

- (void)close
{
    [self.splashBackView stopAutorotate];
    [navigationController popToRootViewControllerAnimated:NO];
    [backView removeFromSuperview];
}

@end
