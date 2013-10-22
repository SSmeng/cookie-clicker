#import "InAppPurchaseManager.h"
#import "SNAdsManager.h"
#import "Flurry.h"

@implementation InAppPurchaseManager

static InAppPurchaseManager *_sharedInAppManager = nil;

+ (InAppPurchaseManager *)sharedInAppManager
{
	@synchronized([InAppPurchaseManager class])
	{
		if (!_sharedInAppManager)
			[[self alloc] init];
		
		return _sharedInAppManager;
	}
	// to avoid compiler warning
	return nil;
}

+(id)alloc
{
	@synchronized([InAppPurchaseManager class])
	{
		NSAssert(_sharedInAppManager == nil, @"Attempted to allocate a second instance of a singleton.");
		_sharedInAppManager = [super alloc];
		return _sharedInAppManager;
	}
	// to avoid compiler warning
	return nil;
}

-(id) init
{
	storeDoneLoading = NO;
    storeDoneLoading_AllAds= NO;
    
	return self;
}

- (void) dealloc
{
	[removeAdsProduct release];
    [removeAllAdsProduct release];
    
	[super dealloc];
}

- (BOOL) storeLoaded
{
	return storeDoneLoading;
}

- (BOOL) storeLoaded_AllAds
{ 
	return storeDoneLoading_AllAds;
}


- (void)requestAppStoreProductData
{	
    NSSet *productIdentifiers = [NSSet setWithObjects: INAPPPURCHASE_REMOVESADS_ID, nil ];
    productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:productIdentifiers];
    productsRequest.delegate = self;
    [productsRequest start];
    
    // we will release the request object in the delegate callback
}


- (void)requestAppStoreProductData_AllAds
{
    NSSet *productIdentifiers = [NSSet setWithObjects: INAPPPURCHASE_REMOVESALLADS_ID, nil ];
    productsRequest_AllAds = [[SKProductsRequest alloc] initWithProductIdentifiers:productIdentifiers];
    productsRequest_AllAds.delegate = self;
    [productsRequest_AllAds start];
    
    // we will release the request object in the delegate callback
}




#pragma mark In-App Product Accessor Methods

- (SKProduct *)getRemoveAdsProduct
{
	return removeAdsProduct;
}

- (SKProduct *)getRemoveAllAdsProduct
{
	return removeAllAdsProduct;
}



#pragma mark -
#pragma mark SKProductsRequestDelegate methods

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    NSArray *products = response.products;
	for (SKProduct *inAppProduct in products)
	{
		if ([inAppProduct.productIdentifier isEqualToString:INAPPPURCHASE_REMOVESADS_ID])
		{
			removeAdsProduct = [inAppProduct retain];
            storeDoneLoading = YES;
		}
        
        if ([inAppProduct.productIdentifier isEqualToString:INAPPPURCHASE_REMOVESALLADS_ID])
		{
			removeAllAdsProduct = [inAppProduct retain];
            storeDoneLoading_AllAds = YES;
		} 
	}
	    
	
    
    for (NSString *invalidProductId in response.invalidProductIdentifiers)
    {
        NSLog(@"Invalid product id: %@" , invalidProductId);
        
        
        
        for (SKProduct *inAppProduct in products)
        {
            if([inAppProduct.productIdentifier isEqualToString:INAPPPURCHASE_REMOVESADS_ID])
            {
                storeDoneLoading = NO;
            }
            
            if([inAppProduct.productIdentifier isEqualToString:INAPPPURCHASE_REMOVESALLADS_ID])
            {

                storeDoneLoading_AllAds = NO;
            }
            
       
            
        }
        

    }
    
    // finally release the reqest we alloc/init’ed in requestlevelUpgradeProductData

    for (SKProduct *inAppProduct in products)
	{
        if([inAppProduct.productIdentifier isEqualToString:INAPPPURCHASE_REMOVESADS_ID])
        {
            [productsRequest release];
        }
        
        if([inAppProduct.productIdentifier isEqualToString:INAPPPURCHASE_REMOVESALLADS_ID])
        {
			[productsRequest_AllAds release];
        }
        
       
	}
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kInAppPurchaseManagerProductsFetchedNotification object:self userInfo:nil];
}

//
// call this method once on startup
//
- (void)loadStore
{
    // restarts any purchases if they were interrupted last time the app was open
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    
    // get the product description (defined in early sections)
    [self requestAppStoreProductData];
}

- (void)loadStore_AllAds
{
    // restarts any purchases if they were interrupted last time the app was open
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    
    // get the product description (defined in early sections)
    [self requestAppStoreProductData_AllAds];
    
}



//
// call this before making a purchase
//
- (BOOL)canMakePurchases
{
    return [SKPaymentQueue canMakePayments];
}

