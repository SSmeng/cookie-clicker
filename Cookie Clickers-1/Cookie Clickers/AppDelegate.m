//
//  AppDelegate.m
//  Cookie Clickers
//
//  Created by Cookiedev on 10/9/13.
//  Copyright __MyCompanyName__ 2013. All rights reserved.
//

#import "cocos2d.h"

#import "AppDelegate.h"
#import "GameConfig.h"
#import "HelloWorldLayer.h"
#import "MKStoreManager.h"
#import "RootViewController.h"
#import "FileIO.h"
#import "SNAdsManager.h"

@implementation AppDelegate

@synthesize cb;
@synthesize window;
@synthesize fx;
@synthesize fy;
@synthesize bRetina;
@synthesize gameCenterManager, currentLeaderBoard;
@synthesize gameScore;
@synthesize viewController2;
@synthesize arraySound;
@synthesize nRemoveAds;
@synthesize m_gameFile;

@synthesize nTotalGameAutoClickClickers;

@synthesize nAutoClickClickers;
@synthesize nAutoClickLevel;
@synthesize nCFactoryClickers;
@synthesize nCFactoryLevel;
@synthesize nCookieFarmClickers;
@synthesize nCookieFarmLevel;
@synthesize nCRobotClickers;
@synthesize nCRobotLevel;
@synthesize nGrandMaClickers;
@synthesize nGrandMaLevel;

@synthesize nCurClickAmounts;
@synthesize fCurCps;
@synthesize fBaseCps;

@synthesize m_gameScene;

- (void) removeStartupFlicker
{
	//
	// THIS CODE REMOVES THE STARTUP FLICKER
	//
	// Uncomment the following code if you Application only supports landscape mode
	//
#if GAME_AUTOROTATION == kGameAutorotationUIViewController

//	CC_ENABLE_DEFAULT_GL_STATES();
//	CCDirector *director = [CCDirector sharedDirector];
//	CGSize size = [director winSize];
//	CCSprite *sprite = [CCSprite spriteWithFile:@"Default.png"];
//	sprite.position = ccp(size.width/2, size.height/2);
//	sprite.rotation = -90;
//	[sprite visit];
//	[[director openGLView] swapBuffers];
//	CC_ENABLE_DEFAULT_GL_STATES();
	
#endif // GAME_AUTOROTATION == kGameAutorotationUIViewController	
}
- (void) applicationDidFinishLaunching:(UIApplication*)application
{
	// Init the window
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	// Try to use CADisplayLink director
	// if it fails (SDK < 3.1) use the default director
	if( ! [CCDirector setDirectorType:kCCDirectorTypeDisplayLink] )
		[CCDirector setDirectorType:kCCDirectorTypeDefault];
	
	
	CCDirector *director = [CCDirector sharedDirector];
	
	// Init the View Controller
	viewController = [[RootViewController alloc] initWithNibName:nil bundle:nil];
	viewController.wantsFullScreenLayout = YES;
	
	//
	// Create the EAGLView manually
	//  1. Create a RGB565 format. Alternative: RGBA8
	//	2. depth format of 0 bit. Use 16 or 24 bit for 3d effects, like CCPageTurnTransition
	//
	//
	EAGLView *glView = [EAGLView viewWithFrame:[window bounds]
								   pixelFormat:kEAGLColorFormatRGB565	// kEAGLColorFormatRGBA8
								   depthFormat:0						// GL_DEPTH_COMPONENT16_OES
						];
	
	// attach the openglView to the director
	[director setOpenGLView:glView];
	
//	// Enables High Res mode (Retina Display) on iPhone 4 and maintains low res on all other devices
//	if( ! [director enableRetinaDisplay:YES] )
//		CCLOG(@"Retina Display Not supported");
	
	//
	// VERY IMPORTANT:
	// If the rotation is going to be controlled by a UIViewController
	// then the device orientation should be "Portrait".
	//
	// IMPORTANT:
	// By default, this template only supports Landscape orientations.
	// Edit the RootViewController.m file to edit the supported orientations.
	//
#if GAME_AUTOROTATION == kGameAutorotationUIViewController
	[director setDeviceOrientation:kCCDeviceOrientationPortrait];
#else
	[director setDeviceOrientation:kCCDeviceOrientationLandscapeLeft];
#endif
	
	[director setAnimationInterval:1.0/60];
	[director setDisplayFPS:NO];
	
	
	// make the OpenGLView a child of the view controller
	[viewController setView:glView];
	
	// make the View Controller a child of the main window
	[window addSubview: viewController.view];
	
	[window makeKeyAndVisible];
	
    [MKStoreManager sharedManager];
    
    [self getInitInfo];
    [self loadSounds];
    
    //game file
    self.m_gameFile = [[FileIO alloc] initFileIO];
    [self loadParam];
    
    [self initGameCenter];
    
    nCurClickAmounts = 0;
    fCurCps = nAutoClickLevel * 0.1 + nGrandMaLevel * 0.3 + nCRobotLevel * 1.0f + nCookieFarmLevel * 3.1f + nCFactoryLevel * 6.0f;
    fBaseCps = nAutoClickLevel * 0.1 + nGrandMaLevel * 0.3 + nCRobotLevel * 1.0f + nCookieFarmLevel * 3.1f + nCFactoryLevel * 6.0f;

	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];

	
	// Removes the startup flicker
	[self removeStartupFlicker];
	
    [[SNAdsManager sharedManager] loadPLISTValues: viewController];
    
    /*
    cb = [Chartboost sharedChartboost];
    cb.appId = @"519d7b0517ba47e72a00000a";
    cb.appSignature = @"ca60775b137e0978327fb6dcd3a6098ea7373aa8";
    
    cb.delegate = self;
    
    // Begin a user session. This should be done once per boot
    [cb startSession];
    
    [cb cacheInterstitial];
    
    [cb showInterstitial];
    */
    
    //UIViewController* rootVC = [self getRootViewController];
    
    //In order to check if fullscreen can pop-up, we need to create an AppLovin's banner adView so that we can AppLovin's ads listener. After we finish the checking, we remove this banner ads because this is not a function for banner ads.
    
    /*
    ALAdView * adView_temporary = [[ALAdView alloc] initBannerAd];
    adView_temporary.adDisplayDelegate = self;
    adView_temporary.adLoadDelegate = self;
    adView_temporary.frame = CGRectMake(0,0,0,0);
    [viewController.view addSubview: adView_temporary];
    [adView_temporary loadNextAd];
    [adView_temporary removeFromSuperview];
    
    //this is a full screen ads
    [ALSdk initializeSdk];
    [ALInterstitialAd showOver:viewController.view.window];
    */
    
	// Run the intro Scene
	[[CCDirector sharedDirector] runWithScene: [HelloWorldLayer scene]];
}

