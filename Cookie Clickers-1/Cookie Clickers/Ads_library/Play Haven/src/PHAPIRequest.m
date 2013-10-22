/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 Copyright 2013 Medium Entertainment, Inc.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.

 PHAPIRequest.m
 playhaven-sdk-ios

 Created by Jesus Fernandez on 3/30/11.
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#import <CommonCrypto/CommonHMAC.h>
#import "PHConnectionManager.h"
#import "PHAPIRequest.h"

#import "NSObject+QueryComponents.h"
#import "PHStringUtil.h"
#import "JSON.h"
#import "UIDevice+HardwareString.h"
#import "PHNetworkUtil.h"
#import "PHConstants.h"
#import "PHAPIRequest+Private.h"

#ifdef PH_USE_NETWORK_FIXTURES
#import "WWURLConnection.h"
#endif

static NSString *sPlayHavenSession;
static NSString *const kSessionPasteboard = @"com.playhaven.session";
static NSString *sPlayHavenPluginIdentifier;
static NSString *sPlayHavenCustomUDID;
static NSString *const kPHRequestParameterIDFVKey = @"idfv";
static NSString *const kPHRequestParameterOptOutStatusKey = @"opt_out";
static NSString *const kPHDefaultUserIsOptedOut = @"PHDefaultUserIsOptedOut";

@interface PHAPIRequest (Private)
+ (NSMutableSet *)allRequests;
- (void)finish;
- (void)afterConnectionDidFinishLoading;
+ (void)setSession:(NSString *)session;
- (void)processRequestResponse:(NSDictionary *)responseData;

- (void)didSucceedWithResponse:(NSDictionary *)responseData;
- (void)didFailWithError:(NSError *)error;
@end

@implementation PHAPIRequest
@synthesize token    = _token;
@synthesize secret   = _secret;
@synthesize delegate = _delegate;
@synthesize urlPath  = _urlPath;
@synthesize hashCode = _hashCode;
@synthesize additionalParameters = _additionalParameters;

+ (void)initialize
{
    if  (self == [PHAPIRequest class]) {
        [[PHNetworkUtil sharedInstance] checkDNSResolutionForURLPath:PH_BASE_URL];
        [[PHNetworkUtil sharedInstance] checkDNSResolutionForURLPath:PH_CONTENT_ADDRESS];
#ifdef PH_USE_NETWORK_FIXTURES
        [WWURLConnection setResponsesFromFileNamed:@"dev.wwfixtures"];
#endif
    }
}

+ (NSMutableSet *)allRequests
{
    static NSMutableSet *allRequests = nil;

    if (allRequests == nil) {
        allRequests = [[NSMutableSet alloc] init];
    }

    return allRequests;
}

+ (void)cancelAllRequestsWithDelegate:(id<PHAPIRequestDelegate>)delegate
{
    NSEnumerator *allRequests = [[PHAPIRequest allRequests] objectEnumerator];
    PHAPIRequest *request = nil;

    NSMutableSet *canceledRequests = [NSMutableSet set];

    while ((request = [allRequests nextObject])) {
        if ([[request delegate] isEqual:delegate]) {
            [canceledRequests addObject:request];
        }
    }

    [canceledRequests makeObjectsPerformSelector:@selector(cancel)];
}

+ (int)cancelRequestWithHashCode:(int)hashCode
{
    PHAPIRequest *request = [self requestWithHashCode:hashCode];
    if (!!request) {
        [request cancel];

        return 1;
    }
    return 0;
}

+ (NSString *)base64SignatureWithString:(NSString *)string
{
    return [PHStringUtil b64DigestForString:string];
}

