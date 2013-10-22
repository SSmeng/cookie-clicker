

#import "MKStoreManager.h"
#import "AppDelegate.h"
#import "HelloWorldLayer.h"

@implementation MKStoreManager

@synthesize purchasableObjects;
@synthesize storeObserver;

// all your features should be managed one and only by StoreManager

static NSString *featureAutoClicker = @"com.marvin.cookieclikers.AutoClicker";
static NSString *featureGrandma = @"com.marvin.cookieclikers.GrandMa";
static NSString *featureCRobot = @"com.marvin.cookieclikers.CRobot";
static NSString *featureCookieFarm = @"com.marvin.cookieclikers.CookieFarm";
static NSString *featureCFactory = @"com.marvin.cookieclikers.CFactory";
static NSString *featureRemoveAds = @"com.marvin.cookieclikers.RemoveAds";

BOOL featurePurchased_AutoClicker = false;
BOOL featurePurchased_Grandma = false;
BOOL featurePurchased_CRobot = false;
BOOL featurePurchased_CookieFarm = false;
BOOL featurePurchased_CFactory = false;
BOOL featurePurchased_RemoveAds = false;

static MKStoreManager* _sharedStoreManager; // self

- (void)dealloc {
	
	[_sharedStoreManager release];
	[storeObserver release];
	[super dealloc];
}

//+ (BOOL) featureAllLevels_Purchased {
//	
//	return featurePurchased_AllLevels;
//}

+ (BOOL) featureAutoClicker_Purchased {
	
	return featurePurchased_AutoClicker;
}
+ (BOOL) featureGrandma_Purchased {
	
	return featurePurchased_Grandma;
}
+ (BOOL) featureCRobot_Purchased {
	
	return featurePurchased_CRobot;
}
+ (BOOL) featureCookieFarm_Purchased {
	
	return featurePurchased_CookieFarm;
}

+ (BOOL) featureCFactory_Purchased {
	
	return featurePurchased_CFactory;
}

+ (BOOL) featureRemoveAds_Purchased {
	
	return featurePurchased_RemoveAds;
}

+ (MKStoreManager*)sharedManager
{
	@synchronized(self) {
		
        if (_sharedStoreManager == nil) {
			
            [[self alloc] init]; // assignment not done here
			_sharedStoreManager.purchasableObjects = [[NSMutableArray alloc] init];			
			[_sharedStoreManager requestProductData];
			
			[MKStoreManager loadPurchases];
			_sharedStoreManager.storeObserver = [[MKStoreObserver alloc] init];
			[[SKPaymentQueue defaultQueue] addTransactionObserver:_sharedStoreManager.storeObserver];
        }
    }
    return _sharedStoreManager;
}


#pragma mark Singleton Methods

+ (id)allocWithZone:(NSZone *)zone

{	
    @synchronized(self) {
		
        if (_sharedStoreManager == nil) {
			
            _sharedStoreManager = [super allocWithZone:zone];			
            return _sharedStoreManager;  // assignment and return on first allocation
        }
    }
	
    return nil; //on subsequent allocation attempts return nil	
}


- (id)copyWithZone:(NSZone *)zone
{
    return self;	
}

- (id)retain
{	
    return self;	
}

- (unsigned)retainCount
{
    return UINT_MAX;  //denotes an object that cannot be released
}

//- (void)release
//{
//    //do nothing
//}

- (id)autorelease
{
    return self;	
}


- (void) requestProductData
{
	SKProductsRequest *request= [[SKProductsRequest alloc] initWithProductIdentifiers: 
								 [NSSet setWithObjects: /*featureAllLevels, */ featureAutoClicker, featureGrandma, featureCRobot, featureCookieFarm, featureCFactory, featureRemoveAds, nil]]; // add any other product here
	request.delegate = self;
	[request start];
}


- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
	[purchasableObjects addObjectsFromArray:response.products];
	// populate your UI Controls here
	for(int i=0;i<[purchasableObjects count];i++)
	{
		
		SKProduct *product = [purchasableObjects objectAtIndex:i];
		NSLog(@"Feature: %@, Cost: %f, ID: %@",[product localizedTitle],
			  [[product price] doubleValue], [product productIdentifier]);
	}
	
	[request autorelease];
}

//- (void) buyFeature_ALL_LEVELS
//{
//    g_gameInfo.isInAPP = YES;
//    
//	[self buyFeature: featureAllLevels];
//}

- (void) buyFeatureAutoClicker
{
	[self buyFeature: featureAutoClicker];
}
- (void) buyFeatureGrandma
{
	[self buyFeature: featureGrandma];
}
- (void) buyFeatureCRobot
{
	[self buyFeature: featureCRobot];
}
- (void) buyFeatureCookieFarm
{
	[self buyFeature: featureCookieFarm];
}

