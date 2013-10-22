

#import "SNAdsManager.h"

@implementation SNAdsManager

@synthesize adView_mobclix;
@synthesize adBannerView = _adBannerView;

@synthesize isInReview;
@synthesize adsDelayTime;
@synthesize adBootUpOn;
@synthesize adBootUp1;
@synthesize adBootUp2;
@synthesize adBootUp3;
@synthesize adBootUp4;
@synthesize adBootUp5;
@synthesize adBannerOn;
@synthesize adBanner1;
@synthesize adBanner2;
@synthesize adBanner3;
@synthesize adBanner4;
@synthesize adBanner5;
@synthesize adMoreGameOn;
@synthesize adMoreGame1;
@synthesize adMoreGame2;
@synthesize adMoreGame3;
@synthesize adMoreGame4;
@synthesize adMoreGame5;
@synthesize adGameOverOn;
@synthesize adGameOver1;
@synthesize adGameOver2;
@synthesize adGameOver3;
@synthesize adGameOver4;
@synthesize adGameOver5;
@synthesize adPauseOn;
@synthesize adPause1;
@synthesize adPause2;
@synthesize adPause3;
@synthesize adPause4;
@synthesize adPause5;
@synthesize adReturnOn;
@synthesize adReturn1;
@synthesize adReturn2;
@synthesize adReturn3;
@synthesize adReturn4;
@synthesize adReturn5;


static SNAdsManager *sharedManager = nil;

+ (SNAdsManager*)sharedManager{
    if (sharedManager != nil)
    {
        return sharedManager;
    }
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_4_0
    static dispatch_once_t safer;
    dispatch_once(&safer, ^(void)
                  {
                      sharedManager = [[SNAdsManager alloc] init];
                      
                  });
#else
    @synchronized([SNAdsManager class])
    {
        if (sharedManager == nil)
        {
            sharedManager = [[SNAdsManager alloc] init];
            
        }
    }
#endif
    return sharedManager;
}


-(UIViewController*) getRootViewController
{
	return [UIApplication sharedApplication].keyWindow.rootViewController;
}

- (id) init
{
	self = [super init];
	if(self !=nil)
    { 
        currentLevel_bootUp=1;
        currentLevel_moreGame=1;
        currentLevel_bannerAds=1;
        currentLevel_gameOver=1;
        currentLevel_foreGround=1;
        currentLevel_pause=1;
        
        for(int i=0; i<ADSTYPE_MAX; i++)
        {
            adsStack_bootUp[i]=0;
            adsStack_moreGame[i]=0;
            adsStack_bannerAds[i]=0;
            adsStack_gameOver[i]=0;
            adsStack_foreGround[i]=0;
            adsStack_pause[i]=0;
        }
        
        tried_chartboost=FALSE;
        tried_revmob=FALSE;
        tried_playhaven=FALSE;  
        tried_mobclix=FALSE;
        tried_applovin=FALSE;
        tried_vungle=FALSE;
        
        adsNumber_bootUp=2;     //this is a fixed value, not be assigned from plist. 
        adsNumber_moreGame=1;   //this is a fixed value, not be assigned from plist. 
        adsNumber_bannerAds=1;  //this is a fixed value, not be assigned from plist. 
        adsNumber_gameOver=1;   //this is a fixed value, not be assigned from plist. 
        adsNumber_foreGround=1; //this is a fixed value, not be assigned from plist.
        adsNumber_pause=1;  //this is a fixed value, not be assigned from plist.
        
        callTime_last=0;
        callTime_current=CACurrentMediaTime();
        
        p4rcPosition_x=0;
        p4rcPosition_y=0;
        p4rcscorePosition_x=0;
        p4rcscorePosition_y=0;
        p4rcscoreSize_width=0;
        p4rcscoreSize_height=0;
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        {
            p4rcPosition_x=10;
            p4rcPosition_y=105;
            p4rcscorePosition_x=105;
            p4rcscorePosition_y=115;
            p4rcscoreSize_width=70;
            p4rcscoreSize_height=40;
        }
        else if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            p4rcPosition_x=20;
            p4rcPosition_y=255;
            p4rcscorePosition_x=205;
            p4rcscorePosition_y=290;
            p4rcscoreSize_width=140;
            p4rcscoreSize_height=80;
        }
	}
	return self;
}


