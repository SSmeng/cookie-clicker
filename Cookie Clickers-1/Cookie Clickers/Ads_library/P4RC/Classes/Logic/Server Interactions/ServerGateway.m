//
//  ServerGateway.m
//  ShowMe
//
//  Created by Kostiantyn Zamiesov on 4/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ServerGateway.h"
#import "JSON.h"
#import "P4RCUserInfo.h"
#import "P4RCCacheManager.h"
#import "P4RCUtils.h"
#import "P4RC.h"
#import "P4RCServerConfig.h"
#import "MacAddressHelper.h"

#define JSON_RESPONCE_STATUS_KEY        @"status"
#define JSON_RESPONCE_STATUS_ERROR      @"ERROR"
#define JSON_RESPONCE_STATUS_SUCCESS    @"SUCCESS"

#define JSON_REQUEST_PAYLOAD_KEY        @"payload"
#define JSON_SECURITY_OBJECT_KEY        @"securityObject"

#define GAME_REF_ID_KEY                 @"gameRefId"

#define SIGN_IN_PATH                    @"services/v1/user/authenticate"
#define SIGN_UP_PATH                    @"services/v1/user/registerNewUser"
#define CHECK_POINT_PATH                @"services/v1/userpoints/checkinPoints"
#define CONVERT_POINTS					@"services/v1/gamepoints/convertPoints"
#define NEW_REWARDS_COUNT               @"services/v1/coupon/newCouponsCount"
#define GET_COUPONS_COUNT               @"services/v1/coupon/couponsForInGameBrowsing"
#define PUT_COUPON_IMAGE_PATH			@"services/v1/coupon/couponImageForInGameBrowsing"
#define CLAIM_COUPON                    @"services/v1/coupon/claimCoupon"
#define CHECK_IN_POINTS_PATH            @"services/v2/userpoints/checkinPoints"
#define LOG_EVENT_PATH                  @"services/v1/user/playerPing"
#define CHECK_IN_BATCH_POINTS_PATH      @"services/v2/userpoints/checkinPointsInBatch"
#define FORGOT_PASSWORD_PATH            @"services/v1/user/forgotPassword"
//#define CHECK_IN_POINTS_PATH            @"services/v1/userpoints/checkinPoints"
//#define CHECK_IN_BATCH_POINTS_PATH		@"services/v1/userpoints/checkinPointsInBatch"
#define GET_USER_INFO_PATH              @"services/v1/user/userInfo"
#define GET_POINTS_TABLE_PATH           @"services/v1/gamepoints/pointsTable"
#define GET_MAX_POINTS_PATH             @"services/v1/gamepoints/maxPoints"
#define JSON_ERROR_MESSAGE_KEY          @"message"
#define JSON_ERROR_CODE_KEY             @"code"

#define API_KEY_FIELD					@"X-P4RC-ApiKey"


@interface ServerGateway()

@property (nonatomic, retain, readonly) NSDateFormatter *dateFormatter;

- (BOOL)checkResultForErrors:(NSString *) jsonResult error: (NSError **) error;
- (void)convertPointsToP4RCPointsComplete:(NSString*)jsonResult forConnection:(BaseConnect*)theConnection;
- (void)getUserInfoComplete:(NSString *)jsonResult forConnection:(BaseConnect *) theConnection;
- (void)checkInPointsComplete:(NSString *)jsonResult forConnection:(BaseConnect *)connection;
- (void)checkInBatchPointsComplete:(NSString *)jsonResult forConnection:(BaseConnect *)connection;
- (P4RCUserInfo *)userInfoFromJSON:(NSDictionary *)json;
- (BOOL)checkField:(NSString *)field inObject:(NSDictionary *)object;
- (void)getMaxPointsComplete:(NSString *)jsonResult forConnection:(BaseConnect *)theConnection;

@end


@implementation ServerGateway

@synthesize dateFormatter;
@synthesize isBusy;

static ServerGateway *sharedInstance = nil;

- (void)dealloc 
{
	[dateFormatter release];
	[receiverHashTable release];
    [super dealloc];
}

- (id)init 
{
	if (self = [super init]) 
    {
		receiverHashTable = [[NSMutableDictionary alloc] init];
        isBusy = NO;
	}
	return self;
}

+ (ServerGateway *)sharedInstance
{
	if (sharedInstance == nil)
	{
		sharedInstance = [[ServerGateway alloc] init];
	}
	return sharedInstance;
}

#pragma mark -
#pragma mark Signing Up

