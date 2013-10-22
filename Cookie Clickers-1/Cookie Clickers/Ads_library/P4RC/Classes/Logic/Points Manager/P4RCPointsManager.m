//
//  P4RCPointsManager.m
//  ConstaPad
//
//  Created by Artem Stepanenko on 7/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "P4RCPointsManager.h"
#import "ServerGateway.h"
#import "P4RCCacheManager.h"
#import "P4RCUtils.h"
#import "P4RCServerConfig.h"
#import "ServerGateway.h"
#import "P4RCEncodingUtil.h"

#define TOTAL_GAME_POINTS_KEY		@"totalPoints"
#define LAST_GAME_POINTS_KEY		@"lastPoints"
#define TOTAL_P4RC_POINTS_KEY		@"totalP4RCPoints"
#define LAST_P4RC_POINTS_KEY		@"lastP4RCPoints"

#define CACHED_POINTS_INFO			@"cachedPointsInfo"

#define LEVEL_KEY					@"level"
#define MINUTES_PLAYED_KEY			@"minutesPlayed"
#define LEVEL_START_DATE_KEY		@"levelStartDate"
#define LEVEL_END_DATE_KEY			@"levelEndDate"
#define GAME_POINTS_KEY				@"gamePoints"
#define SECURITY_OBJECT_KEY			@"securityObject"
#define TRANS_TIME_KEY				@"transTime"

#define POINTS_STORAGE_NAME			@"file4.dat"

static const int kMaxScore = 100;


@interface P4RCPointsManager () <ReceiverProtocol>

@property (nonatomic, assign) NSInteger lastP4RCPoints;
@property (nonatomic, assign) NSInteger lastGamePoints;
@property (nonatomic, readonly) NSMutableArray *waitingForResponsePointsArray;
@property (nonatomic, readonly) NSMutableArray *checkedInPointsIndeces;
@property (nonatomic, assign, readwrite) id<P4RCPointsManagerDelegate> delegate;

- (NSString *)pointsStoragePath;
- (NSInteger)pointsWithKey:(NSString *)key;
- (void)setPoints:(NSInteger)points byKey:(NSString *)key;

- (void)addToCacheGamePoints:(NSInteger)gamePoints
			   minutesPlayed:(NSInteger)minutesPlayed
				   startDate:(NSDate *)startDate
					 endDate:(NSDate *)endDate
					   level:(NSInteger)level;

- (void)addToWaitingForResponseGamePoints:(NSInteger)gamePoints
							minutesPlayed:(NSInteger)minutesPlayed
								startDate:(NSDate *)startDate
								  endDate:(NSDate *)endDate
									level:(NSInteger)level;

- (NSDictionary *)pointsDictionaryWithGamePoints:(NSInteger)gamePoints
								   minutesPlayed:(NSInteger)minutesPlayed
									   startDate:(NSDate *)startDate
										 endDate:(NSDate *)endDate
										   level:(NSInteger)level;

- (NSInteger)cachedPointsArrayCount;
- (NSMutableDictionary *)pointsDictionary;

@end


@implementation P4RCPointsManager

@synthesize totalP4RCPoints;
@synthesize	lastP4RCPoints;
@synthesize	totalGamePoints;
@synthesize	lastGamePoints;
@synthesize	waitingForResponsePointsArray;
@synthesize	checkedInPointsIndeces;
@synthesize	levelStartDate;
@synthesize	delegate;
@synthesize pointsTable;
@synthesize maxPointsPerLevel;

- (void)dealloc
{
	[waitingForResponsePointsArray release];
	[gameRefId release];
	[levelStartDate release];
    [pointsTable release];
    
	[super dealloc];
}

- (NSMutableArray *)checkedInPointsIndeces
{
	if (checkedInPointsIndeces == nil)
	{
		checkedInPointsIndeces = [NSMutableArray new];
	}
	return checkedInPointsIndeces;
}

