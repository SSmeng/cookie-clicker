//
//  HelloWorldLayer.m
//  Cookie Clickers
//
//  Created by Cookiedev on 10/9/13.
//  Copyright __MyCompanyName__ 2013. All rights reserved.
//


// Import the interfaces
#import "HelloWorldLayer.h"
#import "AppDelegate.h"
#import "MKStoreManager.h"
#import "StoreLayer.h"
#import "SimpleAudioEngine.h"

#define sliding_strings1                        @"I'm all about cookies."
#define sliding_strings2                        @"I just can't stop eating cookies. I think I seriously need help."
#define sliding_strings3                        @"I guess I have a cookie problem."
#define sliding_strings4                        @"I'm not addicted to cookies. That's just speculation by fans with too much free time."
#define sliding_strings5                        @"My upcoming album contains 3 songs about cookies."
#define sliding_strings6                        @"I've had dreams about cookies 3 nights in a row now. I'm a bit worried honestly."
#define sliding_strings7                        @"accusations of cookie abuse are only vile slander."
#define sliding_strings8                        @"cookies really helped me when I was feeling low."
#define sliding_strings9                        @"cookies are the secret behind my perfect skin."
#define sliding_strings10                       @"cookies helped me stay sane while filming my upcoming movie."
#define sliding_strings11                       @"cookies helped me stay thin and healthy."
#define sliding_strings12                        @"I'll say one word, just one : cookies."

#define TEMP_ANGLE                              10.f

// HelloWorldLayer implementation
@implementation HelloWorldLayer

@synthesize storeLayer;
@synthesize nButtonClicksNum;

+(CCScene *) scene
{
	CCScene *scene = [CCScene node];
	
	HelloWorldLayer *layer = [HelloWorldLayer node];
	
	[scene addChild: layer];
	
	return scene;
}

// on "init" you need to initialize your instance
-(id) init
{
	if( (self=[super init])) {
        m_appDelegate.m_gameScene = self;
        
        self.isTouchEnabled = YES;
        
        bChangeRadius = false;
        
        arrayScrollText = [[NSMutableArray alloc] initWithObjects:sliding_strings1, sliding_strings2, sliding_strings3, sliding_strings4, sliding_strings5, sliding_strings6, sliding_strings7, sliding_strings8, sliding_strings9, sliding_strings10, sliding_strings11, sliding_strings12, nil];
        
        nButtonClicksNum = 0;
        fBaseCps = m_appDelegate.fBaseCps;
        
        fInitialAngle = 0.f;
        nAutoClickersIdx = 0;
        arrayPointers = [[NSMutableArray alloc] init];
        
        [self createBg];
        
        [self createButtons];
        
        [self createPizza];
        
        [self createPointer];
        
        [self createAccessories];
        
        [self createMilk];
        
		storeLayer = [[StoreLayer alloc] init];
        storeLayer.position = ccp(0, -SCREEN_HEIGHT);
        [self addChild:storeLayer z:10];
        
        m_appDelegate.fBaseCps = m_appDelegate.nAutoClickLevel * 0.1 + m_appDelegate.nGrandMaLevel * 0.3f + m_appDelegate.nCRobotLevel * 1.0f + m_appDelegate.nCookieFarmLevel * 3.1f + m_appDelegate.nCFactoryLevel * 6.0f;

        [self schedule:@selector(scheduleClickers) interval:1.f];
        
        [self schedule:@selector(scheduleShowCookieClickers) interval:0.01f];
        [self schedule:@selector(showPointer) interval:0.01f];
        
        [self updatePointerCps];
        
        spriteMask = [CCSprite spriteWithFile:@"mask.png"];
        [spriteMask setOpacity:100.f];
        [spriteMask setScaleX:m_appDelegate.fx];
        [spriteMask setScaleY:m_appDelegate.fy];
        
        if (SCREEN_HEIGHT == 568)
            [spriteMask setScaleY:1136.f / 960.f];
        
        spriteMask.position = ccp(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2);
        
        [self addChild:spriteMask z:100];
        spriteMask.visible = NO;
        
        thinkIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	}
    
	return self;
}

-(void) showIAPViews
{
    self.isTouchEnabled = NO;
    spriteMask.visible = YES;
    
    UIView* view = [[CCDirector sharedDirector] openGLView];
    [view addSubview:thinkIndicator];
    thinkIndicator.center = ccp(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2);
    thinkIndicator.hidden = NO;
    [thinkIndicator startAnimating];
}