- (void)signUpUserWithFirstName:(NSString *)firstName lastName:(NSString *)lastName password:(NSString *)password email:(NSString *)email userAcceptedTerms:(BOOL)accepted forReceiver:(id<ReceiverProtocol>)theReceiver
{
	NSDictionary *payload = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:firstName, lastName, password, email, [NSNumber numberWithBool:accepted], [[P4RC sharedInstance] gameRefId], @"sdk", nil] forKeys:[NSArray arrayWithObjects:@"firstName", @"lastName", @"password", @"email", @"userAcceptedTerms", @"gameRefId", @"deviceType", nil]];
	
	NSDictionary *payloadObject = [NSDictionary dictionaryWithObject:payload forKey:JSON_REQUEST_PAYLOAD_KEY];
	
	NSString *jsonBody = [payloadObject JSONRepresentation];
	BaseConnect *newConnection = [[BaseConnect alloc] initWithPutRequestBody:jsonBody delegate:self 
                                                            remoteMethodPath:SIGN_UP_PATH];
	[newConnection setDidFinishSelector:@selector(signingUpComplete:forConnection:)];
    
	[receiverHashTable setObject:theReceiver forKey:[newConnection requestID]];
	[newConnection sendRequest];
}

- (void)signingUpComplete:(NSString *)jsonResult forConnection:(BaseConnect *)theConnection 
{
    NSError *error;
    id receiver = [receiverHashTable objectForKey:[theConnection requestID]];
    
    [receiverHashTable removeObjectForKey:[theConnection requestID]];
	[theConnection release];
	
    if([self checkResultForErrors:jsonResult error:&error] == NO)
    {
        NSDictionary *responseObject = [jsonResult JSONValue];
        
        NSDictionary *payload = [responseObject objectForKey:JSON_REQUEST_PAYLOAD_KEY];
        
        P4RCUserInfo *userInfo = [self userInfoFromJSON:payload];
        
        [receiver signingUpCompleteWithSuccess:YES userInfo:userInfo error:nil];
    }
    else 
    {
        [receiver signingUpCompleteWithSuccess:NO userInfo:nil error:error];
    }
}

#pragma mark -
#pragma mark Signing In

- (void)signInWithUsername:(NSString *)username password:(NSString *)password forReceiver:(id<ReceiverProtocol>)theReceiver 
{
	NSDictionary *payload = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"REGULAR", username, password, nil] forKeys:[NSArray arrayWithObjects:@"authType", @"email", @"password",nil]];
	
	NSDictionary *payloadObject = [NSDictionary dictionaryWithObject:payload forKey:JSON_REQUEST_PAYLOAD_KEY];
	
	NSString *jsonBody = [payloadObject JSONRepresentation];
	BaseConnect *newConnection = [[BaseConnect alloc] initWithPostRequestBody:jsonBody delegate:self remoteMethodPath:SIGN_IN_PATH];
	[newConnection setDidFinishSelector:@selector(signingInComplete:forConnection:)];
    
	[receiverHashTable setObject:theReceiver forKey:[newConnection requestID]];
	[newConnection sendRequest];
}

- (void)signingInComplete:(NSString *)jsonResult forConnection:(BaseConnect *)theConnection 
{
    id receiver = [receiverHashTable objectForKey:[theConnection requestID]];
    NSError *error;
    [receiverHashTable removeObjectForKey:[theConnection requestID]];
	[theConnection release];
    
    if([self checkResultForErrors:jsonResult error:&error] == NO)
    {
        id responseObject = [jsonResult JSONValue];
        NSString *sessionToken = [[responseObject objectForKey:JSON_REQUEST_PAYLOAD_KEY] objectForKey:@"sessionToken"];
        NSDictionary *user = [[responseObject objectForKey:JSON_REQUEST_PAYLOAD_KEY] objectForKey:@"user"];
        NSInteger authoriseStatus = [[[responseObject objectForKey:JSON_REQUEST_PAYLOAD_KEY] objectForKey:@"authStatus"] intValue];
        
        P4RCUserInfo *userInfo = [self userInfoFromJSON:user];
        [userInfo setSecurityObject:sessionToken];
        [userInfo setAuthStatus:authoriseStatus];
        
        [receiver signingInCompleteWithSuccess:YES sessionToken:sessionToken authStatus:0 userInfo:userInfo error:nil];
    }
    else 
    {
        [receiver signingInCompleteWithSuccess:NO sessionToken:nil authStatus:0 userInfo:nil error:error];
    }
}

