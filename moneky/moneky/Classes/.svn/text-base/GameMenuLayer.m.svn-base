//
//  HelloWorldLayer.m
//  moneky
//
//  Created by Sood, Abhishek on 8/30/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//


// Import the interfaces
#import "GameMenuLayer.h"
#import "GamePlayLayer.h"
#import "CardManager.h"
#import "MonkeyNotificationDefinitions.h"
#import "SimpleAudioEngine.h"
#import "MonkeyClientData.h"
#import "BuyUpgradeScene.h"
#import "InfoScreen.h"
#import "PlayMenuItem.h"
#import "Flurry.h"
#import "GameCenterManager.h"
#import "TrophyNode.h"
#import "ccUtils.h"
#import "SoundManager.h"

#define kTagDownArrow 1
#define kTagEffectsButton 2
#define kTagMusicButton 3
#define kTagInfoButton 4

#define kInfoMenuVerticalMargin 5

// HelloWorldLayer implementation
@implementation GameMenuLayer

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	GameMenuLayer *layer = [GameMenuLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

-(void)playTapped:(DifficultyMode)diffMode checkUpsell:(BOOL)check{
    NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithCapacity:2];
    [dict setValue:[MonkeyClientData getDifficultyString:diffMode] forKey:@"Difficulty Mode"];
    bool showBuyScreen = check && ![[MonkeyClientData sharedData].purchased boolValue];
    [dict setValue:[NSNumber numberWithBool:showBuyScreen] forKey:@"Show Buy Screen"];
    if (showBuyScreen) {
        [[CCDirector sharedDirector] pushScene:[CCTransitionCrossFade transitionWithDuration:kAnimationDuration scene:[BuyUpgradeScene scene]]];
    }else{
        [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1 scene:[GamePlayLayer scene:diffMode]]];
    }
    [Flurry logEvent:@"Start Game" withParameters:dict];
}

-(CCMenuItem*)getMenuItemForDifficulty:(DifficultyMode)diff checkUpsell:(BOOL)check{
    PlayMenuItem* item = [[[PlayMenuItem alloc] initFromString:[MonkeyClientData getDifficultyString:diff] block:^(id sender) {
        [self playTapped:diff checkUpsell:check];
    }] autorelease];
    item.color = [MonkeyClientData colorForDifficulty:diff];
    if (check && ![[MonkeyClientData sharedData].purchased boolValue]) {        
        CCLabelTTF* lockText = [CCLabelTTF labelWithString:@"[Full Version]" fontName:kSpacedFont fontSize:22];
        lockText.position = ccp(item.boundingBox.size.width/2,item.boundingBox.size.height/2);
        lockText.rotation = -5;
        lockText.color = ccBLACK;
        [item addChild:lockText z:2];
        [_lockItems addObject:lockText];
    }
    return item;
}

-(void)initPlayMenu{
    [CCMenuItemFont setFontSize:35];
    CCMenuItem *veryEasy = [self getMenuItemForDifficulty:DifficultyModeVeryEasy checkUpsell:NO];
    CCMenuItem *easy = [self getMenuItemForDifficulty:DifficultyModeEasy checkUpsell:NO];
    CCMenuItem *normal = [self getMenuItemForDifficulty:DifficultyModeNormal checkUpsell:NO];
    CCMenuItem *hard = [self getMenuItemForDifficulty:DifficultyModeHard checkUpsell:YES];
    CCMenuItem *veryHard = [self getMenuItemForDifficulty:DifficultyModeVeryHard checkUpsell:YES];
    CCMenuItem *impossible = [self getMenuItemForDifficulty:DifficultyModeImpossible checkUpsell:YES];
    
    _playMenu = [[CCMenu menuWithItems:veryEasy,easy,normal,hard,veryHard,impossible, nil] retain];
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    _playMenu.position = ccp(winSize.width/2, winSize.height/2 - 50);
    [_playMenu alignItemsVertically];
    _playMenu.opacity = 0;
    _playMenu.isTouchEnabled = NO;
    [self addChild:_playMenu];
}