- (void) getInitInfo
{
    bRetina = false;
    
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    NSLog(@"%f", [[CCDirector sharedDirector] contentScaleFactor]);
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        if ([[CCDirector sharedDirector] enableRetinaDisplay:YES])
        {
            if (winSize.height == 568)
                bRetina = true;
            
            fx = 1.0f;
            fy = 1.0f;
        }
        else
        {
            fx = 0.5f;
            fy = 0.5f;
        }
    }
    else
    {
        fx = 768.f / 640.f;
        fy = 1024.f / 960.f;
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
	[[CCDirector sharedDirector] pause];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	[[CCDirector sharedDirector] resume];
    
 
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
	[[CCDirector sharedDirector] purgeCachedData];
}

-(void) applicationDidEnterBackground:(UIApplication*)application {
	[[CCDirector sharedDirector] stopAnimation];
}

-(void) applicationWillEnterForeground:(UIApplication*)application {
    [[SNAdsManager sharedManager]giveMeWillEnterForegroundAd];
	[[CCDirector sharedDirector] startAnimation];
}

- (void)applicationWillTerminate:(UIApplication *)application {
	CCDirector *director = [CCDirector sharedDirector];
	
	[[director openGLView] removeFromSuperview];
	
    [[SNAdsManager sharedManager]stopVungle];
    
	[viewController release];
	
	[window release];
	
	[director end];	
}

- (void)applicationSignificantTimeChange:(UIApplication *)application {
	[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
}

- (void) loadSounds
{
    NSURL *urlFileName;
	NSError *error = nil;
    
    arraySound = [[NSMutableArray alloc] init];
    
    AVAudioPlayer * avPlayer;
    
    NSMutableArray* arraySoundName = [[NSMutableArray alloc] initWithObjects:@"click", @"click2", nil];
    
    for (int i = 0; i < [arraySoundName count]; i ++)
    {
        urlFileName = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:[arraySoundName objectAtIndex:i] ofType:@"caf"]];
        avPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL: urlFileName error:&error];
        
        avPlayer.volume = 2.0f;
        
        [arraySound addObject:[avPlayer retain]];
    }
}

