//
//  AppDelegate.h
//  Cookie Clickers
//
//  Created by Cookiedev on 10/9/13.
//  Copyright __MyCompanyName__ 2013. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import "GCViewController.h"
#import <GameKit/GameKit.h>
#import "GameCenterManager.h"
#import "AppSpecificValues.h"
#import "Chartboost.h"

@class RootViewController;
@class FileIO;
@class HelloWorldLayer;

@interface AppDelegate : NSObject <UIApplicationDelegate, GKAchievementViewControllerDelegate, GKLeaderboardViewControllerDelegate, GameCenterManagerDelegate> {
	UIWindow			*window;
	RootViewController	*viewController;
    
#pragma mark GAME_CENTER
    GCViewController* viewController2;
	GameCenterManager* gameCenterManager;
	NSString* currentLeaderBoard;

}

@property (nonatomic, retain) UIWindow *window;

@property (nonatomic, retain) Chartboost* cb;
@property (nonatomic, assign) CGFloat fx;
@property (nonatomic, assign) CGFloat fy;
@property (nonatomic, assign) bool bRetina;
@property (nonatomic, retain) NSMutableArray* arraySound;
@property(nonatomic, retain) GCViewController* viewController2;
@property (nonatomic, retain) GameCenterManager* gameCenterManager;
@property (nonatomic, retain) NSString* currentLeaderBoard;
@property (nonatomic) int gameScore;

@property (nonatomic, assign) NSUInteger nRemoveAds;

@property (nonatomic, retain) FileIO     *m_gameFile;

@property (nonatomic, retain) HelloWorldLayer     *m_gameScene;

@property (nonatomic, assign) NSUInteger nTotalGameAutoClickClickers;

@property (nonatomic, assign) NSUInteger nAutoClickClickers;
@property (nonatomic, assign) NSUInteger nGrandMaClickers;
@property (nonatomic, assign) NSUInteger nCRobotClickers;
@property (nonatomic, assign) NSUInteger nCookieFarmClickers;
@property (nonatomic, assign) NSUInteger nCFactoryClickers;

@property (nonatomic, assign) NSUInteger nAutoClickLevel;
@property (nonatomic, assign) NSUInteger nGrandMaLevel;
@property (nonatomic, assign) NSUInteger nCRobotLevel;
@property (nonatomic, assign) NSUInteger nCookieFarmLevel;
@property (nonatomic, assign) NSUInteger nCFactoryLevel;

@property (nonatomic, assign) NSUInteger nCurClickAmounts;

@property (nonatomic, assign) CGFloat fCurCps;
@property (nonatomic, assign) CGFloat fBaseCps;

-(BOOL) loadParam;
-(BOOL) saveParam;

-(NSUInteger) getChangedClickers:(NSUInteger) nNumsIdx clickerType:(NSUInteger) nType;

#pragma mark GAME_CENTER

- (void) addOne;
- (void) submitScore;
- (void) showLeaderboard;
- (void) showAchievements;
- (void) initGameCenter;

- (void) abrirLDB;
- (void) abrirACHV;

@end
