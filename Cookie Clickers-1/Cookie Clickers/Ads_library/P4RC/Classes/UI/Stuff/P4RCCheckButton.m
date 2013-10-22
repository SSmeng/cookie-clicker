//
//  P4RCCheckButton.m
//  P4RCIntegrationSample
//
//  Created by Artem Stepanenko on 5/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "P4RCCheckButton.h"


@interface P4RCCheckButton ()

- (void)update;
- (void)touchUpInside;

@end


@implementation P4RCCheckButton

@synthesize checked;

- (id)initWithFrame:(CGRect)theFrame
{
    self = [super initWithFrame:theFrame];
    if (self)
    {
        [self setChecked:NO];
        [self addTarget:self action:@selector(touchUpInside) forControlEvents:UIControlEventTouchUpInside];
        
        [self setAdjustsImageWhenHighlighted:NO];
    }
    return self;
}

- (void)setChecked:(BOOL)flag
{
    checked = flag;
    [self update];
}

#pragma mark - Private

- (void)update
{
    UIImage *backImage = [UIImage imageNamed:([self isChecked] ? @"P4RC.bundle/check_box_checked.png" : @"P4RC.bundle/check_box_unchecked.png")];
    [self setFrame:CGRectMake([self frame].origin.x, [self frame].origin.y, [backImage size].width + 10, [backImage size].height + 10)];
    [self setImage:backImage forState:UIControlStateNormal];
}

- (void)touchUpInside
{
    [self setChecked:([self isChecked] == NO)];
}

@end
