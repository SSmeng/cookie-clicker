//
//  P4RCBaseViewController.h
//  P4RCIntegrationSample
//
//  Created by Artem Stepanenko on 5/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "P4RCBaseSplashView.h"

@class P4RCBaseViewController;

@protocol P4RCBaseViewControllerDelegate

- (void)baseViewControllerDidPressClose:(P4RCBaseViewController *)sender;

@end


@class P4RCWaitView;

@interface P4RCBaseViewController : UIViewController <P4RCBaseSplashViewDelegate>
{
    @private
    P4RCWaitView *waitView;
    id<P4RCBaseViewControllerDelegate> delegate;
}

@property (nonatomic, assign) id<P4RCBaseViewControllerDelegate> delegate;

- (void)startWaiting:(BOOL)animated;
- (void)stopWaiting:(BOOL)animated;

@end
