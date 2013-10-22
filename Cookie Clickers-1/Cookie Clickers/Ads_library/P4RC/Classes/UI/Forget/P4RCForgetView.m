//
//  P4RCForgetView.m
//  P4RCIntegrationSample
//
//  Created by Artem Stepanenko on 6/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "P4RCForgetView.h"

#define MARGIN                  10
#define TEXT_FIELD_HEIGHT       36


@interface P4RCForgetView () <UITextFieldDelegate>

@end


@implementation P4RCForgetView

@dynamic delegate;

- (void)dealloc
{
    [hintLabel release];
    [emailTextField release];
    [submitButton release];
    [super dealloc];
}

- (id)initWithFrame:(CGRect)theFrame
{
    self = [super initWithFrame:theFrame];
    if (self)
    {
        // hint
        hintLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [hintLabel setText:@"Enter your email address below and we'll send you instructions on how to reset your password.\nEmail Address"];
        [hintLabel setFont:[UIFont systemFontOfSize:14]];
        [hintLabel setBackgroundColor:[UIColor clearColor]];
        [hintLabel setNumberOfLines:0];
        [scrollView addSubview:hintLabel];
        // field back
        UIImage *textFieldImage = [UIImage imageNamed:@"P4RC.bundle/blue_box.png"];
        // email field
        emailTextField = [[P4RCTextField alloc] initWithFrame:CGRectZero];
        [emailTextField setSideTextIndent:MARGIN];
        [emailTextField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
        [emailTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
        [emailTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
        [emailTextField setClearButtonMode:UITextFieldViewModeWhileEditing];
        [emailTextField setDelegate:self];
        [emailTextField setReturnKeyType:UIReturnKeyDone];
        [emailTextField setBackground:textFieldImage];
        [emailTextField setPlaceholder:@"e-mail"];
        [scrollView addSubview:emailTextField];
        // button back image
        UIImage *buttonBackImage = [UIImage imageNamed:@"P4RC.bundle/main_menu_view_account_button.png"];
        // submit
        submitButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
        [submitButton setBackgroundImage:buttonBackImage forState:UIControlStateNormal];
        [[submitButton titleLabel] setFont:[UIFont systemFontOfSize:12]];
        [submitButton setFrame:CGRectMake(0, 0, [buttonBackImage size].width, [buttonBackImage size].height)];
        [submitButton setTitle:@"Submit" forState:UIControlStateNormal];
        [[submitButton titleLabel] setTextColor:[UIColor whiteColor]];
        [submitButton addTarget:self action:@selector(submitDidPress:) forControlEvents:UIControlEventTouchUpInside];
        [scrollView addSubview:submitButton];
    }
    return self;
}

- (void)updateWithOrientation:(UIInterfaceOrientation)orientation
{
    [super updateWithOrientation:orientation];
    
    CGFloat width = [self bounds].size.width;
    // hint
    [hintLabel setFrame:CGRectMake(0, 0, width - MARGIN * 2, 0)];
    [hintLabel sizeToFit];
    [hintLabel setFrame:CGRectMake(MARGIN, MARGIN, [hintLabel bounds].size.width, [hintLabel bounds].size.height)];
    // email field
    [emailTextField setFrame:CGRectMake(MARGIN, [hintLabel frame].origin.y + [hintLabel bounds].size.height + MARGIN, width - MARGIN * 2, TEXT_FIELD_HEIGHT)];
    // submit
    [submitButton setFrame:CGRectMake(width - [submitButton bounds].size.width - MARGIN, [emailTextField frame].origin.y + [emailTextField bounds].size.height + MARGIN, [submitButton bounds].size.width, [submitButton bounds].size.height)];
    
    [self setScrollContentHeight:([submitButton frame].origin.y + [submitButton frame].size.height + MARGIN)];
    [self updateScrollOffsetForOrientation:orientation];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [emailTextField resignFirstResponder];
    return NO;
}

#pragma mark - Protected

- (BOOL)isAnyTextFieldEditing
{
    return [emailTextField isEditing];
}

#pragma mark - Private

- (void)submitDidPress:(id)sender
{
    [emailTextField resignFirstResponder];
    [[self delegate] forgetView:self didPressSubmitWithEmail:[emailTextField text]];
}

@end