-(NSUInteger) getChangedClickers:(NSUInteger) nNumsIdx clickerType:(NSUInteger) nType
{
    NSUInteger nRet;
    
    NSUInteger nFirstNum = 0;
    NSUInteger nSecondNum = 1;
    NSUInteger nThirdNum = 2;
    
    for (NSUInteger nIdx = 0; nIdx < nNumsIdx; nIdx++)
    {
        nRet = nFirstNum + nThirdNum;
        nFirstNum = nSecondNum;
        nSecondNum = nThirdNum;
        nThirdNum = nRet;
    }
    
    switch (nType) {
        case 0:
            nRet = nRet * 3;
            break;

        case 1:
            nRet = 30 + nRet * 3;
            break;

        case 2:
            nRet = (30 + nRet * 3) * 10;
            break;

        case 3:
            nRet = (30 + nRet * 3) * 100;
            break;

        case 4:
            nRet = (30 + nRet * 3) * 100;
            break;

        default:
            break;
    }

    return nRet;
}

#define PR_POS 7200
-(BOOL) loadParam
{
    int pt = PR_POS;
	@try {
		[self.m_gameFile openFile:YES];
		int nFlag = [self.m_gameFile readInt:pt]; pt +=4;
		if (nFlag != 1) {
            nRemoveAds = 0;
            nTotalGameAutoClickClickers = 0;
            nAutoClickClickers = 30;
            nAutoClickLevel = 0;
            nCFactoryClickers = 50000;
            nCFactoryLevel = 0;
            nCookieFarmClickers = 10000;
            nCookieFarmLevel = 0;
            nCRobotClickers = 1000;
            nCRobotLevel = 0;
            nGrandMaClickers = 100;
            nGrandMaLevel = 0;
		}
		else {
			nRemoveAds = [self.m_gameFile readInt:pt]; pt += 4;
            nTotalGameAutoClickClickers = [self.m_gameFile readInt:pt]; pt += 4;
			nAutoClickClickers = [self.m_gameFile readInt:pt]; pt += 4;
			nAutoClickLevel = [self.m_gameFile readInt:pt]; pt += 4;
			nCFactoryClickers = [self.m_gameFile readInt:pt]; pt += 4;
			nCFactoryLevel = [self.m_gameFile readInt:pt]; pt += 4;
			nCookieFarmClickers = [self.m_gameFile readInt:pt]; pt += 4;
			nCookieFarmLevel = [self.m_gameFile readInt:pt]; pt += 4;
			nCRobotClickers = [self.m_gameFile readInt:pt]; pt += 4;
			nCRobotLevel = [self.m_gameFile readInt:pt]; pt += 4;
			nGrandMaClickers = [self.m_gameFile readInt:pt]; pt += 4;
			nGrandMaLevel = [self.m_gameFile readInt:pt]; pt += 4;
            
		}
        
		[self.m_gameFile closeFile];
		
	}
	@catch (NSException * e) {
		NSLog(@"load err: %@", e);
		return FALSE;
	}
    
    return TRUE;
    
}

-(BOOL) saveParam
{
	int pt = PR_POS;
    
	@try {
		[self.m_gameFile openFile:NO];
		[self.m_gameFile writeInt:pt :1]; pt += 4; // set flag = 1
        [self.m_gameFile writeInt:pt :nRemoveAds]; pt += 4;
        [self.m_gameFile writeInt:pt :nTotalGameAutoClickClickers]; pt += 4;
        [self.m_gameFile writeInt:pt :nAutoClickClickers]; pt += 4;
        [self.m_gameFile writeInt:pt :nAutoClickLevel]; pt += 4;
        [self.m_gameFile writeInt:pt :nCFactoryClickers]; pt += 4;
        [self.m_gameFile writeInt:pt :nCFactoryLevel]; pt += 4;
        [self.m_gameFile writeInt:pt :nCookieFarmClickers]; pt += 4;
        [self.m_gameFile writeInt:pt :nCookieFarmLevel]; pt += 4;
        [self.m_gameFile writeInt:pt :nCRobotClickers]; pt += 4;
        [self.m_gameFile writeInt:pt :nCRobotLevel]; pt += 4;
        [self.m_gameFile writeInt:pt :nGrandMaClickers]; pt += 4;
        [self.m_gameFile writeInt:pt :nGrandMaLevel]; pt += 4;
		[self.m_gameFile closeFile];
	}
	@catch (NSException * e) {
		NSLog(@"save err: %@",e);
		return FALSE;
	}
	return TRUE;
    
}

