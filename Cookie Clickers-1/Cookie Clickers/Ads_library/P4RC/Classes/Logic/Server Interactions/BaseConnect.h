//
//  BaseConnect.h
//  MercedesBenz
//
//  Created by kost on 2/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

@class ExtendedURLConnection;

@interface BaseConnect : NSObject {
	ExtendedURLConnection *connection;
	
	SEL didFinishSelector;
	
	id delegate;
	
	NSMutableURLRequest *request;
}

@property (nonatomic, assign) id delegate;
@property (nonatomic, assign) SEL didFinishSelector;

@property (nonatomic, copy) NSString *bodyRequestString;

@property (nonatomic, retain) NSMutableURLRequest *request;

- (id)initWithPostRequestBody:(NSString*)theRequestBody delegate:(id)theDelegate remoteMethodPath:(NSString*)theMethodPath;
- (id)initWithPutRequestBody:(NSString*)theRequestBody delegate:(id)theDelegate remoteMethodPath:(NSString*)theMethodPath;
- (id)initWithGetRequestPath:(NSString *)theMethodPath delegate:(id)theDelegate;

- (void)sendRequest;

- (void)setValue:(NSString *)theValue forHTTPHeaderField:(NSString *)theField;
- (NSString*)requestID;
 
@end

@interface  BaseConnect (Utils)

- (NSMutableURLRequest*)createPostRequestWithString:(NSString *)theBodyString path:(NSString*)thePath;
- (NSMutableURLRequest*)createGetRequestWithString:(NSString *)theBodyString path:(NSString*)thePath;
- (NSMutableURLRequest*)createPutRequestWithString:(NSString *)theBodyString path:(NSString*)thePath;

@end
