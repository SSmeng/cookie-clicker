

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Mobclix.h"
#import "MobclixAds.h"
#import "MobclixFeedback.h"
#import "MobclixFullScreenAdViewController.h"
#import <RevMobAds/RevMobAds.h>
#import "ChartBoost.h"
#import "PlayHavenSDK.h"
#import "ALSdk.h"
#import "ALInterstitialAd.h"
#import "ALAdView.h"
#import <iAd/iAd.h>
#import "Reachability.h"
#import "TapjoyConnect.h"
#import "Flurry.h"
#import "vunglepub.h"
#import "InAppPurchaseManager.h"
#import "P4RC.h"

#define ADSTYPE_MAX      5
#define PLIST_URL @"http://iosgames.slightlysocial.com/kungfucookie.plist"
#define Chartboost_ID  @"52542efd17ba474b4d00000c"
#define Chartboost_Signature  @"821f3dc7d8a3d9da9df44c312b450cf14287fb31"
#define PlayHavenToken   @"7663a88170af49b29e41f7b913e2b405"
#define PlayHavenSecret  @"fd7a93f972c24a50bd389605947e3120"
#define PlayHavenPlacementTags_gameLoad   @"main_menu"
#define PlayHavenPlacementTags_moreGames  @"more_games"
#define Revmob_ID  @"5254587565d21ab18100003e"
#define Mobclix_ID @"481420e9-6a26-459c-a9c1-64be668835d2"
#define Tapjoy_ID  @"47341fd3-275d-4976-bebf-959653863b18"
#define Tapjoy_key @"8v45Efr095FfXRGGnbaf"
#define Flurry_ID  @"3Z6BZFDH28F9HNFMG35S"
#define VUNGLE_ID  @"722427946"


//this is p4rc's testing ids.
//#define TEST_SERVER_HOST                @"test.p4rc.com:8080"
//#define DEFAULT_SERVER_HOST             TEST_SERVER_HOST
//#define DEFAULT_CURRENT_API_KEY         @"d1919f76-395e-4ef0-a7cb-4a31a79fcdd0"
//#define DEFAULT_GAME_ID                 @"TESTGAME001"

//this is p4rc's real ids.
#define PRODUCTION_SERVER_HOST          @"www.p4rc.com"
#define DEFAULT_SERVER_HOST             PRODUCTION_SERVER_HOST
#define DEFAULT_CURRENT_API_KEY         @"57abf34c-9250-4084-92f0-7896834e5340"
#define DEFAULT_GAME_ID                 @"HS863374"


#define INAPPPURCHASE_REMOVESADS_ID     @"com.bestfreegamesfactory.highwayzombies613f.removeAds"
#define INAPPPURCHASE_REMOVESALLADS_ID  @"com.bestfreegamesfactory.highwayzombies613f.removeAds"

#define AD_OFF      0
#define CHARTBOOST  1
#define REVMOB      2
#define PLAYHAVEN   3
#define MOBCLIX     4
#define IADS        5
#define APPLOVIN    6
#define VUNGLE      7
#define ADMOB       8

 
#define requestFromBootUp       1
#define requestFromMoreGames    2
#define requestFromGameOver     3
#define requestFromBannerAds    4
#define requestFromForeground   5
#define requestFromPause        6

#define IS_IPHONE_5 ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )

@interface SNAdsManager: NSObject<RevMobAdsDelegate, ChartboostDelegate, MobclixAdViewDelegate, PHPublisherContentRequestDelegate,ALAdDisplayDelegate, ALAdLoadDelegate, ADBannerViewDelegate>
{
    MobclixAdView *adView_mobclix;
    UIButton* adCloseButton;
    ALAdView * adView_applovin;
    RevMobFullscreen *revmobAd_fullscreen;
    RevMobPopup *revmobAd_popup;
    ADBannerView *adView_iAd;
    id _adBannerView;
    UIViewController *bootViewController;
    
    int p4rcPosition_x;
    int p4rcPosition_y;
    int p4rcscorePosition_x;
    int p4rcscorePosition_y;
    int p4rcscoreSize_width;
    int p4rcscoreSize_height;
    UIButton*   p4rcButton_GameMenu;
    UIButton*   p4rcButton_GameOver;
    UITextView *    p4rcscore;
    