//
// kick off the upgrade transaction
//
- (void)purchaseRemoveAds{
    SKPayment *payment = [SKPayment paymentWithProductIdentifier:INAPPPURCHASE_REMOVESADS_ID];
    
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

- (void)purchaseRemoveAllAds{

    SKPayment *payment = [SKPayment paymentWithProductIdentifier:INAPPPURCHASE_REMOVESALLADS_ID];
    
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}



// Restore completed transactions
- (void) restoreCompletedTransactions
{
	[[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}


//
// saves a record of the transaction by storing the receipt to disk
//
- (void)recordTransaction:(SKPaymentTransaction *)transaction
{
    if ([transaction.payment.productIdentifier isEqualToString:INAPPPURCHASE_REMOVESADS_ID])
    {
        // save the transaction receipt to disk
        [[NSUserDefaults standardUserDefaults] setValue:transaction.transactionReceipt forKey:@"removeAdsTransactionReceipt" ];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    if ([transaction.payment.productIdentifier isEqualToString:INAPPPURCHASE_REMOVESALLADS_ID])
    {
        // save the transaction receipt to disk
        [[NSUserDefaults standardUserDefaults] setValue:transaction.transactionReceipt forKey:@"removeAllAdsTransactionReceipt" ];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    
    
}

//
// enable pro features
//
- (void)provideContent:(NSString *)productId
{
    if ([productId isEqualToString:INAPPPURCHASE_REMOVESADS_ID])
    {
        // enable the requested features by setting a global user value
        //[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isLevelUpgradePurchased" ];
        //[[NSUserDefaults standardUserDefaults] synchronize];
        
        NSLog(@"Purchased: %@", productId);
    
        UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Success!" 
                                                         message:@"Banner ads have been removed"
                                                        delegate:nil 
                                               cancelButtonTitle:nil 
                                               otherButtonTitles:@"OK", nil] autorelease];
        
        [alert show];
        
        [[SNAdsManager sharedManager] saveAdRemovalStatus];
        
        [Flurry logEvent:@"Purchase banner ads"];
    }
    
    if ([productId isEqualToString:INAPPPURCHASE_REMOVESALLADS_ID])
    {
        UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Success!"
                                                         message:@"All ads have been removed"
                                                        delegate:nil
                                               cancelButtonTitle:nil
                                               otherButtonTitles:@"OK", nil] autorelease];
        
        [alert show];
        
        
        [[SNAdsManager sharedManager] saveAllAdRemovalStatus];
        
        [Flurry logEvent:@"Purchase all ads"];
    }
    
   
    
    
}


//
// removes the transaction from the queue and posts a notification with the transaction result
//
- (void)finishTransaction:(SKPaymentTransaction *)transaction wasSuccessful:(BOOL)wasSuccessful
{
    // remove the transaction from the payment queue.
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:transaction, @"transaction" , nil];
    if (wasSuccessful)
    {
        // send out a notification that we’ve finished the transaction
        [[NSNotificationCenter defaultCenter] postNotificationName:kInAppPurchaseManagerTransactionSucceededNotification object:self userInfo:userInfo];
    }
    else
    {
        // send out a notification for the failed transaction
        [[NSNotificationCenter defaultCenter] postNotificationName:kInAppPurchaseManagerTransactionFailedNotification object:self userInfo:userInfo];
    }
}

//
// called when the transaction was successful
//
- (void)completeTransaction:(SKPaymentTransaction *)transaction
{
    [self recordTransaction:transaction];
    [self provideContent:transaction.payment.productIdentifier];
    [self finishTransaction:transaction wasSuccessful:YES];
}

//
// called when a transaction has been restored and and successfully completed
//
- (void)restoreTransaction:(SKPaymentTransaction *)transaction
{
    [self recordTransaction:transaction.originalTransaction];
    [self provideContent:transaction.originalTransaction.payment.productIdentifier];
    [self finishTransaction:transaction wasSuccessful:YES];
}

//
// called when a transaction has failed
//
- (void)failedTransaction:(SKPaymentTransaction *)transaction
{
    if (transaction.error.code != SKErrorPaymentCancelled)
    {
        // error!
		NSString *messageToBeShown = [NSString stringWithFormat:@"Reason: %@, You can try: %@", [transaction.error localizedFailureReason], [transaction.error localizedRecoverySuggestion]];
        
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unable to complete your purchase" message:messageToBeShown
													   delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
		[alert show];
		[alert release];
		
        [self finishTransaction:transaction wasSuccessful:NO];
    }
    else
    {
        // this is fine, the user just cancelled, so don’t notify
        [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    }
}

#pragma mark -
#pragma mark SKPaymentTransactionObserver methods

//
// called when the transaction status is updated
//
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
                break;
            default:
                break;
        }
    }
}

@end

@implementation SKProduct (LocalizedPrice)

- (NSString *)localizedPrice
{
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [numberFormatter setLocale:self.priceLocale];
    NSString *formattedString = [numberFormatter stringFromNumber:self.price];
    [numberFormatter release];
    return formattedString;
}

@end
