//
//  P4RC.h
//  PRCExample
//
//  Created by Lenin on 6/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "P4RCTypes.h"

// old for banners support
typedef enum
{
	P4RCBannerPositionUndefined = 0,
	P4RCBannerPositionTop = 1,
	P4RCBannerPositionBottom = 2,
} P4RCBannerPosition;

#define P4RCInitializationDidCompleteNotification               @"P4RCInitializationDidCompleteNotification"
#define P4RCInitializationDidFailNotification					@"P4RCInitializationDidFailNotification"
#define P4RCPointsWasSentOnServerNotification					@"P4RCPointsWasSentOnServerNotification"
#define P4RCPointsSendingDidFailNotification					@"P4RCPointsSendingDidFailNotification"


@class P4RCPointsManager;
@class P4RCFramedBrowserView;
@class P4RCBannerManager;
@class P4RCScreensController;

@interface P4RC : NSObject
{
	@private
	P4RCPointsManager *pointsManager;
	P4RCFramedBrowserView *framedBrowserView;
    P4RCScreensController *screensController;
	
	NSString *gameRefId;
	NSString *couponImageUrlString;
	NSString *couponDescription;
	NSString *firstName;
	NSString *lastName;
	NSInteger newRewardsCount;
	
	BOOL isInitialized;
	BOOL readyForInitialization;
	BOOL isUserInfoReceived;
	BOOL isCouponImageReceived;
	BOOL isErrorOccured;
}

@property (nonatomic, copy, readwrite) NSString *gameRefId;

+ (id)sharedInstance;

// this method should be sent as soon as possible. When initialization complete, notification ... will be sent
- (void)initializeWithTestServer;
- (void)initializeWithProductionServerAndApikey:(NSString *)apiKey;
- (void)initializeWithServerHost:(NSString *)serverHost andApiKey:(NSString *)apiKey;

// FIXME: deprecated
- (UIImage *)imageForButton;	// image for P4RC button

- (NSString *)imageNameForButtonState:(UIControlState)controlState forDeviceType:(P4RCDeviceType)deviceType;

- (void)gameWasRestarted;	// should be sent, when game is restarted and game points being reset
- (void)totalGamePointsWasChangedTo:(NSInteger)gamePoints;
- (void)showMain;		// should be sent when P4RC button is pressed
- (void)showSplash;
- (BOOL)isLoggedIn;		// is user logged in
- (void)logout;			// reset cached session id and cookie
- (void)didCompleteLevel:(NSInteger)level withTotalPoints:(NSInteger)totalGamePoints;		// should be sent, when user complete some level
- (void)didCompleteLevel:(NSInteger)level withPoints:(NSInteger)levelGamePoints;		// should be sent, when user complete some level
- (void)didStartLevel;
// Annotation: 1) levels go from 1
//             2) points have to be total for the game, sum for all completed levels
- (NSInteger)lastP4RCPoints;	// last earned P4RC points by current user
- (NSInteger)totalP4RCPoints;	// total earned P4RC points by current user
- (void)showDescriptiveAlertView;
- (void)tableReceived:(NSArray*)pointsTable;

// BANNERS
#warning DEPRECATED!! Methods don't have an implementation. 

// settings
- (void)setBannersTop:(CGFloat)top;
- (void)setBannersTopPosition:(P4RCBannerPosition)topPosition;
- (void)setBannersTimeBeforeHiding:(CGFloat)delay;
// welcome
- (void)showWelcomeBanner;
- (void)hideWelcomeBanner;
// interstitial
- (void)showInterstitialBanner;
- (void)hideInterstitialBanner;
// general
- (void)hideAllBanners;


@end