    double callTime_last;       //this value is used for record the system time for the last ads call.
    double callTime_current;    //this value is used for record the system time for the current ads call.
    
    int adsNumber_bootUp;     //the total number of ads for boot up.
    int adsNumber_moreGame;   //the total number of ads for more game.
    int adsNumber_bannerAds;  //the total number of ads for banner ads.
    int adsNumber_gameOver;   //the total number of ads for game over.
    int adsNumber_foreGround; //the total number of ads for back to foreground.
    int adsNumber_pause;      //the total number of ads for pause.
    
    int adsRequestSource;
    
    int currentLevel_bootUp;     //this value is used for marking which ads we are doing now for boot up.
    int currentLevel_moreGame;   //this value is used for marking which ads we are doing now for more game.
    int currentLevel_bannerAds;  //this value is used for marking which ads we are doing now for banner ads.
    int currentLevel_gameOver;   //this value is used for marking which ads we are doing now for game over.
    int currentLevel_foreGround; //this value is used for marking which ads we are doing now for back to foreground.
    int currentLevel_pause;      //this value is used for marking which ads we are doing now for pause.
    
    int adsStack_bootUp[ADSTYPE_MAX];       //this stack is to store all the priority level for ads of boot up.
    int adsStack_moreGame[ADSTYPE_MAX];     //this stack is to store all the priority level for ads of more game.
    int adsStack_bannerAds[ADSTYPE_MAX];    //this stack is to store all the priority level for ads of banner ads.
    int adsStack_gameOver[ADSTYPE_MAX];     //this stack is to store all the priority level for ads of game over.
    int adsStack_foreGround[ADSTYPE_MAX];   //this stack is to store all the priority level for ads of back to foreground.
    int adsStack_pause[ADSTYPE_MAX];        //this stack is to store all the priority level for ads of back to pause.
    
    //because sometimes ads listener can be called for one more time when the ads fails, which would cause more than one next ads be called. So, we use the BOOL value to mark if the ads has tried to call. 
    BOOL tried_chartboost;  //this bool value is used for checking if we tried to pop-up chartboost.
    BOOL tried_revmob;      //this bool value is used for checking if we tried to pop-up revmob.
    BOOL tried_playhaven;   //this bool value is used for checking if we tried to pop-up play haven.
    BOOL tried_mobclix;     //this bool value is used for checking if we tried to pop-up mobclix.
    BOOL tried_applovin;    //this bool value is used for checking if we tried to pop-up applovin.
    BOOL tried_vungle;      //this bool value is used for checking if we tried to pop-up vungle.
}


+ (SNAdsManager *)sharedManager;

@property (retain, nonatomic) MobclixAdView *adView_mobclix;

@property (nonatomic, retain) id adBannerView;
@property (assign, nonatomic) int adOnFreeGame;
@property (assign, nonatomic) int adOnPause;
@property (assign, nonatomic) int adOnActive;
@property (assign, nonatomic) int adOnLoad1;
@property (assign, nonatomic) int adOnLoad2;
@property (assign, nonatomic) int adOnGameOver;


@property (assign, nonatomic) int isInReview;        //1: open all ads;  0: close all ads
@property (assign, nonatomic) int adsDelayTime;      //the interval time between two ads by seconds.

@property (assign, nonatomic) int adBootUpOn;        //1: on;  0: off
@property (assign, nonatomic) int adBootUp1;
@property (assign, nonatomic) int adBootUp2;
@property (assign, nonatomic) int adBootUp3;
@property (assign, nonatomic) int adBootUp4;
@property (assign, nonatomic) int adBootUp5;

@property (assign, nonatomic) int adBannerOn;        //1: on;  0: off
@property (assign, nonatomic) int adBanner1;
@property (assign, nonatomic) int adBanner2;
@property (assign, nonatomic) int adBanner3;
@property (assign, nonatomic) int adBanner4;
@property (assign, nonatomic) int adBanner5;

