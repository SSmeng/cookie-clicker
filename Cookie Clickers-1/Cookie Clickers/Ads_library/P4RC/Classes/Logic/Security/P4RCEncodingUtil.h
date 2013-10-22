//
//  P4RCEncodingUtil.h
//  ConstaPad
//
//  Created by Artem Stepanenko on 1/31/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

@interface P4RCEncodingUtil : NSObject

+ (NSDictionary *)loadDictionaryWithDecryptedContentOfFile:(NSString *)filePath;
+ (BOOL)saveEncryptedDictionary:(NSDictionary *)dictionary toFile:(NSString *)filePath;

+ (BOOL)saveEncryptedArray:(NSArray *)array toFile:(NSString *)filePath;
+ (NSArray *)loadArrayWithDecryptedContentOfFile:(NSString *)filePath;

@end
