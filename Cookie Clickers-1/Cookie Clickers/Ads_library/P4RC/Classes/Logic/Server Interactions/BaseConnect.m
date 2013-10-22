//
//  BaseConnect.m
//  MercedesBenz
//
//  Created by kost on 2/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BaseConnect.h"
#import "ExtendedURLConnection.h"
#import "P4RCUtils.h"
#import "P4RCServerConfig.h"
#import "server.h"


@interface BaseConnect ()

- (void)notifyDelegateWithConnection:(ExtendedURLConnection *)theConnection;
- (void)connectionDidMiss:(ExtendedURLConnection *)theConnection;

@end


@implementation BaseConnect (Utils)

- (NSMutableURLRequest*)createPostRequestWithString:(NSString *)theBodyString path:(NSString*)thePath 
{
	NSMutableURLRequest *postRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [P4RCServerConfig serverAddress], thePath]]];
    [postRequest setHTTPMethod:@"POST"];
    [postRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
	[postRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [postRequest setHTTPBody:[theBodyString dataUsingEncoding:NSUTF8StringEncoding]];    

    return postRequest;
}

- (NSMutableURLRequest*)createGetRequestWithString:(NSString *)theBodyString path:(NSString*)thePath 
{
	NSMutableURLRequest *getRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [P4RCServerConfig serverAddress], thePath]]];
	
    [getRequest setHTTPMethod:@"GET"];
  	
    return getRequest;
}

- (NSMutableURLRequest*)createPutRequestWithString:(NSString *)theBodyString path:(NSString*)thePath 
{
    NSMutableURLRequest *getRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [P4RCServerConfig serverAddress], thePath]]];
	[getRequest setHTTPMethod:@"PUT"];
	[getRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
	[getRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [getRequest setHTTPBody:[theBodyString dataUsingEncoding:NSUTF8StringEncoding]];    

    return getRequest;
}

@end

@implementation BaseConnect

@synthesize bodyRequestString,
			request,
			didFinishSelector,
			delegate;

- (void)dealloc 
{
	[connection cancel];
	[connection release];
	
	[bodyRequestString release];
	
	[request release];
	
    [super dealloc];
}

- (id)initWithPostRequestBody:(NSString*)theRequestBody delegate:(id)theDelegate remoteMethodPath:(NSString*)theMethodPath 
{
	//NSLog(@"POST request: %@", theRequestBody);
	if ((self = [super init])) 
    {
		connection = nil;
		[self setRequest:[self createPostRequestWithString:theRequestBody path:theMethodPath]];
        NSLog(@"Request: %@", [request description]);
		[self setDelegate:theDelegate];
	}
	return self;
}

- (id)initWithPutRequestBody:(NSString*)theRequestBody delegate:(id)theDelegate remoteMethodPath:(NSString*)theMethodPath 
{
	//NSLog(@"PUT request: %@", theRequestBody);
	if ((self = [super init])) 
    {
		connection = nil;
		[self setRequest:[self createPutRequestWithString:theRequestBody path:theMethodPath]];
		[self setDelegate:theDelegate];
	}
	return self;
}

- (id) initWithGetRequestPath:(NSString *) theMethodPath delegate:(id)theDelegate
{
	//NSLog(@"GET request: %@", theMethodPath);
    if(self = [super init])
    {
        connection = nil;
        [self setRequest:[self createGetRequestWithString:[P4RCServerConfig serverAddress] path:theMethodPath]];
        [self setDelegate: theDelegate];
    }
    return self;
}

- (NSString*)requestID 
{
	return [NSString stringWithFormat:@"%d", (id)request];
}

- (void)setValue:(NSString *)theValue forHTTPHeaderField:(NSString *)theField
{
	[request setValue:theValue forHTTPHeaderField:theField];
}

- (void)sendRequest 
{
	if (connection)
	{
		[connection release];
	}
	connection = [[ExtendedURLConnection alloc] initWithRequest:request delegate:self];
	[connection setDidReceiveResponseSelector:@selector(connectionDidReceiveResponse:)];
	[connection setDidFinishSelector:@selector(connectionDidFinish:)];
	[connection setDidFailSelector:@selector(connectionDidFail:)];
	
    [self performSelector:@selector(connectionDidMiss:) withObject:connection afterDelay:REQUEST_TIMEOUT];
    [connection start];
}

#pragma mark -
#pragma mark Private

- (void)connectionDidMiss:(ExtendedURLConnection *)theConnection
{
    [theConnection cancel];
    [self notifyDelegateWithConnection:theConnection];
}

- (void)notifyDelegateWithConnection:(ExtendedURLConnection *)theConnection {
    if ([delegate respondsToSelector:didFinishSelector]) 
    {
		[delegate performSelector:didFinishSelector withObject:[theConnection responseString] withObject:self];
	}
}

#pragma mark -
#pragma mark MBURLConnection delegate

- (void)connectionDidReceiveResponse:(ExtendedURLConnection*)theConnection 
{
	[BaseConnect cancelPreviousPerformRequestsWithTarget:self selector:@selector(connectionDidFail:) object:connection];
}

- (void)connectionDidFinish:(ExtendedURLConnection*)theConnection 
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(connectionDidMiss:) object:theConnection];
    [theConnection cancel];
	[self notifyDelegateWithConnection:theConnection];
}

- (void)connectionDidFail:(ExtendedURLConnection*)theConnection 
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(connectionDidMiss:) object:theConnection];
    [theConnection cancel];
	[self notifyDelegateWithConnection:theConnection];
}

@end
