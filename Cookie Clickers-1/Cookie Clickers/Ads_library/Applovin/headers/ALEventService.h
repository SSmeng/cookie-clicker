//
//  ALEventService.h
//  sdk
//
//  Created by Matt Szaro on 5/21/13.
//
//

#import <Foundation/Foundation.h>

@interface ALEventService : NSObject

-(void) trackSessionStart;
-(void) trackSessionPause;
-(void) trackSessionEnd;

-(void) trackRevenue: (NSNumber*) revenue currencyCode: (NSString*) isoCurrencyCode name: (NSString*) name;

@end
    