-(void) hideIAPViews
{
    self.isTouchEnabled = YES;
    spriteMask.visible = NO;
    
    [thinkIndicator stopAnimating];
    thinkIndicator.hidden = YES;
    [thinkIndicator removeFromSuperview];
}

- (void) scheduleShowCookieClickers
{
    lblClickAmounts.string = [NSString stringWithFormat:@"%d cookies", m_appDelegate.nCurClickAmounts];
    
    fBaseCps = m_appDelegate.fBaseCps;
    
    lblCps.string = [NSString stringWithFormat:@"%.01f per second", m_appDelegate.fCurCps];
}

- (void) createPointer
{
    NSUInteger nPointerNums = 360 / TEMP_ANGLE;
    
    if ([arrayPointers count] > 0)
    {
        for (NSUInteger nIdx = 0; nIdx < [arrayPointers count]; nIdx++)
        {
            CCSprite* tmpSprite = (CCSprite *)[arrayPointers objectAtIndex:nIdx];
            tmpSprite.visible = NO;
            [self removeChild:tmpSprite cleanup:YES];
        }
        
        [arrayPointers removeAllObjects];
        
    }

    for (NSUInteger nIdx = 0; nIdx < nPointerNums; nIdx++)
    {
        CCSprite* spritePointer = [CCSprite spriteWithFile:@"pointer.png"];
        [spritePointer setScaleX:m_appDelegate.fx];
        [spritePointer setScaleY:m_appDelegate.fy];
        
        spritePointer.position = ccp(menuItemPizza.position.x + fRadius[nIdx] * cosf(fInitialAngle * M_PI / 180.f + nIdx * TEMP_ANGLE * M_PI / 180.f), menuItemPizza.position.y + fRadius[nIdx] * sinf(fInitialAngle * M_PI / 180.f + nIdx * TEMP_ANGLE * M_PI / 180.f));
        
        spritePointer.rotation = 180 - nIdx * TEMP_ANGLE - fInitialAngle;
        
        [self addChild:spritePointer z:5];
        spritePointer.visible = NO;
        
        if (nIdx < m_appDelegate.nTotalGameAutoClickClickers)
            spritePointer.visible = YES;
        
        [arrayPointers addObject:spritePointer];
    }
}

- (void) showPointer
{
    fInitialAngle += 0.2f;

    if (fInitialAngle >= 360.f)
        fInitialAngle = 0.f;
    
    [self createPointer];
}

-(void) clickAutoClickers
{
    if (bChangeRadius)
        return;
    
    nAutoClickersIdx++;
    
    if (nAutoClickersIdx >= m_appDelegate.nTotalGameAutoClickClickers)
        nAutoClickersIdx = 0;
    
    CCSprite* tmpSprite = (CCSprite *)[arrayPointers objectAtIndex:nAutoClickersIdx];
    if (tmpSprite.visible)
    {
        nChangeRadiusCounter = 0;
        bChangeRadius = true;
        [self schedule:@selector(changeRadius) interval:0.001f];
    }
    
}

-(void) changeRadius
{
    CGFloat fTempRadius= 3.0f;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        fTempRadius = 5.f;
    
    nChangeRadiusCounter++;
    if (nChangeRadiusCounter <= 2)
        fRadius[nAutoClickersIdx] -= fTempRadius;
    else
        fRadius[nAutoClickersIdx] += fTempRadius;
    if (nChangeRadiusCounter == 2)
        m_appDelegate.nCurClickAmounts++;
    
    if (nChangeRadiusCounter >= 4)
    {
        [self unschedule:@selector(changeRadius)];
        
        bChangeRadius = false;

    }
}

-(void) updatePointerCps
{
    fBaseCps = m_appDelegate.fBaseCps;

    [self unschedule:@selector(clickAutoClickers)];
    
    if (fBaseCps == 0.f) return;
    
    CGFloat fUpdatedInterval = 1.f / fBaseCps;
    
    [self schedule:@selector(clickAutoClickers) interval:fUpdatedInterval];
}

- (void) createBg
{
    CCSprite* spriteBg = [CCSprite spriteWithFile:@"background.png"];
    [spriteBg setScaleX:m_appDelegate.fx];
    [spriteBg setScaleY:m_appDelegate.fy];
    if (m_appDelegate.bRetina)
        [spriteBg setScaleY:1136.f / 960.f];
    
    [spriteBg setPosition:ccp(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2)];
    [self addChild:spriteBg z:0];
    
}