#pragma mark -
#pragma mark FBConnect login

- (void)signInUserWithFBAccessToken:(NSString*)token andExpirationDate:(NSDate *)expirationDate forReceiver:(id<ReceiverProtocol>)theReceiver
{
    long expDate = round([expirationDate timeIntervalSinceNow]);
	NSDictionary *payload = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"FACEBOOK", token, [NSNumber numberWithDouble:expDate], [[P4RC sharedInstance] gameRefId], @"sdk", [NSNumber numberWithBool:YES], nil] forKeys:[NSArray arrayWithObjects:@"authType", @"fbAccessToken", @"expiryTime", @"gameRefId", @"deviceType", @"userAcceptedTerms",nil]];
	
	NSDictionary *payloadObject = [NSDictionary dictionaryWithObject:payload forKey:JSON_REQUEST_PAYLOAD_KEY];
	
	NSString *jsonBody = [payloadObject JSONRepresentation];
	BaseConnect *newConnection = [[BaseConnect alloc] initWithPostRequestBody:jsonBody delegate:self remoteMethodPath: SIGN_IN_PATH];
	[newConnection setDidFinishSelector:@selector(signingInComplete:forConnection:)];
    
	[receiverHashTable setObject:theReceiver forKey:[newConnection requestID]];
	[newConnection sendRequest];
}

#pragma mark -
#pragma mark Checkin points

- (void)checkinPoints:(NSInteger)score
				level:(NSInteger)level
		minutesPlayed:(NSInteger)minutes
			startDate:(NSDate *)startDate
			  endDate:(NSDate *)endDate
			gameRefId:(NSString *)gameRefId
	   securityObject:(NSString *)theSecurityObject
		  forReceiver:(id<ReceiverProtocol>)theReceiver
{
	NSString *startDateString = [[self dateFormatter] stringFromDate:startDate];
	NSString *endDateString = [[self dateFormatter] stringFromDate:endDate];
	
	NSDictionary *payload = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects: 
																 [NSNumber numberWithInt:score], 
																 [NSNumber numberWithInt:level], 
																 [NSNumber numberWithInt:minutes],
																 startDateString,
																 endDateString,
																 gameRefId, nil]
                                                        forKeys:[NSArray arrayWithObjects:
																 @"gamePoints",
																 @"level",
																 @"minutesPlayed",
																 @"startTimeInGMT",
																 @"endTimeInGMT",
																 @"gameRefId", nil]];
    NSMutableDictionary *payloadObject = [[NSMutableDictionary alloc] initWithDictionary:[NSDictionary dictionaryWithObject:payload forKey:JSON_REQUEST_PAYLOAD_KEY]];

    if(theSecurityObject)
    {
        [payloadObject setObject:[NSDictionary dictionaryWithObject:theSecurityObject forKey:@"sessionId"] forKey:JSON_SECURITY_OBJECT_KEY];
    }
    NSString *jsonBody = [payloadObject JSONRepresentation];
    
    BaseConnect *newConnection = [[BaseConnect alloc] initWithPutRequestBody:jsonBody 
                                                                    delegate:self 
                                                            remoteMethodPath:CHECK_IN_POINTS_PATH];
	
	[newConnection setValue:[P4RCServerConfig apiKey] forHTTPHeaderField:API_KEY_FIELD];
	
	[newConnection setDidFinishSelector:@selector(checkInPointsComplete:forConnection:)];
    
	[receiverHashTable setObject:theReceiver forKey:[newConnection requestID]];
	[newConnection sendRequest];
    isBusy = YES;
    [payloadObject release];
}

- (void) checkInPointsComplete:(NSString *) jsonResult forConnection:(BaseConnect *) theConnection
{
    isBusy = NO;
    id receiver = [receiverHashTable objectForKey: [theConnection requestID]];
    
    [receiverHashTable removeObjectForKey: [theConnection requestID]];
	[theConnection release];
	NSError *error;
    
    if([self checkResultForErrors:jsonResult error:&error] == NO)
    {
        NSDictionary *jsonDictionary = [jsonResult JSONValue];
        NSDictionary *payload = [jsonDictionary objectForKey:JSON_REQUEST_PAYLOAD_KEY];
        NSInteger points = [[payload objectForKey:@"p4rcPoints"] intValue];
        [receiver checkInPointsComplete:points error:nil];
    }
    else 
    {
        [receiver checkInPointsComplete:0 error: error];
    } 
}

#pragma mark -
#pragma mark Checkin batch points

