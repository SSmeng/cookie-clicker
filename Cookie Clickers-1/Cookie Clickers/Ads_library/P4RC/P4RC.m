//
//  P4RC.m
//  PRCExample
//
//  Created by Lenin on 6/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "P4RC.h"
#import "P4RCPointsManager.h"
#import "P4RCFramedBrowserView.h"
#import "P4RCCacheManager.h"
#import "P4RCUtils.h"
#import "ServerGateway.h"
#import "P4RCServerConfig.h"
#import "NSData+CommonCrypto.h"
#import "P4RCScreensController.h"
#import "server.h"
#import "PingHistory.h"
#import "P4RCUtils.h"
#import "P4RCEncodingUtil.h"
#import "FacebookSDK.h"

#define FACEBOOK_APP_ID                 @"269252363122513"

@interface P4RC () <ReceiverProtocol, P4RCFramedBrowserViewDelegate, P4RCPointsManagerDelegate, P4RCScreensControllerDelegate, P4RCPingHistoryDelegate>

@property (nonatomic, readonly) P4RCFramedBrowserView *framedBrowserView;
@property (nonatomic, readonly) P4RCPointsManager *pointsManager;
@property (nonatomic, readonly) P4RCScreensController *screensController;

@property (nonatomic, copy) NSString *couponImageUrlString;
@property (nonatomic, copy) NSString *couponDescription;
@property (nonatomic, copy) NSString *firstName;
@property (nonatomic, copy) NSString *lastName;
@property (nonatomic, assign) NSInteger newRewardsCount;
@property (nonatomic, retain) PingHistory *eventLogger;

- (void)initialize;
- (void)checkUserState;
- (void)presentMainMenuPage;
- (void)removeP4RCSessionCookie;
- (void)useCookieFromCache;
- (NSHTTPCookie *)currentSessionIdCookie;
- (void)applicationDidBecomeActive;

@end


@implementation P4RC

@synthesize framedBrowserView;
@synthesize pointsManager;
@synthesize screensController;
@synthesize gameRefId;
@synthesize couponImageUrlString;
@synthesize couponDescription;
@synthesize firstName;
@synthesize lastName;
@synthesize newRewardsCount;
@synthesize eventLogger;

static P4RC *sharedP4RC = nil;

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
	[pointsManager release];
	[framedBrowserView release];
	[gameRefId release];
	[couponImageUrlString release];
	[couponDescription release];
	[screensController release];
	[super dealloc];
}

#pragma mark -
#pragma mark Public

- (void)setGameRefId:(NSString *)theGameRefId {
    if (gameRefId != theGameRefId) {
        [gameRefId release];
        gameRefId = [theGameRefId copy];
    }
    if ([[NSFileManager defaultManager] fileExistsAtPath:[P4RCUtils pathToFileWithName:[NSString stringWithFormat:@"%@.plist", gameRefId]]]) {
        NSArray *tableArray = [P4RCEncodingUtil loadArrayWithDecryptedContentOfFile:[P4RCUtils pathToFileWithName:[NSString stringWithFormat:@"%@.plist", gameRefId]]];
        [[self pointsManager] setPointsTable:tableArray];
    }
    
    // try to load saved max score
    if ([[NSFileManager defaultManager] fileExistsAtPath:[P4RCUtils pathToFileWithName:[NSString stringWithFormat:@"%@_maxscore.plist", gameRefId]]]) {
        NSArray *maxPointsArray = [P4RCEncodingUtil loadArrayWithDecryptedContentOfFile:[P4RCUtils pathToFileWithName:[NSString stringWithFormat:@"%@_maxscore.plist", gameRefId]]];

        [pointsManager setMaxPointsPerLevel:[[maxPointsArray objectAtIndex:0] integerValue]];
    }
}

- (UIImage *)imageForButton
{
    return [UIImage imageNamed:[self imageNameForButtonState:UIControlStateNormal forDeviceType:[P4RCUtils deviceType]]];
}

- (NSString *)imageNameForButtonState:(UIControlState)controlState forDeviceType:(P4RCDeviceType)deviceType
{
    if (deviceType == P4RCDeviceTypeIPhone)
    {
        if (controlState == UIControlStateNormal)
        {
            return @"P4RC.bundle/logo_main_menu.png";
        }
        else if (controlState == UIControlStateHighlighted)
        {
            return @"P4RC.bundle/logo_main_menu.png";   // FIXME
        }
    }
    else if (deviceType == P4RCDeviceTypeIPad)
    {
        if (controlState == UIControlStateNormal)
        {
            return @"P4RC.bundle/logo_main_menu_ipad.png";
        }
        else if (controlState == UIControlStateHighlighted)
        {
            return @"P4RC.bundle/logo_main_menu_ipad.png";   // FIXME
        }
    }
    return nil;
}