#pragma mark Action Methods
- (void) addOne{
	NSString* identifier= NULL;
	double percentComplete= 0;
    
	if (gameScore == 100) {
		identifier= kAchievement100;
		percentComplete= 100.0;
	}
	else if ( gameScore == 300) {
		identifier= kAchievement300;
		percentComplete= 300.0;
	}
	else if ( gameScore == 600) {
		identifier= kAchievement600;
		percentComplete= 600.0;
	}
	else if ( gameScore >= 1000) {
		identifier= kAchievement1000;
		percentComplete= 1000.0;
	}
	if(identifier!= NULL){
		[self.gameCenterManager submitAchievement: identifier percentComplete: percentComplete];
	}
    //	[self performSelector:@selector(submitScore) withObject:nil afterDelay:0.2];
}

- (void)submitScore
{
	if( gameScore > 0){
        
        if ([GameCenterManager isGameCenterAvailable])
        {
            //            [self initGameCenter];
            
            [self.gameCenterManager reportScore:self.gameScore  forCategory: self.currentLeaderBoard];
            //                     [self.gameCenterManager reloadHighScoresForCategory:self.currentLeaderBoard];
        }
	}
}

- (void) scoreReported: (NSError*) error;
{
	if(error == NULL)
	{
		[self.gameCenterManager reloadHighScoresForCategory: self.currentLeaderBoard];
        //		[self showAlertWithTitle: @"Score Reported in Game Center!"
        //						 message: [NSString stringWithFormat: @"", [error localizedDescription]]];
	}
    //	else
    //	{
    //		[self showAlertWithTitle: @"Score Report Failed!"
    //						 message: [NSString stringWithFormat: @"Reason: %@", [error localizedDescription]]];
    //	}
}


#pragma mark GameCenter View Controllers

- (void)initGameCenter
{
	if(viewController2 != nil)
		return;
	viewController2 = [GCViewController alloc];
    self.currentLeaderBoard = kEasyLeaderboardID;
    
	if ([GameCenterManager isGameCenterAvailable])
	{
		self.gameCenterManager = [[[GameCenterManager alloc] init] autorelease];
		[self.gameCenterManager setDelegate:self];
		[self.gameCenterManager authenticateLocalUser];
	}
    
    //	viewController2.view.bounds = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    
}

- (void)abrirLDB{
    //    [self initGameCenter];
    self.currentLeaderBoard = kEasyLeaderboardID;
    if ([GameCenterManager isGameCenterAvailable]) {
        [viewController2.view setHidden:NO];
        [self.window addSubview:viewController2.view];
        [self submitScore];
        [self showLeaderboard];
        
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Notice" message:@"Gamecenter is not available in your iOS version" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
        
    }
}

- (void)abrirACHV{
    if ([GameCenterManager isGameCenterAvailable])
    {
        [viewController2.view setHidden:NO];
        [self.window addSubview:viewController2.view];
        [self showAchievements];
        
    }
}

- (void) showLeaderboard{
	GKLeaderboardViewController *leaderboardController = [[GKLeaderboardViewController alloc] init];
	if (leaderboardController != NULL) {
		leaderboardController.category = self.currentLeaderBoard;
		leaderboardController.timeScope = GKLeaderboardTimeScopeAllTime;
		leaderboardController.leaderboardDelegate = self;
		[viewController2 presentModalViewController: leaderboardController animated: YES];
        //		leaderboardController.view.transform = CGAffineTransformMakeRotation(CC_DEGREES_TO_RADIANS(0.0f));
	}
}

- (void)leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController1{
	[viewController1 dismissModalViewControllerAnimated: YES];
	[viewController2.view removeFromSuperview];
	[viewController2.view setHidden:YES];
	[viewController1 release];
}

- (void) showAchievements{
	GKAchievementViewController *achievements = [[GKAchievementViewController alloc] init];
	if (achievements != NULL){
		achievements.achievementDelegate = self;
		[viewController2 presentModalViewController: achievements animated: YES];
	}
}

- (void)achievementViewControllerDidFinish:(GKAchievementViewController *)viewController1{
	[viewController1 dismissModalViewControllerAnimated: YES];
	[viewController2.view removeFromSuperview];
	[viewController2.view setHidden:YES];
	[viewController1 release];
}

- (IBAction) resetAchievements: (id) sender{
	[gameCenterManager resetAchievements];
}

- (void)dealloc {
	[[CCDirector sharedDirector] end];
	[window release];
	[super dealloc];
}

@end