- (void)checkinInBatchGamePoints:(NSArray *)points
						  levels:(NSArray *)levels
				   minutesPlayed:(NSArray *)minutesPlayed
					  startDates:(NSArray *)startDates
						endDates:(NSArray *)endDates
					  transTimes:(NSArray *)transTimes
					   gameRefId:(NSString *)gameRefId
				  securityObject:(NSString *)theSecurityObject
					 forReceiver:(id<ReceiverProtocol>)theReceiver
{
	// game ref id
	NSMutableDictionary *payload = [NSMutableDictionary dictionaryWithObject:gameRefId forKey:@"gameRefId"];
	// cache
	NSMutableArray *cacheArray = [NSMutableArray new];
	NSInteger count = [points count];
	for (NSInteger i = 0; i < count; ++i)
	{
		[cacheArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:
							   [NSString stringWithFormat:@"%@", [points objectAtIndex:i]], @"gamePoints",
							   [NSString stringWithFormat:@"%@", [levels objectAtIndex:i]], @"level",
							   [NSString stringWithFormat:@"%@", [minutesPlayed objectAtIndex:i]], @"minutesPlayed",
							   [[self dateFormatter] stringFromDate:[NSDate dateWithTimeIntervalSince1970:(NSTimeInterval)[[startDates objectAtIndex:i] doubleValue]]], @"startTimeInGMT",
							   [[self dateFormatter] stringFromDate:[NSDate dateWithTimeIntervalSince1970:(NSTimeInterval)[[endDates objectAtIndex:i] doubleValue]]], @"endTimeInGMT",
                               [[self dateFormatter] stringFromDate:[NSDate dateWithTimeIntervalSince1970:(NSTimeInterval)[[transTimes objectAtIndex:i] doubleValue]]], @"transTime", nil]];
	}
	[payload addEntriesFromDictionary:[NSDictionary dictionaryWithObject:[NSArray arrayWithArray:[cacheArray autorelease]] forKey:@"cache"]];
	// payload
    NSMutableDictionary *payloadObject = [[NSMutableDictionary alloc] initWithDictionary:[NSDictionary dictionaryWithObjectsAndKeys:[NSDictionary dictionaryWithObject:theSecurityObject forKey:@"sessionId"], @"securityObject", payload, JSON_REQUEST_PAYLOAD_KEY, nil]];
    NSString *jsonBody = [payloadObject JSONRepresentation];
    BaseConnect *newConnection = [[BaseConnect alloc] initWithPutRequestBody:jsonBody 
																	delegate:self 
															remoteMethodPath:CHECK_IN_BATCH_POINTS_PATH];
	
	[newConnection setValue:[P4RCServerConfig apiKey] forHTTPHeaderField:API_KEY_FIELD];
	
	[newConnection setDidFinishSelector:@selector(checkInBatchPointsComplete:forConnection:)];
    
	[receiverHashTable setObject:theReceiver forKey:[newConnection requestID]];
	[newConnection sendRequest];
    [payloadObject release];
}

- (void)checkInBatchPointsComplete:(NSString *)jsonResult forConnection:(BaseConnect *)theConnection
{
	id receiver = [receiverHashTable objectForKey:[theConnection requestID]];
    
    [receiverHashTable removeObjectForKey:[theConnection requestID]];
	[theConnection release];
	NSError *error;
    
    if([self checkResultForErrors:jsonResult error:&error] == NO)
    {
        NSDictionary *jsonDictionary = [jsonResult JSONValue];
        NSDictionary *payload = [jsonDictionary objectForKey: JSON_REQUEST_PAYLOAD_KEY];
        NSInteger points = [[payload objectForKey:@"p4rcPoints"] intValue];
        [receiver checkInBatchPointsComplete:points error:nil];
    }
    else 
    {
        [receiver checkInBatchPointsComplete:0 error:error];
    }
}

#pragma mark -
#pragma mark get user info

- (void)getUserInfo:(NSString *)securityToken forReceiver:(id<ReceiverProtocol>)theReceiver
{
	NSDictionary *securityObjectDictionary = [NSDictionary dictionaryWithObject: [NSDictionary dictionaryWithObject:(securityToken ? securityToken : @"") forKey: @"sessionId"] forKey: JSON_SECURITY_OBJECT_KEY];
	NSString *jsonBody = [securityObjectDictionary JSONRepresentation];
    
	BaseConnect *newConnection = [[BaseConnect alloc] initWithPostRequestBody:jsonBody 
																	delegate:self 
															remoteMethodPath: GET_USER_INFO_PATH];
	[newConnection setDidFinishSelector:@selector(getUserInfoComplete:forConnection:)];
	
	[receiverHashTable setObject: theReceiver forKey: [newConnection requestID]];
	[newConnection sendRequest];
}

