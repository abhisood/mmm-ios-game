//
//  InfoScreen.m
//  moneky
//
//  Created by Sood, Abhishek on 10/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "InfoScreen.h"
#import "MonkeyClientData.h"
#import "Flurry.h"
#import "ccUtils.h"

#define kTagCloseMenu 1

@implementation InfoScreen

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	InfoScreen *layer = [InfoScreen node];
	
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
        closeMenu.tag = kTagCloseMenu;
        [self addChild:closeMenu];
                
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        float height = [[[MonkeyClientData sharedData] purchased] boolValue]? 50 : 20;
        closeMenu.position = ccp(-90 +closeItem.boundingBox.size.width/2, winSize.height - closeItem.boundingBox.size.height/2 -height/2);
                
        CCSprite* title = [CCSprite spriteWithFile:@"title.png"];
        title.position = ccp(winSize.width/2,winSize.height - title.boundingBox.size.height/2 - height );
        [self addChild:title];
        
        NSString* versionText = [NSString stringWithFormat:@"v%@", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]];
        CCLabelTTF* versionLabel = [CCLabelTTF labelWithString:versionText fontName:kMenuFont fontSize:16];
        height = title.position.y - title.boundingBox.size.height/2; 
        height -= (versionLabel.boundingBox.size.height/2);        
        versionLabel.position = ccp(winSize.width*3/4,height);
        versionLabel.color = kColorLightBlue;
        [self addChild:versionLabel];

        NSString* infoText = @"Bob the Monkey has fled from the circus and the trainer is chasing him. Match the cards of fate before Bob is caught.\n\n√ Made with Cocos2D\n√ Sounds taken from www.freesound.org\n√ Thanks to PhreaKsAccount for Sound Effects";
        float size = 14;
        NSString* fontName = [MonkeyClientData getTextFontName];
        
        CGSize labelSize = [infoText sizeWithFont:[UIFont fontWithName:fontName size:size]constrainedToSize:CGSizeMake(winSize.width *9/10, winSize.height *2/3)];
        CCLabelTTF* infoTextLabel = [CCLabelTTF labelWithString:infoText dimensions:labelSize alignment:UITextAlignmentLeft fontName:fontName fontSize:size];
        height = title.position.y - title.boundingBox.size.height/2; 
        height -= (infoTextLabel.boundingBox.size.height/2 + 25);        
        infoTextLabel.position = ccp(winSize.width/2,height);
        infoTextLabel.color = ccWHITE;
        [self addChild:infoTextLabel];
        
        NSString* madeByText =@"Concept by Garima Sood\nProgramming by Abhishek Sood\nArt by Anupam Das";
        labelSize = [madeByText sizeWithFont:[UIFont fontWithName:fontName size:size]constrainedToSize:CGSizeMake(winSize.width *9/10, winSize.height *2/3)];
        CCLabelTTF* madeByTextLabel = [CCLabelTTF labelWithString:madeByText dimensions:labelSize alignment:UITextAlignmentCenter fontName:fontName fontSize:size];
        height = infoTextLabel.position.y - infoTextLabel.boundingBox.size.height/2; 
        height -= (madeByTextLabel.boundingBox.size.height/2 + 25);        
        madeByTextLabel.position = ccp(winSize.width/2,height);
        madeByTextLabel.color = ccWHITE;
        [self addChild:madeByTextLabel];
    }
    return self;
}

-(void)onEnterTransitionDidFinish{
    [super onEnterTransitionDidFinish];
    [[self getChildByTag:kTagCloseMenu] runAction:[CCMoveBy actionWithDuration:kAnimationDuration position:ccp(100,0)]];
    [Flurry logEvent:@"Info screen displayed"];
}

-(void)endScene{
    [[CCDirector sharedDirector] popScene];
}

@end
