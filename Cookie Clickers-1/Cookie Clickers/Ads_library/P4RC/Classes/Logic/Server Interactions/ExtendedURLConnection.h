//
//  IdeasCell.h
//  MercedesBenz
//
//  Created by kost on 9/6/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

//! Wrapper around |NSURLConnection|. Will automatically update network activity indicator
// TODO: fix analysis errors

#import <Foundation/Foundation.h>

@interface ExtendedURLConnection : NSObject {
	id delegate;
	
	SEL didFailSelector;            //!< is called if connection error occurred
	SEL didReceiveResponseSelector; //!< is called on |connection:didReceiveResponse:|
	SEL didFinishSelector;          //!< is called on |connectionDidFinishLoading:|
	
	NSHTTPURLResponse *response;     //!< |NSURLConnection| response
	NSMutableData     *responseData; //!< |NSURLConnection| response data
	NSError           *error;        //!< last |NSURLConnection| error
	
	NSURLConnection *connection;
	
	NSString *downloadDestinationPath; //! path to file into which response will be downloaded; if nil - downloads into |responseData|; is set to nil on |cancel|
	
	NSFileHandle *downloadFileHandle;  //! handle for downloaded file
}
@property(nonatomic, assign) id delegate;
@property(nonatomic, assign) SEL didFailSelector;
@property(nonatomic, assign) SEL didReceiveResponseSelector;
@property(nonatomic, assign) SEL didFinishSelector;
@property(nonatomic, retain) NSString *downloadDestinationPath;

//! Will init the connection and start loading data from the specified URL
- (id)initWithRequest:(NSMutableURLRequest*)theRequest delegate:(id)theDelegate;
- (id)initWithRequest:(NSMutableURLRequest*)theRequest delegate:(id)theDelegate downloadDestinationPath:(NSString*)theDownloadDestinationPath;

//! (async) Will start performing request
- (void)start;

//! Cancels request. The same as [NSURLConnection cancel] + flushes all the downloaded data and removes the download file. 
//! Sets |downloadDestinationPath| to nil.
//! Is called automatically on errors.
- (void)cancel;

//@{ Getters:
- (NSHTTPURLResponse*)response;
- (NSMutableData*)responseData;
- (NSError*)error;
//@}

//! Converts |responseData| into string using encoding specified in |response|.
//! If wrong encoding is specified - returns nil.
//! If encoding is not specified - uses |CXNURLConnectionDefaultEncoding| for convertion.
- (NSString*)responseString;

@end