-(void)initMainMenu{
    if (![GameCenterManager isGameCenterAvailable]) {
        _playMenu.isTouchEnabled = YES;
        _playMenu.opacity = 255;
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        [_gameTitle runAction:[CCMoveTo actionWithDuration:kAnimationDuration position:ccp(winSize.width/2,winSize.height*5/6)]];
        return;
    }
    
    [CCMenuItemFont setFontName:kMenuFont];        
    [CCMenuItemFont setFontSize:35];
    [_play release];
    _play = [[CCMenuItemFont itemFromString:@"Play" target:self selector:@selector(playSelected)] retain];
    [_play setColor:kColorGreen];
    float duration = 0.3;
    id rotateCW = [CCRotateTo actionWithDuration:duration angle:-5];
    id scaleUp = [CCScaleTo actionWithDuration:duration scale:1.02];
    id rotateOrig = [CCRotateTo actionWithDuration:duration angle:0];
    id rotateCCW = [CCRotateTo actionWithDuration:duration angle:5];
    id scaleDown = [CCScaleTo actionWithDuration:duration scale:0.98];
    id spawn1 = [CCSpawn actions:rotateCW, scaleUp, nil];
    id spawn2 = [CCSpawn actions:rotateOrig, scaleDown, nil];
    id spawn3 = [CCSpawn actions:rotateCCW, scaleUp, nil];
    id sequence = [CCSequence actions:spawn1,spawn2,spawn3, spawn2 , nil]; 
    [_play runAction:[CCRepeatForever actionWithAction:sequence]];
    
    CCMenuItemFont *leaderBoards = nil;
    CCMenuItemFont *achievements = nil;
    CCMenuItemFont *resetAchievements = nil;
    
    leaderBoards = [CCMenuItemFont itemFromString:@"Leaderboards" target:self selector:@selector(showLeaderBoards)];
    [leaderBoards setColor:kColorOrange];
    achievements = [CCMenuItemFont itemFromString:@"Achievements" target:self selector:@selector(showAchievements)];
    [achievements setColor:kColorRed];
    [CCMenuItemFont setFontSize:20];
    resetAchievements = [CCMenuItemFont itemFromString:@"Reset Achievements" target:self selector:@selector(resetAchievements)];
    [resetAchievements setColor:ccBLACK];

    _gameMenu = [[CCMenu menuWithItems:_play, leaderBoards, achievements, resetAchievements, nil] retain];
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    _gameMenu.position = ccp(winSize.width/2, winSize.height/2 - 100);
    [_gameMenu alignItemsVertically];
    [self addChild:_gameMenu];   
}

