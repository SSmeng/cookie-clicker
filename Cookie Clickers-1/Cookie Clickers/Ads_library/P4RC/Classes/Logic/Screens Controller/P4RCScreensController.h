//
//  P4RCScreensController.h
//  P4RCIntegrationSample
//
//  Created by Artem Stepanenko on 5/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

@class P4RCScreensController;
@class P4RCSplashViewController;
@class P4RCUserInfo;

@protocol P4RCScreensControllerDelegate

- (void)screensController:(P4RCScreensController *)sender didAuthizeWithUserInfo:(P4RCUserInfo *)userInfo;

@end

@class P4RCSplashViewController;

@interface P4RCScreensController : NSObject
{
    UIView *backView;
    UINavigationController *navigationController;
    P4RCSplashViewController *splashViewController;
    
    id<P4RCScreensControllerDelegate> delegate;
}

@property (nonatomic, readonly) P4RCSplashViewController *splashViewController;
@property (nonatomic, assign) id<P4RCScreensControllerDelegate> delegate;

- (void)showSplash;

@end
