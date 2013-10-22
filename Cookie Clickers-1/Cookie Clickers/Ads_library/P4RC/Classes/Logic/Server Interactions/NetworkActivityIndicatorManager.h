//
//  NetworkActivityIndicatorManager.h
//
//  Created by kost on 9/6/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

//! Singleton class for managing network activity indicator
@interface NetworkActivityIndicatorManager : NSObject {
	NSInteger counter;
}

+ (NetworkActivityIndicatorManager*)sharedInstance;

//! Retain (start) activity indicator
- (void)activate;

//! Release (stop) activity indicator
- (void)deactivate;

@end
