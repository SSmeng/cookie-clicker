//
//  P4RCFramedBrowserView.m
//  ConstaPad
//
//  Created by Artem Stepanenko on 7/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "P4RCFramedBrowserView.h"
#import "P4RCCacheManager.h"
#import <QuartzCore/QuartzCore.h>
#import "P4RCServerConfig.h"
#import "P4RCUtils.h"
#import "server.h"
#import "UIImage+Retina4.h"

#define TOP_PANEL_HEIGHT		30
#define ANIMATION_SHOW_BROWSER	@"animationShowBrowser"
#define ANIMATION_HIDE_BROWSER	@"animationHideBrowser"

#define TIMEOUT					10
#define TIMEOUT_INTERVAL		60
#define MAX_TIMEOUTS_COUNT		1

#define NO_INTERNET_CONNECTION_ALERT_TAG    8001


@interface P4RCFramedBrowserView () <UIWebViewDelegate, UIAlertViewDelegate>

@property (nonatomic, retain) NSString *lastURLString;
@property (nonatomic, retain) NSError *lastError;
@property (nonatomic, assign) UIInterfaceOrientation currentOrientation;
@property (nonatomic, copy) NSURL *iTunesURL;

- (BOOL)isITunesUrlString:(NSString *)urlString;

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context;
- (void)closeDidPress:(id)sender;
- (void)retryToLoadPage;
- (void)showInternetIsNotAvailableAlert;

- (CGFloat)margin;
- (CGRect)generalRect;
- (CGRect)generalRectForOrientation:(UIInterfaceOrientation)orientation;
- (CGRect)browserRect;
- (CGRect)browserRectForOrientation:(UIInterfaceOrientation)orientation;
- (CGRect)contentRect;
- (CGRect)backRect;
- (CGRect)backRectForOrientation:(UIInterfaceOrientation)orientation;
- (CGRect)closeButtonRectForOrientation:(UIInterfaceOrientation)orientation;
- (CGRect)closeButtonRect;
- (void)disableJavascriptAlerts;

- (void)configureScrollView:(UIScrollView *)scrollView;

@end


@implementation P4RCFramedBrowserView

@synthesize lastURLString = lastURLString_,
lastError = lastError_,
currentOrientation = currentOrientation_,
delegate = delegate_,
iTunesURL = iTunesURL_;

- (void)dealloc
{
	delegate_ = nil;
    [iTunesURL_ release];
	[errorLabel_ release];
	[lastURLString_ release];
	[backView_ release];
	[fadeView_ release];
	[lastError_ release];
	[closeButton_ release];
	[webView_ setDelegate:nil];
	[webView_ stopLoading];
	[webView_ release];
	[activityIndicatorView_ release];
    [blueBackImageView_ release];
	[super dealloc];
}

#pragma mark -
#pragma mark Initialization