- (NSMutableArray *)waitingForResponsePointsArray
{
	if (waitingForResponsePointsArray == nil)
	{
		waitingForResponsePointsArray = [NSMutableArray new];
	}
	return waitingForResponsePointsArray;
}

- (id)initWithGameRefId:(NSString *)theGameRefId delegate:(id<P4RCPointsManagerDelegate>)theDelegate
{
	self = [super init];
	if (self)
	{
		[self setDelegate:theDelegate];
		gameRefId = [theGameRefId copy];
        
        maxPointsPerLevel = kMaxScore;
	}
	return self;
}

- (void)resetGamePoints
{
	[self setTotalGamePoints:0];
	[self setLastGamePoints:0];
}

- (void)resetP4RCPoints
{
	[self setTotalP4RCPoints:0];
	[self setLastP4RCPoints:0];
}

- (NSInteger)totalP4RCPoints
{
	return [self pointsWithKey:TOTAL_P4RC_POINTS_KEY];
}

- (void)setTotalP4RCPoints:(NSInteger)points
{
	[self setPoints:points byKey:TOTAL_P4RC_POINTS_KEY];
}

- (NSInteger)lastP4RCPoints
{
	return [self pointsWithKey:LAST_P4RC_POINTS_KEY];
}

- (void)setLastP4RCPoints:(NSInteger)points
{
	[self setPoints:points byKey:LAST_P4RC_POINTS_KEY];
}

- (NSInteger)totalGamePoints
{
	return [self pointsWithKey:TOTAL_GAME_POINTS_KEY];
}

- (void)setTotalGamePoints:(NSInteger)points
{
	[self setPoints:points byKey:TOTAL_GAME_POINTS_KEY];
}

- (NSInteger)lastGamePoints
{
	return [self pointsWithKey:LAST_GAME_POINTS_KEY];
}

- (void)setLastGamePoints:(NSInteger)points
{
	[self setPoints:points byKey:LAST_GAME_POINTS_KEY];
}

- (void)checkInPoints:(NSInteger)points forLevel:(NSInteger)level
{
	[P4RCCacheManager setLastLevelPlayed:level];
	[self setTotalGamePoints:([self totalGamePoints] + points)];
	[self setLastGamePoints:points];
	
	NSDate *levelEndDate = [NSDate date];
	
	// add to cache for response
	[self addToCacheGamePoints:points minutesPlayed:0 startDate:[self levelStartDate] endDate:levelEndDate level:level];
	// sending points
    
    
    
    if ([self pointsTable] != nil) {
        [self convertPointsToP4RCPoints:points level:level];
    } else {
        [[ServerGateway sharedInstance] convertPointsToP4RCPoints:points
                                                            level:level
                                                    minutesPlayed:0
                                                        gameRefId:gameRefId
                                                         loggedIn:NO
                                                   securityObject:nil
                                                      forReceiver:self];
    }
	
	NSString *securityObject = [P4RCCacheManager sessionId];
	if ((securityObject != nil) && ([securityObject isEqualToString:@""] == NO))
	{
		// sending points
		[[ServerGateway sharedInstance] checkinPoints:points
												level:level
										minutesPlayed:0
											startDate:[self levelStartDate]
											  endDate:levelEndDate
											gameRefId:gameRefId
									   securityObject:securityObject
										  forReceiver:self];
	}
}

- (void)convertPointsToP4RCPoints:(NSInteger)points level:(NSInteger)level {
    if (level > [pointsTable count] || level <= 0) {
        [[self delegate] pointsManagerDidFail:self];
        return;
    }
    NSInteger gameScore = [[[pointsTable objectAtIndex:(level - 1)] objectForKey:@"gameScore"] integerValue];
    NSInteger p4rcPoints = [[[pointsTable objectAtIndex:(level - 1)] objectForKey:@"p4rcPoints"] integerValue];
    NSInteger p4rcCoef =  gameScore / p4rcPoints;
    NSInteger newP4RCPoints = points / p4rcCoef;
    
    // check if earned points is not bigger than max allowed points 
    if (newP4RCPoints > [self maxPointsPerLevel]) {
        newP4RCPoints = [self maxPointsPerLevel];
    }
    
    [self setLastP4RCPoints:newP4RCPoints];
    [self setTotalP4RCPoints:([self totalP4RCPoints] + [self lastP4RCPoints])];
    [[self delegate] pointsManagerDidCompleteLocally:self];
}

