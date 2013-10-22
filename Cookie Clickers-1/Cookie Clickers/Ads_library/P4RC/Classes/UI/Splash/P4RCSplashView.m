//
//  P4RCSplashView.m
//  P4RCIntegrationSample
//
//  Created by Artem Stepanenko on 5/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "P4RCSplashView.h"
#import "P4RCCheckButton.h"
#import "P4RCCellView.h"

#define MARGIN      10


@interface P4RCSplashView ()

@property (nonatomic, retain) UIButton *facebookButton;
@property (nonatomic, retain) UIButton *notAFacebookUserButton;
@property (nonatomic, retain) UIButton *noThanksButton;
@property (nonatomic, retain) UILabel *firstTitleLabel;
@property (nonatomic, retain) UILabel *secondTitleLabel;
@property (nonatomic, retain) P4RCCellView *earnPointsCellView;
@property (nonatomic, retain) P4RCCellView *redeemPointsCellView;

- (void)noThanksDidPress:(id)sender;
- (void)facebookDidPress:(id)sender;
- (void)notAFacebookUserDidPress:(id)sender;
- (void)termsDidPress:(id)sender;

@end


@implementation P4RCSplashView

@synthesize facebookButton,
            notAFacebookUserButton,
            noThanksButton,
            earnPointsCellView,
            redeemPointsCellView,
            firstTitleLabel,
            secondTitleLabel;

@dynamic delegate;

- (void)dealloc
{
    [firstLineTermsLabel release];
    [secondLineTermsButton release];
    [facebookButton release];
    [noThanksButton release];
    [notAFacebookUserButton release];
    [firstTitleLabel release];
    [secondTitleLabel release];
    [earnPointsCellView release];
    [redeemPointsCellView release];
    [super dealloc];
}