- (id)init
{
	self = [super initWithFrame:[self generalRect]];
	if (self)
	{
        [self setBackgroundColor:[UIColor clearColor]];
		// fade view
		fadeView_ = [[UIView alloc] initWithFrame:[self bounds]];
        [fadeView_ setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
        fadeView_.backgroundColor = [UIColor clearColor];
		[fadeView_ setHidden:YES];
		[self addSubview:fadeView_];
        // blue backround
        blueBackImageView_ = [[UIImageView alloc] init];
        if ([P4RCUtils deviceType] == P4RCDeviceTypeIPad)
        {
            blueBackImageView_.alpha = 0.86;
        }
        blueBackImageView_.frame = fadeView_.bounds;
        [fadeView_ addSubview:blueBackImageView_];
		// back view
		backView_ = [[UIView alloc] initWithFrame:[self backRect]];
        [backView_ setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
		if ([P4RCUtils deviceType] == P4RCDeviceTypeIPad)
		{
			[[backView_ layer] setCornerRadius:8];
		}
        
        // The color: #14 56 A1
        
        UIColor *backgroundColor = [UIColor colorWithRed:0x14/255.0 green:0x56/255.0 blue:0xA1/255.0 alpha:1];
		[backView_ setBackgroundColor:backgroundColor];
		[self addSubview:backView_];
		// close button
		closeButton_ = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
        [closeButton_ setAutoresizingMask:(UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin)];
		[closeButton_ setBackgroundColor:[UIColor clearColor]];
		[closeButton_ setFrame:[self closeButtonRect]];
		[closeButton_ setTitle:@"X" forState:UIControlStateNormal];
		[closeButton_ addTarget:self action:@selector(closeDidPress:) forControlEvents:UIControlEventTouchUpInside];
		[closeButton_ setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		[closeButton_ setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
		[self addSubview:closeButton_];
		// back button
		backButton_ = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
        [backButton_ setAutoresizingMask:(UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin)];
		[backButton_ setBackgroundColor:[UIColor clearColor]];
		[backButton_ setFrame:CGRectMake([backView_ frame].origin.x,
                                         [backView_ frame].origin.y,
                                         TOP_PANEL_HEIGHT,
                                         TOP_PANEL_HEIGHT)];
		[backButton_ setTitle:@"<" forState:UIControlStateNormal];
		[backButton_ addTarget:self action:@selector(backDidPress:) forControlEvents:UIControlEventTouchUpInside];
		[backButton_ setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		[backButton_ setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
		//[self addSubview:backButton_];
		// blank view
		blankView_ = [[UIView alloc] initWithFrame:[self browserRect]];
        [blankView_ setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
		[blankView_ setBackgroundColor:[UIColor whiteColor]];
		[self addSubview:blankView_];
		// error label
		errorLabel_ = [[UILabel alloc] init];
		[errorLabel_ setNumberOfLines:0];
		[errorLabel_ setBackgroundColor:[UIColor lightGrayColor]];
		[errorLabel_ setTextColor:[UIColor blackColor]];
		[errorLabel_ setFont:[UIFont systemFontOfSize:16]];
		[self addSubview:errorLabel_];
		// activity indicator
		activityIndicatorView_ = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
		[activityIndicatorView_ setCenter:[blankView_ center]];
        [activityIndicatorView_ setAutoresizingMask:(UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin)];
		[activityIndicatorView_ setHidesWhenStopped:YES];
		[self addSubview:activityIndicatorView_];
	}
	return self;
}

#pragma mark -
#pragma mark Public

- (void)showWithURLString:(NSString *)urlString
{
    isAboutToBeClosed = NO;
    
    if ([self isITunesUrlString:urlString] == YES) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
        return;
    }
    
    [errorLabel_ setHidden:YES];
	
	[[[UIApplication sharedApplication] keyWindow] addSubview:self];
	
	[blankView_ setHidden:NO];
	[activityIndicatorView_ startAnimating];
	
	webView_ = [[UIWebView alloc] initWithFrame:[self browserRect]];
    [webView_ setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
	if ([webView_ respondsToSelector:@selector(scrollView)])
	{
		[self configureScrollView:[webView_ scrollView]];
	}
	else
	{
		for (UIView *subview in [webView_ subviews])
		{
			if ([subview isKindOfClass:[UIScrollView class]])
			{
				[self configureScrollView:(UIScrollView *)subview];
				break;
			}
		}
	}
	
	[webView_ setDelegate:self];
	[self insertSubview:webView_ belowSubview:blankView_];
	[webView_ setUserInteractionEnabled:NO];
    // cache disabling
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString] cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:TIMEOUT_INTERVAL];
    [request setValue:@"no-cache" forHTTPHeaderField:@"Cache-Control"];
    
	[webView_ loadRequest:request];
    [self performSelector:@selector(showInternetIsNotAvailableAlert) withObject:nil afterDelay:FRAMED_BROWSER_TIMEOUT];
	
	[closeButton_ setFrame:CGRectMake([backView_ frame].origin.x + [backView_ frame].size.width - TOP_PANEL_HEIGHT,
									  [backView_ frame].origin.y,
									  TOP_PANEL_HEIGHT,
									  TOP_PANEL_HEIGHT)];
	
	[self setAlpha:0];
    [self startAutorotate];
	[self setTransform:CGAffineTransformScale([self transform], 0.001f, 0.001f)];
	[UIView beginAnimations:ANIMATION_SHOW_BROWSER context:NULL];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
	[UIView setAnimationDuration:0.5f];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
	
	[self setAlpha:1];
    [self setTransform:CGAffineTransformScale([self transform], 1000, 1000)];
	
	[UIView commitAnimations];
}

- (void)hide
{
    
    [self stopAutorotate];
	
	if ([self delegate])
	{
		[[self delegate] p4rcFramedBrowserViewWillDisappear:self];
	}
		
    [fadeView_ setHidden:YES];
	
	[UIView beginAnimations:ANIMATION_HIDE_BROWSER context:NULL];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
	[UIView setAnimationDuration:0.5f];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	
	[self setAlpha:0];
	[self setTransform:CGAffineTransformScale([self transform], 0.001f, 0.001f)];
	
	[UIView commitAnimations];
}

#pragma mark -
#pragma mark UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView
shouldStartLoadWithRequest:(NSURLRequest *)request
 navigationType:(UIWebViewNavigationType)navigationType
{
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    
    if ([self isITunesUrlString:[[request URL] absoluteString]] == YES) {
        [[UIApplication sharedApplication] openURL:[request URL]];
        return NO;
    }
    
	return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
	NSString *urlString = [[[webView request] URL] absoluteString];
	if ([urlString rangeOfString:[P4RCServerConfig serverHost]].location != NSNotFound)
	{
		[self setLastURLString:urlString];
	}
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showInternetIsNotAvailableAlert) object:nil];
	[activityIndicatorView_ stopAnimating];
	[blankView_ setHidden:YES];
	[webView_ setUserInteractionEnabled:YES];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    if ([error code] != NSURLErrorCancelled && [error code] != 102)
    {
        [self showInternetIsNotAvailableAlert];
    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if ([alertView tag] == NO_INTERNET_CONNECTION_ALERT_TAG)
    {
        [self hide];
    }
}

#pragma mark -
#pragma mark Private

- (BOOL)isITunesUrlString:(NSString *)urlString
{
    if ([urlString rangeOfString:@"://itunes.apple.com/"].location != NSNotFound)
    {
        return YES;
    }
    return NO;
}

- (UIInterfaceOrientation)currentOrientation
{
    if (currentOrientation_ == 0)
    {
        currentOrientation_ = UIInterfaceOrientationPortrait;
    }
    return currentOrientation_;
}

- (void)configureScrollView:(UIScrollView *)scrollView {
	[scrollView setAlwaysBounceVertical:YES];
	[scrollView setAlwaysBounceHorizontal:NO];
	[scrollView setDelaysContentTouches:NO];
}

- (void)updateWithOrientation:(UIInterfaceOrientation)orientation
{
    [super updateWithOrientation:orientation];
    
    [self setCurrentOrientation:orientation];
    
	[backView_ setFrame:[self backRect]];
	[blankView_ setFrame:[self browserRect]];
    [webView_ setFrame:[self browserRectForOrientation:orientation]];
    [backView_ setFrame:[self backRectForOrientation:orientation]];
    [closeButton_ setFrame:[self closeButtonRectForOrientation:orientation]];
    
    UIImage *image = [UIImage imageNamed:@"P4RC.bundle/splash_back.png"];
    image = [UIImage imageWithCGImage:image.CGImage scale:image.scale orientation:(UIInterfaceOrientationIsPortrait(orientation) ? UIImageOrientationRight : UIImageOrientationUp)];
    blueBackImageView_.image = image;
    blueBackImageView_.frame = fadeView_.bounds;
}

- (CGRect)generalRectForOrientation:(UIInterfaceOrientation)orientation
{
    CGFloat width = 0;
    CGFloat height = 0;
    
    if (UIInterfaceOrientationIsPortrait(orientation) == YES)
    {
        width = [[[UIApplication sharedApplication] keyWindow] frame].size.width;
        height = [[[UIApplication sharedApplication] keyWindow] frame].size.height;
    }
    else
    {
        width = [[[UIApplication sharedApplication] keyWindow] frame].size.height;
        height = [[[UIApplication sharedApplication] keyWindow] frame].size.width;
    }
    
    return CGRectMake(0, 0, width, height);
}

- (CGRect)generalRect
{
    UIInterfaceOrientation orientation = [self currentOrientation];
    return [self generalRectForOrientation:orientation];
}

- (CGRect)browserRectForOrientation:(UIInterfaceOrientation)orientation
{
    CGRect generalRect = [self generalRectForOrientation:orientation];
    CGFloat width = generalRect.size.width;
    CGFloat height = generalRect.size.height;
    CGFloat browserWidth = width;
    CGFloat browserHeight = height;
    
    if ([P4RCUtils deviceType] == P4RCDeviceTypeIPad)
    {
        browserWidth = 480;
        browserHeight = 768;
    }
    else
    {
        browserHeight = (browserHeight > 480 ? 480 : browserHeight);
        browserWidth = (browserWidth > 480 ? 480 : browserWidth);
    }
    
    browserWidth -= 2 * [self margin];
    browserHeight -= 2 * [self margin] + TOP_PANEL_HEIGHT;
    
    return CGRectMake((width - browserWidth) / 2,
                      (height - browserHeight + TOP_PANEL_HEIGHT) / 2,
                      browserWidth,
                      browserHeight);
}

- (CGRect)browserRect
{
    UIInterfaceOrientation orientation = [self currentOrientation];
    return [self browserRectForOrientation:orientation];
}

- (CGRect)contentRect {
	CGRect rect = [self browserRect];
	rect.origin.x = 0;
	rect.origin.y = 0;
	return rect;
}

- (CGRect)backRectForOrientation:(UIInterfaceOrientation)orientation
{
    CGRect rect = [self browserRectForOrientation:orientation];
    
    rect.origin.y -= TOP_PANEL_HEIGHT;
    rect.size.height += TOP_PANEL_HEIGHT;

    return rect;
}

- (CGRect)backRect
{
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    return [self backRectForOrientation:orientation];
}

- (CGRect)closeButtonRectForOrientation:(UIInterfaceOrientation)orientation
{
    return CGRectMake([self backRectForOrientation:orientation].origin.x + [self backRectForOrientation:orientation].size.width - TOP_PANEL_HEIGHT,
                      [self backRectForOrientation:orientation].origin.y,
                      TOP_PANEL_HEIGHT,
                      TOP_PANEL_HEIGHT);
}

- (CGRect)closeButtonRect
{
    return [self closeButtonRectForOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
}

- (void)disableJavascriptAlerts
{
    [webView_ stringByEvaluatingJavaScriptFromString:@"window.alert=null;"];
}

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
	if ([animationID isEqualToString:ANIMATION_SHOW_BROWSER])
	{
		//if ([P4RCUtils deviceType] == P4RCDeviceTypeIPad)
		{
			[fadeView_ setHidden:NO];
		}
	}
	else if ([animationID isEqualToString:ANIMATION_HIDE_BROWSER])
	{
        if (webView_ != nil)
        {
            [webView_ setDelegate:nil];
            [webView_ stopLoading];
            [webView_ removeFromSuperview];
            [webView_ release];
            webView_ = nil;
        }
        
		[self removeFromSuperview];
        [self setTransform:CGAffineTransformIdentity];
	}
}

- (void)closeDidPress:(id)sender
{
    [self hide];
}

- (void)backDidPress:(id)sender
{
	[webView_ goBack];
}	

- (CGFloat)margin
{
	return 10;
}

- (void)retryToLoadPage
{
	[webView_ loadHTMLString:@"" baseURL:nil];
	[webView_ loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[self lastURLString]]]];
}

- (void)showInternetIsNotAvailableAlert
{
    [self disableJavascriptAlerts];
    if (isAboutToBeClosed == YES)
    {
        return;
    }
    isAboutToBeClosed = YES;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showInternetIsNotAvailableAlert) object:nil];
    [webView_ setDelegate:nil];
    
    UIAlertView *alertView = [P4RCUtils internetIsNotAvailableAlert];
    [alertView setTag:NO_INTERNET_CONNECTION_ALERT_TAG];
    [alertView setDelegate:self];
    [alertView show];
}

@end
