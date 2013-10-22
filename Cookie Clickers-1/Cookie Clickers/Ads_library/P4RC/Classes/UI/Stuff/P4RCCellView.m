//
//  P4RCCellView.m
//  P4RCIntegrationSample
//
//  Created by Artem Stepanenko on 8/31/12.
//
//

#import "P4RCCellView.h"
#import <QuartzCore/QuartzCore.h>

#define MARGIN      10


@interface P4RCCellView ()

@property (nonatomic, retain) UIImageView *cornerImageView;
@property (nonatomic, retain) UILabel *numberLabel;
@property (nonatomic, retain) UIImageView *logoImageView;
@property (nonatomic, retain) UILabel *textLabel;
@property (nonatomic, assign, getter = isSelected) BOOL selected;

- (void)update;

@end


@implementation P4RCCellView

@synthesize textLabel,
            logoImage,
            logoImageView,
            cornerImageView,
            numberLabel,
            number,
            text,
            selected,
            delegate;

- (void)dealloc
{
    self.delegate = nil;
    self.textLabel = nil;
    self.text = nil;
    self.logoImageView = nil;
    self.logoImage = nil;
    self.cornerImageView = nil;
    self.numberLabel = nil;
    [super dealloc];
}

- (id)initWithFrame:(CGRect)theFrame
{
    self = [super initWithFrame:theFrame];
    if (self)
    {
        // self
        self.clipsToBounds = YES;
        self.layer.borderWidth = 1;
        self.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        self.layer.cornerRadius = 5;
        self.backgroundColor = [UIColor whiteColor];
        // corner
        UIImage *cornerImage = [UIImage imageNamed:@"P4RC.bundle/blue_box_corner.png"];
        self.cornerImageView = [[[UIImageView alloc] initWithImage:cornerImage] autorelease];
        self.cornerImageView.frame = CGRectMake(0, 0, cornerImage.size.width, cornerImage.size.height);
        [self addSubview:self.cornerImageView];
        // number
        self.numberLabel = [[[UILabel alloc] init] autorelease];
        self.numberLabel.backgroundColor = [UIColor clearColor];
        self.numberLabel.font = [UIFont boldSystemFontOfSize:12];
        self.numberLabel.textColor = [UIColor whiteColor];
        self.numberLabel.shadowColor = [UIColor blackColor];
        self.numberLabel.shadowOffset = CGSizeMake(0, 1);
        [self addSubview:self.numberLabel];
        // logo
        self.logoImageView = [[[UIImageView alloc] init] autorelease];
        [self addSubview:self.logoImageView];
        // text
        self.textLabel = [[[UILabel alloc] init] autorelease];
        self.textLabel.backgroundColor = [UIColor clearColor];
        self.textLabel.numberOfLines = 0;
        self.textLabel.lineBreakMode = UILineBreakModeWordWrap;
        self.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14];
        self.textLabel.textColor = [UIColor blackColor];
        [self addSubview:self.textLabel];
        // update
        [self update];
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.selected = YES;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.selected = NO;
    [self.delegate didSelectCellView:self];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.selected = NO;
}

- (void)setNumber:(NSInteger)theNumber
{
    number = theNumber;
    [self setNeedsLayout];
}

- (void)setLogoImage:(UIImage *)theLogoImage
{
    [logoImage autorelease];
    logoImage = [theLogoImage retain];
    self.logoImageView.image = logoImage;
    self.logoImageView.frame = CGRectMake(0, 0, self.logoImage.size.width, self.logoImage.size.height);
    [self setNeedsLayout];
}

- (void)setText:(NSString *)theText
{
    [text autorelease];
    text = [theText retain];
    self.textLabel.text = self.text;
    [self.textLabel sizeToFit];
    [self setNeedsLayout];
}

- (void)setSelected:(BOOL)theSelected
{
    selected = theSelected;
    
    if (self.isSelected)
    {
        self.backgroundColor = [UIColor lightGrayColor];
    }
    else
    {
        self.backgroundColor = [UIColor whiteColor];
    }
}

- (void)update
{
    self.selected = self.isSelected;
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    // corner
    self.cornerImageView.frame = CGRectMake(0, 0, self.cornerImageView.frame.size.width, self.cornerImageView.frame.size.height);
    // number
    self.numberLabel.text = [NSString stringWithFormat:@"%d", self.number];
    [self.numberLabel sizeToFit];
    self.numberLabel.frame = CGRectMake(MARGIN / 2, MARGIN / 2, self.numberLabel.frame.size.width, self.numberLabel.frame.size.height);
    // logo image
    self.logoImageView.frame = CGRectMake(self.frame.size.width - self.logoImageView.frame.size.width - MARGIN, (self.frame.size.height - self.logoImageView.frame.size.height) / 2, self.logoImageView.frame.size.width, self.logoImageView.frame.size.height);
    // text
    self.textLabel.frame = CGRectMake(3 * MARGIN, (self.frame.size.height - self.textLabel.frame.size.height) / 2, self.frame.size.width - self.logoImageView.frame.size.width - 4 * MARGIN, self.textLabel.frame.size.height);
    [self.textLabel sizeToFit];
    self.textLabel.frame = CGRectMake(self.textLabel.frame.origin.x, (self.frame.size.height - self.textLabel.frame.size.height) / 2, self.textLabel.frame.size.width, self.textLabel.frame.size.height);
}

@end
