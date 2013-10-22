//
//  P4RCPointsManager.h
//  ConstaPad
//
//  Created by Artem Stepanenko on 7/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@class P4RCPointsManager;

@protocol P4RCPointsManagerDelegate

- (void)pointsManagerDidComplete:(P4RCPointsManager *)sender;
- (void)pointsManagerDidFail:(P4RCPointsManager *)sender;

@optional

- (void)pointsManagerDidCompleteLocally:(P4RCPointsManager *)sender;

@end


@class Reachability;

@interface P4RCPointsManager : NSObject
{
	NSString *gameRefId;
	BOOL isProcessingData;		// FIXME: deprecated
	NSMutableArray *waitingForResponsePointsArray;
	NSMutableArray *checkedInPointsIndeces;
	NSDate *levelStartDate;
	
	id<P4RCPointsManagerDelegate> delegate;
}

@property (nonatomic, assign, readwrite) NSInteger totalP4RCPoints;
@property (nonatomic, assign, readonly) NSInteger lastP4RCPoints;
@property (nonatomic, assign, readwrite) NSInteger totalGamePoints;
@property (nonatomic, assign, readonly) NSInteger lastGamePoints;
@property (nonatomic, copy, readwrite) NSDate *levelStartDate;
@property (nonatomic, retain, readwrite) NSArray *pointsTable;
@property (nonatomic, assign, readwrite) NSInteger maxPointsPerLevel; ///< Received from server once per 24 hours


- (id)initWithGameRefId:(NSString *)theGameRefId delegate:(id<P4RCPointsManagerDelegate>)theDelegate;
- (void)checkInTotalPoints:(NSInteger)points afterLevel:(NSInteger)level;
- (void)checkInPoints:(NSInteger)points forLevel:(NSInteger)level;
- (BOOL)checkInCachedPoints;

- (void)resetGamePoints;	// for game restart
- (void)resetP4RCPoints;	// for logout

@end