+ (NSString *)expectedSignatureValueForResponse:(NSString *)responseString nonce:(NSString *)nonce secret:(NSString *)secret
{
    if (!responseString || !secret)
        return nil;

    const char   *cKey = [secret cStringUsingEncoding:NSUTF8StringEncoding];
    unsigned char cHMAC[CC_SHA1_DIGEST_LENGTH];

    CCHmacContext context;
    CCHmacInit(&context, kCCHmacAlgSHA1, cKey, strlen(cKey));

    if (nonce) {
        const char *cNonce = [nonce cStringUsingEncoding:NSUTF8StringEncoding];
        CCHmacUpdate(&context, cNonce, strlen(cNonce));
    }

    const char *cResponse = [responseString cStringUsingEncoding:NSUTF8StringEncoding];
    CCHmacUpdate(&context, cResponse, strlen(cResponse));

    CCHmacFinal(&context, &cHMAC);

    NSData *HMAC = [[[NSData alloc] initWithBytes:cHMAC
                                           length:sizeof(cHMAC)] autorelease];

    NSString *localSignature = [PHStringUtil base64EncodedStringForData:HMAC];

    // Figure out if we need to pad to multiple of 4 length
    NSUInteger length = [localSignature length];
    NSUInteger modulo = [localSignature length] % 4;
    if (modulo != 0) {
        length = length + (4 - modulo);
    }

    return [localSignature stringByPaddingToLength:length withString:@"=" startingAtIndex:0];
}

+ (NSString *)session
{
    @synchronized (self) {
        if (sPlayHavenSession == nil) {
            UIPasteboard *pasteboard = [UIPasteboard pasteboardWithName:kSessionPasteboard create:NO];
            sPlayHavenSession = [[NSString alloc] initWithString:([pasteboard string] == nil ? @"" : [pasteboard string])];
        }
    }

    return (!!sPlayHavenSession) ? sPlayHavenSession : @"";
}

+ (void)setSession:(NSString *)session
{
    @synchronized (self) {
        if (![session isEqualToString:sPlayHavenSession]) {
            UIPasteboard *pasteboard = [UIPasteboard pasteboardWithName:kSessionPasteboard create:YES];
            [pasteboard setString:((session!= nil) ? session : @"")];
            [sPlayHavenSession release];
            sPlayHavenSession = (!!session) ? [[NSString alloc] initWithString:session] : nil;
        }
    }
}

+ (BOOL)optOutStatus
{
    BOOL theDefaultOptOutStatus = [[[NSBundle mainBundle] infoDictionary][kPHDefaultUserIsOptedOut]
                boolValue];
    NSNumber *theUserPreference = [[NSUserDefaults standardUserDefaults] objectForKey:
                @"PlayHavenOptOutStatus"];
    BOOL theOptOutStatus = theDefaultOptOutStatus;
    
    // User preference overrides the default status.
    if (nil != theUserPreference)
    {
        theOptOutStatus = [theUserPreference boolValue];
    }

    return theOptOutStatus;
}

+ (void)setOptOutStatus:(BOOL)yesOrNo
{
    [[NSUserDefaults standardUserDefaults] setBool:yesOrNo forKey:@"PlayHavenOptOutStatus"];
}

+ (NSString *)pluginIdentifier
{
    @synchronized (self) {
        if (sPlayHavenPluginIdentifier == nil ||
            [sPlayHavenPluginIdentifier isEqualToString:@""]) {
                [sPlayHavenPluginIdentifier autorelease];
                sPlayHavenPluginIdentifier = [[NSString alloc] initWithFormat:@"ios"];
        }
    }

    return sPlayHavenPluginIdentifier;
}

+ (void)setPluginIdentifier:(NSString *)identifier
{
    @synchronized (self) {
        [sPlayHavenPluginIdentifier autorelease];

        if (!identifier || [identifier isEqual:[NSNull null]] || [identifier isEqualToString:@""]) {
            PH_LOG(@"Setting the plugin identifier to nil or an empty string will result in using the default value: \"ios\"", nil);
            sPlayHavenPluginIdentifier = nil;
            return;
        }

        NSError *error = nil;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[^A-Za-z0-9\\-\\.\\_\\~]*"
                                                                               options:NSRegularExpressionCaseInsensitive
                                                                                 error:&error];

        NSString *string = [regex stringByReplacingMatchesInString:identifier
                                                           options:NSMatchingWithTransparentBounds
                                                             range:NSMakeRange(0, [identifier length])
                                                      withTemplate:@""];

        if ([string length] > 42)
            string = [string substringToIndex:42];

        if (error || !string) {
            PH_LOG(@"There was an error setting the plugin identifier. Using the default value: \"ios\"", nil);
            string = nil;
        }


        sPlayHavenPluginIdentifier = [string retain];
    }
}

