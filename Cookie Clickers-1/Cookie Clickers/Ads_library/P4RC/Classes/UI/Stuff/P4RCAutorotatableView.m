//
//  P4RCAutorotatableView.m
//  P4RCIntegrationSample
//
//  Created by Artem Stepanenko on 5/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "P4RCAutorotatableView.h"


@interface P4RCAutorotatableView ()

- (void)willChangeStatusBarOrientation:(NSNotification *)notification;
- (void)didChangeStatusBarOrientation:(NSNotification *)notification;
- (UIInterfaceOrientation)orientationFromNotification:(NSNotification *)notification;

@end


@implementation P4RCAutorotatableView

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

- (void)startAutorotate
{
    [self update];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willChangeStatusBarOrientation:) name:UIApplicationWillChangeStatusBarOrientationNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeStatusBarOrientation:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
}

- (void)stopAutorotate
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillChangeStatusBarOrientationNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
}

- (void)update
{
    [self updateWithOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
}

- (void)updateWithOrientation:(UIInterfaceOrientation)orientation
{
    [self setTransform:CGAffineTransformIdentity];
    
    CGFloat screenWidth = [[self superview] frame].size.width;
    CGFloat screenHeight = [[self superview] frame].size.height;
    CGFloat width;
    CGFloat height;
    
    if (UIInterfaceOrientationIsLandscape(orientation))
    {
        width = screenWidth > screenHeight ? screenWidth : screenHeight;
        height = screenWidth > screenHeight ? screenHeight : screenWidth;
    }
    else
    {
        width = screenWidth > screenHeight ? screenHeight : screenWidth;
        height = screenWidth > screenHeight ? screenWidth : screenHeight;
    }
    
    CGRect rect = CGRectMake(0, 0, width, height);
    [self setFrame:rect];
    
	if (orientation == UIInterfaceOrientationLandscapeLeft)
	{
		[self setTransform:CGAffineTransformMakeRotation(-M_PI / 2)];
		[self setTransform:CGAffineTransformTranslate([self transform], -(rect.size.width - rect.size.height) / 2, -(rect.size.width - rect.size.height) / 2)];
	}
	else if (orientation == UIInterfaceOrientationLandscapeRight)
	{
		[self setTransform:CGAffineTransformMakeRotation(M_PI / 2)];
		[self setTransform:CGAffineTransformTranslate([self transform], (rect.size.width - rect.size.height) / 2, (rect.size.width - rect.size.height) / 2)];
	}
    else if (orientation == UIInterfaceOrientationPortrait)
    {
        [self setTransform:CGAffineTransformMakeRotation(0)];
    }
    else if (orientation == UIInterfaceOrientationPortraitUpsideDown)
    {
        [self setTransform:CGAffineTransformMakeRotation(M_PI)];
    }
}

- (void)orientationDidChange:(UIInterfaceOrientation)orientation
{
    // do nothing
}

#pragma mark - Private

- (void)willChangeStatusBarOrientation:(NSNotification *)notification
{
	[self updateWithOrientation:[self orientationFromNotification:notification]];
}

- (void)didChangeStatusBarOrientation:(NSNotification *)notification
{
    [self orientationDidChange:[self orientationFromNotification:notification]];
}

- (UIInterfaceOrientation)orientationFromNotification:(NSNotification *)notification
{
    NSDictionary *userInfoDictionary = [notification userInfo];
	return (UIInterfaceOrientation)[(NSNumber *)[userInfoDictionary objectForKey:UIApplicationStatusBarOrientationUserInfoKey] integerValue];
}

@end
