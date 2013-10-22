//
//  ServerGateway.h
//  ShowMe
//
//  Created by Kostiantyn Zamiesov on 4/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BaseConnect.h"
#import "P4RCUserInfo.h"
#import <SystemConfiguration/SystemConfiguration.h>


@protocol ReceiverProtocol

@optional

- (void)signingUpCompleteWithSuccess:(BOOL)success userInfo:(P4RCUserInfo *)userInfo error:(NSError *)error;

- (void)signingInCompleteWithSuccess:(BOOL)success sessionToken:(NSString *)token authStatus:(NSInteger)status userInfo:(P4RCUserInfo *)userInfo error:(NSError *)error;

- (void)convertGamePointsCompleteWithP4RCPoints:(NSInteger)points error:(NSError *)error;
- (void)checkInPointsComplete:(NSInteger)points error:(NSError *)error;
- (void)checkInBatchPointsComplete:(NSInteger)points error:(NSError *)error;

- (void)getUserInfoCompleteWithUser:(P4RCUserInfo *)user newCouponsCount:(NSInteger)newCouponsCount eligibleNewCouponsCount:(NSInteger)eligibleNewCouponsCount leaderBoardRanking:(NSInteger)leaderBoardRanking error:(NSError *)error;

- (void)getCouponImageCompleteWithUrl:(NSString *)imageUrl description:(NSString *)description error:(NSError *)error;
- (void)forgotPasswordCompleteWithError:(NSError *)error;

- (void)tableReceived:(NSArray*)table;

- (void)eventLogged;
- (void)eventLoggingFailWithError:(NSError*)error;

- (void)maxPointsReceived:(NSInteger)points;
- (void)maxPointsReceivingFailedWithError:(NSError *)error;

@end


@interface ServerGateway : NSObject
{
	@private
	NSMutableDictionary *receiverHashTable;
	NSDateFormatter *dateFormatter;
}

@property (nonatomic, assign, readonly) BOOL isBusy;

+ (ServerGateway *)sharedInstance;

- (void)signUpUserWithFirstName:(NSString *)firstName
                       lastName:(NSString *)lastName
                       password:(NSString *)password
                          email:(NSString *)email
              userAcceptedTerms:(BOOL)accepted
                    forReceiver:(id<ReceiverProtocol>)theReceiver;

- (void)signInUserWithFBAccessToken:(NSString*)token
                  andExpirationDate:(NSDate *)expirationDate
                        forReceiver:(id<ReceiverProtocol>)theReceiver;

- (void)signInWithUsername:(NSString *)username
                  password:(NSString *)password
               forReceiver:(id<ReceiverProtocol>)theReceiver;

- (void)convertPointsToP4RCPoints:(NSInteger)gamePoints
                            level:(NSInteger)level
                    minutesPlayed:(NSInteger)minutes
                        gameRefId:(NSString *)gameRefId
                         loggedIn:(BOOL)logged
                   securityObject:(NSString *)theSecurityObject
                      forReceiver:(id<ReceiverProtocol>)theReceiver;

- (void)checkinPoints:(NSInteger)score
                level:(NSInteger)level
        minutesPlayed:(NSInteger)minutes
            startDate:(NSDate *)startDate
              endDate:(NSDate *)endDate
            gameRefId:(NSString *)gameRefId
       securityObject:(NSString *)theSecurityObject
          forReceiver:(id<ReceiverProtocol>)theReceiver;

- (void)checkinInBatchGamePoints:(NSArray *)points
                          levels:(NSArray *)levels
                   minutesPlayed:(NSArray *)minutesPlayed
                      startDates:(NSArray *)startDates
                        endDates:(NSArray *)endDates
                      transTimes:(NSArray *)transTimes
                       gameRefId:(NSString *)gameRefId
                  securityObject:(NSString *)theSecurityObject
                     forReceiver:(id<ReceiverProtocol>)theReceiver;

- (void)getUserInfo:(NSString *)securityToken
        forReceiver:(id<ReceiverProtocol>)theReceiver;

- (void)getCouponImageWithGameRefId:(NSString *)gameRefId
                        forReceiver:(id<ReceiverProtocol>)theReceiver;

- (void)logEventForGameRefId:(NSString *)gameRefId
              securityObject:(NSString *)theSecurityObject
                 forReceiver:(id<ReceiverProtocol>)theReceiver;

- (void)forgotPasswordWithEmail:(NSString *)email forReceiver:(id<ReceiverProtocol>)theReceiver;

- (void)getPointsTableForGameRefId:(NSString *)gameRefId
                       forReceiver:(id<ReceiverProtocol>)theReceiver;

- (void)getMaxPointsForGameRefId:(NSString *)gameRefId
                     forReceiver:(id<ReceiverProtocol>)theReceiver;


@end