+ (NSString *)customUDID
{
    return sPlayHavenCustomUDID;
}

+ (void)setCustomUDID:(NSString *)customUDID
{
    @synchronized (self) {
        [sPlayHavenCustomUDID autorelease];

        if (!customUDID || [customUDID isEqual:[NSNull null]] || [customUDID isEqualToString:@""]) {
            sPlayHavenCustomUDID = nil;
            return;
        }

        NSError *error = nil;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[^A-Za-z0-9\\-\\.\\_\\~]*"
                                                                               options:NSRegularExpressionCaseInsensitive
                                                                                 error:&error];

        NSString *string = [regex stringByReplacingMatchesInString:customUDID
                                                           options:NSMatchingWithTransparentBounds
                                                             range:NSMakeRange(0, [customUDID length])
                                                      withTemplate:@""];

        if (error || !string || ![string length]) {
            PH_LOG(@"There was an error setting the custom UDID. Value will not be sent to PlayHaven server.", nil);
            string = nil;
        }

        sPlayHavenCustomUDID = [string retain];
    }
}

- (void)setCustomUDID:(NSString *)customUDID
{
    [PHAPIRequest setCustomUDID:customUDID];
}

- (NSString *)customUDID
{
    return [PHAPIRequest customUDID];
}

+ (id)requestForApp:(NSString *)token secret:(NSString *)secret
{
    return [[[[self class] alloc] initWithApp:token secret:secret] autorelease];
}

+ (id)requestWithHashCode:(int)hashCode
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"hashCode == %d", hashCode];
    NSSet       *resultSet = [[self allRequests] filteredSetUsingPredicate:predicate];

    return [resultSet anyObject];
}

- (id)initWithApp:(NSString *)token secret:(NSString *)secret
{
    if (nil == token || nil == secret)
    {
        PH_LOG(@"[%@ %@] ERROR: Nil input arguments. (token - %@; secret - %@)", NSStringFromClass(
                    [self class]), NSStringFromSelector(_cmd), token, secret, nil);
        [self release];
        return nil;
    }

    self = [self init];
    if (self) {
        _token  = [token copy];
        _secret = [secret copy];
    }

    return self;
}

- (id)init
{
    self = [super init];
    if (self) {
        [[PHAPIRequest allRequests] addObject:self];
    }

    return  self;
}

- (NSURL *)URL
{
    if (_URL == nil) {
        NSString *urlString = [NSString stringWithFormat:@"%@?%@",
                               [self urlPath],
                               [self signedParameterString]];
        _URL = [[NSURL alloc] initWithString:urlString];
    }

    return _URL;
}

- (NSDictionary *)signedParameters
{
    if (_signedParameters == nil) {
        CGRect  screenBounds = [[UIScreen mainScreen] applicationFrame];
        BOOL    isLandscape  = UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]);
        CGFloat screenWidth  = (isLandscape) ? CGRectGetHeight(screenBounds) : CGRectGetWidth(screenBounds);
        CGFloat screenHeight = (!isLandscape) ? CGRectGetHeight(screenBounds) : CGRectGetWidth(screenBounds);
        CGFloat screenScale  = [[UIScreen mainScreen] scale];

        NSString *preferredLanguage = ([[NSLocale preferredLanguages] count] > 0) ?
                                            [[NSLocale preferredLanguages] objectAtIndex:0] : nil;

        NSDictionary *theIdentifiers = [[self class] identifiers];
        NSMutableDictionary *combinedParams = [[NSMutableDictionary alloc] initWithDictionary:
                    theIdentifiers];

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 60000
#if PH_USE_AD_SUPPORT == 1
        if ([ASIdentifierManager class])
        {
            NSNumber *trackingEnabled = [NSNumber numberWithBool:[[ASIdentifierManager sharedManager] isAdvertisingTrackingEnabled]];
            [combinedParams setValue:trackingEnabled forKey:@"tracking"];
        }