-(BOOL)reachable {
    Reachability *r = [Reachability reachabilityWithHostName:@"www.slightlysocial.com"];
    NetworkStatus internetStatus = [r currentReachabilityStatus];
    if(internetStatus == NotReachable) {
        return NO;
    }
    return YES;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    NSLog(@"More data.");
    
    NSDictionary* plistsDictionary;
    plistsDictionary = [NSDictionary dictionaryWithContentsOfURL:[NSURL URLWithString:PLIST_URL]];
    
    //if we want to test with local PLIST
    
    if (!plistsDictionary)
    {
        //no dictionary was found of ad settings
        return;
    }
    
    NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    //used in prior versions for version checking
    
    NSDictionary* plistValues = [plistsDictionary valueForKey:appVersion];
    if (plistValues)
    {
        //get the plistvalues specific to this app version
        
        [self setIsInReview:[[plistValues valueForKey:@"IS_IN_REVIEW"] intValue]];
        [self setAdsDelayTime:[[plistValues valueForKey:@"ADS_DELAY"] intValue]];
        
        [self setAdBootUpOn:[[plistValues valueForKey:@"AD_BOOT_UP_ON"] intValue]];
        [self setAdBootUp1:[[plistValues valueForKey:@"AD_BOOT_UP_1"] intValue]];
        [self setAdBootUp2:[[plistValues valueForKey:@"AD_BOOT_UP_2"] intValue]];
        [self setAdBootUp3:[[plistValues valueForKey:@"AD_BOOT_UP_3"] intValue]];
        [self setAdBootUp4:[[plistValues valueForKey:@"AD_BOOT_UP_4"] intValue]];
        [self setAdBootUp5:[[plistValues valueForKey:@"AD_BOOT_UP_5"] intValue]];
        
        [self setAdBannerOn:[[plistValues valueForKey:@"AD_BANNER_ON"] intValue]];
        [self setAdBanner1:[[plistValues valueForKey:@"AD_BANNER_1"] intValue]];
        [self setAdBanner2:[[plistValues valueForKey:@"AD_BANNER_2"] intValue]];
        [self setAdBanner3:[[plistValues valueForKey:@"AD_BANNER_3"] intValue]];
        [self setAdBanner4:[[plistValues valueForKey:@"AD_BANNER_4"] intValue]];
        [self setAdBanner5:[[plistValues valueForKey:@"AD_BANNER_5"] intValue]];
        
        [self setAdMoreGameOn:[[plistValues valueForKey:@"AD_MOREGAME_ON"] intValue]];
        [self setAdMoreGame1:[[plistValues valueForKey:@"AD_MOREGAME_1"] intValue]];
        [self setAdMoreGame2:[[plistValues valueForKey:@"AD_MOREGAME_2"] intValue]];
        [self setAdMoreGame3:[[plistValues valueForKey:@"AD_MOREGAME_3"] intValue]];
        [self setAdMoreGame4:[[plistValues valueForKey:@"AD_MOREGAME_4"] intValue]];
        [self setAdMoreGame5:[[plistValues valueForKey:@"AD_MOREGAME_5"] intValue]];
        
        [self setAdGameOverOn:[[plistValues valueForKey:@"AD_GAMEOVER_ON"] intValue]];
        [self setAdGameOver1:[[plistValues valueForKey:@"AD_GAMEOVER_1"] intValue]];
        [self setAdGameOver2:[[plistValues valueForKey:@"AD_GAMEOVER_2"] intValue]];
        [self setAdGameOver3:[[plistValues valueForKey:@"AD_GAMEOVER_3"] intValue]];
        [self setAdGameOver4:[[plistValues valueForKey:@"AD_GAMEOVER_4"] intValue]];
        [self setAdGameOver5:[[plistValues valueForKey:@"AD_GAMEOVER_5"] intValue]];
        
        [self setAdPauseOn:[[plistValues valueForKey:@"AD_PAUSE_ON"] intValue]];
        [self setAdPause1:[[plistValues valueForKey:@"AD_PAUSE_1"] intValue]];
        [self setAdPause2:[[plistValues valueForKey:@"AD_PAUSE_2"] intValue]];
        [self setAdPause3:[[plistValues valueForKey:@"AD_PAUSE_3"] intValue]];
        [self setAdPause4:[[plistValues valueForKey:@"AD_PAUSE_4"] intValue]];
        [self setAdPause5:[[plistValues valueForKey:@"AD_PAUSE_5"] intValue]];
        
        [self setAdReturnOn:[[plistValues valueForKey:@"AD_RETURN_ON"] intValue]];
        [self setAdReturn1:[[plistValues valueForKey:@"AD_RETURN_1"] intValue]];
        [self setAdReturn2:[[plistValues valueForKey:@"AD_RETURN_2"] intValue]];
        [self setAdReturn3:[[plistValues valueForKey:@"AD_RETURN_3"] intValue]];
        [self setAdReturn4:[[plistValues valueForKey:@"AD_RETURN_4"] intValue]];
        [self setAdReturn5:[[plistValues valueForKey:@"AD_RETURN_5"] intValue]];
    }
    
    adsStack_bootUp[0]=adBootUp1;
    adsStack_bootUp[1]=adBootUp2;
    adsStack_bootUp[2]=adBootUp3;
    adsStack_bootUp[3]=adBootUp4;
    adsStack_bootUp[4]=adBootUp5;
    
    adsStack_bannerAds[0]=adBanner1;
    adsStack_bannerAds[1]=adBanner2;
    adsStack_bannerAds[2]=adBanner3;
    adsStack_bannerAds[3]=adBanner4;
    adsStack_bannerAds[4]=adBanner5;
    
    adsStack_moreGame[0]=adMoreGame1;
    adsStack_moreGame[1]=adMoreGame2;
    adsStack_moreGame[2]=adMoreGame3;
    adsStack_moreGame[3]=adMoreGame4;
    adsStack_moreGame[4]=adMoreGame5;
    
    adsStack_gameOver[0]=adGameOver1;
    adsStack_gameOver[1]=adGameOver2;
    adsStack_gameOver[2]=adGameOver3;
    adsStack_gameOver[3]=adGameOver4;
    adsStack_gameOver[4]=adGameOver5;
    
    adsStack_foreGround[0]=adReturn1;
    adsStack_foreGround[1]=adReturn2;
    adsStack_foreGround[2]=adReturn3;
    adsStack_foreGround[3]=adReturn4;
    adsStack_foreGround[4]=adReturn5;
    
    adsStack_pause[0]=adPause1;
    adsStack_pause[1]=adPause2;
    adsStack_pause[2]=adPause3;
    adsStack_pause[3]=adPause4;
    adsStack_pause[4]=adPause5;
    
    [self giveMeBootUpAd];
    
    [self p4rcInitialize];
    [self p4rcListenerRegester];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"Connection successful.");
}


- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error
{
    // release the connection, and the data object
    [connection release];
    
    // inform the user
    NSLog(@"Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
}


-(void) loadPLISTValues:(UIViewController*)viewController
{
    bootViewController=viewController;

    // Plist
    if (![self reachable])
    {
        //since there is no internet turn all of the adds off
        
        [self setIsInReview:0];
        [self setAdsDelayTime:0];
        
        [self setAdBootUpOn:0];
        [self setAdBootUp1:0];
        [self setAdBootUp2:0];
        [self setAdBootUp3:0];
        [self setAdBootUp4:0];
        [self setAdBootUp5:0];
        
        [self setAdBannerOn:0];
        [self setAdBanner1:0];
        [self setAdBanner2:0];
        [self setAdBanner3:0];
        [self setAdBanner4:0];
        [self setAdBanner5:0];
        
        [self setAdMoreGameOn:0];
        [self setAdMoreGame1:0];
        [self setAdMoreGame2:0];
        [self setAdMoreGame3:0];
        [self setAdMoreGame4:0];
        [self setAdMoreGame5:0];
        
        [self setAdGameOverOn:0];
        [self setAdGameOver1:0];
        [self setAdGameOver2:0];
        [self setAdGameOver3:0];
        [self setAdGameOver4:0];
        [self setAdGameOver5:0];
        
        [self setAdPauseOn:0];
        [self setAdPause1:0];
        [self setAdPause2:0];
        [self setAdPause3:0];
        [self setAdPause4:0];
        [self setAdPause5:0];
        
        [self setAdReturnOn:0];
        [self setAdReturn1:0];
        [self setAdReturn2:0];
        [self setAdReturn3:0];
        [self setAdReturn4:0];
        [self setAdReturn5:0];

        return;
    }
    
    //[NSURL URLWithString:PLIST_URL]NSURL* url = [NSURL URLWithString:PLIST_URL];
    
    NSURLRequest *theRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:PLIST_URL] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:2.0];
    
    NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
    
    if (theConnection) {
        NSLog(@"Connection open.");
        
        
    }
    else {
        NSLog(@"Failed connecting.");
        return;
    }
}


- (void) purchase_bannerAds
{  
    [[InAppPurchaseManager sharedInAppManager] purchaseRemoveAds];
}

- (void)cancleBannerAd
{
    adView_applovin.hidden = true;
    adView_iAd.hidden = true;
    adView_mobclix.hidden = true;
    adCloseButton.hidden = true;
    
    [[RevMobAds session] hideBanner];
}

- (void) saveAdRemovalStatus
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setBool:true forKey:@"removed_bannerAds"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    adView_applovin.hidden = true;
    adView_iAd.hidden = true;
    adView_mobclix.hidden = true;
    adCloseButton.hidden = true;

    [Flurry logEvent:@"Removed Banner Ads"];
}

- (void) saveAllAdRemovalStatus
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setBool:true forKey:@"removed_AllAds"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    adView_applovin.hidden = true;
    adView_iAd.hidden = true;
    adView_mobclix.hidden = true;
    adCloseButton.hidden = true;

    [Flurry logEvent:@"Removed All Banner Ads"];
}

-(void) p4rcInitialize
{
    [[P4RC sharedInstance] setGameRefId:DEFAULT_GAME_ID];
    [[P4RC sharedInstance] initializeWithServerHost:DEFAULT_SERVER_HOST andApiKey:DEFAULT_CURRENT_API_KEY];
}

-(void) p4rcListenerRegester
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initializationDidComplete) name:P4RCInitializationDidCompleteNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initializationDidFail) name:P4RCInitializationDidFailNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pointsWasSentOnServer) name:P4RCPointsWasSentOnServerNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pointsSendingDidFail) name:P4RCPointsSendingDidFailNotification object:nil];
}


-(void) p4rcShowMain
{
    if([self reachable])
    {
        [[P4RC sharedInstance] showMain];
    }
}

-(void) p4rcStartLevel
{
    if([self reachable])
    {
        [[P4RC sharedInstance] didStartLevel];
    }
}

-(void) p4rcGamewasRestarted
{
    if([self reachable])
    {
        [[P4RC sharedInstance] gameWasRestarted];
    }
}

-(void) p4rcCompleteLevel:(NSInteger)level withPoints:(NSInteger)levelGamePoints
{
    if([self reachable])
    {
        [[P4RC sharedInstance] didCompleteLevel:level withPoints:levelGamePoints];
    }
}

-(void) p4rcShowGameMenuButtonInPositionX:(NSInteger)positionX inPositionY:(NSInteger)positionY
{
    //UIViewController* rootVC =[[[[UIApplication sharedApplication]delegate] window] rootViewController];
    
    UIImage* imgp4rc;
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        imgp4rc= [UIImage imageNamed:@"Menu_Button_P4RC@3x.png"];
    }
    else
    {
        imgp4rc= [UIImage imageNamed:@"Menu_Button_P4RC@3x-ipad.png"];
    }
    
    
	p4rcButton_GameMenu = [[UIButton alloc] initWithFrame:CGRectMake(positionX, positionY, imgp4rc.size.width, imgp4rc.size.height)];
	[p4rcButton_GameMenu setBackgroundImage:imgp4rc forState:UIControlStateNormal];
	[p4rcButton_GameMenu setBackgroundImage:imgp4rc forState:UIControlStateHighlighted];
	[p4rcButton_GameMenu addTarget:self action:@selector(p4rcShowMain) forControlEvents:UIControlEventTouchUpInside];
	[bootViewController.view addSubview:p4rcButton_GameMenu];
}

-(void) p4rcShowGameOverButtonInPositionX:(NSInteger)positionX inPositionY:(NSInteger)positionY
{
    //UIViewController* rootVC =[[[[UIApplication sharedApplication]delegate] window] rootViewController];
    
    UIImage* imgp4rc;
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        imgp4rc= [UIImage imageNamed:@"Menu_Button_P4RC@3x.png"];
    }
    else
    {
        imgp4rc= [UIImage imageNamed:@"Menu_Button_P4RC@3x-ipad.png"];
    }
    
    
	p4rcButton_GameOver = [[UIButton alloc] initWithFrame:CGRectMake(positionX, positionY, imgp4rc.size.width, imgp4rc.size.height)];
	[p4rcButton_GameOver setBackgroundImage:imgp4rc forState:UIControlStateNormal];
	[p4rcButton_GameOver setBackgroundImage:imgp4rc forState:UIControlStateHighlighted];
	[p4rcButton_GameOver addTarget:self action:@selector(p4rcShowMain) forControlEvents:UIControlEventTouchUpInside];
	[bootViewController.view addSubview:p4rcButton_GameOver];
}

