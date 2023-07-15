//
//  BuyUpgradeScene.m
//  moneky
//
//  Created by Sood, Abhishek on 9/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.

#import "BuyUpgradeScene.h"
#import "MonkeyStore.h"
#import "MonkeyClientData.h"
#import "Flurry.h"
#import "MonkeyNotificationDefinitions.h"
#import <StoreKit/StoreKit.h>
#import "ccUtils.h"

@implementation BuyUpgradeScene

#define kTagBuyMenu 1
#define kTagCloseMenu 2
#define kTagPriceLabel 3
#define kTagRetrivingLabel 4

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	BuyUpgradeScene *layer = [BuyUpgradeScene node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

-(id)init{
    self = [super init];
    if (self) {
        CCMenuItem* closeItem = [CCMenuItemSprite itemFromSpriteFileName:@"close.png" block:^(id sender) {
            [self endScene];
        }];
        [closeItem runAction:[CCRepeatForever actionWithAction:[CCUtils animationForButton]]];
        CCMenu* closeMenu = [CCMenu menuWithItems:closeItem, nil];
        
        [CCMenuItemFont setFontName:kMenuFont];
        [CCMenuItemFont setFontSize:35];
        CCMenuItemFont* buyItem = [CCMenuItemFont itemFromString:@"Buy Full Version!" target:self selector:@selector(buySelected)];
        buyItem.color = ccGREEN;
        [buyItem runAction:[CCRepeatForever actionWithAction:[CCUtils animationForButton]]];
        CCMenuItemFont* restoreItem = [CCMenuItemFont itemFromString:@"Restore" target:self selector:@selector(restoreSelected)];
        restoreItem.color = ccc3(128,128,255);
        [restoreItem runAction:[CCRepeatForever actionWithAction:[CCUtils animationForButton]]];
        CCMenu *buyMenu = [CCMenu menuWithItems:buyItem, restoreItem,  nil];
        [buyMenu alignItemsVertically];
        
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        buyMenu.position = ccp(winSize.width/2, -100);

        [self addChild:closeMenu z:1 tag:kTagCloseMenu];
        [self addChild:buyMenu z:1 tag:kTagBuyMenu];
        
        CCSprite* buyScreenTitle = [CCSprite spriteWithFile:@"buy.png"];
        buyScreenTitle.position = ccp(winSize.width/2,winSize.height*5/6);
        closeMenu.position = ccp(-90 +closeItem.boundingBox.size.width/2, buyScreenTitle.boundingBox.origin.y + buyScreenTitle.boundingBox.size.height);
        [self addChild:buyScreenTitle];
        
        NSString* buyText = @"Full version of the game includes:\n  -No Advertisements\n  -Unlock Hard, Very Hard and Impossible difficulty modes\n  -New Achievements to unlock\n  -Compete on new Leaderboards\n  -Thanks from the developers :)\n\n                    -Ginna & Babs";
        float size = 14;
        NSString* fontName = [MonkeyClientData getTextFontName];
        CGSize labelSize = [buyText sizeWithFont:[UIFont fontWithName:fontName size:size]constrainedToSize:CGSizeMake(winSize.width *9/10, winSize.height *2/3)];
        
        CCLabelTTF* buyTextLabel = [CCLabelTTF labelWithString:buyText dimensions:labelSize alignment:UITextAlignmentLeft fontName:fontName fontSize:size];
        float margin = winSize.height / 100;
        margin = margin *margin *margin/3;
        float height = buyScreenTitle.boundingBox.origin.y;
        height -= (buyTextLabel.boundingBox.size.height/2 + margin);
        buyTextLabel.position = ccp(winSize.width/2,height);
        buyTextLabel.color = ccWHITE;
        [self addChild:buyTextLabel];
        
        CCLabelTTF* contactingAppStore = [CCLabelTTF labelWithString:@"Contacting App Store..." fontName:fontName fontSize:size+1];
        height = buyTextLabel.position.y - buyTextLabel.boundingBox.size.height/2; 
        height -= (contactingAppStore.boundingBox.size.height/2 + margin);        
        contactingAppStore.position = ccp(winSize.width/2,height);
        contactingAppStore.color = kColorOrange;
        contactingAppStore.tag = kTagRetrivingLabel;
        id fadeIn = [CCFadeTo actionWithDuration:0.5 opacity:255];
        id fadeOut = [CCFadeTo actionWithDuration:0.5 opacity:140];
        [contactingAppStore runAction:[CCRepeatForever actionWithAction:[CCSequence actions:fadeIn, fadeOut, nil]]];
        [self addChild:contactingAppStore];


        [[MonkeyStore sharedStore] setDelegate:self];
        
        CCLabelTTF* priceLabel = [CCLabelTTF labelWithString:@"Only $0.99!!!" fontName:kMenuFont fontSize:20];
        height = buyScreenTitle.position.y - buyScreenTitle.boundingBox.size.height/2; 
        priceLabel.position = ccp(winSize.width*2/3,height);
        priceLabel.color = kColorGreen;
        priceLabel.opacity = 0;
        [self addChild:priceLabel z:2 tag:kTagPriceLabel];
    }
    return self;
}

-(void)onEnterTransitionDidFinish{
    [super onEnterTransitionDidFinish];
    [[self getChildByTag:kTagCloseMenu] runAction:[CCMoveBy actionWithDuration:kAnimationDuration position:ccp(100,0)]];
    [Flurry logEvent:@"Buy Screen shown"];
    [[MonkeyStore sharedStore] requestProductData];
}

-(void)hideBuyMenu{
    CCMenu* buyMenu = (CCMenu*)[self getChildByTag:kTagBuyMenu];
    buyMenu.isTouchEnabled = NO;
    [buyMenu runAction:[CCFadeOut actionWithDuration:kAnimationDuration]];
    [[self getChildByTag:kTagRetrivingLabel] setVisible:YES];
}

-(void)showBuyMenu{
    CCMenu* buyMenu = (CCMenu*)[self getChildByTag:kTagBuyMenu];
    buyMenu.isTouchEnabled = YES;
    [buyMenu runAction:[CCFadeIn actionWithDuration:kAnimationDuration]];
    [[self getChildByTag:kTagRetrivingLabel] setVisible:NO];
}

-(void)buySelected{
    [Flurry logEvent:@"Buy button tapped"];
    [self hideBuyMenu];
    [[MonkeyStore sharedStore] buy];
}

-(void)restoreSelected{
    [Flurry logEvent:@"Restore button tapped"];
    [self hideBuyMenu];
    [[MonkeyStore sharedStore] restore];
}

-(void)endScene{
    [[MonkeyStore sharedStore] setDelegate:nil];
    [[CCDirector sharedDirector] popScene];
    NSDictionary* dict =[NSDictionary dictionaryWithObjectsAndKeys:[MonkeyClientData sharedData].purchased,@"Game Purchased" ,nil];
    [Flurry logEvent:@"Buy Screen hiding" withParameters:dict];
}

#pragma mark -
#pragma mark Monkey Store delegate

-(void)monkeyStoreBuySuccessful:(MonkeyStore *)mkStore{
    [self endScene];
}

-(void)monkeyStoreRestoreSuccessful:(MonkeyStore *)mkStore{
    [self endScene];    
}

-(void)monkeyStoreBuyFailed:(MonkeyStore *)mkStore{
    [self performSelectorOnMainThread:@selector(showBuyMenu) withObject:nil waitUntilDone:NO];
}

-(void)monkeyStore:(MonkeyStore *)mkStore didGetProduct:(SKProduct *)product{
    if (product) {
        CCLabelTTF* priceLabel = (CCLabelTTF*) [self getChildByTag:kTagPriceLabel];
        priceLabel.string = [NSString stringWithFormat:@"Only %@", [self priceAsString:product]];
        priceLabel.scale = 10;
        priceLabel.opacity = 0;
        priceLabel.rotation =0;
        id action1 = [CCEaseExponentialOut actionWithAction:[CCScaleTo actionWithDuration:.7 scale:1]];
        id action2 = [CCFadeIn actionWithDuration:.5];
        id action3 = [CCEaseExponentialOut actionWithAction:[CCRotateTo actionWithDuration:.7 angle:3615]];
        id block = [CCCallBlock actionWithBlock:^{
            CCSprite* tex = [CCUtils createStroke:priceLabel size:1 color:ccYELLOW];
            [self addChild:tex z:1];
            tex.position = priceLabel.position;
            tex.rotation = priceLabel.rotation;
        }];
        id spawn = [CCSpawn actions:action1, action2, action3, nil];
        [priceLabel runAction:[CCSequence actions:spawn,block, nil]];
        
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        [[self getChildByTag:kTagBuyMenu] runAction:[CCMoveTo actionWithDuration:3*kAnimationDuration position:ccp(winSize.width/2,100)]];
        
        DLog(@"Product price: %@",priceLabel.string);
        NSDictionary* dict =[NSDictionary dictionaryWithObjectsAndKeys:product.price,@"Game price",priceLabel.string,@"Game price text" ,nil];
        [Flurry logEvent:@"Got buy product" withParameters:dict];
        [[self getChildByTag:kTagRetrivingLabel] setVisible:NO];
    }else {
        CCLabelTTF* priceLabel = (CCLabelTTF*) [self getChildByTag:kTagPriceLabel];        
        priceLabel.opacity = 0;
        [Flurry logEvent:@"Failed to get buy product"];
        postHintNotification(self, @"Error", @"Unable to contact app store. Please check your Network connection.", YES);
        CCLabelTTF* contactAppStore = (CCLabelTTF*)[self getChildByTag:kTagRetrivingLabel];
        [contactAppStore stopAllActions];
        contactAppStore.color = kColorRed;
        contactAppStore.string = @"Unable to contact app store.";
    }
}

- (NSString *) priceAsString:(SKProduct*)product{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [formatter setLocale:[product priceLocale]];
    
    NSString *str = [formatter stringFromNumber:[product price]];
    [formatter release];
    return str;
}

@end
