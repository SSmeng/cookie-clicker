//
//  CXNKeychainManager.m
//  CXN
//
//  Created by Igor Ishchenko on 23.07.10.
//  Copyright 2010 nix. All rights reserved.
//

#import "CXNKeychainManager.h"
#import "SFHFKeychainUtils.h"

#define KEY_LENGTH		16


// private interface
@interface CXNKeychainManager ()

//! Generates hex string with random data with specified length
- (NSString*)randomHexKeyWithLength:(NSUInteger)theLengthInBits;

//! Returns random data with specified length
- (NSData*)randomDataWithLengthInBytes:(NSInteger)theLengthInBytes;

//! Returns hex string representation of given data
- (NSString*)hexStringWithData:(NSData*)theData;

//! Saves key for given code in iphone keychain
- (void)saveKey:(NSString*)theKey withCode:(NSString*)theCode;

@end

@implementation CXNKeychainManager

static CXNKeychainManager *_instance = nil;

+ (CXNKeychainManager *)sharedInstance {
    @synchronized(self) {
        if (_instance == nil) {
            [[self alloc] init];
        }
    }
    return _instance;
}

+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if (_instance == nil) {
            _instance = [super allocWithZone:zone];
            return _instance;
        }
    }
    return nil;
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

- (oneway void)release {
}

- (id)retain {
    return self;
}

- (id)autorelease {
    return self;
}

- (NSUInteger)retainCount {
    return UINT_MAX;
}

-(id)init {
    if (self = [super init]) {
    }
    
    return self;
}

#pragma mark -
#pragma mark Keychain management methods

- (NSString*)keyForSiteWithCode:(NSString*)theSiteCode {
    NSError *error = nil;
    
    // try to get key from keychain
    NSString *key = [SFHFKeychainUtils getPasswordForUsername:theSiteCode
                                               andServiceName:SERVICE_CODE
                                                        error:&error];
    // FIXME: add error handling for release
    if (error != nil) {
        return nil;
    } 
    
    // if key doesn't exists, generate it and store in keychain
    if (key == nil) {
        key = [self randomHexKeyWithLength:KEY_LENGTH];
        [self saveKey:key withCode:theSiteCode];
    }
    
    return key;
}

- (BOOL)removeKeyForSiteWithCode:(NSString*)theSiteCode {
    NSError *error = nil;
    NSString *key = [SFHFKeychainUtils getPasswordForUsername:theSiteCode 
                                               andServiceName:SERVICE_CODE 
                                                        error:&error];
    
    // if key for specified site exists, remove it
    if (key != nil) {
        [SFHFKeychainUtils deleteItemForUsername:theSiteCode
                                  andServiceName:SERVICE_CODE
                                           error:&error];
		
		if (error != nil) {
            return NO;
        }
    }
    return YES;
}

- (BOOL)renameKeyForSiteWithCode:(NSString *)theOldSiteCode 
                 withNewSiteCode:(NSString *)theNewSiteCode 
{
    if (!theOldSiteCode || !theNewSiteCode) {
        return NO;
    }
    NSString *key = [self keyForSiteWithCode:theOldSiteCode];
    [self removeKeyForSiteWithCode:theOldSiteCode];
    [self saveKey:key withCode:theNewSiteCode];
    
    return YES;
}

- (BOOL)createCopyOfKeyForSiteWithCode:(NSString *)theSiteCode 
                          withCopyCode:(NSString *)theCopyCode
{
    if (!theSiteCode || !theCopyCode) {
        return NO;
    }
    NSString *key = [self keyForSiteWithCode:theSiteCode];
    [self saveKey:key withCode:theCopyCode];
    
    return YES;
}

#pragma mark -
#pragma mark Private interface implementation

- (NSString*)randomHexKeyWithLength:(NSUInteger)theLengthInBits {
    NSData *data = [self randomDataWithLengthInBytes:(theLengthInBits/8)];
    NSString *key = [self hexStringWithData:data];
    
    // key must be in x'XXXXXXX...XXX' format, where X - hex digit
    NSString *hexKey = [NSString stringWithFormat:@"x'%@'", key];
    
    return hexKey;
}

- (NSData*)randomDataWithLengthInBytes:(NSInteger)theLengthInBytes {
    // initialize buffer for random bytes
    unsigned char *buffer;
    buffer = malloc(theLengthInBytes);
    memset((void *)buffer, 0x0, theLengthInBytes);
    
    // get random bytes
    SecRandomCopyBytes(kSecRandomDefault, theLengthInBytes, buffer);    

    NSData *data = [[NSData alloc] initWithBytes:(const void *)buffer 
                                          length:theLengthInBytes];
    
    free(buffer);
    
    return [data autorelease];
}

- (NSString *)hexStringWithData:(NSData*)theData {
    // initialize buffers
    NSMutableString *stringBuffer = [NSMutableString string];
    const unsigned char *dataBuffer = [theData bytes];
    
    //convert binary data to hex string
    for (NSUInteger i = 0; i < [theData length]; ++i)
        [stringBuffer appendFormat:@"%02lX", (unsigned long)dataBuffer[i]];
    
    return [[stringBuffer copy] autorelease];
}

- (void)saveKey:(NSString*)theKey withCode:(NSString*)theCode {    
    NSError *error = nil;
    
    [SFHFKeychainUtils storeUsername:theCode 
                         andPassword:theKey
                      forServiceName:SERVICE_CODE
                      updateExisting:YES
                               error:&error];
    
    // FIXME: add error handling for release
    if (error != nil) {
    }
}

@end
