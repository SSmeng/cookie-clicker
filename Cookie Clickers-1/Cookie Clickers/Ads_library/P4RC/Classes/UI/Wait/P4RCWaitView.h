//
//  P4RCWaitView.h
//  P4RCIntegrationSample
//
//  Created by Artem Stepanenko on 5/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

@interface P4RCWaitView : UIView
{
    @private
    UIActivityIndicatorView *activityIndicatorView;
}

- (void)showAnimated:(BOOL)animated parentView:(UIView *)parentView;
- (void)hideAnimated:(BOOL)animated;

@end