- (void)getUserInfoComplete:(NSString *)jsonResult forConnection:(BaseConnect *)theConnection
{
    id receiver = [receiverHashTable objectForKey:[theConnection requestID]];
    
    [receiverHashTable removeObjectForKey: [theConnection requestID]];
	[theConnection release];
    NSError *error;
    if([self checkResultForErrors:jsonResult error:&error] == NO)
    {
        NSDictionary *jsonDictionary = [jsonResult JSONValue];
        NSDictionary *payload = [jsonDictionary objectForKey:JSON_REQUEST_PAYLOAD_KEY];
    
        NSDictionary *userDictionary = [payload objectForKey: @"user"];
        P4RCUserInfo *userInfo = [self userInfoFromJSON:userDictionary];
    
        NSInteger newCouponsCount = [[payload objectForKey:@"newCouponCount"] intValue];
        NSInteger eligibleNewCouponsCount = [[payload objectForKey:@"eligibleNewCouponCount"] intValue];
        NSInteger leaderBoardRanking = [[payload objectForKey:@"leadershipBoardRanking"] intValue];
		
        [receiver getUserInfoCompleteWithUser:userInfo 
                              newCouponsCount:newCouponsCount
                      eligibleNewCouponsCount:eligibleNewCouponsCount
                           leaderBoardRanking:leaderBoardRanking
                                        error:nil];
    }
    else 
    {
        [receiver getUserInfoCompleteWithUser:nil 
                              newCouponsCount:0
                      eligibleNewCouponsCount:0
                           leaderBoardRanking:0
                                        error:error];
    } 
}

#pragma mark -
#pragma mark Coupon image

- (void)getCouponImageWithGameRefId:(NSString *)gameRefId forReceiver:(id<ReceiverProtocol>)theReceiver
{
	NSString *sessionId = [P4RCCacheManager sessionId];
	NSObject *securityObject;
	if (!sessionId || ([sessionId isEqualToString:@""] == YES))
	{
		sessionId = @"0";
	}
	securityObject = [NSDictionary dictionaryWithObject:sessionId forKey:@"sessionId"];
	NSDictionary *requestBody = [NSDictionary dictionaryWithObjectsAndKeys:
								 [NSDictionary dictionaryWithObjectsAndKeys:gameRefId, @"gameRefId", [P4RCUtils deviceTypeString], @"agent", nil], JSON_REQUEST_PAYLOAD_KEY,
								 securityObject, JSON_SECURITY_OBJECT_KEY, nil];
	NSString *jsonBody = [requestBody JSONRepresentation];
	BaseConnect *newConnection = [[BaseConnect alloc] initWithPutRequestBody:jsonBody delegate:self remoteMethodPath:PUT_COUPON_IMAGE_PATH];
	[newConnection setDidFinishSelector:@selector(getCouponImageComplete:forConnection:)];
	[receiverHashTable setObject:theReceiver forKey:[newConnection requestID]];
	[newConnection sendRequest];
}

- (void)getCouponImageComplete:(NSString*)jsonResult forConnection:(BaseConnect *)connection
{
	id receiver = [receiverHashTable objectForKey:[connection requestID]];
	[receiverHashTable removeObjectForKey:[connection requestID]];
    [connection release];
    
	NSError *error;
    
	if ([self checkResultForErrors:jsonResult error:&error] == NO)
    {
		NSDictionary *responceObject = [jsonResult JSONValue];
        NSDictionary *payload = [responceObject objectForKey:JSON_REQUEST_PAYLOAD_KEY];
		[receiver getCouponImageCompleteWithUrl:[payload objectForKey:@"imageUrl"]
									description:[payload objectForKey:@"shortDescription"]
										  error:nil];
	}
	else
	{
		[receiver getCouponImageCompleteWithUrl:nil
									description:nil
										  error:error];
	}
}

#pragma mark -
#pragma mark Forgot password

