//
//  P4RCSplashBackView.m
//  P4RCIntegrationSample
//
//  Created by Artem Stepanenko on 9/10/12.
//
//

#import "P4RCSplashBackView.h"


@interface P4RCSplashBackView ()

@property (nonatomic, retain) UIImageView *logoImageView;

@end


@implementation P4RCSplashBackView

@synthesize logoImageView;

- (void)dealloc
{
    self.logoImageView = nil;
    [super dealloc];
}

- (id)initWithFrame:(CGRect)theFrame
{
    self = [super initWithFrame:theFrame];
    if (self)
    {
        UIImage *logoImage = [UIImage imageNamed:@"P4RC.bundle/logo_splash_ipad.png"];
        self.logoImageView = [[[UIImageView alloc] initWithImage:logoImage] autorelease];
        self.logoImageView.frame = CGRectMake(0, 0, logoImage.size.width, logoImage.size.height);
        [self addSubview:self.logoImageView];
    }
    return self;
}

- (void)updateWithOrientation:(UIInterfaceOrientation)orientation
{
    [super updateWithOrientation:orientation];
    
    CGFloat screenWidth = self.frame.size.width;
    CGFloat screenHeight = self.frame.size.height;
    
    CGFloat width = UIInterfaceOrientationIsPortrait(orientation) ? screenWidth : screenHeight;
    CGFloat height = UIInterfaceOrientationIsPortrait(orientation) ? screenHeight : screenWidth;
    
    self.logoImageView.frame = CGRectMake(width - self.logoImageView.frame.size.width - 10,
                                          height - self.logoImageView.frame.size.height - 10,
                                          self.logoImageView.frame.size.width,
                                          self.logoImageView.frame.size.height);
}

@end
