//
//  NetworkActivityIndicatorManager.m
//
//  Created by kost on 9/6/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NetworkActivityIndicatorManager.h"
#import <UIKit/UIKit.h>


@interface NetworkActivityIndicatorManager()

@property(nonatomic,assign) NSInteger counter;

@end

@implementation NetworkActivityIndicatorManager

static NetworkActivityIndicatorManager *sharedInstance = nil;

@synthesize counter;

#pragma mark -
#pragma mark Initialization/dealloc

- (void) dealloc {	
	[super dealloc];
}

- (id)init {
	self = [super init];
	if (self) {
		counter = 0;
	}
	
	return self;
}

#pragma mark -
#pragma mark Implementation

- (void)activate {
	//LOG(@"NetworkActivityIndicatorManager - activate. counter = %i", counter);
	if ( counter == 0 ) {
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	}
	++counter;
}

- (void)deactivate {
	if(counter != 0) {
		//LOG(@"NetworkActivityIndicatorManager - deactivate. counter = %i", counter);
		--counter;
		if ( counter == 0 ) {
			[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
		}		
	}
	else {
		//LOG(@"NetworkActivityIndicatorManager - deactivate. Error. Counter is zero.");
	}
}

#pragma mark -
#pragma mark Singleton object methods

// See "Creating a Singleton Instance" in the Cocoa Fundamentals Guide for more info

+ (NetworkActivityIndicatorManager *)sharedInstance {
	//LOG(@"NetworkActivityIndicatorManager - sharedInstance");
    @synchronized(self) {
        if (sharedInstance == nil) {
            [[self alloc] init]; // assignment not done here
        }
    }
    return sharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if (sharedInstance == nil) {
            sharedInstance = [super allocWithZone:zone];
            return sharedInstance;  // assignment and return on first allocation
        }
    }
    return nil; // on subsequent allocation attempts return nil
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

- (id)retain {
    return self;
}

- (unsigned)retainCount {
    return UINT_MAX;  // denotes an object that cannot be released
}

- (oneway void)release {
    //do nothing
}

- (id)autorelease {
    return self;
}

@end