-(void) p4rcShowScoreInPositionX:(NSInteger)positionX inPositionY:(NSInteger)positionY
{
    //UIViewController* rootVC =[[[[UIApplication sharedApplication]delegate] window] rootViewController];
    
    
    p4rcscore = [[UITextView alloc]initWithFrame:CGRectMake(positionX,positionY,p4rcscoreSize_width,p4rcscoreSize_height)];
    int p4rcCoinsNumber = [[P4RC sharedInstance] lastP4RCPoints];
    p4rcscore.text = [NSString stringWithFormat:@"%d", p4rcCoinsNumber];
    p4rcscore.backgroundColor = [UIColor clearColor];
    
    int textSize=0;
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        textSize=20;
    }
    else if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        textSize=40;
    }
    p4rcscore.font = [UIFont systemFontOfSize:textSize];
    p4rcscore.textColor=[UIColor redColor];
    //p4rcscore.hidden = YES;
    [bootViewController.view addSubview:p4rcscore];
}

-(void) p4rcGameMenuButtonHide
{
    [p4rcButton_GameMenu removeFromSuperview];
    //p4rcButton_GameMenu.hidden = YES;
}

-(void) p4rcGameOverButtonHide
{
    [p4rcButton_GameOver removeFromSuperview];
    [p4rcscore removeFromSuperview];
    //p4rcButton_GameOver.hidden = YES;
    //p4rcscore.hidden = YES;
}


//this is an interface function between ads manager and games' file.
- (void)giveMeMoreAppsAd
{
    if(isInReview==0)
    {
        return;
    }
    
    if(adMoreGameOn==0)
    {
        return;
    }
    
    callTime_current = CACurrentMediaTime();
    
    if(fabs(callTime_current-callTime_last)>=adsDelayTime)
    {
        callTime_last=callTime_current;
    
        currentLevel_moreGame=1;
        tried_chartboost=FALSE;
        tried_revmob=FALSE;
        tried_playhaven=FALSE;
        tried_applovin=FALSE;
        tried_vungle=FALSE;
        adsRequestSource=requestFromMoreGames;
        [self startAdsWithCurrentLevel_moreGame];
    }
}

//this is an interface function between ads manager and games' file.
- (void)giveMeGameOverAd
{
    if(isInReview==0)
    {
        return;
    }
    
    if(adGameOverOn==0)
    {
        return;
    }
    
    callTime_current = CACurrentMediaTime();
    
    if(fabs(callTime_current-callTime_last)>=adsDelayTime)
    {
        callTime_last=callTime_current;
        
        currentLevel_gameOver=1;
        tried_chartboost=FALSE;
        tried_revmob=FALSE;
        tried_playhaven=FALSE;
        tried_applovin=FALSE;
        tried_vungle=FALSE;
        adsRequestSource=requestFromGameOver;
        [self startAdsWithCurrentLevel_gameOver];
    }
}

//this is an interface function between ads manager and games' file.
- (void)giveMeWillEnterForegroundAd
{
    if(isInReview==0)
    {
        return;
    }
    
    if(adReturnOn==0)
    {
        return;
    }
    
    callTime_current = CACurrentMediaTime();
    
    if(fabs(callTime_current-callTime_last)>=adsDelayTime)
    {
        callTime_last=callTime_current;
        
        currentLevel_foreGround=1;
        tried_chartboost=FALSE;
        tried_revmob=FALSE;
        tried_playhaven=FALSE;
        tried_applovin=FALSE;
        tried_vungle=FALSE;
        adsRequestSource=requestFromForeground;
        [self startAdsWithCurrentLevel_foreGround];
    }
}


//this is an interface function between ads manager and games' file.
- (void)giveMePauseAd
{
    if(isInReview==0)
    {
        return;
    }
    
    if(adPauseOn==0)
    {
        return;
    }
    
    callTime_current = CACurrentMediaTime();
    
    if(fabs(callTime_current-callTime_last)>=adsDelayTime)
    {
        callTime_last=callTime_current;
    
        currentLevel_pause=1;
        tried_chartboost=FALSE;
        tried_revmob=FALSE;
        tried_playhaven=FALSE;
        tried_applovin=FALSE;
        tried_vungle=FALSE;
        adsRequestSource=requestFromPause;
        [self startAdsWithCurrentLevel_pause];
    }
}

//this is an interface function between ads manager and games' file.
- (void)giveMeBannerAd
{
    if(isInReview==0)
    {
        return;
    }
    
    if(adBannerOn==0)
    {
        return;
    }
    
    currentLevel_bannerAds=1;
    tried_chartboost=FALSE;
    tried_revmob=FALSE;
    tried_playhaven=FALSE;
    tried_applovin=FALSE;
    tried_vungle=FALSE;
    adsRequestSource=requestFromBannerAds;
    [self startAdsWithCurrentLevel_bannerAds];
}

//this is an interface function between ads manager and games' file.
- (void)giveMeBootUpAd
{
    if(isInReview==0)
    {
        return;
    }
  
    if(adBootUpOn==0)
    {
        return;
    }

    //tapjoy
    [self startTapjoy];
    
    //flurry
    [self startFlurry];
    
    //vungle
    [self initVungle];

    
    //chartboost,playhaven,applovin,revmob,vungle
    currentLevel_bootUp=1;
    tried_chartboost=FALSE;
    tried_revmob=FALSE;
    tried_playhaven=FALSE;
    tried_applovin=FALSE;
    tried_vungle=FALSE;
    adsRequestSource=requestFromBootUp;
    [self startAdsWithCurrentLevel_bootUp];
}


- (void)startAdsWithCurrentLevel_foreGround
{
    switch (adsStack_foreGround[currentLevel_foreGround-1])
    {
        case CHARTBOOST:
            [self startChartBoost_FullScreen];
            break;
                
        case REVMOB:
            [self startRevmob_Popup];
            break;
                
        case PLAYHAVEN:
            [self startPlayHaven_FullScreen];
            break;
                
        case APPLOVIN:
            [self startAppLovin_FullScreen];
            break;

        case VUNGLE:
            [self startVungle];
            break;
                
        default:
            break;
    }
        
    return;
}