- (id)initWithFrame:(CGRect)theFrame
{
    self = [super initWithFrame:theFrame];
    if (self)
    {
        // title
        // first
        self.firstTitleLabel = [[[UILabel alloc] init] autorelease];
        self.firstTitleLabel.backgroundColor = [UIColor clearColor];
        self.firstTitleLabel.text = @"Earn Rewards";
        self.firstTitleLabel.textColor = [UIColor colorWithRed:1 green:0.42 blue:0 alpha:1];
        self.firstTitleLabel.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:28];
        [self.firstTitleLabel sizeToFit];
        [self addSubview:self.firstTitleLabel];
        // second
        self.secondTitleLabel = [[[UILabel alloc] init] autorelease];
        self.secondTitleLabel.backgroundColor = [UIColor clearColor];
        self.secondTitleLabel.text = @"While You Play!";
        self.secondTitleLabel.textColor = [UIColor colorWithRed:1 green:0.42 blue:0 alpha:1];
        self.secondTitleLabel.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:28];
        [self.secondTitleLabel sizeToFit];
        [self addSubview:self.secondTitleLabel];
        // facebook
        facebookButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
        [facebookButton setAutoresizingMask:(UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin)];
        [facebookButton addTarget:self action:@selector(facebookDidPress:) forControlEvents:UIControlEventTouchUpInside];
        UIImage *facebookImage = [UIImage imageNamed:@"P4RC.bundle/facebook_button.png"];
        [facebookButton setImage:facebookImage forState:UIControlStateNormal];
        [facebookButton setFrame:CGRectMake(0, 0, [facebookImage size].width, [facebookImage size].height)];
        [scrollView addSubview:facebookButton];
        // not a facebook user
        notAFacebookUserButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
        [notAFacebookUserButton setAutoresizingMask:(UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin)];
        [notAFacebookUserButton addTarget:self action:@selector(notAFacebookUserDidPress:) forControlEvents:UIControlEventTouchUpInside];
        NSString *notAFacebookUserTitle = @"Not a Facebook User?";
        [notAFacebookUserButton setTitle:notAFacebookUserTitle forState:UIControlStateNormal];
        [[notAFacebookUserButton titleLabel] setFont:[UIFont systemFontOfSize:10]];
        [notAFacebookUserButton setTitleColor:[UIColor colorWithRed:0.24f green:0.67f blue:0.75f alpha:1] forState:UIControlStateNormal];
        [notAFacebookUserButton setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
        [notAFacebookUserButton sizeToFit];
        [scrollView addSubview:notAFacebookUserButton];
        // no thanks
        noThanksButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
        [noThanksButton setAutoresizingMask:(UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin)];
        [noThanksButton addTarget:self action:@selector(noThanksDidPress:) forControlEvents:UIControlEventTouchUpInside];
        [noThanksButton setTitle:@"I Don't Like Free Stuff" forState:UIControlStateNormal];
        noThanksButton.titleLabel.font = [UIFont systemFontOfSize:10];
        [noThanksButton setTitleColor:[UIColor colorWithRed:0.24f green:0.67f blue:0.75f alpha:1] forState:UIControlStateNormal];
        [noThanksButton setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
        [noThanksButton sizeToFit];
        [scrollView addSubview:noThanksButton];
        // check
        checkButton = [[P4RCCheckButton alloc] initWithFrame:CGRectZero];
        [scrollView addSubview:checkButton];
        // terms and conditions 1
        firstLineTermsLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [firstLineTermsLabel setText:@"I have read and agree to the"];
        [firstLineTermsLabel setBackgroundColor:[UIColor clearColor]];
        [firstLineTermsLabel setFont:[UIFont systemFontOfSize:10]];
        [firstLineTermsLabel sizeToFit];
        [scrollView addSubview:firstLineTermsLabel];
        // terms and conditions 2
        secondLineTermsButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
        [secondLineTermsButton addTarget:self action:@selector(termsDidPress:) forControlEvents:UIControlEventTouchUpInside];
        [secondLineTermsButton setTitle:@"Terms of Use." forState:UIControlStateNormal];
        [secondLineTermsButton setTitleColor:[UIColor colorWithRed:0.24f green:0.67f blue:0.75f alpha:1] forState:UIControlStateNormal];
        [secondLineTermsButton setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
        [[secondLineTermsButton titleLabel] setFont:[UIFont boldSystemFontOfSize:10]];
        [secondLineTermsButton sizeToFit];
        [scrollView addSubview:secondLineTermsButton];
        // cells
        // earn points
        self.earnPointsCellView = [[[P4RCCellView alloc] initWithFrame:CGRectZero] autorelease];
        self.earnPointsCellView.userInteractionEnabled = NO;
        self.earnPointsCellView.number = 1;
        self.earnPointsCellView.logoImage = [UIImage imageNamed:@"P4RC.bundle/piggy.png"];
        self.earnPointsCellView.text = @"Earn points while you play!";
        [self addSubview:self.earnPointsCellView];
        // redeem points
        self.redeemPointsCellView = [[[P4RCCellView alloc] initWithFrame:CGRectZero] autorelease];
        self.redeemPointsCellView.userInteractionEnabled = NO;
        self.redeemPointsCellView.number = 2;
        self.redeemPointsCellView.logoImage = [UIImage imageNamed:@"P4RC.bundle/gifts.png"];
        self.redeemPointsCellView.text = @"Redeem points for prizes!";
        [self addSubview:self.redeemPointsCellView];
    }
    return self;
}

/*- (NSString *)backImageNameForPortraitOrientation
{
    return @"P4RC.bundle/splash_portrait_back.png";
}

- (NSString *)backImageNameForLandscapeOrientation
{
    return @"P4RC.bundle/splash_landscape_back.png";
}*/

- (void)updateWithOrientation:(UIInterfaceOrientation)orientation
{
    [super updateWithOrientation:orientation];
    
    UIView *bottomView = nil;
    
    CGFloat width = [scrollView bounds].size.width;
    CGFloat height = [scrollView bounds].size.height;
    if (UIInterfaceOrientationIsPortrait(orientation))
    {
        // titles
        self.firstTitleLabel.frame = CGRectMake((width - self.firstTitleLabel.frame.size.width) / 2, 105, self.firstTitleLabel.frame.size.width, self.firstTitleLabel.frame.size.height);
        self.secondTitleLabel.frame = CGRectMake((width - self.secondTitleLabel.frame.size.width) / 2, self.firstTitleLabel.frame.origin.y + self.firstTitleLabel.frame.size.height, self.secondTitleLabel.frame.size.width, self.secondTitleLabel.frame.size.height);
        // cells
        // earn
        self.earnPointsCellView.frame = CGRectMake(MARGIN, self.secondTitleLabel.frame.origin.y + self.secondTitleLabel.frame.size.height + 24 - 10, width - 2 * MARGIN, 90);
        // redeem
        self.redeemPointsCellView.frame = CGRectMake(MARGIN, self.earnPointsCellView.frame.origin.y + self.earnPointsCellView.frame.size.height + 15 - 10, width - 2 * MARGIN, 90);
    }
    else
    {
        // titles
        CGFloat generalTitlesWidth = self.firstTitleLabel.frame.size.width + self.secondTitleLabel.frame.size.width + MARGIN;
        
        self.firstTitleLabel.frame = CGRectMake((width - generalTitlesWidth) / 2, 96, self.firstTitleLabel.frame.size.width, self.firstTitleLabel.frame.size.height);
        self.secondTitleLabel.frame = CGRectMake(self.firstTitleLabel.frame.origin.x + self.firstTitleLabel.frame.size.width + MARGIN, 96, self.secondTitleLabel.frame.size.width, self.secondTitleLabel.frame.size.height);
        // cells
        CGFloat cellWidth = (width - 3 * MARGIN) / 2;
        // earn
        self.earnPointsCellView.frame = CGRectMake(MARGIN, self.secondTitleLabel.frame.origin.y + self.secondTitleLabel.frame.size.height + 15 - 10, cellWidth, 80);
        // redeem
        self.redeemPointsCellView.frame = CGRectMake(self.earnPointsCellView.frame.origin.x + self.earnPointsCellView.frame.size.width + MARGIN, self.earnPointsCellView.frame.origin.y, cellWidth, 80);
    }
    
    // no thanks
    noThanksButton.frame = CGRectMake(width - noThanksButton.frame.size.width - MARGIN, height - noThanksButton.frame.size.height - MARGIN / 2, noThanksButton.frame.size.width, noThanksButton.frame.size.height);
    // not a facebook user
    notAFacebookUserButton.frame = CGRectMake(MARGIN, height - notAFacebookUserButton.frame.size.height - MARGIN / 2, notAFacebookUserButton.frame.size.width, notAFacebookUserButton.frame.size.height);
    // facebook
    facebookButton.frame = CGRectMake((width - facebookButton.frame.size.width) / 2, notAFacebookUserButton.frame.origin.y - MARGIN - facebookButton.frame.size.height, facebookButton.frame.size.width, facebookButton.frame.size.height);
    // checkbox
    checkButton.frame = CGRectMake((width - (checkButton.frame.size.width + firstLineTermsLabel.frame.size.width + secondLineTermsButton.frame.size.width + 2 * MARGIN)) / 2, facebookButton.frame.origin.y - MARGIN + 5 - checkButton.frame.size.height, checkButton.bounds.size.width, checkButton.bounds.size.height);
    // terms and conditions 1
    firstLineTermsLabel.frame = CGRectMake(checkButton.frame.origin.x + checkButton.frame.size.width + MARGIN / 2, checkButton.frame.origin.y + (checkButton.frame.size.height - firstLineTermsLabel.frame.size.height) / 2, firstLineTermsLabel.frame.size.width, firstLineTermsLabel.frame.size.height);
    // terms and conditions 2
    secondLineTermsButton.frame = CGRectMake(firstLineTermsLabel.frame.origin.x + firstLineTermsLabel.frame.size.width + 4, firstLineTermsLabel.frame.origin.y, secondLineTermsButton.frame.size.width, secondLineTermsButton.frame.size.height);
    
    [self setScrollContentHeight:([bottomView frame].origin.y + [bottomView frame].size.height + MARGIN)];
    [self updateScrollOffsetForOrientation:orientation];
}

- (void)noThanksDidPress:(id)sender
{
    [[self delegate] splashViewDidPressNoThanks:self];
}

- (void)facebookDidPress:(id)sender
{
    [[self delegate] splashViewDidPressFacebook:self userAcceptedTerms:[checkButton isChecked]];
}

- (void)notAFacebookUserDidPress:(id)sender
{
    [[self delegate] splashViewDidPressNotAFacebookUserDidPress:self];
}

- (void)termsDidPress:(id)sender
{
    [[self delegate] splashViewDidPressTermsAndConditions:self];
}

#pragma mark - P4RCCellViewDelegate

- (void)didSelectCellView:(P4RCCellView *)sender
{
    // TODO: open some URL
}

@end