#endif
#endif
#endif

        if (self.customUDID)
        {
            [combinedParams setValue:self.customUDID forKey:@"d_custom"];
        }

        // Adds plugin identifier
        [combinedParams setValue:[PHAPIRequest pluginIdentifier] forKey:@"plugin"];

        // This allows for unit testing of request values!
        NSBundle *mainBundle = [NSBundle bundleForClass:[self class]];

        NSString
            *nonce         = [PHStringUtil uuid],
            *appId         = [[mainBundle infoDictionary] objectForKey:@"CFBundleIdentifier"],
            *appVersion    = [[mainBundle infoDictionary] objectForKey:@"CFBundleVersion"],
            *hardware      = [[UIDevice currentDevice] hardware],
            *os            = [NSString stringWithFormat:@"%@ %@",
                                    [[UIDevice currentDevice] systemName],
                                    [[UIDevice currentDevice] systemVersion]],
            *languages     = preferredLanguage;

        if (!appVersion) appVersion = @"NA";
        
        NSString *signature = [[self class] v4SignatureWithIdentifiers:theIdentifiers token:
                    self.token nonce:nonce signatureKey:self.secret];
        signature = nil != signature ? signature : @"";

        NSNumber
            *idiom      = [NSNumber numberWithInt:(int)UI_USER_INTERFACE_IDIOM()],
            *connection = [NSNumber numberWithInt:PHNetworkStatus()],
            *width      = [NSNumber numberWithFloat:screenWidth],
            *height     = [NSNumber numberWithFloat:screenHeight],
            *scale      = [NSNumber numberWithFloat:screenScale];
        NSNumber *theOptOutStatus = @([PHAPIRequest optOutStatus]);

        [combinedParams addEntriesFromDictionary:self.additionalParameters];

        NSDictionary *signatureParams =
             [NSDictionary dictionaryWithObjectsAndKeys:
                                 self.token,     @"token",
                                 signature,      @"sig4",
                                 nonce,          @"nonce",
                                 appId,          @"app",
                                 hardware,       @"hardware",
                                 os,             @"os",
                                 idiom,          @"idiom",
                                 appVersion,     @"app_version",
                                 connection,     @"connection",
                                 PH_SDK_VERSION, @"sdk-ios",
                                 languages,      @"languages",
                                 width,          @"width",
                                 height,         @"height",
                                 scale,          @"scale",
                                 theOptOutStatus, kPHRequestParameterOptOutStatusKey,
                                 nil];

        [combinedParams addEntriesFromDictionary:signatureParams];
        _signedParameters = combinedParams;
    }

    return _signedParameters;
}

- (NSString *)signedParameterString
{
    return [[self signedParameters] stringFromQueryComponents];
}

- (void)dealloc
{
    [_token release], _token = nil;
    [_secret release], _secret = nil;
    [_URL release], _URL = nil;
    [_signedParameters release], _signedParameters = nil;
    [_urlPath release], _urlPath = nil;
    [_additionalParameters release], _additionalParameters = nil;

    [super dealloc];
}

#pragma mark -
#pragma mark PHPublisherOpenRequest

- (void)send
{
    if (!alreadySent)
    {
        PH_LOG(@"Sending request: %@", [self.URL absoluteString]);

        NSURLRequest *request = [NSURLRequest requestWithURL:self.URL
                                                 cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                             timeoutInterval:PH_REQUEST_TIMEOUT];

        if ([PHConnectionManager createConnectionFromRequest:request forDelegate:self withContext:nil])
            alreadySent = YES;
        else
            [self didFailWithError:nil]; // TODO: Create error
    }
}

- (void)cancel
{
    PH_LOG(@"%@ canceled!", NSStringFromClass([self class]));

    // TODO: Confirm that by moving this from 'finish' to 'cancel' doesn't break anything
    [PHConnectionManager stopConnectionsForDelegate:self];
    [self finish];
}

/*
 * Internal cleanup method
 */
- (void)finish
{
    // REQUEST_RELEASE see REQUEST_RETAIN
    [[PHAPIRequest allRequests] removeObject:self];
}

