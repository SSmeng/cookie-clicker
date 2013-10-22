//
//  P4RCSignUpView.m
//  P4RCIntegrationSample
//
//  Created by Artem Stepanenko on 5/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "P4RCSignUpView.h"
#import "P4RCCheckButton.h"
#import "P4RCTextField.h"

#define MARGIN                  10
#define TEXT_FIELD_HEIGHT       36
#define BUTTON_WIDTH            150


@interface P4RCSignUpView () <UITextFieldDelegate>

- (void)termsDidPress:(id)sender;

@end


@implementation P4RCSignUpView

@dynamic delegate;

- (void)dealloc
{
    [alreadyHaveLabel release];
    [checkButton release];
    [firstNameTextField release];
    [lastNameTextField release];
    [emailTextField release];
    [confirmedEmailTextField release];
    [passwordTextField release];
    [verifiedPasswordTextField release];
    [signUpButton release];
    [cancelButton release];
    [super dealloc];
}

- (id)initWithFrame:(CGRect)theFrame
{
    self = [super initWithFrame:theFrame];
    if (self)
    {
        // hint
        hintLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [hintLabel setText:@"Sign Up For P4RC"];
        [hintLabel setFont:[UIFont boldSystemFontOfSize:14]];
        [hintLabel setBackgroundColor:[UIColor clearColor]];
        [scrollView addSubview:hintLabel];
        
        UIImage *textFieldImage = [UIImage imageNamed:@"P4RC.bundle/blue_box.png"];
        // first name
        firstNameTextField = [[P4RCTextField alloc] initWithFrame:CGRectZero];
        [firstNameTextField setSideTextIndent:MARGIN];
        [firstNameTextField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
        [firstNameTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
        [firstNameTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
        [firstNameTextField setClearButtonMode:UITextFieldViewModeWhileEditing];
        [firstNameTextField setReturnKeyType:UIReturnKeyNext];
        [firstNameTextField setBackground:textFieldImage];
        [firstNameTextField setPlaceholder:@"First Name"];
        [firstNameTextField setDelegate:self];
        [scrollView addSubview:firstNameTextField];
        // last name
        lastNameTextField = [[P4RCTextField alloc] initWithFrame:CGRectZero];
        [lastNameTextField setSideTextIndent:MARGIN];
        [lastNameTextField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
        [lastNameTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
        [lastNameTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
        [lastNameTextField setClearButtonMode:UITextFieldViewModeWhileEditing];
        [lastNameTextField setReturnKeyType:UIReturnKeyNext];
        [lastNameTextField setBackground:textFieldImage];
        [lastNameTextField setPlaceholder:@"Last Name"];
        [lastNameTextField setDelegate:self];
        [scrollView addSubview:lastNameTextField];
        // email
        emailTextField = [[P4RCTextField alloc] initWithFrame:CGRectZero];
        [emailTextField setSideTextIndent:MARGIN];
        [emailTextField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
        [emailTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
        [emailTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
        [emailTextField setClearButtonMode:UITextFieldViewModeWhileEditing];
        [emailTextField setReturnKeyType:UIReturnKeyNext];
        [emailTextField setBackground:textFieldImage];
        [emailTextField setPlaceholder:@"Email"];
        [emailTextField setDelegate:self];
        [scrollView addSubview:emailTextField];
        // confirmed email
        confirmedEmailTextField = [[P4RCTextField alloc] initWithFrame:CGRectZero];
        [confirmedEmailTextField setSideTextIndent:MARGIN];
        [confirmedEmailTextField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
        [confirmedEmailTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
        [confirmedEmailTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
        [confirmedEmailTextField setClearButtonMode:UITextFieldViewModeWhileEditing];
        [confirmedEmailTextField setReturnKeyType:UIReturnKeyNext];
        [confirmedEmailTextField setBackground:textFieldImage];
        [confirmedEmailTextField setPlaceholder:@"Confirm Email"];
        [confirmedEmailTextField setDelegate:self];
        [scrollView addSubview:confirmedEmailTextField];
        // password
        passwordTextField = [[P4RCTextField alloc] initWithFrame:CGRectZero];
        [passwordTextField setSecureTextEntry:YES];
        [passwordTextField setSideTextIndent:MARGIN];
        [passwordTextField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
        [passwordTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
        [passwordTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
        [passwordTextField setClearButtonMode:UITextFieldViewModeWhileEditing];
        [passwordTextField setReturnKeyType:UIReturnKeyNext];
        [passwordTextField setBackground:textFieldImage];
        [passwordTextField setPlaceholder:@"Password"];
        [passwordTextField setDelegate:self];
        [scrollView addSubview:passwordTextField];
        // varified password
        verifiedPasswordTextField = [[P4RCTextField alloc] initWithFrame:CGRectZero];
        [verifiedPasswordTextField setSecureTextEntry:YES];
        [verifiedPasswordTextField setSideTextIndent:MARGIN];
        [verifiedPasswordTextField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
        [verifiedPasswordTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
        [verifiedPasswordTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
        [verifiedPasswordTextField setClearButtonMode:UITextFieldViewModeWhileEditing];
        [verifiedPasswordTextField setReturnKeyType:UIReturnKeyDone];
        [verifiedPasswordTextField setBackground:textFieldImage];
        [verifiedPasswordTextField setPlaceholder:@"Verify Password"];
        [verifiedPasswordTextField setDelegate:self];
        [verifiedPasswordTextField setDelegate:self];
        [scrollView addSubview:verifiedPasswordTextField];
        // check
        checkButton = [[P4RCCheckButton alloc] initWithFrame:CGRectZero];
        [scrollView addSubview:checkButton];
        // terms and conditions 1
        firstLineTermsLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [firstLineTermsLabel setText:@"I have read and agree to the "];
        [firstLineTermsLabel sizeToFit];
        [firstLineTermsLabel setBackgroundColor:[UIColor clearColor]];
        [firstLineTermsLabel setFont:[UIFont systemFontOfSize:12]];
        [scrollView addSubview:firstLineTermsLabel];
        // terms and conditions 2
        secondLineTermsButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
        [secondLineTermsButton addTarget:self action:@selector(termsDidPress:) forControlEvents:UIControlEventTouchUpInside];
        [secondLineTermsButton setTitle:@"Terms of Use." forState:UIControlStateNormal];
        [secondLineTermsButton setTitleColor:[UIColor colorWithRed:0.24f green:0.67f blue:0.75f alpha:1] forState:UIControlStateNormal];
        [secondLineTermsButton setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
        [[secondLineTermsButton titleLabel] setFont:[UIFont boldSystemFontOfSize:12]];
        [scrollView addSubview:secondLineTermsButton];
        // button back image
        UIImage *buttonBackImage = [UIImage imageNamed:@"P4RC.bundle/main_menu_view_account_button.png"];
        // sign up
        signUpButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
        [signUpButton setBackgroundImage:buttonBackImage forState:UIControlStateNormal];
        [[signUpButton titleLabel] setFont:[UIFont systemFontOfSize:12]];
        [signUpButton setFrame:CGRectMake(0, 0, [buttonBackImage size].width, [buttonBackImage size].height)];
        [signUpButton setTitle:@"Sign Up" forState:UIControlStateNormal];
        [[signUpButton titleLabel] setTextColor:[UIColor whiteColor]];
        [signUpButton addTarget:self action:@selector(signUpDidPress:) forControlEvents:UIControlEventTouchUpInside];
        [scrollView addSubview:signUpButton];
        // already have
        alreadyHaveLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [alreadyHaveLabel setText:@"Already have an account?"];
        [alreadyHaveLabel setBackgroundColor:[UIColor clearColor]];
        [alreadyHaveLabel setFont:[UIFont systemFontOfSize:14]];
        [scrollView addSubview:alreadyHaveLabel];
        // cancel
        cancelButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
        [[cancelButton titleLabel] setTextAlignment:UITextAlignmentLeft];
        [[cancelButton titleLabel] setFont:[UIFont boldSystemFontOfSize:14]];
        [cancelButton setTitle:@"Sign In" forState:UIControlStateNormal];
        [cancelButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [cancelButton setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
        [cancelButton addTarget:self action:@selector(cancelDidPress:) forControlEvents:UIControlEventTouchUpInside];
        [scrollView addSubview:cancelButton];
    }
    return self;
}

- (void)updateWithOrientation:(UIInterfaceOrientation)orientation
{
    [super updateWithOrientation:orientation];
    // hint
    [hintLabel sizeToFit];
    [hintLabel setFrame:CGRectMake(MARGIN, MARGIN, [hintLabel bounds].size.width, [hintLabel bounds].size.height)];
    // user name
    [firstNameTextField setFrame:CGRectMake(MARGIN, [hintLabel frame].origin.y + [hintLabel frame].size.height, [self bounds].size.width - 2 * MARGIN, TEXT_FIELD_HEIGHT)];
    // last name
    [lastNameTextField setFrame:CGRectMake([firstNameTextField frame].origin.x, [firstNameTextField frame].origin.y + [firstNameTextField frame].size.height + MARGIN, [firstNameTextField bounds].size.width, [firstNameTextField frame].size.height)];
    // email
    [emailTextField setFrame:CGRectMake([lastNameTextField frame].origin.x, [lastNameTextField frame].origin.y + [lastNameTextField frame].size.height + MARGIN, [lastNameTextField bounds].size.width, [lastNameTextField frame].size.height)];
    // confirmed email
    [confirmedEmailTextField setFrame:CGRectMake([emailTextField frame].origin.x, [emailTextField frame].origin.y + [emailTextField frame].size.height + MARGIN, [emailTextField bounds].size.width, [emailTextField frame].size.height)];
    // password
    [passwordTextField setFrame:CGRectMake([confirmedEmailTextField frame].origin.x, [confirmedEmailTextField frame].origin.y + [confirmedEmailTextField frame].size.height + MARGIN, [confirmedEmailTextField bounds].size.width, [confirmedEmailTextField frame].size.height)];
    // varified password
    [verifiedPasswordTextField setFrame:CGRectMake([passwordTextField frame].origin.x, [passwordTextField frame].origin.y + [passwordTextField frame].size.height + MARGIN, [passwordTextField bounds].size.width, [passwordTextField frame].size.height)];
    // check
    [checkButton setFrame:CGRectMake(MARGIN, [verifiedPasswordTextField frame].origin.y + [verifiedPasswordTextField frame].size.height + MARGIN, [checkButton bounds].size.width, [checkButton bounds].size.height)];
    // terms 1
    [firstLineTermsLabel sizeToFit];
    [firstLineTermsLabel setCenter:CGPointMake([checkButton frame].origin.x + [checkButton frame].size.width + [firstLineTermsLabel bounds].size.width / 2, [checkButton center].y)];
    // terms 2
    NSString *termsString = [[secondLineTermsButton titleLabel] text];
    CGSize termsSize = [termsString sizeWithFont:[[secondLineTermsButton titleLabel] font]];
    [secondLineTermsButton setBounds:CGRectMake(0, 0, termsSize.width, termsSize.height)];
    
    [secondLineTermsButton setCenter:CGPointMake([firstLineTermsLabel frame].origin.x + [firstLineTermsLabel frame].size.width + [secondLineTermsButton bounds].size.width / 2, [firstLineTermsLabel center].y)];
        
    [checkButton setCenter:CGPointMake([firstLineTermsLabel frame].origin.x - [checkButton bounds].size.width / 2 - MARGIN / 2, ([firstLineTermsLabel frame].origin.y + [secondLineTermsButton frame].origin.y + [secondLineTermsButton frame].size.height) / 2)];
    
    // sign up
    CGFloat secondLineBottom = [secondLineTermsButton frame].origin.y + [secondLineTermsButton bounds].size.height;
    CGFloat checkBottom = [checkButton frame].origin.y + [checkButton bounds].size.height;
    [signUpButton setFrame:CGRectMake(MARGIN, (secondLineBottom > checkBottom ? secondLineBottom : checkBottom) + MARGIN, [signUpButton bounds].size.width, [signUpButton bounds].size.height)];
    // already have
    [alreadyHaveLabel sizeToFit];
    [alreadyHaveLabel setFrame:CGRectMake(MARGIN, [signUpButton frame].origin.y + [signUpButton bounds].size.height + MARGIN, [alreadyHaveLabel bounds].size.width, [alreadyHaveLabel bounds].size.height)];
    // sign in
    [cancelButton setFrame:CGRectMake(0, 0, 60, [alreadyHaveLabel bounds].size.height)];
    [cancelButton setCenter:CGPointMake([alreadyHaveLabel frame].origin.x + [alreadyHaveLabel bounds].size.width + [cancelButton bounds].size.width / 2, [alreadyHaveLabel center].y)];
    
    [self updateScrollContentSize];
    [self updateScrollOffsetForOrientation:orientation];
}

- (void)clearFields
{
    [firstNameTextField setText:@""];
    [lastNameTextField setText:@""];
    [emailTextField setText:@""];
    [confirmedEmailTextField setText:@""];
    [passwordTextField setText:@""];
    [verifiedPasswordTextField setText:@""];
    [checkButton setChecked:NO];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    shouldScrollBack = NO;
    if ([textField isEqual:firstNameTextField] == YES)
    {
        [lastNameTextField becomeFirstResponder];
    }
    else if ([textField isEqual:lastNameTextField] == YES)
    {
        [emailTextField becomeFirstResponder];
    }
    else if ([textField isEqual:emailTextField] == YES)
    {
        [confirmedEmailTextField becomeFirstResponder];
    }
    else if ([textField isEqual:confirmedEmailTextField] == YES)
    {
        [passwordTextField becomeFirstResponder];
    }
    else if ([textField isEqual:passwordTextField] == YES)
    {
        [verifiedPasswordTextField becomeFirstResponder];
    }
    else if ([textField isEqual:verifiedPasswordTextField] == YES)
    {
        shouldScrollBack = YES;
        [verifiedPasswordTextField resignFirstResponder];
    }
    return NO;
}

#pragma mark - Protected

- (BOOL)isAnyTextFieldEditing
{
    return [firstNameTextField isEditing] || [lastNameTextField isEditing] || [emailTextField isEditing] || [confirmedEmailTextField isEditing] || [passwordTextField isEditing] || [verifiedPasswordTextField isEditing];
}

#pragma mark - Private

- (void)termsDidPress:(id)sender
{
    [[self delegate] signUpViewDidPressTermsAndConditions:self];
}

- (void)signUpDidPress:(id)sender
{
    [firstNameTextField resignFirstResponder];
    [lastNameTextField resignFirstResponder];
    [emailTextField resignFirstResponder];
    [confirmedEmailTextField resignFirstResponder];
    [passwordTextField resignFirstResponder];
    [verifiedPasswordTextField resignFirstResponder];
    
    [[self delegate] signUpView:self signUpDidPressWithFirstName:[firstNameTextField text] lastName:[lastNameTextField text] email:[emailTextField text] confirmedEmail:[confirmedEmailTextField text] password:[passwordTextField text] verifiedPassword:[verifiedPasswordTextField text] acceptedTerms:[checkButton isChecked]];   // FIXME
}

- (void)cancelDidPress:(id)sender
{
    [[self delegate] signUpViewDidPressCancel:self];
}

@end
