//
//  StoreLayer.m
//  Cookie Clickers
//
//  Created by Cookiedev on 7/12/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "StoreLayer.h"
#import "AppDelegate.h"
#import "MKStoreManager.h"
#import "HelloWorldLayer.h"
#import "SNAdsManager.h"

@implementation StoreLayer

-(id) init{
    if ((self = [super init])) {
        [self createBg];
        
        [self createButtons];
        
        [self createAllInfoNums];
        
        return self;
    }
    
    return nil;
}

- (void) createBg
{
    CCSprite* spriteBg = [CCSprite spriteWithFile:@"shop_container.png"];
    [spriteBg setScaleX:m_appDelegate.fx];
    [spriteBg setScaleY:m_appDelegate.fy];
//    [spriteBg setScaleY:1136.f / 960.f];

    [spriteBg setPosition:ccp(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2)];
    [self addChild:spriteBg z:1];
    
    CCSprite* spriteNor = [CCSprite spriteWithFile:@"button_close.png"];
    CCSprite* spriteSel = [CCSprite spriteWithFile:@"button_close.png"];
    [spriteSel setOpacity:100.f];
    
    CCMenuItemSprite* menuItemClose = [CCMenuItemSprite itemFromNormalSprite:spriteNor selectedSprite:spriteSel target:self selector:@selector(actionClose)];
    [menuItemClose setScaleX:m_appDelegate.fx];
    [menuItemClose setScaleY:m_appDelegate.fy];
    [menuItemClose setPosition:ccp(spriteBg.position.x + spriteBg.contentSize.width / 2 * m_appDelegate.fx - menuItemClose.contentSize.width / 2 * m_appDelegate.fx, spriteBg.position.y + spriteBg.contentSize.height / 2 * m_appDelegate.fy - menuItemClose.contentSize.height / 2 * m_appDelegate.fy)];
    
    CCMenu* menu = [CCMenu menuWithItems:menuItemClose, nil];
    menu.position = ccp(0, 0);
    [self addChild:menu z:1];
}

- (void) createButtons
{
    CCSprite* spriteNor = [CCSprite spriteWithFile:@"shop_item0.png"];
    CCSprite* spriteSel = [CCSprite spriteWithFile:@"shop_item0.png"];
    [spriteSel setOpacity:100.f];
    
    menuItemItem0 = [CCMenuItemSprite itemFromNormalSprite:spriteNor selectedSprite:spriteSel target:self selector:@selector(actionItem0)];
    [menuItemItem0 setScaleX:m_appDelegate.fx];
    [menuItemItem0 setScaleY:m_appDelegate.fy];
    
    spriteNor = [CCSprite spriteWithFile:@"shop_item1.png"];
    spriteSel = [CCSprite spriteWithFile:@"shop_item1.png"];
    [spriteSel setOpacity:100.f];
    
    menuItemItem1 = [CCMenuItemSprite itemFromNormalSprite:spriteNor selectedSprite:spriteSel target:self selector:@selector(actionItem1)];
    [menuItemItem1 setScaleX:m_appDelegate.fx];
    [menuItemItem1 setScaleY:m_appDelegate.fy];

    spriteNor = [CCSprite spriteWithFile:@"shop_item2.png"];
    spriteSel = [CCSprite spriteWithFile:@"shop_item2.png"];
    [spriteSel setOpacity:100.f];
    
    menuItemItem2 = [CCMenuItemSprite itemFromNormalSprite:spriteNor selectedSprite:spriteSel target:self selector:@selector(actionItem2)];
    [menuItemItem2 setScaleX:m_appDelegate.fx];
    [menuItemItem2 setScaleY:m_appDelegate.fy];

    spriteNor = [CCSprite spriteWithFile:@"shop_item3.png"];
    spriteSel = [CCSprite spriteWithFile:@"shop_item3.png"];
    [spriteSel setOpacity:100.f];
    
    menuItemItem3 = [CCMenuItemSprite itemFromNormalSprite:spriteNor selectedSprite:spriteSel target:self selector:@selector(actionItem3)];
    [menuItemItem3 setScaleX:m_appDelegate.fx];
    [menuItemItem3 setScaleY:m_appDelegate.fy];

    spriteNor = [CCSprite spriteWithFile:@"shop_item4.png"];
    spriteSel = [CCSprite spriteWithFile:@"shop_item4.png"];
    [spriteSel setOpacity:100.f];
    
    menuItemItem4 = [CCMenuItemSprite itemFromNormalSprite:spriteNor selectedSprite:spriteSel target:self selector:@selector(actionItem4)];
    [menuItemItem4 setScaleX:m_appDelegate.fx];
    [menuItemItem4 setScaleY:m_appDelegate.fy];

    spriteNor = [CCSprite spriteWithFile:@"shop_item5.png"];
    spriteSel = [CCSprite spriteWithFile:@"shop_item5.png"];
    [spriteSel setOpacity:100.f];
    
    CCMenuItemSprite* menuItemItem5 = [CCMenuItemSprite itemFromNormalSprite:spriteNor selectedSprite:spriteSel target:self selector:@selector(actionItem5)];
    [menuItemItem5 setScaleX:m_appDelegate.fx];
    [menuItemItem5 setScaleY:m_appDelegate.fy];

    CCMenu* menu = [CCMenu menuWithItems:menuItemItem0, menuItemItem1, menuItemItem2, menuItemItem3, menuItemItem4, menuItemItem5, nil];
    [menu alignItemsVerticallyWithPadding:0.0f];
    [menu setPosition:ccp(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2 - 15)];
    
    [self addChild:menu z:0];

}