#pragma mark -
#pragma mark NSURLConnectionDelegate PHConnectionManagerDelegate
- (void)connectionDidFinishLoadingWithRequest:(NSURLRequest *)request response:(NSURLResponse *)response data:(NSData *)data context:(id)context
{
    PH_NOTE(@"Request finished!");

    if ([self.delegate respondsToSelector:@selector(requestDidFinishLoading:)]) {
        [self.delegate performSelector:@selector(requestDidFinishLoading:) withObject:self withObject:nil];
    }

    NSString *responseString = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];

    //if (!responseString) ; // TODO: Create an error for when responseString is nil, which happens when data is not UTF8 encoded. Right now it fails in the signature check

    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        NSString *requestSignature  = [self requestSignatureFromHttpHeaderFields:[httpResponse allHeaderFields]];
        NSString *nonce             = [self.signedParameters valueForKey:@"nonce"];
        NSString *expectedSignature = [PHAPIRequest expectedSignatureValueForResponse:responseString
                                                                                nonce:nonce
                                                                               secret:self.secret];

        if (![expectedSignature isEqualToString:requestSignature]) {
            [self didFailWithError:PHCreateError(PHRequestDigestErrorType)];

            return;
        }
    }

    PH_SBJSONPARSER_CLASS *parser           = [[[PH_SBJSONPARSER_CLASS alloc] init] autorelease];
    NSDictionary          *resultDictionary = [parser objectWithString:responseString];

    [self processRequestResponse:resultDictionary];
}

- (void)afterConnectionDidFinishLoading
{

}

- (void)connectionDidFailWithError:(NSError *)error request:(NSURLRequest *)request context:(id)context
{
    PH_LOG(@"Request failed with error: %@", [error localizedDescription]);
    [self didFailWithError:error];

    // REQUEST_RELEASE see REQUEST_RETAIN
    //[self finish]; // TODO: Why is this here if it's also in didFailWithError which is called immediately above??
    // TODO: Investigate this further. Having it here causes crash, and removing it makes things work more as expected. Why else would it be needed?
}

#pragma mark -
- (void)processRequestResponse:(NSDictionary *)responseData
{
    id errorValue = [responseData valueForKey:@"error"];
    if (!!errorValue && ![errorValue isEqual:[NSNull null]]) {
        PH_LOG(@"Error response: %@", errorValue);
        [self didFailWithError:PHCreateError(PHAPIResponseErrorType)];
    } else {
        id responseValue = [responseData valueForKey:@"response"];
        if ([responseValue isEqual:[NSNull null]]) {
            responseValue = nil;
        }

        [self didSucceedWithResponse:responseValue];
    }
}

- (void)didSucceedWithResponse:(NSDictionary *)responseData
{
    if ([self.delegate respondsToSelector:@selector(request:didSucceedWithResponse:)]) {
        [self.delegate performSelector:@selector(request:didSucceedWithResponse:) withObject:self withObject:responseData];
    }

    [self finish];
}

- (void)didFailWithError:(NSError *)error
{
    if ([self.delegate respondsToSelector:@selector(request:didFailWithError:)]) {
        [self.delegate performSelector:@selector(request:didFailWithError:) withObject:self withObject:error];
    }

    [self finish];
}

#pragma mark -

// The functions returns request signature looking for X-PH-DIGEST header field using
// caseinsennsetive comparsion. It fixes an issue with signature validation failing as some
// iOS versions return expected header but with changed letters so that just first letter are in
// upper-case. F.e. 4.3.2 returns X-Ph-Digest.
- (NSString *)requestSignatureFromHttpHeaderFields:(NSDictionary *)aHeaderFields
{
    NSString *theSignature = nil;
    
    for (NSString *theFiledName in [aHeaderFields allKeys])
    {
        if (NSOrderedSame == [theFiledName caseInsensitiveCompare:@"X-PH-DIGEST"])
        {
            theSignature = [aHeaderFields objectForKey:theFiledName];
            break;
        }
    }
    
    return theSignature;
}