- (void)forgotPasswordWithEmail:(NSString *)email forReceiver:(id<ReceiverProtocol>)theReceiver
{
	NSDictionary *requestBody = [NSDictionary dictionaryWithObject:[NSDictionary dictionaryWithObject:email forKey:@"email"] forKey:JSON_REQUEST_PAYLOAD_KEY];
	NSString *jsonBody = [requestBody JSONRepresentation];
	BaseConnect *newConnection = [[BaseConnect alloc] initWithPostRequestBody:jsonBody delegate:self remoteMethodPath:FORGOT_PASSWORD_PATH];
	[newConnection setDidFinishSelector:@selector(forgotPasswordComplete:forConnection:)];
	[receiverHashTable setObject:theReceiver forKey:[newConnection requestID]];
	[newConnection sendRequest];
}

- (void)forgotPasswordComplete:(NSString *)jsonResult forConnection:(BaseConnect *)theConnection {
    id receiver = [receiverHashTable objectForKey: [theConnection requestID]];
    
    [receiverHashTable removeObjectForKey: [theConnection requestID]];
	[theConnection release];
	NSError *error;
    
    if([self checkResultForErrors:jsonResult error:&error] == NO)
    {
        [receiver forgotPasswordCompleteWithError:nil];
    }
    else 
    {
        [receiver forgotPasswordCompleteWithError:error];
    }
}

#pragma mark -
#pragma mark convert points

- (void) convertPointsToP4RCPoints:(NSInteger)gamePoints 
                             level:(NSInteger)level 
                     minutesPlayed:(NSInteger)minutes 
						 gameRefId:(NSString *)gameRefId 
                          loggedIn:(BOOL)logged 
                    securityObject:(NSString *)theSecurityObject
                       forReceiver:(id<ReceiverProtocol>)theReceiver 
{
    NSDictionary *payload = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSString stringWithFormat:@"%d", gamePoints], [NSString stringWithFormat:@"%d", level], [NSString stringWithFormat:@"%d", minutes], gameRefId, nil] forKeys:[NSArray arrayWithObjects:@"gamePoints", @"level", @"minutesPlayed", @"gameRefId",nil]];
    NSMutableDictionary *payloadObject = [[NSMutableDictionary alloc] initWithDictionary:[NSDictionary dictionaryWithObject:payload forKey:JSON_REQUEST_PAYLOAD_KEY]];
    if (logged && theSecurityObject)
    {
        [payloadObject setObject:[NSDictionary dictionaryWithObject:theSecurityObject forKey:@"sessionId"] forKey:JSON_SECURITY_OBJECT_KEY];
    }
    NSString *jsonBody = [payloadObject JSONRepresentation];
	
    BaseConnect *newConnection = [[BaseConnect alloc] initWithPutRequestBody:jsonBody delegate:self 
                                                             remoteMethodPath:CONVERT_POINTS];
	
	
	[newConnection setDidFinishSelector:@selector(convertPointsToP4RCPointsComplete:forConnection:)];
    
	[receiverHashTable setObject: theReceiver forKey: [newConnection requestID]];
	[newConnection sendRequest];
    [payloadObject release];
}

- (void)convertPointsToP4RCPointsComplete:(NSString *)jsonResult forConnection:(BaseConnect *)theConnection 
{
    id receiver = [receiverHashTable objectForKey: [theConnection requestID]];

    [receiverHashTable removeObjectForKey: [theConnection requestID]];
	[theConnection release];
	NSError *error;
    
    if([self checkResultForErrors:jsonResult error:&error] == NO)
    {
        NSDictionary *jsonDictionary = [jsonResult JSONValue];
        NSDictionary *payload = [jsonDictionary objectForKey:JSON_REQUEST_PAYLOAD_KEY];
        NSInteger points = [[payload objectForKey: @"p4rcPoints"] intValue];
        
        [receiver convertGamePointsCompleteWithP4RCPoints: points error: nil];
    }
    else
    {
        [receiver convertGamePointsCompleteWithP4RCPoints: 0 error: error];
    }
}

#pragma mark - Max points

- (void)getMaxPointsForGameRefId:(NSString *)gameRefId
                     forReceiver:(id<ReceiverProtocol>)theReceiver
{
    NSDictionary *payload = [NSDictionary dictionaryWithObject:gameRefId
                                                        forKey:GAME_REF_ID_KEY];
    NSMutableDictionary *payloadObject = [[NSMutableDictionary alloc] initWithDictionary:[NSDictionary dictionaryWithObject:payload forKey:JSON_REQUEST_PAYLOAD_KEY]];
    
    NSString *jsonBody = [payloadObject JSONRepresentation];
    
    BaseConnect *newConnection = [[BaseConnect alloc] initWithPostRequestBody:jsonBody
                                                                     delegate:self
                                                             remoteMethodPath:GET_MAX_POINTS_PATH];

    [newConnection setValue:[P4RCServerConfig apiKey] forHTTPHeaderField:API_KEY_FIELD];
    
    [newConnection setDidFinishSelector:@selector(getMaxPointsComplete:forConnection:)];
    
    [receiverHashTable setObject:theReceiver forKey:[newConnection requestID]];
    [newConnection sendRequest];
    [payloadObject release];
}