- (void) createButtons
{
    CCSprite* spriteNor = [CCSprite spriteWithFile:@"rank.png"];
    CCSprite* spriteSel = [CCSprite spriteWithFile:@"rank.png"];
    spriteSel.scale = 1.1f;
    
    CCMenuItemSprite* menuItemRank = [CCMenuItemSprite itemFromNormalSprite:spriteNor selectedSprite:spriteSel target:self selector:@selector(actionRank)];
    [menuItemRank setScaleX:m_appDelegate.fx];
    [menuItemRank setScaleY:m_appDelegate.fy];
//    menuItemRank.position = ccp(menuItemRank.contentSize.width / 2 * m_appDelegate.fx + 10, menuItemRank.contentSize.height / 2 * m_appDelegate.fy + 10);

    spriteNor = [CCSprite spriteWithFile:@"shop.png"];
    spriteSel = [CCSprite spriteWithFile:@"shop.png"];
    spriteSel.scale = 1.1f;

    CCMenuItemSprite* menuItemShop = [CCMenuItemSprite itemFromNormalSprite:spriteNor selectedSprite:spriteSel target:self selector:@selector(actionShop)];
    [menuItemShop setScaleX:m_appDelegate.fx];
    [menuItemShop setScaleY:m_appDelegate.fy];
//    menuItemShop.position = ccp(SCREEN_WIDTH - menuItemShop.contentSize.width / 2 * m_appDelegate.fx - 10, menuItemShop.contentSize.height / 2 * m_appDelegate.fy + 10);

    spriteNor = [CCSprite spriteWithFile:@"removeads.png"];
    spriteSel = [CCSprite spriteWithFile:@"removeads.png"];
    spriteSel.scale = 1.1f;
    
    CCMenuItemSprite* menuItemRemoveAds = [CCMenuItemSprite itemFromNormalSprite:spriteNor selectedSprite:spriteSel target:self selector:@selector(actionRemoveAds)];
    [menuItemRemoveAds setScaleX:m_appDelegate.fx];
    [menuItemRemoveAds setScaleY:m_appDelegate.fy];
//    menuItemRemoveAds.position = ccp(SCREEN_WIDTH - menuItemShop.contentSize.width / 2 * m_appDelegate.fx - 10, menuItemShop.contentSize.height / 2 * m_appDelegate.fy + 10);

    spriteNor = [CCSprite spriteWithFile:@"restore.png"];
    spriteSel = [CCSprite spriteWithFile:@"restore.png"];
    spriteSel.scale = 1.1f;
    
    CCMenuItemSprite* menuItemRestore = [CCMenuItemSprite itemFromNormalSprite:spriteNor selectedSprite:spriteSel target:self selector:@selector(actionRestorePurchase)];
    [menuItemRestore setScaleX:m_appDelegate.fx];
    [menuItemRestore setScaleY:m_appDelegate.fy];
//    menuItemRestore.position = ccp(SCREEN_WIDTH - menuItemShop.contentSize.width / 2 * m_appDelegate.fx - 10, menuItemShop.contentSize.height / 2 * m_appDelegate.fy + 10);

    CCMenu* menu = [CCMenu menuWithItems:menuItemRank, menuItemRemoveAds, menuItemRestore, menuItemShop, nil];
    
    CGFloat fPadding = 15.f;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        fPadding = 30.f;
    
    [menu alignItemsHorizontallyWithPadding:fPadding];
    
    [menu setPosition:ccp(SCREEN_WIDTH / 2, menuItemShop.contentSize.height / 2 * m_appDelegate.fy + 10)];
    
    [self addChild:menu z:30];
}

-(void) actionRemoveAds
{
    [self showIAPViews];
    
    [[MKStoreManager sharedManager] buyFeatureRemoveAds];
}

-(void) actionRestorePurchase
{
    [self showIAPViews];
    
    [[MKStoreManager sharedManager] restore];
}

-(void) createMilk
{
    spriteMilk[0] = [CCSprite spriteWithFile:@"milk.png"];
    spriteMilk[0].anchorPoint = ccp(0, 0);
    [spriteMilk[0] setScaleX:m_appDelegate.fx];
    [spriteMilk[0] setScaleY:m_appDelegate.fy];
    [spriteMilk[0] setPosition:ccp(0, -spriteMilk[0].contentSize.height / 2 * m_appDelegate.fy)];

    [self addChild:spriteMilk[0] z:10];

    spriteMilk[1] = [CCSprite spriteWithFile:@"milk.png"];
    spriteMilk[1].anchorPoint = ccp(0, 0);
    [spriteMilk[1] setScaleX:m_appDelegate.fx];
    [spriteMilk[1] setScaleY:m_appDelegate.fy];
    [spriteMilk[1] setPosition:ccp(SCREEN_WIDTH - 2, -spriteMilk[1].contentSize.height / 2 * m_appDelegate.fy)];
    
    [self addChild:spriteMilk[1] z:10];

    [self schedule:@selector(moveMilk) interval:0.2f];
}