-(void)initInfoMenu{
    _infoMenuShown = NO;
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    CCMenuItemSprite* infoButton = [CCMenuItemSprite itemFromSpriteFileName:@"info.png" block:^(id sender) {
        [[CCDirector sharedDirector] pushScene:[CCTransitionFadeDown transitionWithDuration:0.5 scene:[InfoScreen scene]]];
    }];
    infoButton.tag = kTagInfoButton;
    infoButton.opacity = 0;
    infoButton.isEnabled = NO;
    [infoButton runAction:[CCRepeatForever actionWithAction:[CCUtils animationForButton]]];
    
    CCMenuItemSprite* downArrow = [CCMenuItemSprite itemFromSpriteFileName:@"up_arrow.png" block:^(id sender) {
        [self toggleInfoMenu];
    }];
    downArrow.rotation = 180;
    downArrow.tag = kTagDownArrow;
    [downArrow runAction:[CCRepeatForever actionWithAction:[CCUtils animationForButton]]];
    
    CCMenuItemSprite* musicButtonOn = [CCMenuItemSprite itemFromSpriteFileName:@"audio_on.png" block:nil];
    CCMenuItemSprite* musicButtonOff = [CCMenuItemSprite itemFromSpriteFileName:@"audio_off.png" block:nil];
    CCMenuItemToggle* musicButton = [CCMenuItemToggle itemWithBlock:^(id sender) {
        bool musicOn = ![[MonkeyClientData sharedData].musicOn boolValue];
        [MonkeyClientData sharedData].musicOn = [NSNumber numberWithBool:musicOn];
        [SimpleAudioEngine sharedEngine].backgroundMusicVolume = musicOn?1:0;
        if (musicOn) {
            [[SimpleAudioEngine sharedEngine] resumeBackgroundMusic];
            if (![[SimpleAudioEngine sharedEngine] isBackgroundMusicPlaying]) {
                [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"21685__summonhue__04-pollie-soft.mp3" loop:YES];
            }
        }
    } items:musicButtonOn, musicButtonOff, nil];
    musicButton.tag = kTagMusicButton;
    musicButton.isEnabled = NO;
    musicButton.opacity =0;
    musicButton.scale = 0.9;
    [musicButton runAction:[CCRepeatForever actionWithAction:[CCUtils animationForButton]]];
    musicButton.selectedIndex = [[MonkeyClientData sharedData].musicOn boolValue]?0:1;
    [SimpleAudioEngine sharedEngine].backgroundMusicVolume = [[MonkeyClientData sharedData].musicOn boolValue]?1:0;
    
    CCMenuItemSprite* effectsButtonOn = [CCMenuItemSprite itemFromSpriteFileName:@"effects_on.png" block:nil];
    CCMenuItemSprite* effectsButtonOff = [CCMenuItemSprite itemFromSpriteFileName:@"effects_off.png" block:nil];
    CCMenuItemToggle* effectsButton = [CCMenuItemToggle itemWithBlock:^(id sender) {
        bool effectsOn = ![[MonkeyClientData sharedData].effectsOn boolValue];
        [MonkeyClientData sharedData].effectsOn = [NSNumber numberWithBool:effectsOn];
        [SimpleAudioEngine sharedEngine].effectsVolume = effectsOn?1:0;
        if (effectsOn) {
            [[SoundManager sharedSoundManager] playCheerSound];
        }
    } items:effectsButtonOn, effectsButtonOff, nil];
    effectsButton.tag = kTagEffectsButton;
    effectsButton.isEnabled = NO;
    effectsButton.opacity = 0;
    effectsButton.scale = 0.9;
    [effectsButton runAction:[CCRepeatForever actionWithAction:[CCUtils animationForButton]]];
    effectsButton.selectedIndex = [[MonkeyClientData sharedData].effectsOn boolValue]?0:1;
    [SimpleAudioEngine sharedEngine].effectsVolume = [[MonkeyClientData sharedData].effectsOn boolValue]?1:0;
    
    _infoMenu = [[CCMenu menuWithItems: infoButton, musicButton, effectsButton, downArrow, nil] retain];
    _infoMenu.position = ccp(winSize.width -kInfoMenuVerticalMargin -downArrow.contentSize.width/2 ,winSize.height * 9/10);
    [self addChild:_infoMenu z:1];
}

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init])) {
        _lockItems = [[NSMutableArray alloc] initWithCapacity:3];
        CGSize winSize = [[CCDirector sharedDirector] winSize];

        CCSprite* background = [CCSprite spriteWithFile:@"background.png"];
        background.anchorPoint = ccp(0,1);
        background.position = ccp(0,winSize.height);
        [self addChild:background z:-4];

        [self addChild:[TrophyNode node] z:-3];
        
        _gameTitle = [CCSprite spriteWithFile:@"title.png"];
        _gameTitle.position = ccp(winSize.width/2,winSize.height*2/3);
        [self addChild:_gameTitle z:-2];
                
        if ([GameCenterManager isGameCenterAvailable]) {
            CCMenuItem *back = nil;
            back = [CCMenuItemSprite itemFromSpriteFileName:@"back_button.png" block:^(id sender) {
                [self backSelected];
            }];
            [back runAction:[CCRepeatForever actionWithAction:[CCUtils animationForButton]]];
            _backMenu = [[CCMenu menuWithItems:back, nil] retain];
            _backMenu.position = ccp(winSize.width /10 ,winSize.height * 9/10);
            _backMenu.opacity = 0;
            _backMenu.isTouchEnabled = NO;
            [self addChild:_backMenu];            
        }
        [self initInfoMenu];
        [self initPlayMenu];
        [self initMainMenu];
	}
	return self;
}

-(void)backSelected{
    _playMenu.isTouchEnabled = NO;
    _backMenu.isTouchEnabled = NO;
    _gameMenu.isTouchEnabled = YES;    
    _infoMenu.isTouchEnabled = YES;
    [_playMenu runAction:[CCFadeOut actionWithDuration:kAnimationDuration]];
    [_backMenu runAction:[CCFadeOut actionWithDuration:kAnimationDuration]];
    [_gameMenu runAction:[CCFadeIn actionWithDuration:2*kAnimationDuration]];
    [[_infoMenu getChildByTag:kTagDownArrow] runAction:[CCFadeIn actionWithDuration:2*kAnimationDuration]];
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    [_gameTitle runAction:[CCMoveTo actionWithDuration:kAnimationDuration position:ccp(winSize.width/2,winSize.height*2/3)]];
    [Flurry logEvent:@"Back to main menu"];
}