- (void)startAdsWithCurrentLevel_gameOver
{
    switch (adsStack_gameOver[currentLevel_gameOver-1])
    {
        case CHARTBOOST:
            [self startChartBoost_FullScreen];
            break;
                
        case REVMOB:
            [self startRevmob_Popup];
            break;
                
        case PLAYHAVEN:
            [self startPlayHaven_FullScreen];
            break;
                
        case APPLOVIN:
            [self startAppLovin_FullScreen];
            break;

        case VUNGLE:
            [self startVungle];
            break;
                
        default:
            break;
    }
        
    return;
}

- (void)startAdsWithCurrentLevel_moreGame
{
    switch (adsStack_moreGame[currentLevel_moreGame-1])
    {
        case CHARTBOOST:
            [self startChartBoost_MoreGames];
            break;
            
        case REVMOB:
            [self startRevmob_Popup];
            break;
            
        case PLAYHAVEN: 
            [self startPlayHaven_MoreGames];
            break;
            
        case APPLOVIN:
            [self startAppLovin_FullScreen];
            break;
            
        case VUNGLE:
            [self startVungle];
            break;
            
        default:
            break;
    }
    
    return;
}

- (void)startAdsWithCurrentLevel_pause
{
    switch (adsStack_pause[currentLevel_pause-1])
    {
        case CHARTBOOST:
            [self startChartBoost_FullScreen];
            break;
            
        case REVMOB:
            [self startRevmob_Popup];
            break;
            
        case PLAYHAVEN:
            [self startPlayHaven_FullScreen];
            break;
            
        case APPLOVIN:
            [self startAppLovin_FullScreen];
            break;
            
        case VUNGLE:
            [self startVungle];
            break;
            
        default:
            break;
    }
}

- (void)startAdsWithCurrentLevel_bannerAds
{
    switch (adsStack_bannerAds[currentLevel_bannerAds-1])
    {
        case APPLOVIN:
            [self startAppLovin_Banner];
            break;
            
        case MOBCLIX:
            [self startMobClix_Banner];
            break;
            
        case IADS:
            [self startiAds_Banner];
            break;
            
            
        case REVMOB:
            [self startRevmob_Banner];
            break;
            
        default:
			break;
    }
}


- (void)startAdsWithCurrentLevel_bootUp
{
    switch (adsStack_bootUp[currentLevel_bootUp-1])
    {
        case CHARTBOOST:
            [self startChartBoost_FullScreen];
            break; 
            
        case REVMOB:
            [self startRevmob_Popup];
            break;
            
        case PLAYHAVEN:
            [self startPlayHaven_FullScreen];
            break;
            
        case APPLOVIN:
            [self startAppLovin_FullScreen];
            break;
       
        case VUNGLE:
            [self startVungle];
            break;
            
        default:
			break;
    }
}

//tapjoy
- (void)startTapjoy
{
    //in order to open tapjoy's listener
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tjcConnectSuccess:) name:TJC_CONNECT_SUCCESS object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tjcConnectFail:) name:TJC_CONNECT_FAILED object:nil];
    
    //start tapjoy
    [TapjoyConnect requestTapjoyConnect:Tapjoy_ID secretKey:Tapjoy_key];
}

//flurry
- (void)startFlurry
{
    [Flurry startSession:Flurry_ID];
}

//vungle
- (void)initVungle
{
    VGUserData*  data  = [VGUserData defaultUserData];
    NSString*    appID = VUNGLE_ID;
    
    // set up config data
    data.age             = 36;
    data.gender          = VGGenderFemale;
    data.adOrientation   = VGAdOrientationLandscape;
    data.locationEnabled = TRUE;
    
    // start vungle publisher library
    [VGVunglePub startWithPubAppID:appID userData:data];
    
    //This delegate can open vungle's listener functions, but I find this delegate can influence game's view control, so I comment it.
    //[VGVunglePub setDelegate:(VGVungleDelegate)self];
}

- (void)startVungle
{
    bool adsRemoved = [[[NSUserDefaults standardUserDefaults] valueForKey:@"removed_AllAds"] boolValue];
    if (adsRemoved)
        return;
    
    [self stopVungle];
    
    VGUserData*  data  = [VGUserData defaultUserData];
    NSString*    appID = VUNGLE_ID;
    
    // set up config data
    data.age             = 36;
    data.gender          = VGGenderFemale;
    data.adOrientation   = VGAdOrientationLandscape;
    data.locationEnabled = TRUE;
    
    // start vungle publisher library
    [VGVunglePub startWithPubAppID:appID userData:data];
    
    //Because Vungle has no listener that can return a FALSE when ads fails. Instead of, it uses a public function [VGVunglePub adIsAvailable] to do this task. So, we check and make a failover link in here, not in any fail function just like chartboost, revmob, paly haven and applovin do.
    if([VGVunglePub adIsAvailable])
    {
        //UIViewController* rootVC = [self getRootViewController];
        [VGVunglePub playModalAd:bootViewController animated:TRUE];
        [self adSuccess];
    }
    else if(![VGVunglePub adIsAvailable])
    {
        [self adFailover];
    }
}

- (void)stopVungle
{
    [VGVunglePub stop];
}


//ChartBoost ads

- (void)startChartBoost_FullScreen
{
    bool adsRemoved = [[[NSUserDefaults standardUserDefaults] valueForKey:@"removed_AllAds"] boolValue];
    if (adsRemoved)
        return;

    Chartboost *cb;
    cb = [Chartboost sharedChartboost];
    cb.appId = Chartboost_ID;
    cb.appSignature = Chartboost_Signature;
    cb.delegate = self;
    
    [cb startSession];
    [cb showInterstitial];
    [cb cacheInterstitial];
    
    [Flurry logEvent:@"Showing Chartboost FullScreen"];
}