+ (NSDictionary *)identifiers
{
    NSMutableDictionary *theIdentifiers = [NSMutableDictionary dictionary];
    
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 60000
#if PH_USE_AD_SUPPORT == 1
    if (![PHAPIRequest optOutStatus] && [ASIdentifierManager class])
    {
        NSUUID *uuid = [[ASIdentifierManager sharedManager] advertisingIdentifier];
        NSString *uuidString = [uuid UUIDString];

        if (0 < [uuidString length])
        {
            [theIdentifiers setValue:uuidString forKey:@"ifa"];
        }
    }
#endif
#endif
#endif

    if ([[UIDevice currentDevice] respondsToSelector:@selector(identifierForVendor)])
    {
        NSString *theDeviceIDFV = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        if (nil != theDeviceIDFV)
        {
            theIdentifiers[kPHRequestParameterIDFVKey] = theDeviceIDFV;
        }
    }

#if PH_USE_MAC_ADDRESS == 1
    if (![PHAPIRequest optOutStatus] && PH_SYSTEM_VERSION_LESS_THAN(@"6.0"))
    {
        PHNetworkUtil *netUtil = [PHNetworkUtil sharedInstance];
        CFDataRef macBytes = [netUtil newMACBytes];
        if (macBytes)
        {
            [theIdentifiers setValue:[netUtil stringForMACBytes:macBytes] forKey:@"mac"];
            CFRelease(macBytes);
        }
    }
#endif

    NSString *theSession = [PHAPIRequest session];
    if (0 < [theSession length])
    {
        theIdentifiers[@"session"] = theSession;
    }

    return theIdentifiers;
}

+ (NSString *)v4SignatureWithIdentifiers:(NSDictionary *)anIdentifiers token:(NSString *)aToken
            nonce:(NSString *)aNonce signatureKey:(NSString *)aKey
{
    if (0 == [aToken length] || 0 == [aNonce length] || 0 == [aKey length])
    {
        PH_DEBUG(@"Incorrect input parmameters: token - %@, nonce - %@, key - %@\n", aToken, aNonce,
                    aKey);
        return nil;
    }
    
    NSArray *theSortedKeys = [[anIdentifiers allKeys] sortedArrayUsingSelector:@selector(
                caseInsensitiveCompare:)];
    // Sort the identifiers by key (identifier name).
    NSArray *theSortedValues = [anIdentifiers objectsForKeys:theSortedKeys notFoundMarker:[NSNull
                null]];

    // Join identifiers with a colon.
    NSString *theJoinedIdentifiers = [theSortedValues componentsJoinedByString:@":"];

    // Construct message with the format string.
    NSString *theMessage = [NSString stringWithFormat:@"%@:%@:%@", nil != theJoinedIdentifiers ?
                theJoinedIdentifiers : @"", aToken, aNonce];

    return [self v4SignatureWithMessage:theMessage signatureKey:aKey];
}

+ (NSString *)v4SignatureWithMessage:(NSString *)aMessage signatureKey:(NSString *)aKey
{
    if (0 == [aMessage length] || 0 == [aKey length])
    {
        PH_DEBUG(@"Incorrect input parmameters: message - %@, key - %@\n", aMessage, aKey);
        return nil;
    }

    const char *theMessageCString = [aMessage cStringUsingEncoding:NSUTF8StringEncoding];
    const char *theKeyCString = [aKey cStringUsingEncoding:NSUTF8StringEncoding];

    unsigned char theHMACDigest[CC_SHA1_DIGEST_LENGTH];
    NSString *theBase64EncodedDigest = nil;

    if (NULL != theKeyCString && NULL != theMessageCString)
    {
        CCHmac(kCCHmacAlgSHA1, theKeyCString, strlen(theKeyCString), theMessageCString,
                    strlen(theMessageCString), &theHMACDigest);

        NSData *theHMACData = [[[NSData alloc] initWithBytes:theHMACDigest length:sizeof(
                    theHMACDigest)] autorelease];
        theBase64EncodedDigest = [PHStringUtil base64EncodedStringForData:theHMACData];
    }
    
    return theBase64EncodedDigest;
}

@end