- (void) createAllInfoNums
{
    CGFloat fFontSize = 16.f, fTemp = 0.f;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        fFontSize = 40.f;
        fTemp = 40.f;
    }
    
    lblAutoClickClickers = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d", m_appDelegate.nAutoClickClickers] fontName:@"Arial" fontSize:fFontSize];
    [lblAutoClickClickers setPosition:ccp(menuItemItem0.contentSize.width / 2 * m_appDelegate.fx + 20 + fTemp, SCREEN_HEIGHT / 2 + menuItemItem0.position.y / 2 + menuItemItem0.contentSize.height / 4 * 3 * m_appDelegate.fy - 5 + fTemp / 4.f)];
    [lblAutoClickClickers setColor:ccBLACK];
    [self addChild:lblAutoClickClickers z:2];
    lblAutoClickClickers.tag = 0;
    
    lblAutoClickLevel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d", m_appDelegate.nAutoClickLevel] fontName:@"Arial" fontSize:fFontSize];
    [lblAutoClickLevel setPosition:ccp(menuItemItem0.contentSize.width * m_appDelegate.fx + 20 + fTemp, SCREEN_HEIGHT / 2 + menuItemItem0.position.y / 2 + menuItemItem0.contentSize.height * m_appDelegate.fy + 4+ fTemp / 2.f)];
    [lblAutoClickLevel setColor:ccBLACK];
    [self addChild:lblAutoClickLevel z:2];

    lblGrandMaClickers = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d", m_appDelegate.nGrandMaClickers] fontName:@"Arial" fontSize:fFontSize];
    [lblGrandMaClickers setPosition:ccp(menuItemItem0.contentSize.width / 2 * m_appDelegate.fx + 20 + fTemp, SCREEN_HEIGHT / 2 - (45 + fTemp / 4 * 5) + menuItemItem0.position.y / 2 + menuItemItem0.contentSize.height / 4 * 3 * m_appDelegate.fy - 5 + fTemp / 4.f)];
    [lblGrandMaClickers setColor:ccBLACK];
    [self addChild:lblGrandMaClickers z:2];
    lblGrandMaClickers.tag = 1;
    
    lblGrandMaLevel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d", m_appDelegate.nGrandMaLevel] fontName:@"Arial" fontSize:fFontSize];
    [lblGrandMaLevel setPosition:ccp(menuItemItem0.contentSize.width * m_appDelegate.fx + 20 + fTemp, SCREEN_HEIGHT / 2 - (45 + fTemp / 4 * 5) + menuItemItem0.position.y / 2 + menuItemItem0.contentSize.height * m_appDelegate.fy + 4 + fTemp / 2.f)];
    [lblGrandMaLevel setColor:ccBLACK];
    [self addChild:lblGrandMaLevel z:2];

    lblCRobotClickers = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d", m_appDelegate.nCRobotClickers] fontName:@"Arial" fontSize:fFontSize];
    [lblCRobotClickers setPosition:ccp(menuItemItem0.contentSize.width / 2 * m_appDelegate.fx + 20 + fTemp, SCREEN_HEIGHT / 2 - (45 + fTemp / 4 * 5) * 2 + menuItemItem0.position.y / 2 + menuItemItem0.contentSize.height / 4 * 3 * m_appDelegate.fy - 5 + fTemp / 4.f)];
    [lblCRobotClickers setColor:ccBLACK];
    [self addChild:lblCRobotClickers z:2];
    lblCRobotClickers.tag = 2;

    lblCRobotLevel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d", m_appDelegate.nCRobotLevel] fontName:@"Arial" fontSize:fFontSize];
    [lblCRobotLevel setPosition:ccp(menuItemItem0.contentSize.width * m_appDelegate.fx + 20 + fTemp, SCREEN_HEIGHT / 2 - (45 + fTemp / 4 * 5) * 2 + menuItemItem0.position.y / 2 + menuItemItem0.contentSize.height * m_appDelegate.fy + 4+ fTemp / 2.f)];
    [lblCRobotLevel setColor:ccBLACK];
    [self addChild:lblCRobotLevel z:2];

    lblCookieFarmClickers = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d", m_appDelegate.nCookieFarmClickers] fontName:@"Arial" fontSize:fFontSize];
    [lblCookieFarmClickers setPosition:ccp(menuItemItem0.contentSize.width * m_appDelegate.fx / 2 + 20 + fTemp, SCREEN_HEIGHT / 2 - (45 + fTemp / 4 * 5) * 3 + menuItemItem0.position.y / 2 + menuItemItem0.contentSize.height / 4 * 3 * m_appDelegate.fy - 5 + fTemp / 4.f)];
    [lblCookieFarmClickers setColor:ccBLACK];
    [self addChild:lblCookieFarmClickers z:2];
    lblCookieFarmClickers.tag = 3;

    lblCookieFarmLevel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d", m_appDelegate.nCookieFarmLevel] fontName:@"Arial" fontSize:fFontSize];
    [lblCookieFarmLevel setPosition:ccp(menuItemItem0.contentSize.width * m_appDelegate.fx + 20 + fTemp, SCREEN_HEIGHT / 2 - (45 + fTemp / 4 * 5) * 3 + menuItemItem0.position.y / 2 + menuItemItem0.contentSize.height * m_appDelegate.fy + 4 + fTemp / 2.f)];
    [lblCookieFarmLevel setColor:ccBLACK];
    [self addChild:lblCookieFarmLevel z:2];

    lblCFactoryClickers = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d", m_appDelegate.nCFactoryClickers] fontName:@"Arial" fontSize:fFontSize];
    [lblCFactoryClickers setPosition:ccp(menuItemItem0.contentSize.width / 2 * m_appDelegate.fx + 20 + fTemp, SCREEN_HEIGHT / 2 - (45 + fTemp / 4 * 5) * 4 + menuItemItem0.position.y / 2 + menuItemItem0.contentSize.height / 4 * 3 * m_appDelegate.fy - 5 + fTemp / 4.f)];
    [lblCFactoryClickers setColor:ccBLACK];
    [self addChild:lblCFactoryClickers z:2];
    lblCFactoryClickers.tag = 4;

    lblCFactoryLevel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d", m_appDelegate.nCFactoryLevel] fontName:@"Arial" fontSize:fFontSize];
    [lblCFactoryLevel setPosition:ccp(menuItemItem0.contentSize.width * m_appDelegate.fx + 20 + fTemp, SCREEN_HEIGHT / 2 - (45 + fTemp / 4 * 5) * 4 + menuItemItem0.position.y / 2 + menuItemItem0.contentSize.height * m_appDelegate.fy + 4 + fTemp / 2.f)];
    [lblCFactoryLevel setColor:ccBLACK];
    [self addChild:lblCFactoryLevel z:2];
    
}