- (void)checkInTotalPoints:(NSInteger)points afterLevel:(NSInteger)level
{
	NSInteger newGamePoints = points - [self totalGamePoints];
	[self checkInPoints:newGamePoints forLevel:level];
}

- (BOOL)checkInCachedPoints
{
	NSDictionary *pointsDictionary = [P4RCEncodingUtil loadDictionaryWithDecryptedContentOfFile:[self pointsStoragePath]];
	
	NSArray *cachedPointsArray = [pointsDictionary objectForKey:CACHED_POINTS_INFO];
    
    if ([cachedPointsArray lastObject] == nil)
    {
        return NO;
    }
	
	NSMutableArray *pointsArray = [NSMutableArray new];
	NSMutableArray *levelsArray = [NSMutableArray new];
	NSMutableArray *minutesPlayedArray = [NSMutableArray new];
	NSMutableArray *startDatesArray = [NSMutableArray new];
	NSMutableArray *endDatesArray = [NSMutableArray new];
	NSMutableArray *transTimesArray = [NSMutableArray new];
	
	NSString *currentSecurityObject = [P4RCCacheManager sessionId];
	NSInteger i = 0;
	for (NSDictionary *pointsItemDictionary in cachedPointsArray)
	{
        [[self checkedInPointsIndeces] addObject:[NSNumber numberWithInteger:i]];
        NSNumber *gamePoints = [pointsItemDictionary objectForKey:GAME_POINTS_KEY];
        [pointsArray addObject:gamePoints];
        [levelsArray addObject:[pointsItemDictionary objectForKey:LEVEL_KEY]];
        [minutesPlayedArray addObject:[pointsItemDictionary objectForKey:MINUTES_PLAYED_KEY]];
        [startDatesArray addObject:[pointsItemDictionary objectForKey:LEVEL_START_DATE_KEY]];
        [endDatesArray addObject:[pointsItemDictionary objectForKey:LEVEL_END_DATE_KEY]];
        [transTimesArray addObject:[pointsItemDictionary objectForKey:TRANS_TIME_KEY]];
		i ++;
	}
	
	BOOL flag;
	
	if ([pointsArray count] > 0)
	{
        if ([[ServerGateway sharedInstance] isBusy])
        {
            flag = NO;
            [self performSelector:@selector(checkInCachedPoints) withObject:nil afterDelay:15];
        }
        else
        {
            flag = YES;
            [[ServerGateway sharedInstance] checkinInBatchGamePoints:[NSArray arrayWithArray:pointsArray]
                                                              levels:[NSArray arrayWithArray:levelsArray]
                                                       minutesPlayed:[NSArray arrayWithArray:minutesPlayedArray]
                                                          startDates:[NSArray arrayWithArray:startDatesArray]
                                                            endDates:[NSArray arrayWithArray:endDatesArray]
                                                          transTimes:transTimesArray
                                                           gameRefId:gameRefId
                                                      securityObject:currentSecurityObject
                                                         forReceiver:self];
        }
	}
	else
	{
		flag = NO;
	}

	
	[pointsArray release];
	[levelsArray release];
	[minutesPlayedArray release];
	[startDatesArray release];
	[endDatesArray release];
	[transTimesArray release];
	
	return flag;
}

#pragma mark -
#pragma mark ReceiverProtocol methods