- (NSString *)imageNameForButtonStateNormal
{
    return @"P4RC.bundle/logo_main_menu.png";
}

- (NSString *)imageNameForButtonStateHighlighted
{
    return @"P4RC.bundle/logo_main_menu.png";
}

#pragma mark Initialization

- (void)initialize
{
    isInitialized = YES;
}

- (void)initializeWithTestServer
{
    [self initializeWithServerHost:TEST_SERVER_HOST andApiKey:DEFAULT_API_KEY];
}

- (void)initializeWithProductionServerAndApikey:(NSString *)apiKey
{
    [self initializeWithServerHost:PRODUCTION_SERVER_HOST andApiKey:apiKey];
}

- (void)initializeWithServerHost:(NSString *)serverHost andApiKey:(NSString *)apiKey
{
    [P4RCServerConfig setServerHost:serverHost];
    [P4RCServerConfig setApiKey:apiKey];
    [self initialize];
}

#pragma mark Appearance

- (void)showMain
{
    if (isInitialized == YES)
    {
        [self useCookieFromCache];
        if ([self isLoggedIn] == YES)
        {
            [[self pointsManager] checkInCachedPoints];
        }
        [self presentMainMenuPage];
    }
}

- (void)showSplash
{
    [[self screensController] showSplash];
}

#pragma mark Authorization

- (BOOL)isLoggedIn
{
	NSString *sessionId = [P4RCCacheManager sessionId];
	if ((sessionId == nil) || ([sessionId isEqualToString:@""]))
	{
		return NO;
	}
	
	return YES;
}

- (void)logout
{
	[P4RCCacheManager setSessionId:nil];
	[P4RCCacheManager setSessionIdCookie:nil];
	[[self pointsManager] resetP4RCPoints];
}

#pragma mark Points

- (void)gameWasRestarted
{
	[[self pointsManager] resetGamePoints];
}

- (void)totalGamePointsWasChangedTo:(NSInteger)gamePoints
{
	[[self pointsManager] setTotalGamePoints:gamePoints];
}

- (void)didCompleteLevel:(NSInteger)level withTotalPoints:(NSInteger)totalGamePoints
{
	[[self pointsManager] checkInTotalPoints:totalGamePoints afterLevel:level];
}

- (void)didCompleteLevel:(NSInteger)level withPoints:(NSInteger)levelGamePoints
{
	[[self pointsManager] checkInPoints:levelGamePoints forLevel:level];
}

- (void)didStartLevel
{
    [eventLogger logStartLevelForGameRefId:gameRefId];
	[[self pointsManager] setLevelStartDate:[NSDate date]];
    
}

- (NSInteger)lastP4RCPoints
{
	return [[self pointsManager] lastP4RCPoints];
}

- (NSInteger)totalP4RCPoints
{
	return [[self pointsManager] totalP4RCPoints];
}

- (void)didSuccessfullPing {
    [[ServerGateway sharedInstance] getPointsTableForGameRefId:[self gameRefId]
                                                   forReceiver:self];
    
    [[ServerGateway sharedInstance] getMaxPointsForGameRefId:[self gameRefId]
                                                 forReceiver:self];
}

- (void)tableReceived:(NSArray*)pointsTable {
    [pointsManager setPointsTable:pointsTable];
    
    // save received table localy
    NSString *path = [NSString stringWithFormat:@"%@.plist", [P4RCUtils pathToFileWithName:[self gameRefId]]];
	[P4RCEncodingUtil saveEncryptedArray:pointsTable toFile:path];
}

- (void)maxPointsReceived:(NSInteger)points {
    [pointsManager setMaxPointsPerLevel:points];
    
    // save received max points localy
    NSString *path = [NSString stringWithFormat:@"%@_maxscore.plist", [P4RCUtils pathToFileWithName:[self gameRefId]]];
	[P4RCEncodingUtil saveEncryptedArray:@[[NSNumber numberWithInteger:points]] toFile:path];
}

- (void)maxPointsReceivingFailedWithError:(NSError *)error {
    // failed to get max points
    // manager will use saved max points or default value
}

#pragma mark Info

- (void)showDescriptiveAlertView
{
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"P4RC"
														message:[NSString stringWithFormat:@"Total game points: %d"
																 "\nLast game points: %d"
																 "\nTotal P4RC points: %d"
																 "\nLast P4RC points: %d",
																 [[self pointsManager] totalGamePoints],
																 [[self pointsManager] lastGamePoints],
																 [[self pointsManager] totalP4RCPoints],
																 [[self pointsManager] lastP4RCPoints]]
													   delegate:nil
											  cancelButtonTitle:@"Ok"
											  otherButtonTitles:nil];
	[alertView show];
	[alertView release];
}

#pragma mark -
#pragma mark Singleton

