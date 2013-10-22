//
//  P4RCSignInView.m
//  P4RCIntegrationSample
//
//  Created by Artem Stepanenko on 5/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "P4RCSignInView.h"
#import "P4RCTextField.h"

#define MARGIN                  10
#define TEXT_FIELD_HEIGHT       36
#define BUTTON_WIDTH            150


@interface P4RCSignInView ()

- (void)signInDidPress:(id)sender;
- (void)signUpDidPress:(id)sender;
- (void)resetDidPress:(id)sender;

@end


@implementation P4RCSignInView

@dynamic delegate;

- (void)dealloc
{
    [selectedTextField release];
    [forgetLabel release];
    [resetButton release];
    [usernameTextField release];
    [passwordTextField release];
    [signInButton release];
    [signUpButton release];
    [firstLineHintLabel release];
    [secondLineHintLabel release];
    [super dealloc];
}

- (id)initWithFrame:(CGRect)theFrame
{
    self = [super initWithFrame:theFrame];
    if (self)
    {
        UIImage *textFieldImage = [UIImage imageNamed:@"P4RC.bundle/blue_box.png"];
        // hint
        hintLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [hintLabel setText:@"Log-in to P4RC"];
        [hintLabel setFont:[UIFont boldSystemFontOfSize:14]];
        [hintLabel setBackgroundColor:[UIColor clearColor]];
        [scrollView addSubview:hintLabel];
        // username
        usernameTextField = [[P4RCTextField alloc] initWithFrame:CGRectZero];
        [usernameTextField setSideTextIndent:MARGIN];
        [usernameTextField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
        [usernameTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
        [usernameTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
        [usernameTextField setClearButtonMode:UITextFieldViewModeWhileEditing];
        [usernameTextField setDelegate:self];
        [usernameTextField setReturnKeyType:UIReturnKeyNext];
        [usernameTextField setBackground:textFieldImage];
        [usernameTextField setPlaceholder:@"e-mail"];
        [scrollView addSubview:usernameTextField];
        // password
        passwordTextField = [[P4RCTextField alloc] initWithFrame:CGRectZero];
        [passwordTextField setSideTextIndent:MARGIN];
        [passwordTextField setSecureTextEntry:YES];
        [passwordTextField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
        [passwordTextField setSecureTextEntry:YES];
        [passwordTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
        [passwordTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
        [passwordTextField setClearButtonMode:UITextFieldViewModeWhileEditing];
        [passwordTextField setDelegate:self];
        [passwordTextField setReturnKeyType:UIReturnKeyDone];
        [passwordTextField setBackground:textFieldImage];
        [passwordTextField setPlaceholder:@"Password"];
        [scrollView addSubview:passwordTextField];
        // button back image
        UIImage *buttonBackImage = [UIImage imageNamed:@"P4RC.bundle/main_menu_view_account_button.png"];
        // sign in
        signInButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
        [signInButton setBackgroundImage:buttonBackImage forState:UIControlStateNormal];
        [[signInButton titleLabel] setFont:[UIFont systemFontOfSize:12]];
        [signInButton setFrame:CGRectMake(0, 0, [buttonBackImage size].width, [buttonBackImage size].height)];
        [signInButton setTitle:@"Sign In" forState:UIControlStateNormal];
        [[signInButton titleLabel] setTextColor:[UIColor whiteColor]];
        [signInButton addTarget:self action:@selector(signInDidPress:) forControlEvents:UIControlEventTouchUpInside];
        [scrollView addSubview:signInButton];
        // hint 1
        firstLineHintLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [firstLineHintLabel setText:@"Don't have a P4RC Account?"];
        [firstLineHintLabel setBackgroundColor:[UIColor clearColor]];
        [firstLineHintLabel setFont:[UIFont boldSystemFontOfSize:14]];
        [scrollView addSubview:firstLineHintLabel];
        // hint 2
        secondLineHintLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [secondLineHintLabel setText:@"Signing up is easy."];
        [secondLineHintLabel setBackgroundColor:[UIColor clearColor]];
        [secondLineHintLabel setFont:[UIFont boldSystemFontOfSize:14]];
        [scrollView addSubview:secondLineHintLabel];
        // sign up
        signUpButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
        [[signUpButton titleLabel] setFont:[UIFont boldSystemFontOfSize:14]];
        [signUpButton setTitle:@"Sign Up." forState:UIControlStateNormal];
        [signUpButton setTitleColor:[UIColor colorWithRed:0.24f green:0.67f blue:0.75f alpha:1] forState:UIControlStateNormal];
        [signUpButton setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
        [signUpButton addTarget:self action:@selector(signUpDidPress:) forControlEvents:UIControlEventTouchUpInside];
        [scrollView addSubview:signUpButton];
        // forget
        forgetLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [forgetLabel setText:@"Forgot your username or password?"];
        [forgetLabel setBackgroundColor:[UIColor clearColor]];
        [forgetLabel setFont:[UIFont systemFontOfSize:14]];
        [scrollView addSubview:forgetLabel];
        // reset
        resetButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
        [[resetButton titleLabel] setTextAlignment:UITextAlignmentLeft];
        [[resetButton titleLabel] setFont:[UIFont boldSystemFontOfSize:14]];
        [resetButton setTitle:@"Reset it here" forState:UIControlStateNormal];
        [resetButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [resetButton setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
        [resetButton addTarget:self action:@selector(resetDidPress:) forControlEvents:UIControlEventTouchUpInside];
        [scrollView addSubview:resetButton];
    }
    return self;
}

- (void)clearFields
{
    [usernameTextField setText:@""];
    [passwordTextField setText:@""];
}

- (void)updateWithOrientation:(UIInterfaceOrientation)orientation
{
    [super updateWithOrientation:orientation];
    
    // hint
    [hintLabel sizeToFit];
    [hintLabel setFrame:CGRectMake(MARGIN, MARGIN, [hintLabel bounds].size.width, [hintLabel bounds].size.height)];
    // username
    [usernameTextField setFrame:CGRectMake(MARGIN, [hintLabel frame].origin.y + [hintLabel bounds].size.height, [self bounds].size.width - 2 * MARGIN, TEXT_FIELD_HEIGHT)];
    // password
    [passwordTextField setFrame:CGRectMake(MARGIN, [usernameTextField frame].origin.y + [usernameTextField frame].size.height + MARGIN, [usernameTextField bounds].size.width, [usernameTextField frame].size.height)];
    // sign in
    [signInButton setFrame:CGRectMake(MARGIN, [passwordTextField frame].origin.y + [passwordTextField frame].size.height + MARGIN * 2, [signInButton bounds].size.width, [signInButton bounds].size.height)];
    // hint 1
    [firstLineHintLabel sizeToFit];
    [firstLineHintLabel setFrame:CGRectMake([usernameTextField frame].origin.x + [usernameTextField frame].size.width - [firstLineHintLabel bounds].size.width, [signInButton frame].origin.y, [firstLineHintLabel bounds].size.width, [firstLineHintLabel bounds].size.height)];
    // hint 2
    [secondLineHintLabel sizeToFit];
    [secondLineHintLabel setFrame:CGRectMake([firstLineHintLabel frame].origin.x, [firstLineHintLabel frame].origin.y + [firstLineHintLabel frame].size.height, [secondLineHintLabel bounds].size.width, [secondLineHintLabel bounds].size.height)];
    // sign up
    [signUpButton setFrame:CGRectMake([secondLineHintLabel frame].origin.x + [secondLineHintLabel frame].size.width, [secondLineHintLabel frame].origin.y, 70, [secondLineHintLabel bounds].size.height)];
    // forget
    [forgetLabel sizeToFit];
    [forgetLabel setFrame:CGRectMake(MARGIN, [signUpButton frame].origin.y + [signUpButton bounds].size.height + MARGIN * 2, [forgetLabel bounds].size.width, [forgetLabel bounds].size.height)];
    // reset
    if (UIInterfaceOrientationIsLandscape(orientation))
    {
        [resetButton setFrame:CGRectMake([forgetLabel frame].origin.x + [forgetLabel bounds].size.width, [forgetLabel frame].origin.y, 90, [forgetLabel bounds].size.height)];
    }
    else
    {
        [resetButton setFrame:CGRectMake(MARGIN, [forgetLabel frame].origin.y + [forgetLabel bounds].size.height, 90, [forgetLabel bounds].size.height)];
    }
    
    [self setScrollContentHeight:([resetButton frame].origin.y + [resetButton frame].size.height + MARGIN)];
    [self updateScrollOffsetForOrientation:orientation];
}

#pragma mark - Protected

- (BOOL)isAnyTextFieldEditing
{
    return [usernameTextField isEditing] || [passwordTextField isEditing];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    shouldScrollBack = NO;
    if ([textField isEqual:usernameTextField] == YES)
    {
        [passwordTextField becomeFirstResponder];
    }
    else if ([textField isEqual:passwordTextField] == YES)
    {
        shouldScrollBack = YES;
        [passwordTextField resignFirstResponder];
    }
    return NO;
}

#pragma mark - Private

- (void)signInDidPress:(id)sender
{
    [usernameTextField resignFirstResponder];
    [passwordTextField resignFirstResponder];
    
    [[self delegate] signInView:self signInDidPressWithUsername:[usernameTextField text] password:[passwordTextField text]];
}

- (void)signUpDidPress:(id)sender
{
    [[self delegate] signInViewDidPressSignUp:self];
}

- (void)resetDidPress:(id)sender
{
    [[self delegate] signInViewDidPressReset:self];
}

@end