- (void) actionClose
{
    //game over ads here!!
    [[SNAdsManager sharedManager]giveMeGameOverAd];
    
    CCMoveBy* actionMove = [CCMoveBy actionWithDuration:0.8f position:ccp(0, -SCREEN_HEIGHT)];
    [self runAction:actionMove];
    
}

-(void) updateLabel:(NSUInteger)nIdx
{
    if (nIdx >= 100) return;
    
    switch (nIdx) {
        case 0:
            lblAutoClickClickers.string = [NSString stringWithFormat:@"%d", m_appDelegate.nAutoClickClickers];
            lblAutoClickLevel.string = [NSString stringWithFormat:@"%d", m_appDelegate.nAutoClickLevel];
            break;
        case 1:
            lblGrandMaClickers.string = [NSString stringWithFormat:@"%d", m_appDelegate.nGrandMaClickers];
            lblGrandMaLevel.string = [NSString stringWithFormat:@"%d", m_appDelegate.nGrandMaLevel];
            break;
        case 2:
            lblCRobotClickers.string = [NSString stringWithFormat:@"%d", m_appDelegate.nCRobotClickers];
            lblCRobotLevel.string = [NSString stringWithFormat:@"%d", m_appDelegate.nCRobotLevel];
            break;
        case 3:
            lblCookieFarmClickers.string = [NSString stringWithFormat:@"%d", m_appDelegate.nCookieFarmClickers];
            lblCookieFarmLevel.string = [NSString stringWithFormat:@"%d", m_appDelegate.nCookieFarmLevel];
            break;
        case 4:
            lblCFactoryClickers.string = [NSString stringWithFormat:@"%d", m_appDelegate.nCFactoryClickers];
            lblCFactoryLevel.string = [NSString stringWithFormat:@"%d", m_appDelegate.nCFactoryLevel];
            break;
            
        default:
            break;
    }
}

