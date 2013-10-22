//
//  P4RCTextField.m
//  P4RCIntegrationSample
//
//  Created by Artem Stepanenko on 5/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "P4RCTextField.h"


@implementation P4RCTextField

@synthesize sideTextIndent;

- (CGRect)textRectForBounds:(CGRect)bounds
{
    return CGRectMake(sideTextIndent, bounds.origin.y, bounds.size.width - 2 * sideTextIndent, bounds.size.height);
}

- (CGRect)placeholderRectForBounds:(CGRect)bounds
{
    return [self textRectForBounds:bounds];
}

- (CGRect)editingRectForBounds:(CGRect)bounds
{
    return [self textRectForBounds:bounds];
}

@end
