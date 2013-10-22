//
//  IdeasCell.h
//  MercedesBenz
//
//  Created by kost on 9/6/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ExtendedURLConnection.h"
//#import "NSObject-Utilities.h"
#import "NetworkActivityIndicatorManager.h"

#define HTTPS_SCHEME @"https"

//! Private interface
@interface ExtendedURLConnection()

@property(nonatomic, retain) NSURLConnection *connection;
@property(nonatomic, retain) NSHTTPURLResponse* response;
@property(nonatomic, retain) NSMutableData* responseData;
@property(nonatomic, retain) NSError* error;
@property(nonatomic, retain) NSFileHandle *downloadFileHandle;

@end

@implementation ExtendedURLConnection

@synthesize delegate;
@synthesize didFailSelector;
@synthesize didReceiveResponseSelector;
@synthesize didFinishSelector;
@synthesize connection;
@synthesize response;
@synthesize responseData;
@synthesize error;
@synthesize downloadDestinationPath;
@synthesize downloadFileHandle;

- (void)dealloc {
	[connection release];
	
	[response release];
	[responseData release];
	
	[error release];
    	
	[downloadDestinationPath release];
	
	[downloadFileHandle closeFile];
	[downloadFileHandle release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Initialization

- (id)initWithRequest:(NSMutableURLRequest*)theRequest delegate:(id)theDelegate downloadDestinationPath:(NSString*)theDownloadDestinationPath {
	if((self = [super init]) != nil) {
		[self setDelegate:theDelegate];
		
		[self setDownloadDestinationPath:theDownloadDestinationPath];
		[self setDownloadFileHandle:nil];
		
		[self setDidFailSelector:NULL];
		[self setDidReceiveResponseSelector:NULL];
		[self setDidFinishSelector:NULL];
		
		[self setResponse:nil];
		[self setResponseData:nil];
		[self setError:nil];
		
		// tell server that gzipped data is ok
		[theRequest setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"]; // TODO: add acceptGZIP property flag?
		        
		// create connection
		NSURLConnection *newConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self startImmediately:NO];
		[self setConnection:newConnection];
		[newConnection release];
	}
	
	return self;
}

- (id)initWithRequest:(NSMutableURLRequest*)theRequest delegate:(id)theDelegate {
	return [self initWithRequest:theRequest delegate:theDelegate downloadDestinationPath:nil];
}

#pragma mark -
#pragma mark Properties

- (NSHTTPURLResponse*)response {
	return response;
}

- (NSMutableData*)responseData {
	return responseData;
}

- (NSError*)error {
	return error;
}

- (void)setDelegate:(id)theDelegate {	
	delegate = theDelegate;
}

- (void)setDidFailSelector:(SEL)theSelector {
	
	didFailSelector = theSelector;
}

- (void)setDidReceiveResponseSelector:(SEL)theSelector {
	
	didReceiveResponseSelector = theSelector;
}

- (void)setDidFinishSelector:(SEL)theSelector {
	
	didFinishSelector = theSelector;
}

#pragma mark -
#pragma mark Start/Cancel

- (void)start {
	// flush downloaded data
	[self setResponse:nil];
	[self setResponseData:nil];
	
	// close file
	[downloadFileHandle closeFile];
	
	// remove file if it exists
	if ([[NSFileManager defaultManager] fileExistsAtPath:downloadDestinationPath]) {
		[[NSFileManager defaultManager] removeItemAtPath:downloadDestinationPath error:nil];
	}
	
	[self setDownloadDestinationPath:nil];
    
	// start activity indicator
	[[NetworkActivityIndicatorManager sharedInstance] activate];
	
	// start performing request
	[connection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	[connection start];

}

- (void)cancel {
	
	// stop activity indicator
	[[NetworkActivityIndicatorManager sharedInstance] deactivate];
	// cancel NSURL connection
	[connection cancel];
}

#pragma mark -
#pragma mark NSURLConnection delegate methods

- (void)connection:(NSURLConnection*)theConnection didReceiveResponse:(NSHTTPURLResponse*)theResponse {
	
	// save response
	[self setResponse:theResponse];
	
	// init the download
	if(downloadDestinationPath==nil) {
		[self setResponseData:[NSMutableData data]];
	}
	else {
		
		// TODO: check errors
		//error = [theConnection error];
		// remove file if it exists
		if ([[NSFileManager defaultManager] fileExistsAtPath:downloadDestinationPath]) {
			[[NSFileManager defaultManager] removeItemAtPath:downloadDestinationPath error:nil];
		}
		
		// create file for downloading
		[[NSFileManager defaultManager] createFileAtPath:downloadDestinationPath contents:nil attributes:nil];
		
		// open file for downloading
		[self setDownloadFileHandle:[NSFileHandle fileHandleForWritingAtPath:downloadDestinationPath]];
	}

	// notify the delegate
	[delegate performSelector:didReceiveResponseSelector withObject:self];
}

- (void)connection:(NSURLConnection*)theConnection didReceiveData:(NSData*)theData {
	
//	MLOG(@"data = '%@'", [[[NSString alloc] initWithData:theData encoding:NSISOLatin1StringEncoding] autorelease]);

	if(downloadDestinationPath==nil) {
		[responseData appendData:theData];
	}
	else {
		// append to file
		[downloadFileHandle writeData:theData];
	}
}

- (void)connectionDidFinishLoading:(NSURLConnection*)theConnection {
	// finish working with download file
	[downloadFileHandle closeFile];
	 
	// stop activity indicator
	[[NetworkActivityIndicatorManager sharedInstance] deactivate];	
	
	// notify the delegate
    [delegate performSelector:didFinishSelector withObject:self];
	//[delegate tryPerformSelector:didFinishSelector withObject:self];
}

- (void)connection:(NSURLConnection*)theConnection didFailWithError:(NSError*)theError {  
	
	// cancel loading
	[self cancel];
	
	// notify the delegate
	[self setError:theError];
    [delegate performSelector:didFailSelector withObject:self];

	//[delegate tryPerformSelector:didFailSelector withObject:self];
}

#pragma mark -
#pragma mark Caching

- (NSCachedURLResponse*)connection:(NSURLConnection*)theConnection willCacheResponse:(NSCachedURLResponse*)theCachedResponse {
	
	return nil; // no caching
}

#pragma mark -
#pragma mark Converting |responseData| into |NSString|

- (NSString*)responseString {
	// decode response
	NSString *encodingName = [response textEncodingName];
	
	NSStringEncoding encoding = NSISOLatin1StringEncoding;// default encoding
	
	// if there's an encoding specified in response headers
	if(encodingName!=nil) {
		// get encoding from its name
		encoding = CFStringConvertEncodingToNSStringEncoding(CFStringConvertIANACharSetNameToEncoding((CFStringRef) encodingName));
		
		if(encoding==kCFStringEncodingInvalidId) { // couldn't get encoding						
			return nil;
		}
	}
	
	// get response string using encoding
	NSString *responseString = [[NSString alloc] initWithData:responseData encoding:encoding];
	
	return [responseString autorelease];
}

@end