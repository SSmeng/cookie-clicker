//
//  InAppPurchaseManager.h
//  Lightspeed
//
//  Created by Nelson Andre on 12-07-18.
//  Copyright (c) 2012 NetMatch. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>


#define kInAppPurchaseManagerProductsFetchedNotification @"kInAppPurchaseManagerProductsFetchedNotification"

// add a couple notifications sent out when the transaction completes
#define kInAppPurchaseManagerTransactionFailedNotification @"kInAppPurchaseManagerTransactionFailedNotification"
#define kInAppPurchaseManagerTransactionSucceededNotification @"kInAppPurchaseManagerTransactionSucceededNotification"


@interface InAppPurchaseManager : NSObject <SKProductsRequestDelegate, SKPaymentTransactionObserver>
{
    SKProduct *removeAdsProduct;
    SKProduct *removeAllAdsProduct;
    
    SKProductsRequest *productsRequest;
    SKProductsRequest *productsRequest_AllAds;

    
	BOOL storeDoneLoading;
    BOOL storeDoneLoading_AllAds;

}

+(InAppPurchaseManager *)sharedInAppManager;

- (void)requestAppStoreProductData;
- (void)requestAppStoreProductData_AllAds;

- (void)loadStore;
- (void)loadStore_AllAds;

- (BOOL)storeLoaded;
- (BOOL)storeLoaded_AllAds;


- (BOOL)canMakePurchases;

- (void)purchaseRemoveAds;
- (void)purchaseRemoveAllAds;

- (void)restoreCompletedTransactions;

- (SKProduct *)getRemoveAdsProduct;
- (SKProduct *)getRemoveAllAdsProduct;

@end

@interface SKProduct (LocalizedPrice)

@property (nonatomic, readonly) NSString *localizedPrice;

@end