+ (id)allocWithZone:(NSZone *)zone
{
    if (sharedP4RC == nil)
    {
        return [super allocWithZone:zone];
    }
    return nil;
}

- (id)retain
{
    return self;
}

-  (oneway void)release
{
}

- (id)autorelease
{
    return self;
}

- (id)init
{
	self = [super init];
	if (self)
	{
        eventLogger = [[PingHistory alloc] init];
        [eventLogger setDelegate:self];
		isInitialized = NO;
		readyForInitialization = YES;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil] ;
	}
	return self;
}

+ (id)sharedInstance
{
    if (sharedP4RC == nil)
    {
        [FBSession setDefaultAppID:FACEBOOK_APP_ID];
		sharedP4RC = [[P4RC alloc] init];
    }
    return sharedP4RC;
}

#pragma mark -
#pragma mark ReceiverProtocol

- (void)getUserInfoCompleteWithUser:(P4RCUserInfo *)user 
					newCouponsCount:(NSInteger)newCouponsCount
			eligibleNewCouponsCount:(NSInteger)eligibleNewCouponsCount
				 leaderBoardRanking:(NSInteger)leaderBoardRanking
							  error:(NSError *)error
{
	if (error != nil)
	{
		isErrorOccured = YES;
        [self removeP4RCSessionCookie];
	}
	else
	{
		[[self pointsManager] setTotalP4RCPoints:[user totalP4RCPoints]];
		[self setFirstName:[user firstName]];
		[self setLastName:[user lastName]];
		[self setNewRewardsCount:newCouponsCount];
	}
	
	isUserInfoReceived = YES;
}

- (void)getCouponImageCompleteWithUrl:(NSString *)imageUrl
						  description:(NSString *)description
								error:(NSError *)error
{
	if (error != nil)
	{
		isErrorOccured = YES;
	}
	else
	{
		[self setCouponImageUrlString:imageUrl];
		[self setCouponDescription:description];
	}
	
	isCouponImageReceived = YES;
}

#pragma mark -
#pragma mark P4RCFramedBrowserViewDelegate

- (void)p4rcFramedBrowserViewWillDisappear:(P4RCFramedBrowserView *)sender
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSHTTPCookieManagerCookiesChangedNotification
                                                  object:nil];
}

#pragma mark -
#pragma mark P4RCPointsManagerDelegate

- (void)pointsManagerDidComplete:(P4RCPointsManager *)sender
{
	[[NSNotificationCenter defaultCenter] postNotificationName:P4RCPointsWasSentOnServerNotification
                                                        object:nil];
}

- (void)pointsManagerDidFail:(P4RCPointsManager *)sender
{
	[[NSNotificationCenter defaultCenter] postNotificationName:P4RCPointsSendingDidFailNotification
                                                        object:nil];
}

- (void)pointsManagerDidCompleteLocally:(P4RCPointsManager *)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:P4RCPointsWasSentOnServerNotification
                                                        object:nil];
}

#pragma mark -
#pragma mark Private

- (NSHTTPCookie *)currentSessionIdCookie
{
	NSHTTPCookie *cookie;
	NSHTTPCookieStorage *cookies = [NSHTTPCookieStorage sharedHTTPCookieStorage];
	for (cookie in [cookies cookies])
	{
		if ([[cookie name] isEqualToString:@"p4rcSessionId"])
		{
			return cookie;
		}
	}
	return nil;
}

- (void)applicationDidBecomeActive
{
    // to restore user session after application did become active, in case if Internet connection appears while application was in background
    [self useCookieFromCache];
}

