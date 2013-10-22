//
//  P4RCFramedBrowserView.h
//  ConstaPad
//
//  Created by Artem Stepanenko on 7/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "P4RCAutorotatableView.h"


@class P4RCFramedBrowserView;

@protocol P4RCFramedBrowserViewDelegate

- (void)p4rcFramedBrowserViewWillDisappear:(P4RCFramedBrowserView *)sender;

@end


@interface P4RCFramedBrowserView : P4RCAutorotatableView
{
@private
	UILabel *errorLabel_;
	UIButton *closeButton_;
	UIButton *backButton_;
	UIActivityIndicatorView *activityIndicatorView_;
	UIWebView *webView_;
	UIView *blankView_;
	UIView *backView_;
	UIView *fadeView_;
    UIImageView *blueBackImageView_;
	
	NSString *lastURLString_;
	NSError *lastError_;
	
    UIInterfaceOrientation currentOrientation_;
	NSURL *iTunesURL_;
    
    BOOL isAboutToBeClosed;
    
	id<P4RCFramedBrowserViewDelegate> delegate_;
}

@property (nonatomic, assign) id<P4RCFramedBrowserViewDelegate> delegate;

- (id)init;
- (void)showWithURLString:(NSString *)urlString;
- (void)hide;

@end