- (void)startChartBoost_MoreGames
{
    bool adsRemoved = [[[NSUserDefaults standardUserDefaults] valueForKey:@"removed_AllAds"] boolValue];
    if (adsRemoved)
        return;
    
    Chartboost *cb;
    cb = [Chartboost sharedChartboost];
    cb.appId = Chartboost_ID;
    cb.appSignature = Chartboost_Signature;
    cb.delegate = self;
    
    //[cb startSession];
    [cb showMoreApps];
    [cb cacheMoreApps];
    
    [Flurry logEvent:@"Showing Chartboost MoreGames"];
}

- (void)startChartBoost_Banner
{
    bool adsRemoved = [[[NSUserDefaults standardUserDefaults] valueForKey:@"removed_AllAds"] boolValue];
    if (adsRemoved)
        return;
    
    [Flurry logEvent:@"Showing Chartboost Banner"];
}


//Revmob ads
- (void)startRevmob_FullScreen
{
    bool adsRemoved = [[[NSUserDefaults standardUserDefaults] valueForKey:@"removed_AllAds"] boolValue];
    if (adsRemoved)
        return;
    
    [RevMobAds startSessionWithAppID:Revmob_ID];
    
    revmobAd_fullscreen = [[RevMobAds session] fullscreen];
    revmobAd_fullscreen.delegate = self;
    [revmobAd_fullscreen showAd];
    
    //[[RevMobAds session] showFullscreen];
    
    [Flurry logEvent:@"Showing Revmob FullScreen"];
}

- (void)startRevmob_Popup
{
    bool adsRemoved = [[[NSUserDefaults standardUserDefaults] valueForKey:@"removed_AllAds"] boolValue];
    if (adsRemoved)
        return;
    
    [RevMobAds startSessionWithAppID:Revmob_ID];
    
    revmobAd_popup = [[RevMobAds session] popup];
    revmobAd_popup.delegate = self;
    [revmobAd_popup showAd];

    //[[RevMobAds session] showPopup];
    
    [Flurry logEvent:@"Showing Revmob Popup"];
}

- (void)startRevmob_Banner
{
    bool adsRemoved = [[[NSUserDefaults standardUserDefaults] valueForKey:@"removed_AllAds"] boolValue];
    if (adsRemoved)
        return;
    
    [RevMobAds startSessionWithAppID:Revmob_ID];
    
    [[RevMobAds session] showBanner];
    
    
    [Flurry logEvent:@"Showing Revmob Banner"];
}

//PlayHaven ads
- (void)startPlayHaven_FullScreen
{
    bool adsRemoved = [[[NSUserDefaults standardUserDefaults] valueForKey:@"removed_AllAds"] boolValue];
    if (adsRemoved)
        return;
    
    PHPublisherOpenRequest *request = [PHPublisherOpenRequest requestForApp:PlayHavenToken secret:PlayHavenSecret];
    [request send];
    PHPublisherContentRequest *request1 = [PHPublisherContentRequest requestForApp:PlayHavenToken
                                                                            secret:PlayHavenSecret
                                                                         placement:PlayHavenPlacementTags_gameLoad
                                                                          delegate:self];
    [request1 send];
    
    [Flurry logEvent:@"Showing PlayHaven FullScreen"];
}

//PlayHaven ads
- (void)startPlayHaven_MoreGames
{
    bool adsRemoved = [[[NSUserDefaults standardUserDefaults] valueForKey:@"removed_AllAds"] boolValue];
    if (adsRemoved)
        return;
    
    //PHPublisherOpenRequest *request = [PHPublisherOpenRequest requestForApp:PlayHavenToken secret:PlayHavenSecret];
    //[request send];
    
    PHPublisherContentRequest *request1 = [PHPublisherContentRequest requestForApp:PlayHavenToken
                                                                            secret:PlayHavenSecret
                                                                         placement:PlayHavenPlacementTags_moreGames
                                                                          delegate:self];
    [request1 send];
    
    [[PHPublisherContentRequest requestForApp:PlayHavenToken secret:PlayHavenSecret placement:PlayHavenPlacementTags_moreGames delegate:self] preload];
    
    [Flurry logEvent:@"Showing PlayHaven FullScreen"];
}

- (void)startPlayHaven_Banner
{
    bool adsRemoved = [[[NSUserDefaults standardUserDefaults] valueForKey:@"removed_AllAds"] boolValue];
    if (adsRemoved)
        return;
    
    [Flurry logEvent:@"Showing PlayHaven Banner"];
}

//Mobclix ads
- (void)startMobClix_FullScreen
{
    bool adsRemoved = [[[NSUserDefaults standardUserDefaults] valueForKey:@"removed_AllAds"] boolValue];
    if (adsRemoved)
        return;
    
    [Flurry logEvent:@"Showing MobClix FullScreen"];
}

- (void)startMobClix_Banner
{
    
    bool adsRemoved = [[[NSUserDefaults standardUserDefaults] valueForKey:@"removed_bannerAds"] boolValue];
    if (adsRemoved)
        return;
    
    bool adsRemoved1 = [[[NSUserDefaults standardUserDefaults] valueForKey:@"removed_AllAds"] boolValue];
    if (adsRemoved1)
        return;
    
    [Mobclix startWithApplicationId:Mobclix_ID];
    
    
    //UIViewController* rootVC = [self getRootViewController];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        adView_mobclix = [[MobclixAdViewiPhone_320x50 alloc] initWithFrame:CGRectMake(0, 0, 320.0f, 50.0f)];
        adView_mobclix.delegate = self;
        [bootViewController.view addSubview:adView_mobclix];
        
        adCloseButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        adCloseButton.frame = CGRectMake(300,40,16,17);
        [adCloseButton setBackgroundImage:[[UIImage imageNamed:@"adexitbutton.png"] stretchableImageWithLeftCapWidth:10.0 topCapHeight:0.0] forState:UIControlStateNormal];
    }
    else
    {
        adView_mobclix = [[MobclixAdViewiPad_728x90 alloc] initWithFrame:CGRectMake(0, 0, 728, 90.0f)];
        adView_mobclix.delegate = self;
        [bootViewController.view addSubview:adView_mobclix];
        
        adCloseButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        adCloseButton.frame = CGRectMake(700,70,40,41);
        [adCloseButton setBackgroundImage:[[UIImage imageNamed:@"adexitbutton-ipad.png"] stretchableImageWithLeftCapWidth:10.0 topCapHeight:0.0] forState:UIControlStateNormal];
    }
    
    
    [adCloseButton addTarget:self action:@selector(purchase_bannerAds) forControlEvents:UIControlEventTouchUpInside];
    [bootViewController.view addSubview:adCloseButton];
    
    /*
     if (![[InAppPurchaseManager sharedInAppManager]  storeLoaded])
     {
         [self cancleBannerAd];
     }
     */
    
    [self.adView_mobclix resumeAdAutoRefresh];
    
    [Flurry logEvent:@"Showing MobClix Banner"];
}