- (void)convertGamePointsCompleteWithP4RCPoints:(NSInteger)newP4RCPoints error:(NSError *)error
{
	if (!error)
	{
		[self setLastP4RCPoints:newP4RCPoints];
		[self setTotalP4RCPoints:([self totalP4RCPoints] + newP4RCPoints)];
		// notification
		[[self delegate] pointsManagerDidComplete:self];
	}
	else
	{
		[self setLastP4RCPoints:0];
		// notification
		[[self delegate] pointsManagerDidFail:self];
	}
}

- (void)checkInPointsComplete:(NSInteger)p4rcPoints error:(NSError *)error
{
	if (!error)
	{
		NSMutableDictionary *pointsDictionary = [self pointsDictionary];
		if ([[pointsDictionary allKeys] count] == 0)
		{
			return;
		}

		NSMutableArray *cachedPointsArray = [NSMutableArray arrayWithArray:[pointsDictionary objectForKey:CACHED_POINTS_INFO]];
		if (cachedPointsArray == nil)
		{
			return;
		}
		[cachedPointsArray removeLastObject];
		[pointsDictionary setObject:[NSArray arrayWithArray:cachedPointsArray] forKey:CACHED_POINTS_INFO];
		
		[P4RCEncodingUtil saveEncryptedDictionary:[NSDictionary dictionaryWithDictionary:pointsDictionary] toFile:[self pointsStoragePath]];
	}
    else if([error code] == 504) {
        [P4RCCacheManager setSessionIdCookie:nil];
        [P4RCCacheManager setSessionId:nil];
    }
}

- (void)checkInBatchPointsComplete:(NSInteger)points error:(NSError *)error
{
	if (!error)
	{
		// remove checked in points from cache
		NSMutableDictionary *pointsDictionary = [NSMutableDictionary dictionaryWithDictionary:[P4RCEncodingUtil loadDictionaryWithDecryptedContentOfFile:[self pointsStoragePath]]];
		NSMutableArray *cachedPointsArray = [NSMutableArray arrayWithArray:[pointsDictionary objectForKey:CACHED_POINTS_INFO]];
        
        // HOTFIX! If echo, just return.
        if ([cachedPointsArray count] == 0) {
            return;
        }
		NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
        
        [self setTotalP4RCPoints:points];

        
		for (NSNumber *index in [self checkedInPointsIndeces])
		{
			[indexSet addIndex:[index integerValue]];
		}
		[cachedPointsArray removeObjectsAtIndexes:indexSet];
		[pointsDictionary setObject:[NSArray arrayWithArray:cachedPointsArray] forKey:CACHED_POINTS_INFO];
		
		[P4RCEncodingUtil saveEncryptedDictionary:[NSDictionary dictionaryWithDictionary:pointsDictionary] toFile:[self pointsStoragePath]];
		
		[[self checkedInPointsIndeces] removeAllObjects];
	}
	else
	{
		[[self checkedInPointsIndeces] removeAllObjects];
	}
}

#pragma mark -
#pragma mark Private methods

- (NSDictionary *)pointsDictionaryWithGamePoints:(NSInteger)gamePoints
								   minutesPlayed:(NSInteger)minutesPlayed
									   startDate:(NSDate *)startDate
										 endDate:(NSDate *)endDate
										   level:(NSInteger)level
{
	return [NSDictionary dictionaryWithObjectsAndKeys:
			[NSNumber numberWithInteger:level], LEVEL_KEY,
			[NSNumber numberWithInteger:0], MINUTES_PLAYED_KEY,
			[NSNumber numberWithDouble:[startDate timeIntervalSince1970]], LEVEL_START_DATE_KEY,
			[NSNumber numberWithDouble:[endDate timeIntervalSince1970]], LEVEL_END_DATE_KEY,
			[NSNumber numberWithInteger:gamePoints], GAME_POINTS_KEY,
			[NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]], TRANS_TIME_KEY,
			[P4RCCacheManager sessionId], SECURITY_OBJECT_KEY,
			nil];
}

