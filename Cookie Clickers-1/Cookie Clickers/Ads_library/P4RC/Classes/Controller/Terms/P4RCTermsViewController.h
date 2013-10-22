//
//  P4RCTermsViewController.h
//  P4RCIntegrationSample
//
//  Created by Artem Stepanenko on 6/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "P4RCBaseViewController.h"


@class P4RCTermsViewController;

@protocol P4RCTermsViewControllerDelegate <P4RCBaseViewControllerDelegate>

- (void)termsViewControllerDidPressSignUp:(P4RCTermsViewController *)sender;

@end


@class P4RCTermsView;


@interface P4RCTermsViewController : P4RCBaseViewController
{
    @private
    P4RCTermsView *termsView;
}

@property (nonatomic, assign) id<P4RCTermsViewControllerDelegate> delegate;

@end