-(void) moveMilk
{
    float bgPosX;
	float bgPosY;
	for (int i = 0; i < 2; i++) {
		bgPosX = spriteMilk[i].position.x;
		bgPosY = spriteMilk[i].position.y;
		spriteMilk[i].position = ccp(bgPosX - 10, bgPosY);
        
		if (spriteMilk[i].position.x <= -SCREEN_WIDTH + 2 ) {
			spriteMilk[i].position = ccp(spriteMilk[i].position.x + 2 * SCREEN_WIDTH - 4, spriteMilk[i].position.y);
		}
		
	}

    /*
    for (NSUInteger nIdx = 0; nIdx < 2; nIdx++)
    {
        if ( (spriteMilk[nIdx].position.x) > SCREEN_WIDTH / 2 * 3)
            spriteMilk[nIdx].position = ccp(-SCREEN_WIDTH / 2 + 2, spriteMilk[nIdx].position.y);
        
        spriteMilk[nIdx].position = ccp(spriteMilk[nIdx].position.x + 10.f, spriteMilk[nIdx].position.y);
    }
    */
}

- (void) createPizza
{
    CCSprite* spriteNor = [CCSprite spriteWithFile:@"cookie.png"];
    CCSprite* spriteSel = [CCSprite spriteWithFile:@"cookie.png"];
    spriteSel.scaleX = 1.02f;
    spriteSel.scaleY = 1.02f;
    
    menuItemPizza = [CCMenuItemSprite itemFromNormalSprite:spriteNor selectedSprite:spriteSel target:self selector:@selector(actionGame)];
    
    [menuItemPizza setScaleX:m_appDelegate.fx];
    [menuItemPizza setScaleY:m_appDelegate.fx];
    menuItemPizza.position = ccp(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2);
    
    CCMenu* menu = [CCMenu menuWithItems:menuItemPizza, nil];
    [menu setPosition:ccp(0, 0)];
    
    [self addChild:menu z:5];
 
    spritePizzaRay = [CCSprite spriteWithFile:@"cookie_rays.png"];
    [spritePizzaRay setScaleX:m_appDelegate.fx];
    [spritePizzaRay setScaleY:m_appDelegate.fy];
    
    [spritePizzaRay setPosition:ccp(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2)];
    [self addChild:spritePizzaRay z:4];
    spritePizzaRay.rotation = 0.f;
    
    CCRotateBy* actionRotate = [CCRotateBy actionWithDuration:0.6f angle:5.0f];
    CCRepeatForever* actionRepeat = [CCRepeatForever actionWithAction:actionRotate];
    [spritePizzaRay runAction:actionRepeat];
    
    for (NSUInteger nRadiusIdx = 0; nRadiusIdx < 100; nRadiusIdx++)
        fRadius[nRadiusIdx] = menuItemPizza.contentSize.width / 2 * m_appDelegate.fx + 15;
}

-(void) createAccessories
{
    nScrollTextPointer = 0;
    lblScrollText = [CCLabelTTF labelWithString:[arrayScrollText objectAtIndex:nScrollTextPointer] fontName:@"Arial" fontSize:16];
    lblScrollText.position = ccp(SCREEN_WIDTH + lblScrollText.contentSize.width, SCREEN_HEIGHT - 16);
    [self addChild:lblScrollText z:3];
    
    CCSprite* spriteBanner = [CCSprite spriteWithFile:@"counter_mask.png"];
    [spriteBanner setScaleX:m_appDelegate.fx];
    [spriteBanner setScaleY:m_appDelegate.fy];
    spriteBanner.position = ccp(SCREEN_WIDTH / 2, SCREEN_HEIGHT - 30 - spriteBanner.contentSize.height / 2 * m_appDelegate.fy);
    
    [self addChild:spriteBanner z:7];
    
    CGFloat fFontSize = 30.f;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        fFontSize = 60.f;
    
    lblClickAmounts = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d cookies", m_appDelegate.nCurClickAmounts] fontName:@"Arial" fontSize:fFontSize];
    lblClickAmounts.position = ccp(SCREEN_WIDTH / 2, spriteBanner.position.y + spriteBanner.contentSize.height / 4 * m_appDelegate.fy);
    [self addChild:lblClickAmounts z:8];
    
    lblCps = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%.01f per second", m_appDelegate.fCurCps] fontName:@"Arial" fontSize:fFontSize / 2.f];
    lblCps.position = ccp(SCREEN_WIDTH / 2, spriteBanner.position.y - spriteBanner.contentSize.height / 4 * m_appDelegate.fy);
    [self addChild:lblCps z:8];
    
    [self schedule:@selector(showScheduleScrollText) interval:0.2f];
}