- (void)addToWaitingForResponseGamePoints:(NSInteger)gamePoints
							minutesPlayed:(NSInteger)minutesPlayed
								startDate:(NSDate *)startDate
								  endDate:(NSDate *)endDate
									level:(NSInteger)level
{
	[[self waitingForResponsePointsArray] addObject:[self pointsDictionaryWithGamePoints:gamePoints
																		   minutesPlayed:minutesPlayed
																			   startDate:startDate
																				 endDate:endDate
																				   level:level]];
}

- (void)addToCacheGamePoints:(NSInteger)gamePoints
			   minutesPlayed:(NSInteger)minutesPlayed
				   startDate:(NSDate *)startDate
					 endDate:(NSDate *)endDate
					   level:(NSInteger)level
{
	NSMutableDictionary *pointsDictionary = [self pointsDictionary];
	NSMutableArray *cachedPointsArray = [[[NSMutableArray alloc] initWithArray:[pointsDictionary objectForKey:CACHED_POINTS_INFO]] autorelease];
	if (cachedPointsArray == nil)
	{
		cachedPointsArray = [[[NSMutableArray alloc] init] autorelease];
	}
	
	NSDictionary *newPointsInfoDictionary = [self pointsDictionaryWithGamePoints:gamePoints
																   minutesPlayed:minutesPlayed
																	   startDate:startDate
																		 endDate:endDate
																		   level:level];
	
	[cachedPointsArray addObject:newPointsInfoDictionary];
	[pointsDictionary setObject:[NSArray arrayWithArray:cachedPointsArray] forKey:CACHED_POINTS_INFO];
	[P4RCEncodingUtil saveEncryptedDictionary:[NSDictionary dictionaryWithDictionary:pointsDictionary] toFile:[self pointsStoragePath]];
}

- (NSInteger)cachedPointsArrayCount
{
	NSDictionary *pointsDictionary = [P4RCEncodingUtil loadDictionaryWithDecryptedContentOfFile:[self pointsStoragePath]];
	
	if (pointsDictionary == nil)
	{
		return 0;
	}
	
	NSArray *cachedPointsArray = (NSArray *)[pointsDictionary objectForKey:CACHED_POINTS_INFO];
	if (cachedPointsArray == nil)
	{
		return 0;
	}
	else
	{
		return [cachedPointsArray count];
	}
}

- (NSInteger)pointsWithKey:(NSString *)key
{
	NSDictionary *pointsDictionary = [P4RCEncodingUtil loadDictionaryWithDecryptedContentOfFile:[self pointsStoragePath]];
	if (pointsDictionary == nil)
	{
		return 0;
	}
	return [[pointsDictionary objectForKey:key] integerValue];
}

- (void)setPoints:(NSInteger)points byKey:(NSString *)key
{
	NSMutableDictionary *pointsDictionary = [self pointsDictionary];
	
	[pointsDictionary setObject:[NSNumber numberWithInteger:points] forKey:key];
	
	[P4RCEncodingUtil saveEncryptedDictionary:[NSDictionary dictionaryWithDictionary:pointsDictionary] toFile:[self pointsStoragePath]];
}

- (NSString *)pointsStoragePath
{
	return [P4RCUtils pathToFileWithName:POINTS_STORAGE_NAME];
}

- (NSMutableDictionary *)pointsDictionary
{
	NSDictionary *dictionary = [P4RCEncodingUtil loadDictionaryWithDecryptedContentOfFile:[self pointsStoragePath]];
	NSMutableDictionary *pointsDictionary;
	if (dictionary == nil)
	{
		pointsDictionary = [NSMutableDictionary dictionary];
	}
	else
	{
		pointsDictionary = [NSMutableDictionary dictionaryWithDictionary:dictionary];
	}
	
	return pointsDictionary;
}

@end






