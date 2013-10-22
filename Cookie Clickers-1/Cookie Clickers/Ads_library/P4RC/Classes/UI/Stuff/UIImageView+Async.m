//
//  UIImageView+Async.m
//  DownTown
//
//  Created by admin on 2/21/11.
//  Copyright 2011 org. All rights reserved.
//

#import "UIImageView+Async.h"


@implementation UIImageView (async)

- (void)loadImageWithURL:(id)object {
    NSData* imageData = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:(NSString *)object]];
    UIImage* image = [[UIImage alloc] initWithData:imageData];
    [imageData release];
    [self performSelectorOnMainThread:@selector(setImage:)
                           withObject:[image autorelease]
                        waitUntilDone:NO];
}

- (void)setImageAsyncByURL:(NSString *)urlString {
    [self setImage:nil];
	if ([urlString isMemberOfClass:[NSNull class]]) {
		return;
	}
	
	NSOperationQueue *queue = [[NSOperationQueue new] autorelease];
    NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self
																			selector:@selector(loadImageWithURL:)
																			  object:urlString];
    [queue addOperation:operation];
    [operation release];
}

@end