- (void) actionItem0
{
    if (m_appDelegate.nCurClickAmounts > m_appDelegate.nAutoClickClickers)
    {
        m_appDelegate.nCurClickAmounts -= m_appDelegate.nAutoClickClickers;
        
        m_appDelegate.nAutoClickLevel++;
        m_appDelegate.nTotalGameAutoClickClickers++;
        
        m_appDelegate.nAutoClickClickers += [m_appDelegate getChangedClickers:m_appDelegate.nAutoClickLevel clickerType:0];
    }
    else
    {
        [((HelloWorldLayer *)(self.parent)) showIAPViews];
        
        [[MKStoreManager sharedManager] buyFeatureAutoClicker];
    }
    
    m_appDelegate.fBaseCps = m_appDelegate.nAutoClickLevel * 0.1 + m_appDelegate.nGrandMaLevel * 0.3 + m_appDelegate.nCRobotLevel * 1.0f + m_appDelegate.nCookieFarmLevel * 3.1f + m_appDelegate.nCFactoryLevel * 6.0f;

    NSLog(@"base cps = %f, cur cps = %f", m_appDelegate.fBaseCps, m_appDelegate.fCurCps);
    
    m_appDelegate.fCurCps += 0.1f;
    
    lblAutoClickClickers.string = [NSString stringWithFormat:@"%d", m_appDelegate.nAutoClickClickers];
    lblAutoClickLevel.string = [NSString stringWithFormat:@"%d", m_appDelegate.nAutoClickLevel];
    
    [m_appDelegate saveParam];
    [m_appDelegate loadParam];
    
    [((HelloWorldLayer *)(self.parent)) updatePointerCps];
    
}

- (void) actionItem1
{
    if (m_appDelegate.nCurClickAmounts > m_appDelegate.nGrandMaClickers)
    {
        m_appDelegate.nCurClickAmounts -= m_appDelegate.nGrandMaClickers;

        m_appDelegate.nGrandMaLevel++;
        if (m_appDelegate.nAutoClickLevel == 0)
            m_appDelegate.nTotalGameAutoClickClickers++;
        
        m_appDelegate.nGrandMaClickers += [m_appDelegate getChangedClickers:m_appDelegate.nGrandMaLevel clickerType:1];
    }
    else
    {
        [((HelloWorldLayer *)(self.parent)) showIAPViews];
        
        [[MKStoreManager sharedManager] buyFeatureGrandma];
    }
    
    m_appDelegate.fBaseCps = m_appDelegate.nAutoClickLevel * 0.1 + m_appDelegate.nGrandMaLevel * 0.3 + m_appDelegate.nCRobotLevel * 1.0f + m_appDelegate.nCookieFarmLevel * 3.1f + m_appDelegate.nCFactoryLevel * 6.0f;

    m_appDelegate.fCurCps += 0.3f;

    lblGrandMaClickers.string = [NSString stringWithFormat:@"%d", m_appDelegate.nGrandMaClickers];
    lblGrandMaLevel.string = [NSString stringWithFormat:@"%d", m_appDelegate.nGrandMaLevel];
    
    [m_appDelegate saveParam];
    [m_appDelegate loadParam];
    
    [((HelloWorldLayer *)(self.parent)) updatePointerCps];
}