-(void)toggleInfoMenu{
    CCMenuItem* effects = (CCMenuItem*)[_infoMenu getChildByTag:kTagEffectsButton];
    CCMenuItem* music = (CCMenuItem*)[_infoMenu getChildByTag:kTagMusicButton];
    CCMenuItem* info = (CCMenuItem*)[_infoMenu getChildByTag:kTagInfoButton];
    CCMenuItem* down = (CCMenuItem*)[_infoMenu getChildByTag:kTagDownArrow];

    CGFloat x = down.position.x;
    CGFloat y = down.position.y;

    if (!_infoMenuShown) {
        CGFloat height = kInfoMenuVerticalMargin + down.contentSize.height;
        [down runAction:[CCRotateTo actionWithDuration:kAnimationDuration angle:0]];
        [effects runAction:[CCSpawn actions:[CCFadeIn actionWithDuration:kAnimationDuration],
                                                                [CCMoveTo actionWithDuration:kAnimationDuration position:ccp(x,y-height)], nil]];
        [music runAction:[CCSpawn actions:[CCFadeIn actionWithDuration:kAnimationDuration],
                                                                [CCMoveTo actionWithDuration:kAnimationDuration position:ccp(x,y-2*height)], nil]];
        [info runAction:[CCSpawn actions:[CCFadeIn actionWithDuration:kAnimationDuration],
                                                                [CCMoveTo actionWithDuration:kAnimationDuration position:ccp(x,y-3*height)], nil]];
    }else{
        [down runAction:[CCRotateTo actionWithDuration:kAnimationDuration angle:180]];
        [effects runAction:[CCSpawn actions:[CCFadeOut actionWithDuration:kAnimationDuration],
                                                                [CCMoveTo actionWithDuration:kAnimationDuration position:down.position], nil]];
        [music runAction:[CCSpawn actions:[CCFadeOut actionWithDuration:kAnimationDuration],
                                                                [CCMoveTo actionWithDuration:kAnimationDuration position:down.position], nil]];
        [info runAction:[CCSpawn actions:[CCFadeOut actionWithDuration:kAnimationDuration],
                                                                [CCMoveTo actionWithDuration:kAnimationDuration position:down.position], nil]];
    }
    _infoMenuShown = !_infoMenuShown;
    music.isEnabled = _infoMenuShown;
    effects.isEnabled = _infoMenuShown;
    info.isEnabled = _infoMenuShown;
}

-(void)onEnter{
    [super onEnter];
    bool bought = [[MonkeyClientData sharedData].purchased boolValue];
    if (_infoMenuShown) {
        [self toggleInfoMenu];
    }
    
    if(bought){
        for (CCLabelTTF*item in _lockItems) {
            [item removeFromParentAndCleanup:YES];
        }
        [_lockItems removeAllObjects];
    }
}

-(void)playSelected{
    if (_infoMenuShown) {
        [self toggleInfoMenu];
    }
    _playMenu.isTouchEnabled = YES;
    _backMenu.isTouchEnabled = YES;
    _gameMenu.isTouchEnabled = NO;
    _infoMenu.isTouchEnabled = NO;
    [_playMenu runAction:[CCFadeIn actionWithDuration:2*kAnimationDuration]];
    [_backMenu runAction:[CCFadeIn actionWithDuration:2*kAnimationDuration]];
    [_gameMenu runAction:[CCFadeOut actionWithDuration:kAnimationDuration]];
    [[_infoMenu getChildByTag:kTagDownArrow] runAction:[CCFadeOut actionWithDuration:kAnimationDuration]];
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    [_gameTitle runAction:[CCMoveTo actionWithDuration:kAnimationDuration position:ccp(winSize.width/2,winSize.height*5/6)]];
    [Flurry logEvent:@"Play Selected"];
}

-(void)showLeaderBoards{
    [[NSNotificationCenter defaultCenter] postNotificationName:MonkeyNotificationShowLeaderboards object:nil];
    [Flurry logEvent:@"Show Leaderboards Selected"];
}

-(void)showAchievements{
    [[NSNotificationCenter defaultCenter] postNotificationName:MonkeyNotificationShowAchievements object:nil];    
    [Flurry logEvent:@"Show Achievements Selected"];
}

-(void)resetAchievements{
    [[NSNotificationCenter defaultCenter] postNotificationName:MonkeyNotificationResetAchievements object:nil];    
    [Flurry logEvent:@"Reset Achievements Selected"];
}

-(void)onEnterTransitionDidFinish{
    [super onEnterTransitionDidFinish];
    [[NSNotificationCenter defaultCenter] postNotificationName:MonkeyNotificationGameMenuShown object:nil];
    [[SimpleAudioEngine sharedEngine] resumeBackgroundMusic];
    if (![[SimpleAudioEngine sharedEngine] isBackgroundMusicPlaying]) {
        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"21685__summonhue__04-pollie-soft.mp3" loop:YES];
    }
    [Flurry logEvent:@"Game Menu Screen Shown"];
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	
	// don't forget to call "super dealloc"
    [_backMenu release];
    [_playMenu release];
    [_gameMenu release];
    [_infoMenu release];
    [_gameTitle release];
    [_lockItems release];
    [_play release];
	[super dealloc];
}
@end