- (void)getMaxPointsComplete:(NSString *)jsonResult
               forConnection:(BaseConnect *)theConnection
{
    id receiver = [receiverHashTable objectForKey:[theConnection requestID]];
    
    [receiverHashTable removeObjectForKey:[theConnection requestID]];
    [theConnection release];
    
    NSError *error;
    
    if ([self checkResultForErrors:jsonResult error:&error] == NO) {
        NSDictionary *jsonDictionary = [jsonResult JSONValue];
        NSDictionary *payload = [jsonDictionary objectForKey:JSON_REQUEST_PAYLOAD_KEY];
        NSInteger points = [[payload objectForKey:@"p4rcPoints"] intValue];
        [receiver maxPointsReceived:points];
    } else {
        [receiver maxPointsReceivingFailedWithError:error];
    }
}

#pragma mark - Ping

- (void)logEventForGameRefId:(NSString *)gameRefId
	   securityObject:(NSString *)theSecurityObject
		  forReceiver:(id<ReceiverProtocol>)theReceiver
{
	NSDictionary *payload = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects: 
																 gameRefId, [MacAddressHelper getMacAddress], nil]
                                                        forKeys:[NSArray arrayWithObjects:
																 @"gameRefId", @"instanceId", nil]];
    NSMutableDictionary *payloadObject = [[NSMutableDictionary alloc] initWithDictionary:[NSDictionary dictionaryWithObject:payload forKey:JSON_REQUEST_PAYLOAD_KEY]];
    
    if(theSecurityObject)
    {
        [payloadObject setObject:[NSDictionary dictionaryWithObject:theSecurityObject forKey:@"sessionId"] forKey:JSON_SECURITY_OBJECT_KEY];
    }
    NSString *jsonBody = [payloadObject JSONRepresentation];
    
    BaseConnect *newConnection = [[BaseConnect alloc] initWithPostRequestBody:jsonBody 
                                                                    delegate:self 
                                                            remoteMethodPath:LOG_EVENT_PATH];
	
	[newConnection setValue:[P4RCServerConfig apiKey] forHTTPHeaderField:API_KEY_FIELD];
	
    [newConnection setDidFinishSelector:@selector(logEventComplete:forConnection:)];
    
	[receiverHashTable setObject:theReceiver forKey:[newConnection requestID]];
	[newConnection sendRequest];
    [payloadObject release];
}

- (void)logEventComplete:(NSString *)jsonResult forConnection:(BaseConnect *)theConnection
{
    id receiver = [receiverHashTable objectForKey: [theConnection requestID]];
    
    [receiverHashTable removeObjectForKey:[theConnection requestID]];
	[theConnection release];
	NSError *error;
    
    if([self checkResultForErrors:jsonResult error:&error] == NO)
    {
        [receiver eventLogged];
    } else {
        [receiver eventLoggingFailWithError:error];
    }
}



#pragma mark -
#pragma mark Error handling

- (void)serverDidFailWithDescription:(NSString*)description forConnection:(BaseConnect*)theConnection 
{
	[theConnection release];
}

#pragma mark -
#pragma mark server error handling

- (BOOL)checkResultForErrors:(NSString *)jsonResult error:(NSError **)error
{
    if ([jsonResult length] == 0)
	{
        if (error)
        {
            *error = [NSError errorWithDomain:@"" code:408 userInfo:nil];       // timeout
        }
		return YES;
	}
	
    NSDictionary *responseObject = [jsonResult JSONValue];
	NSDictionary *payloadDictionary = [responseObject objectForKey:JSON_REQUEST_PAYLOAD_KEY];
	
	NSString *status = [responseObject objectForKey:JSON_RESPONCE_STATUS_KEY];
	
	if ((status == nil) || ([status isEqualToString:@""]))
	{
		status = [payloadDictionary objectForKey:JSON_RESPONCE_STATUS_KEY];
	}
	
    if (!status || ![status isEqualToString:JSON_RESPONCE_STATUS_SUCCESS])
    {
        if (error)
        {
            NSString *errorMessage = [payloadDictionary objectForKey:JSON_ERROR_MESSAGE_KEY];
            if (errorMessage)
            {
                NSNumber *codeNumber = [payloadDictionary objectForKey:JSON_ERROR_CODE_KEY];
                if (codeNumber != nil)
                {
                    *error = [NSError errorWithDomain:@"server domain" code:[codeNumber intValue] userInfo:[NSDictionary dictionaryWithObject:errorMessage forKey:NSLocalizedDescriptionKey]];
                }
            }
            else
            {
                *error = [NSError errorWithDomain:@"" code:408 userInfo:nil];       // timeout
            }
        }
        return YES;
    }
    
    return NO;
}

