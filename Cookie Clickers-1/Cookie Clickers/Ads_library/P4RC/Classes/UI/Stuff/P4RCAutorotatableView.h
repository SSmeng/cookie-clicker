//
//  P4RCAutorotatableView.h
//  P4RCIntegrationSample
//
//  Created by Artem Stepanenko on 5/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

@interface P4RCAutorotatableView : UIView

- (void)startAutorotate;
- (void)stopAutorotate;
- (void)update;
- (void)updateWithOrientation:(UIInterfaceOrientation)orientation;
- (void)orientationDidChange:(UIInterfaceOrientation)orientation;

@end
