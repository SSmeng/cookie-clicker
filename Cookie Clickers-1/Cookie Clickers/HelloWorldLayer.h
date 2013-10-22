//
//  HelloWorldLayer.h
//  Cookie Clickers
//
//  Created by Cookiedev on 10/9/13.
//  Copyright __MyCompanyName__ 2013. All rights reserved.
//


// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"

@class StoreLayer;

// HelloWorldLayer
@interface HelloWorldLayer : CCLayer
{
    NSUInteger nScrollTextPointer;
    NSMutableArray* arrayScrollText;
    CCLabelTTF* lblScrollText;
    
    StoreLayer* storeLayer;
    CCSprite* spritePizzaRay;
    
    CCMenuItemSprite* menuItemPizza;
    
    CCLabelTTF* lblClickAmounts;
    CCLabelTTF* lblCps;
    
    CGFloat fBaseCps;
    
    NSUInteger nButtonClicksNum;
    
    CCSprite* spriteMilk[2];
    CGFloat fRadius[100];
    
    NSMutableArray* arrayPointers;
    CGFloat fInitialAngle;
    
    NSUInteger nAutoClickersIdx;
    NSUInteger nChangeRadiusCounter;
    CGFloat fSign;
    
    CCSprite* spriteMask;
    UIActivityIndicatorView *thinkIndicator;
    
    bool bChangeRadius;
}

@property (nonatomic, retain)     StoreLayer* storeLayer;
@property (nonatomic, assign) NSUInteger nButtonClicksNum;

-(void) updatePointerCps;
-(void) showIAPViews;
-(void) hideIAPViews;

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;

@end
