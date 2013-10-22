//
//  P4RCForgetViewController.h
//  P4RCIntegrationSample
//
//  Created by Artem Stepanenko on 6/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "P4RCBaseViewController.h"


@class P4RCForgetViewController;

@protocol P4RCForgetViewControllerDelegate <P4RCBaseViewControllerDelegate>

- (void)forgetViewControllerDidSendPasswordSuccessfully:(P4RCForgetViewController *)sender;

@end


@class P4RCForgetView;

@interface P4RCForgetViewController : P4RCBaseViewController
{
    @private
    P4RCForgetView *forgetView;
}

@property (nonatomic, assign) id<P4RCForgetViewControllerDelegate> delegate;

@end