@property (assign, nonatomic) int adMoreGameOn;      //1: on;  0: off
@property (assign, nonatomic) int adMoreGame1;
@property (assign, nonatomic) int adMoreGame2;
@property (assign, nonatomic) int adMoreGame3;
@property (assign, nonatomic) int adMoreGame4;
@property (assign, nonatomic) int adMoreGame5;

@property (assign, nonatomic) int adGameOverOn;      //1: on;  0: off
@property (assign, nonatomic) int adGameOver1;
@property (assign, nonatomic) int adGameOver2;
@property (assign, nonatomic) int adGameOver3;
@property (assign, nonatomic) int adGameOver4;
@property (assign, nonatomic) int adGameOver5;

@property (assign, nonatomic) int adPauseOn;         //1: on;  0: off
@property (assign, nonatomic) int adPause1;
@property (assign, nonatomic) int adPause2;
@property (assign, nonatomic) int adPause3;
@property (assign, nonatomic) int adPause4;
@property (assign, nonatomic) int adPause5;

@property (assign, nonatomic) int adReturnOn;        //1: on;  0: off
@property (assign, nonatomic) int adReturn1;
@property (assign, nonatomic) int adReturn2;
@property (assign, nonatomic) int adReturn3;
@property (assign, nonatomic) int adReturn4;
@property (assign, nonatomic) int adReturn5;


-(UIViewController*) getRootViewController;

-(void) loadPLISTValues:(UIViewController*)viewController;

- (void) giveMeGameOverAd;  //this is an interface function between ads manager and games' file.
- (void) giveMeBootUpAd;    //this is an interface function between ads manager and games' file.
- (void) giveMeWillEnterForegroundAd;   //this is an interface function between ads manager and games' file.
- (void) giveMeMoreAppsAd;  //this is an interface function between ads manager and games' file.
- (void) giveMePauseAd;     //this is an interface function between ads manager and games' file.
- (void) giveMeBannerAd;    //this is an interface function between ads manager and games' file.
- (void) cancleBannerAd;

- (void) saveAdRemovalStatus;
- (void) saveAllAdRemovalStatus;

- (void) purchase_bannerAds;

-(void) cancelAd;


-(void) adSuccess;
-(void) adFailover;

- (void)startAdsWithCurrentLevel_bootUp;
- (void)startAdsWithCurrentLevel_moreGame;
- (void)startAdsWithCurrentLevel_bannerAds;
- (void)startAdsWithCurrentLevel_gameOver;
- (void)startAdsWithCurrentLevel_foreGround;
- (void)startAdsWithCurrentLevel_pause;

- (void)startChartBoost_FullScreen;
- (void)startChartBoost_MoreGames;
- (void)startChartBoost_Banner;

- (void)startRevmob_FullScreen;
- (void)startRevmob_Popup;
- (void)startRevmob_Banner;

- (void)startPlayHaven_FullScreen;
- (void)startPlayHaven_MoreGames;
- (void)startPlayHaven_Banner;

- (void)startMobClix_FullScreen;
- (void)startMobClix_Banner;

- (void)startiAds_FullScreen;
- (void)startiAds_Banner;

- (void)startAppLovin_FullScreen;
- (void)startAppLovin_Banner;

- (void)initVungle;
- (void)startVungle;
- (void)stopVungle;

- (void)startTapjoy;

- (void)startFlurry;

-(void) p4rcInitialize;
-(void) p4rcListenerRegester;
-(void) p4rcShowMain;
-(void) p4rcStartLevel;
-(void) p4rcGamewasRestarted;
-(void) p4rcCompleteLevel:(NSInteger)level withPoints:(NSInteger)levelGamePoints;
-(void) p4rcShowGameMenuButtonInPositionX:(NSInteger)positionX inPositionY:(NSInteger)positionY;
-(void) p4rcShowGameOverButtonInPositionX:(NSInteger)positionX inPositionY:(NSInteger)positionY;
-(void) p4rcShowScoreInPositionX:(NSInteger)positionX inPositionY:(NSInteger)positionY;
-(void) p4rcGameMenuButtonHide;
-(void) p4rcGameOverButtonHide;

@end