#pragma mark - 
#pragma mark Getting Points table

- (void)getPointsTableForGameRefId:(NSString *)gameRefId
                 forReceiver:(id<ReceiverProtocol>)theReceiver
{
    NSDictionary *payload = [NSDictionary dictionaryWithObject:gameRefId forKey:@"gameRefId"];
    NSMutableDictionary *payloadObject = [[NSMutableDictionary alloc] initWithDictionary:[NSDictionary dictionaryWithObject:payload forKey:JSON_REQUEST_PAYLOAD_KEY]];
    
    NSString *jsonBody = [payloadObject JSONRepresentation];
    
    BaseConnect *newConnection = [[BaseConnect alloc] initWithPostRequestBody:jsonBody
                                                                     delegate:self
                                                             remoteMethodPath:GET_POINTS_TABLE_PATH];
	
	[newConnection setValue:[P4RCServerConfig apiKey] forHTTPHeaderField:API_KEY_FIELD];
	
	[newConnection setDidFinishSelector:@selector(tableReceivingComplete:forConnection:)];
    
	[receiverHashTable setObject:theReceiver forKey:[newConnection requestID]];
	[newConnection sendRequest];
    [payloadObject release];
}

- (void)tableReceivingComplete:(NSString *)jsonResult forConnection:(BaseConnect *)theConnection
{
    id receiver = [receiverHashTable objectForKey: [theConnection requestID]];
    
    [receiverHashTable removeObjectForKey:[theConnection requestID]];
	[theConnection release];
	NSError *error;
    
    if([self checkResultForErrors:jsonResult error:&error] == NO)
    {
        NSDictionary *jsonDictionary = [jsonResult JSONValue];
        NSArray *payload = [jsonDictionary objectForKey:JSON_REQUEST_PAYLOAD_KEY];
        [receiver tableReceived:payload];
    }
}

#pragma mark -
#pragma mark utilities

- (BOOL)checkField:(NSString *)field inObject:(NSDictionary *)object
{
    id value = [object objectForKey:field];
    if(!value || [value isKindOfClass:[NSNull class]])
    {
        return NO;
    }
    return YES;
}

- (P4RCUserInfo *)userInfoFromJSON:(NSDictionary *)json
{
    P4RCUserInfo *userInfo = [[[P4RCUserInfo alloc] init] autorelease];
    
    @try 
    {
        [userInfo setEmail:[json objectForKey:@"email"]];
        [userInfo setUserID:[[json objectForKey:@"id"] intValue]]; 
        [userInfo setUserSource:[[json objectForKey:@"userSource"] intValue]];
        [userInfo setUserType:[[json objectForKey:@"userType"] intValue]];
        [userInfo setFirstName:[json objectForKey:@"firstName"]];
        [userInfo setLastName:[json objectForKey:@"lastName"]];
        [userInfo setUserAcceptedTerms:[[json objectForKey:@"userAcceptedTerms"] boolValue]];
        [userInfo setProfileCompletitionPercent:[[json objectForKey:@"profileCompletitionPercent"] intValue]];
        [userInfo setUserAvatarURL:[json objectForKey:@"userAvatarURL"]];
        [userInfo setTotalP4RCPoints:[[json objectForKey:@"totalPoints"] intValue]];
        [userInfo setFbPublishAllowed:[[json objectForKey:@"fbPublishAllowed"] boolValue]];
    }
    @catch (NSException *e)
    {
        userInfo = nil;
    }
    
    return userInfo;
}

#pragma mark - Private

- (NSDateFormatter *)dateFormatter
{
	if (dateFormatter == nil)
	{
		dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setLocale:[[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"] autorelease]];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
		[dateFormatter setDateFormat:@"MM/dd/yyyy HH:mm:ss.SSS"];
	}
	return dateFormatter;
}

@end
