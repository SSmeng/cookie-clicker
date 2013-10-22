

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
#import "MKStoreObserver.h"

@interface MKStoreManager : NSObject<SKProductsRequestDelegate> {

	NSMutableArray *purchasableObjects;
	MKStoreObserver *storeObserver;	
	
}

@property (nonatomic, retain) NSMutableArray *purchasableObjects;
@property (nonatomic, retain) MKStoreObserver *storeObserver;

- (void) requestProductData;
- (void) buyFeatureAutoClicker;
- (void) buyFeatureGrandma;
- (void) buyFeatureCRobot;
- (void) buyFeatureCookieFarm;
-(void) buyFeatureCFactory;
-(void) buyFeatureRemoveAds;

// do not call this directly. This is like a private method
- (void) buyFeature:(NSString*) featureId;

- (void) failedTransaction: (SKPaymentTransaction *)transaction;
-(void) provideContent: (NSString*) productIdentifier;

+ (MKStoreManager*)sharedManager;

//+(BOOL) featureAllLevels_Purchased;
+ (BOOL) featureAutoClicker_Purchased;
+ (BOOL) featureGrandma_Purchased;
+ (BOOL) featureCRobot_Purchased;
+ (BOOL) featureCookieFarm_Purchased;
+ (BOOL) featureCFactory_Purchased;
+ (BOOL) featureRemoveAds_Purchased;

+(void) loadPurchases;
+(void) updatePurchases;

-(void) restore;

@end
