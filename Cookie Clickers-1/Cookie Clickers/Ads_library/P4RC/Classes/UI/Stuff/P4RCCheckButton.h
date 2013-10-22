//
//  P4RCCheckButton.h
//  P4RCIntegrationSample
//
//  Created by Artem Stepanenko on 5/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

@interface P4RCCheckButton : UIButton
{
    @private
    BOOL checked;
}

@property (nonatomic, assign, getter = isChecked) BOOL checked;

@end
