//
//  UIImage+Retina4.m
//  StunOMatic
//
//  Created by Benjamin Stahlhood on 9/12/12.
//  Copyright (c) 2012 DS Media Labs. All rights reserved.
//

#import "UIImage+Retina4.h"
#import <objc/runtime.h>
#import <objc/message.h>


static Method origImageNamedMethod = nil;

@implementation UIImage (Retina4)

+ (void)load {
    if ([UIScreen mainScreen].scale == 2.f && [UIScreen mainScreen].bounds.size.height == 568.0f) {
        origImageNamedMethod = class_getClassMethod(self, @selector(imageNamed:));
        method_exchangeImplementations(origImageNamedMethod, class_getClassMethod(self, @selector(retina4ImageNamed:)));
    }
}

+ (UIImage *)retina4ImageNamed:(NSString *)imageName {
    NSMutableString *imageNameMutable = [imageName mutableCopy];
    NSRange retinaAtSymbol = [imageName rangeOfString:@"@"];
    if (retinaAtSymbol.location != NSNotFound) {
        [imageNameMutable insertString:@"-568h" atIndex:retinaAtSymbol.location];
    } else {
        NSRange dot = [imageName rangeOfString:@"." options:NSBackwardsSearch];
        if (dot.location != NSNotFound) {
            [imageNameMutable insertString:@"-568h@2x" atIndex:dot.location];
        } else {
            [imageNameMutable appendString:@"-568h@2x"];
        }
    }
    // remove extension
    NSRange dot = [imageNameMutable rangeOfString:@"." options:NSBackwardsSearch];
    NSString *extension = @"png";
    if (dot.location != NSNotFound) {
        NSRange range;
        range.location = dot.location;
        range.length = imageNameMutable.length - range.location;
        
        NSRange extensionRange = range;
        extensionRange.location += 1;
        extensionRange.length -= 1;
        
        extension = [imageNameMutable substringWithRange:extensionRange];
        
        [imageNameMutable deleteCharactersInRange:range];
    }
    // get path
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:imageNameMutable ofType:extension];
    
    if (imagePath) {
        return [UIImage retina4ImageNamed:imageNameMutable];
    } else {
        return [UIImage retina4ImageNamed:imageName];
    }
    return nil;
}

@end