//iAds ads
- (void)startiAds_FullScreen
{
    bool adsRemoved = [[[NSUserDefaults standardUserDefaults] valueForKey:@"removed_AllAds"] boolValue];
    if (adsRemoved)
        return;
    
    [Flurry logEvent:@"Showing iAds FullScreen"];
}

- (void)startiAds_Banner
{
    bool adsRemoved = [[[NSUserDefaults standardUserDefaults] valueForKey:@"removed_bannerAds"] boolValue];
    if (adsRemoved)
        return;
    
    bool adsRemoved1 = [[[NSUserDefaults standardUserDefaults] valueForKey:@"removed_AllAds"] boolValue];
    if (adsRemoved1)
        return;
    
    //UIViewController* rootVC = [self getRootViewController];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        adView_iAd = [[ADBannerView alloc] initWithFrame:CGRectZero];
        adView_iAd.currentContentSizeIdentifier = ADBannerContentSizeIdentifierPortrait;
        adView_iAd.delegate=self;
        [bootViewController.view addSubview:adView_iAd];
        
        adCloseButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        adCloseButton.frame = CGRectMake(300,40,16,17);
        [adCloseButton setBackgroundImage:[[UIImage imageNamed:@"adexitbutton.png"] stretchableImageWithLeftCapWidth:10.0 topCapHeight:0.0] forState:UIControlStateNormal];
    }
    else
    {
        adView_iAd = [[ADBannerView alloc] initWithFrame:CGRectZero];
        adView_iAd.currentContentSizeIdentifier = ADBannerContentSizeIdentifierPortrait;
        adView_iAd.delegate=self;
        [bootViewController.view addSubview:adView_iAd];
    
        
        adCloseButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        adCloseButton.frame = CGRectMake(720,70,40,41);
        [adCloseButton setBackgroundImage:[[UIImage imageNamed:@"adexitbutton-ipad.png"] stretchableImageWithLeftCapWidth:10.0 topCapHeight:0.0] forState:UIControlStateNormal];
         
    }
    
    
    [adCloseButton addTarget:self action:@selector(purchase_bannerAds) forControlEvents:UIControlEventTouchUpInside];
    [bootViewController.view addSubview:adCloseButton];
    
    if (![[InAppPurchaseManager sharedInAppManager]  storeLoaded])
    {
        [self cancelAd];
    }
        
    [Flurry logEvent:@"Showing iAds Banner"];
}

//AppLovin ads
- (void)startAppLovin_FullScreen
{
    /*
    bool adsRemoved = [[[NSUserDefaults standardUserDefaults] valueForKey:@"removed_AllAds"] boolValue];
    if (adsRemoved)
        return;
    */
    
    //UIViewController* rootVC = [self getRootViewController];
 
    //In order to check if fullscreen can pop-up, we need to create an AppLovin's banner adView so that we can AppLovin's ads listener. After we finish the checking, we remove this banner ads because this is not a function for banner ads.
    
    
    ALAdView * adView_temporary = [[ALAdView alloc] initBannerAd];
    adView_temporary.adDisplayDelegate = self;
    adView_temporary.adLoadDelegate = self;
    adView_temporary.frame = CGRectMake(0,0,0,0);
    [bootViewController.view addSubview: adView_temporary];
    [adView_temporary loadNextAd];
    [adView_temporary removeFromSuperview];
    
    //this is a full screen ads
    [ALSdk initializeSdk];
    [ALInterstitialAd showOver:bootViewController.view.window];
    
    [Flurry logEvent:@"Showing AppLovin FullScreen"];
}

- (void)startAppLovin_Banner
{
    bool adsRemoved = [[[NSUserDefaults standardUserDefaults] valueForKey:@"removed_bannerAds"] boolValue];
    if (adsRemoved)
        return;
    
    bool adsRemoved1 = [[[NSUserDefaults standardUserDefaults] valueForKey:@"removed_AllAds"] boolValue];
    if (adsRemoved1)
        return;
    
    //UIViewController* rootVC = [self getRootViewController];
    
    adView_applovin = [[ALAdView alloc] initBannerAd];
    adView_applovin.adDisplayDelegate = self;
    adView_applovin.adLoadDelegate = self;
    adView_applovin.frame = CGRectMake(0,0,adView_applovin.frame.size.width,adView_applovin.frame.size.height);
    
    [bootViewController.view addSubview: adView_applovin];
    [adView_applovin loadNextAd];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        
        adCloseButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        adCloseButton.frame = CGRectMake(300,40,16,17);
        [adCloseButton setBackgroundImage:[[UIImage imageNamed:@"adexitbutton.png"] stretchableImageWithLeftCapWidth:10.0 topCapHeight:0.0] forState:UIControlStateNormal];
    }
    else
    {
        adCloseButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        adCloseButton.frame = CGRectMake(700,70,40,41);
        [adCloseButton setBackgroundImage:[[UIImage imageNamed:@"adexitbutton-ipad.png"] stretchableImageWithLeftCapWidth:10.0 topCapHeight:0.0] forState:UIControlStateNormal];
    }

    [adCloseButton addTarget:self action:@selector(purchase_bannerAds) forControlEvents:UIControlEventTouchUpInside];
    [bootViewController.view addSubview:adCloseButton];
    
    /*
     if (![[InAppPurchaseManager sharedInAppManager]  storeLoaded])
     {
         [self cancleBannerAd];
     }
     */
    
    [Flurry logEvent:@"Showing AppLovin Banner"];
}