-(void) showScheduleScrollText
{
    lblScrollText.position = ccp(lblScrollText.position.x - 10, lblScrollText.position.y);
    
    if (lblScrollText.position.x < -lblScrollText.contentSize.width)
    {
        lblScrollText.position = ccp(SCREEN_WIDTH + lblScrollText.contentSize.width, lblScrollText.position.y);
        
        nScrollTextPointer++;
        if (nScrollTextPointer > 11)
            nScrollTextPointer = 0;
        
        lblScrollText.string = [arrayScrollText objectAtIndex:nScrollTextPointer];
    }
}

-(void) actionGame{
    
    [[SimpleAudioEngine sharedEngine] playEffect:@"click.caf"];
//    [(AVPlayer *)[m_appDelegate.arraySound objectAtIndex:0] play];

    CGFloat fCookieWidth = menuItemPizza.contentSize.width / 2 * m_appDelegate.fx;
    CGFloat fCookieHeight = menuItemPizza.contentSize.height / 2 * m_appDelegate.fy;
    
    CGFloat fRandomSign1 = arc4random() % 3 - 1;
    CGFloat fRandomSign2 = arc4random() % 3 - 1;
    
    CGFloat fRandomWidth = arc4random() % ((int)fCookieWidth);
    CGFloat fRandomHeight = arc4random() % ((int)fCookieHeight);
    
    CGFloat fEffectX = menuItemPizza.position.x + fRandomWidth * fRandomSign1;
    CGFloat fEffectY = menuItemPizza.position.y + fRandomHeight * fRandomSign2;
    
    CGFloat nFontSize = 30, fMoveTime = 1.5f;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        nFontSize = 60.f;
        fMoveTime = 3.2f;
    }
    
    NSUInteger nEffectNum = 1;
    if (m_appDelegate.fCurCps > 5.7f)
        nEffectNum = 2;
    if (m_appDelegate.fCurCps > 20.f)
        nEffectNum = 3;
    if (m_appDelegate.fCurCps > 30.f)
        nEffectNum = 4;
    
    CCLabelTTF* lblEffect = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"+%d", nEffectNum] fontName:@"Arial" fontSize:nFontSize];
    [lblEffect setColor:ccWHITE];
    [lblEffect setPosition:ccp(fEffectX, fEffectY)];
    
    [self addChild:lblEffect z:6];
    
    CCMoveBy* actionMove = [CCMoveBy actionWithDuration:fMoveTime position:ccp(0, SCREEN_HEIGHT)];
    CCCallFuncN* callback = [CCCallFuncN actionWithTarget:self selector:@selector(removeEffectLabel:)];
    [lblEffect runAction:[CCSequence actions:actionMove, callback, nil]];
    
    m_appDelegate.nCurClickAmounts += nEffectNum;
    nButtonClicksNum += 1;
    NSLog(@"Button Click = %d", nButtonClicksNum);
    
    lblClickAmounts.string = [NSString stringWithFormat:@"%d cookies", m_appDelegate.nCurClickAmounts];
    
    m_appDelegate.fCurCps = (nButtonClicksNum / 2 + nButtonClicksNum % 2) * 0.5f + nButtonClicksNum / 2 * 0.4f;
    lblCps.string = [NSString stringWithFormat:@"%.01f per second", m_appDelegate.fCurCps];
    
    NSUInteger nManyClicks = 0;
    if (m_appDelegate.fCurCps > 0.f)
        nManyClicks = 0;
    if (m_appDelegate.fCurCps > 5.7f)
        nManyClicks = 1;
    if (m_appDelegate.fCurCps > 20.f)
        nManyClicks = 2;
    if (m_appDelegate.fCurCps > 30.f)
        nManyClicks = 3;
    if (m_appDelegate.fCurCps > 40.f)
        nManyClicks = 4;

    spriteMilk[0].position = ccp(spriteMilk[0].position.x, spriteMilk[0].position.y + m_appDelegate.fCurCps / 6.0f);
    spriteMilk[1].position = ccp(spriteMilk[1].position.x, spriteMilk[1].position.y + m_appDelegate.fCurCps / 6.0f);
    
    for (NSUInteger nCookieNums = 0; nCookieNums <= nManyClicks; nCookieNums++)
    {
        CCSprite* spriteManyClickers = [CCSprite spriteWithFile:@"cookie_many0.png"];
        spriteManyClickers.scaleX = m_appDelegate.fx;
        spriteManyClickers.scaleY = m_appDelegate.fy;
        
        CGFloat fSpriteManyClickers;
        fSpriteManyClickers = arc4random() % ((int)(SCREEN_WIDTH  - spriteManyClickers.contentSize.width * m_appDelegate.fx)) + spriteManyClickers.contentSize.width / 2 * m_appDelegate.fx;
        
        spriteManyClickers.position = ccp(fSpriteManyClickers, SCREEN_HEIGHT + spriteManyClickers.contentSize.height / 2 * m_appDelegate.fy);
        [self addChild:spriteManyClickers z:2];
        
        CCMoveBy* actionMoveManyClickers = [CCMoveBy actionWithDuration:3.0f position:ccp(0, -SCREEN_HEIGHT - spriteManyClickers.contentSize.height * m_appDelegate.fy)];
        CCCallFuncN* callbackAfterMove = [CCCallFuncN actionWithTarget:self selector:@selector(removeManyClickersBackground:)];
        
        [spriteManyClickers runAction:[CCSequence actions:actionMoveManyClickers, callbackAfterMove, nil]];
    }

    if (nButtonClicksNum % 10 == 0)
        [[SimpleAudioEngine sharedEngine] playEffect:@"click2.caf"];

}

