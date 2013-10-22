//
//  StoreLayer.h
//  Cookie Clickers
//
//  Created by Cookiedev on 7/12/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface StoreLayer : CCLayer
{
    CCMenuItemSprite* menuItemItem0;
    CCMenuItemSprite* menuItemItem1;
    CCMenuItemSprite* menuItemItem2;
    CCMenuItemSprite* menuItemItem3;
    CCMenuItemSprite* menuItemItem4;
    
    CCLabelTTF* lblAutoClickClickers;
    CCLabelTTF* lblGrandMaClickers;
    CCLabelTTF* lblCRobotClickers;
    CCLabelTTF* lblCookieFarmClickers;
    CCLabelTTF* lblCFactoryClickers;
    
    CCLabelTTF* lblAutoClickLevel;
    CCLabelTTF* lblGrandMaLevel;
    CCLabelTTF* lblCRobotLevel;
    CCLabelTTF* lblCookieFarmLevel;
    CCLabelTTF* lblCFactoryLevel;
}

-(void) updateLabel:(NSUInteger) nIdx;

@end