-(void) adSuccess
{
    switch(adsRequestSource)
    {
        case requestFromBootUp:
            adsNumber_bootUp--;
            if(adsNumber_bootUp>0)
            {
                currentLevel_bootUp++;
                [self startAdsWithCurrentLevel_bootUp];
            }
            break;
            
        case requestFromMoreGames:
            break;
            
        case requestFromGameOver:
            break;
            
        case requestFromBannerAds:
            break;
            
        case requestFromForeground:
            break;
            
        case requestFromPause:
            break;
            
        default:
			break;
    }
}

-(void) adFailover
{
    switch(adsRequestSource)
    {
        case requestFromBootUp:
            currentLevel_bootUp++;
            [self startAdsWithCurrentLevel_bootUp];
            break;
            
        case requestFromMoreGames:
            currentLevel_moreGame++;
            [self startAdsWithCurrentLevel_moreGame];
            break;
            
        case requestFromGameOver:
            currentLevel_gameOver++;
            [self startAdsWithCurrentLevel_gameOver];
            break;
            
        case requestFromBannerAds:
            currentLevel_bannerAds++;
            [self startAdsWithCurrentLevel_bannerAds];
            break;
            
        case requestFromForeground:
            currentLevel_foreGround++;
            [self startAdsWithCurrentLevel_foreGround];
            break;
            
        case requestFromPause:
            currentLevel_pause++;
            [self startAdsWithCurrentLevel_pause];
            break;
            
        default:
			break;
    }
}

//P4RC Listeners

- (void)initializationDidComplete
{
}

- (void)initializationDidFail
{
}

- (void)pointsWasSentOnServer
{

    int x_distance=0;
    int y_distance=0;
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        if(IS_IPHONE_5)
        {
            x_distance=10;
            y_distance=10;
        }
        else if(!IS_IPHONE_5)
        {
            x_distance=10;
            y_distance=10;
        }
    }
    else if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        x_distance=10;
        y_distance=10;
    }
    
    
	//[self p4rcShowGameOverButtonInPositionX:p4rcPosition_x+x_distance       inPositionY:p4rcPosition_y+y_distance];
    //[self p4rcShowScoreInPositionX: p4rcscorePosition_x+x_distance  inPositionY:p4rcscorePosition_y+y_distance];
     
}

- (void)pointsSendingDidFail
{
}



//chartboost ads Listeners
- (BOOL)shouldDisplayInterstitial:(NSString *)location
{
    [self adSuccess];
    
    return YES;
}

- (void)didFailToLoadInterstitial:(NSString *)location
{
    if(tried_chartboost==FALSE)
    {
        tried_chartboost=TRUE;
        [self adFailover];
    }
}

- (BOOL)shouldDisplayMoreApps
{
    [self adSuccess];
    
    return YES;
}

- (void)didFailToLoadMoreApps
{
    if(tried_chartboost==FALSE)
    {
        tried_chartboost=TRUE;
        [self adFailover];
    }
}

- (void)didCacheInterstitial:(NSString *)location
{
}

//play haven ads Listeners
- (void)requestDidFinishLoading:(PHAPIRequest *)request
{
    [self adSuccess];
}

- (void)request:(PHAPIRequest *)request didFailWithError:(NSError *)error
{
    if(tried_playhaven==FALSE)
    {
        tried_playhaven=TRUE;
        [self adFailover];
    }
}

- (void)request:(PHAPIRequest *)request didSucceedWithResponse:(NSDictionary *)responseData
{
}

- (void)requestFinishedPrefetching:(PHAPIRequest *)request
{
}

//revmob ads Listeners
- (void)revmobAdDisplayed
{
    [self adSuccess];
}

-(void) revmobAdDidFailWithError:(NSError *)error
{
    if(tried_revmob==FALSE)
    {
        tried_revmob=TRUE;
        [self adFailover];
    }
}

- (void)revmobAdDidReceive
{
}

- (void)revmobUserClickedInTheAd
{
}

- (void)revmobUserClosedTheAd
{
}



//appLovin ads Listeners
-(void)adService:(ALAdService *)adService didLoadAd:(ALAd *)ad
{
    [self adSuccess];
}


-(void)adService:(ALAdService *)adService didFailToLoadAdWithError:(int)code
{
    if(tried_applovin==FALSE)
    {
        tried_applovin=TRUE;
        [self adFailover];
    }
}

-(void) ad:(ALAd *) ad wasDisplayedIn: (ALAdView *)view;
{
}

-(void) ad:(ALAd *) ad wasHiddenIn: (ALAdView *)view
{
}

-(void)ad:(ALAd *)ad wasClickedIn:(UIView *)view
{
}


//iAds listener
- (void)bannerViewActionDidFinish:(ADBannerView *)banner
{
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
}

- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
}


//mobclix listener

- (void)adViewDidFinishLoad:(MobclixAdView*)adView {
	
}

- (void)adView:(MobclixAdView*)adView didFailLoadWithError:(NSError*)error {
	
}

- (void)adViewWillTouchThrough:(MobclixAdView*)adView {
	
}

- (void)adViewDidFinishTouchThrough:(MobclixAdView*)adView {
	
}

//tapjoy listener
-(void) tjcConnectSuccess:(NSNotification*)notifyObj
{
}

-(void) tjcConnectFail:(NSNotification*)notifyObj
{
}

//vungle listener

-(void)vungleMoviePlayed:(VGPlayData*)playData
{
}

-(void)vungleStatusUpdate:(VGStatusData*)statusData
{
}

-(void)vungleViewDidDisappear:(UIViewController*)viewController
{
}

-(void)vungleViewWillAppear:(UIViewController*)viewController
{
}


@end