-(void) buyFeatureCFactory
{
	[self buyFeature:featureCFactory];
}

-(void) buyFeatureRemoveAds
{
	[self buyFeature:featureRemoveAds];
}

- (void) buyFeature:(NSString*) featureId
{
//    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions]; 

	if ([SKPaymentQueue canMakePayments])
	{
		SKPayment *payment = [SKPayment paymentWithProductIdentifier:featureId];
//        [payment.quantity ];
//        NSLog(@"******* %d", [payment quantity]);
		[[SKPaymentQueue defaultQueue] addPayment:payment];
	}
	else
	{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"MyApp" message:@"You are not authorized to purchase from AppStore"
													   delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
		[alert show];
		[alert release];
	}
}

- (void) failedTransaction: (SKPaymentTransaction *)transaction
{
	NSString *messageToBeShown = [NSString stringWithFormat:@"Reason: %@, You can try: %@", [transaction.error localizedFailureReason], [transaction.error localizedRecoverySuggestion]];
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unable to complete your purchase" message:messageToBeShown
												   delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
	[alert show];
	[alert release];
}

-(void) provideContent: (NSString*) productIdentifier
{
    NSUInteger nIdx = 200;
    
	if([productIdentifier isEqualToString: featureAutoClicker])
    {
        m_appDelegate.nAutoClickLevel++;
        m_appDelegate.nAutoClickClickers += [m_appDelegate getChangedClickers:m_appDelegate.nAutoClickLevel clickerType:0];
        
        nIdx = 0;
    }

    if([productIdentifier isEqualToString: featureGrandma])
    {
        m_appDelegate.nGrandMaLevel++;
        m_appDelegate.nGrandMaClickers += [m_appDelegate getChangedClickers:m_appDelegate.nGrandMaLevel clickerType:1];

        nIdx = 1;
    }

    if([productIdentifier isEqualToString: featureCRobot])
    {
        m_appDelegate.nCRobotLevel++;
        m_appDelegate.nCRobotClickers += [m_appDelegate getChangedClickers:m_appDelegate.nCRobotLevel clickerType:2];
        
        nIdx = 2;
    }

    if([productIdentifier isEqualToString: featureCookieFarm])
    {
        m_appDelegate.nCookieFarmLevel++;
        m_appDelegate.nCookieFarmClickers += [m_appDelegate getChangedClickers:m_appDelegate.nCookieFarmLevel clickerType:3];
        
        nIdx = 3;
    }

    if([productIdentifier isEqualToString: featureCFactory])
    {
        m_appDelegate.nCFactoryLevel++;
        m_appDelegate.nCFactoryClickers += [m_appDelegate getChangedClickers:m_appDelegate.nCFactoryLevel clickerType:4];
        
        nIdx = 4;
    }

    if([productIdentifier isEqualToString: featureRemoveAds])
    {
        m_appDelegate.nRemoveAds = 1;
    }

    m_appDelegate.fBaseCps = m_appDelegate.nAutoClickLevel * 0.1 + m_appDelegate.nGrandMaLevel * 0.3 + m_appDelegate.nCRobotLevel * 1.0f + m_appDelegate.nCookieFarmLevel * 3.1f + m_appDelegate.nCFactoryLevel * 6.0f;

    [m_appDelegate.m_gameScene.storeLayer updateLabel:nIdx];
    
    [m_appDelegate.m_gameScene hideIAPViews];
    
    [m_appDelegate saveParam];
    [m_appDelegate loadParam];
    
	[MKStoreManager updatePurchases];
    
}


+(void) loadPurchases 
{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];	

	featurePurchased_AutoClicker = [userDefaults boolForKey: featureAutoClicker];
    featurePurchased_Grandma = [userDefaults boolForKey: featureGrandma];
	featurePurchased_CRobot = [userDefaults boolForKey: featureCRobot];
	featurePurchased_CookieFarm = [userDefaults boolForKey: featureCookieFarm];
    featurePurchased_CFactory = [userDefaults boolForKey: featureCFactory];
    featurePurchased_RemoveAds = [userDefaults boolForKey: featureRemoveAds];
}


+(void) updatePurchases
{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults setBool: featurePurchased_AutoClicker forKey:featureAutoClicker];

    [userDefaults setBool: featurePurchased_Grandma forKey:featureGrandma];
	[userDefaults setBool: featurePurchased_CRobot forKey:featureCRobot];
    [userDefaults setBool: featurePurchased_CookieFarm forKey:featureCookieFarm];
    [userDefaults setBool: featurePurchased_CFactory forKey:featureCFactory];
    [userDefaults setBool: featurePurchased_RemoveAds forKey:featureRemoveAds];
 }

-(void) restore
{
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

@end

