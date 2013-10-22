//
//  P4RCEncodingUtil.m
//  ConstaPad
//
//  Created by Artem Stepanenko on 1/31/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "P4RCEncodingUtil.h"
#import "NSData+CommonCrypto.h"
#import "P4RCUtils.h"
#import "CXNKeychainManager.h"

#define SECRET_KEY			@"p4rcSiteCode"


@implementation NSDictionary (Helpers)

+ (NSDictionary *)dictionaryWithData:(NSData *)data
{
	CFPropertyListRef plist =  CFPropertyListCreateFromXMLData(kCFAllocatorDefault,
															   (CFDataRef)data,
															   kCFPropertyListImmutable,
															   NULL);
	if ((plist != nil) && ([(id)plist isKindOfClass:[NSDictionary class]] == YES))
	{
		return [(NSDictionary *)plist autorelease];
	}
	else
	{
        if (plist)
        {
            CFRelease(plist);
        }
		return nil;
	}
}

@end


@implementation NSData (Helpers)

+ (NSData *)dataWithDictionary:(NSDictionary *)dictionary
{
	NSData *data = (NSData *)CFPropertyListCreateXMLData(kCFAllocatorDefault, (CFPropertyListRef)dictionary);
	if ((data != nil) && ([data isKindOfClass:[NSData class]] == YES))
	{
		return [data autorelease];
	}
	else
	{
        if (data)
        {
            CFRelease(data);
        }
		return nil;
	}
}

@end


@implementation P4RCEncodingUtil

+ (NSString *)key
{
	return [[CXNKeychainManager sharedInstance] keyForSiteWithCode:SECRET_KEY];
}

+ (NSDictionary *)loadDictionaryWithDecryptedContentOfFile:(NSString *)filePath
{
	NSData *contentData = [[NSFileManager defaultManager] contentsAtPath:filePath];
	if ((contentData == nil) || ([contentData length] == 0))
	{
		return nil;
	}

	NSError *error = nil;
	NSData *decryptedData = [contentData decryptedAES256DataUsingKey:[P4RCEncodingUtil key] error:&error];
	
	if (error != nil)
	{
		return nil;
	}
	
	error = nil;
	/*NSPropertyListFormat format;
	NSDictionary *contentDictionary = [NSPropertyListSerialization propertyListWithData:decryptedData
																				options:0
																				 format:&format
																				  error:&error];*/
	
	NSDictionary *contentDictionary = [NSDictionary dictionaryWithData:decryptedData];
	
	return error ? nil : contentDictionary;
}

+ (BOOL)saveEncryptedDictionary:(NSDictionary *)dictionary toFile:(NSString *)filePath
{
	NSError *error = nil;

	NSData *contentData = [NSData dataWithDictionary:dictionary];
	
	if ((error != nil) || (contentData == nil) || ([contentData length] == 0))
	{
		return NO;
	}
	
	error = nil;
	NSData *encryptedData = [contentData AES256EncryptedDataUsingKey:[P4RCEncodingUtil key] error:&error];
	
	if (error != nil)
	{
		return NO;
	}
	
	if ([[NSFileManager defaultManager] createFileAtPath:filePath contents:encryptedData attributes:nil] == NO)
	{
		return NO;
	}
	
	return YES;
}

+ (BOOL)saveEncryptedArray:(NSArray *)array toFile:(NSString *)filePath {
	return [P4RCEncodingUtil saveEncryptedDictionary:[NSDictionary dictionaryWithObject:array forKey:@"array"] toFile:filePath];
}

+ (NSArray *)loadArrayWithDecryptedContentOfFile:(NSString *)filePath {
    NSDictionary *loadedDictionary = [P4RCEncodingUtil loadDictionaryWithDecryptedContentOfFile:filePath];
    return [loadedDictionary objectForKey:@"array"];
}

@end