- (void) removeEffectLabel:(id)sender
{
    CCSprite* tmpSprite = (CCSprite *)sender;
    tmpSprite.visible = NO;
    
    [self removeChild:tmpSprite cleanup:YES];
}

-(void) scheduleClickers
{
    [self unschedule:@selector(descreaseClickers)];

    if(nButtonClicksNum >= 0)
    {
        [self schedule:@selector(descreaseClickers) interval:0.2f];
    }
    
}

-(void) removeManyClickersBackground:(id) sender
{
    CCSprite* tmpSprite = (CCSprite *)sender;
    tmpSprite.visible = NO;
    
    [self removeChild:tmpSprite cleanup:YES];
}

-(void) descreaseClickers
{
    if (m_appDelegate.fCurCps <= fBaseCps)
    {
        m_appDelegate.fCurCps = fBaseCps;
        
//        m_appDelegate.fCurCps = (nButtonClicksNum / 2 + nButtonClicksNum % 2) * 0.5f + nButtonClicksNum / 2 * 0.4f;
        lblCps.string = [NSString stringWithFormat:@"%.01f per second", m_appDelegate.fCurCps];
        
        return;
    }

    m_appDelegate.fCurCps = (nButtonClicksNum / 2 + nButtonClicksNum % 2) * 0.5f + nButtonClicksNum / 2 * 0.4f;
    lblCps.string = [NSString stringWithFormat:@"%.01f per second", m_appDelegate.fCurCps];

    nButtonClicksNum--;
    
    spriteMilk[0].position = ccp(spriteMilk[0].position.x, spriteMilk[0].position.y - m_appDelegate.fCurCps / 5.0f);
    spriteMilk[1].position = ccp(spriteMilk[1].position.x, spriteMilk[1].position.y - m_appDelegate.fCurCps / 5.0f);

    for (NSUInteger nIdx = 0; nIdx < 2; nIdx++)
    {
        if (spriteMilk[nIdx].position.y <= -spriteMilk[nIdx].contentSize.height / 5 * m_appDelegate.fy)
            spriteMilk[nIdx].position = ccp(spriteMilk[nIdx].position.x , -spriteMilk[1].contentSize.height / 5 * m_appDelegate.fy);
    }
}

- (void) actionRank
{
    [m_appDelegate abrirLDB];
}

- (void) actionShop
{
    CCMoveBy* actionMove = [CCMoveBy actionWithDuration:0.8f position:ccp(0, SCREEN_HEIGHT)];
    [storeLayer runAction:actionMove];
}

- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	
	// don't forget to call "super dealloc"
	[super dealloc];
}
@end