- (void)useCookieFromCache
{
    NSHTTPCookie *cookie = [P4RCCacheManager sessionIdCookie];
    
	if (cookie == nil)
	{
		NSHTTPCookie *currentCookie = [self currentSessionIdCookie];
		[[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:currentCookie];
	}
	else
	{
		[[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
	}
}

- (P4RCPointsManager *)pointsManager
{
	if (pointsManager == nil)
	{
		pointsManager = [[P4RCPointsManager alloc] initWithGameRefId:[self gameRefId] delegate:self];
        
        // try to load saved points table
        NSString *path = [NSString stringWithFormat:@"%@.plist", [P4RCUtils pathToFileWithName:[self gameRefId]]];
        if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
            [pointsManager setPointsTable:[P4RCEncodingUtil loadArrayWithDecryptedContentOfFile:path]];
        }
        
        // try to load saved max score
        NSString *maxScorePath = [NSString stringWithFormat:@"%@_maxscore.plist", [P4RCUtils pathToFileWithName:[self gameRefId]]];
        if ([[NSFileManager defaultManager] fileExistsAtPath:maxScorePath]) {
            [pointsManager setMaxPointsPerLevel:[[[P4RCEncodingUtil loadArrayWithDecryptedContentOfFile:maxScorePath] objectAtIndex:0] integerValue]];
        }
	}
	return pointsManager;
}

- (P4RCFramedBrowserView *)frameBrowserView
{
	if (framedBrowserView == nil)
	{
		framedBrowserView = [[P4RCFramedBrowserView alloc] init];
		[framedBrowserView setDelegate:self];
	}
	return framedBrowserView;
}

- (P4RCScreensController *)screensController
{
    if (screensController == nil)
    {
        screensController = [[P4RCScreensController alloc] init];
        [screensController setDelegate:self];
    }
    return screensController;
}

- (void)checkUserState
{
	NSHTTPCookie *oldCookie = [P4RCCacheManager sessionIdCookie];
	NSHTTPCookie *newCookie = [self currentSessionIdCookie];
	BOOL needToCheckin = (oldCookie == nil) && (newCookie != nil);
    
    if (newCookie != nil) {
        [P4RCCacheManager setSessionId:[[self currentSessionIdCookie] value]];
        [P4RCCacheManager setSessionIdCookie:newCookie];
        
        if (needToCheckin == YES)
        {
            [[self pointsManager] checkInCachedPoints];
        }
    }
    else {
        [self logout];
    }
}



- (void)logoutFromFacebook
{
	NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
	NSInteger index = 0;
	while (index < [cookies count])
	{
		NSHTTPCookie *cookie = [cookies objectAtIndex:index];
		if ([[cookie domain] rangeOfString:@".facebook.com"].location != NSNotFound)
		{
			[[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
			cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
		}
		else
		{
			index++;
		}
	}
}

- (void)removeP4RCSessionCookie
{
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    for (NSHTTPCookie *cookie in cookies)
    {
        if ([[cookie name] isEqualToString:@"p4rcSessionId"] == YES)
        {
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
            break;
        }
    }
}

- (void)presentMainMenuPage
{
    NSInteger p4rcPoints = [[self pointsManager] lastP4RCPoints];
	NSInteger level = [P4RCCacheManager lastLevelPlayed];
	level = level < 1 ? 1 : level;
	
	NSMutableString *urlString = [[NSMutableString alloc] initWithString:[NSString stringWithFormat:@"%@mIndex.html#showGamersExp&p=[%d,%d,0,", [P4RCServerConfig serverAddress], p4rcPoints, level]];
	[urlString appendString:@"%22"];
	[urlString appendString:[self gameRefId]];
	[urlString appendString:@"%22"];
	[urlString appendString:@"]"];
	[[self frameBrowserView] showWithURLString:[NSString stringWithString:urlString]];
	[urlString release];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(checkUserState)
                                                 name:NSHTTPCookieManagerCookiesChangedNotification
                                               object:nil];
}

#pragma mark -
#pragma mark P4RCBannerManagerDataSource

- (NSInteger)totalP4RCPointsForBannerManager:(P4RCBannerManager *)sender
{
	return [[self pointsManager] totalP4RCPoints];
}

- (NSInteger)lastP4RCPointsForBannerManager:(P4RCBannerManager *)sender
{
	return [[self pointsManager] lastP4RCPoints];
}

- (NSInteger)totalGamePointsForBannerManager:(P4RCBannerManager *)sender
{
	return [[self pointsManager] totalGamePoints];
}

- (NSString *)couponImageUrlStringForBannerManager:(P4RCBannerManager *)sender
{
	return couponImageUrlString;
}

- (NSString *)couponDescriptionForBannerManager:(P4RCBannerManager *)sender
{
	return couponDescription;
}

- (NSString *)firstNameForBannerManager:(P4RCBannerManager *)sender
{
	return [self firstName];
}

- (NSString *)lastNameForBannerManager:(P4RCBannerManager *)sender
{
	return [self lastName];
}

- (NSInteger)newRewardsCountForBannerManager:(P4RCBannerManager *)sender
{
	return [self newRewardsCount];
}

#pragma mark - P4RCScreensControllerDelegate

- (void)screensController:(P4RCScreensController *)sender didAuthizeWithUserInfo:(P4RCUserInfo *)userInfo
{
    [[self pointsManager] setTotalP4RCPoints:[userInfo totalP4RCPoints]];
    [self setFirstName:[userInfo firstName]];
    [self setLastName:[userInfo lastName]];
}

#pragma mark - Banners (DEPRECATED!!! NO IMPLEMENTATION)

- (void)setBannersTop:(CGFloat)top {
}

- (void)setBannersTopPosition:(P4RCBannerPosition)topPosition{
}

- (void)setBannersTimeBeforeHiding:(CGFloat)delay{
}

- (void)showWelcomeBanner{
}

- (void)hideWelcomeBanner{
}

- (void)showInterstitialBanner{
}

- (void)hideInterstitialBanner{
}

- (void)hideAllBanners{
}

@end