- (void) actionItem2
{
    if (m_appDelegate.nCurClickAmounts > m_appDelegate.nCRobotClickers)
    {
        m_appDelegate.nCurClickAmounts -= m_appDelegate.nCRobotClickers;

        m_appDelegate.nCRobotLevel++;
        if (m_appDelegate.nAutoClickLevel == 0)
            m_appDelegate.nTotalGameAutoClickClickers++;

        m_appDelegate.nCRobotClickers += [m_appDelegate getChangedClickers:m_appDelegate.nCRobotLevel clickerType:2];
    }
    else
    {
        [((HelloWorldLayer *)(self.parent)) showIAPViews];
        
        [[MKStoreManager sharedManager] buyFeatureCRobot];

    }

    m_appDelegate.fBaseCps = m_appDelegate.nAutoClickLevel * 0.1 + m_appDelegate.nGrandMaLevel * 0.3 + m_appDelegate.nCRobotLevel * 1.0f + m_appDelegate.nCookieFarmLevel * 3.1f + m_appDelegate.nCFactoryLevel * 6.0f;
    
    m_appDelegate.fCurCps += 1.f;

    lblCRobotClickers.string = [NSString stringWithFormat:@"%d", m_appDelegate.nCRobotClickers];
    lblCRobotLevel.string = [NSString stringWithFormat:@"%d", m_appDelegate.nCRobotLevel];

    [m_appDelegate saveParam];
    [m_appDelegate loadParam];
    
    [((HelloWorldLayer *)(self.parent)) updatePointerCps];
}

- (void) actionItem3
{
    if (m_appDelegate.nCurClickAmounts > m_appDelegate.nCookieFarmClickers)
    {
        m_appDelegate.nCurClickAmounts -= m_appDelegate.nCookieFarmClickers;

        m_appDelegate.nCookieFarmLevel++;
        if (m_appDelegate.nAutoClickLevel == 0)
            m_appDelegate.nTotalGameAutoClickClickers++;

        m_appDelegate.nCookieFarmClickers += [m_appDelegate getChangedClickers:m_appDelegate.nCookieFarmLevel clickerType:3];
    }
    else
    {
        [((HelloWorldLayer *)(self.parent)) showIAPViews];
        
        [[MKStoreManager sharedManager] buyFeatureCookieFarm];

    }
    
    m_appDelegate.fBaseCps = m_appDelegate.nAutoClickLevel * 0.1 + m_appDelegate.nGrandMaLevel * 0.3 + m_appDelegate.nCRobotLevel * 1.0f + m_appDelegate.nCookieFarmLevel * 3.1f + m_appDelegate.nCFactoryLevel * 6.0f;

    m_appDelegate.fCurCps += 3.1f;

    lblCookieFarmClickers.string = [NSString stringWithFormat:@"%d", m_appDelegate.nCookieFarmClickers];
    lblCookieFarmLevel.string = [NSString stringWithFormat:@"%d", m_appDelegate.nCookieFarmLevel];

    [m_appDelegate saveParam];
    [m_appDelegate loadParam];
    
    [((HelloWorldLayer *)(self.parent)) updatePointerCps];
}

- (void) actionItem4
{
    if (m_appDelegate.nCurClickAmounts > m_appDelegate.nCFactoryClickers)
    {
        m_appDelegate.nCurClickAmounts -= m_appDelegate.nCFactoryClickers;

        m_appDelegate.nCFactoryLevel++;
        if (m_appDelegate.nAutoClickLevel == 0)
            m_appDelegate.nTotalGameAutoClickClickers++;

        m_appDelegate.nCFactoryClickers += [m_appDelegate getChangedClickers:m_appDelegate.nCFactoryLevel clickerType:4];
    }
    else
    {
        [((HelloWorldLayer *)(self.parent)) showIAPViews];
        
        [[MKStoreManager sharedManager] buyFeatureCFactory];
    }
    
    m_appDelegate.fBaseCps = m_appDelegate.nAutoClickLevel * 0.1 + m_appDelegate.nGrandMaLevel * 0.3 + m_appDelegate.nCRobotLevel * 1.0f + m_appDelegate.nCookieFarmLevel * 3.1f + m_appDelegate.nCFactoryLevel * 6.0f;

    m_appDelegate.fCurCps += 6.f;

    lblCFactoryClickers.string = [NSString stringWithFormat:@"%d", m_appDelegate.nCFactoryClickers];
    lblCFactoryLevel.string = [NSString stringWithFormat:@"%d", m_appDelegate.nCFactoryLevel];

    [m_appDelegate saveParam];
    [m_appDelegate loadParam];
    
    [((HelloWorldLayer *)(self.parent)) updatePointerCps];
}

- (void) actionItem5
{
    
}

@end
