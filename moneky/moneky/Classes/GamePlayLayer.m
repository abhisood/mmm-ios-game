//
//  GamePlayLayer.m
//  moneky
//
//  Created by Sood, Abhishek on 9/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GamePlayLayer.h"
#import "CardManager.h"
#import "Card.h"
#import "GameMenuLayer.h"
#import "MonkeyNotificationDefinitions.h"
#import "Appirater.h"
#import "SimpleAudioEngine.h"
#import "SoundManager.h"
#import "NSMutableArray+shuffle.h"
#import "GameScoreLayer.h"
#import "MonkeyClientData.h"
#import "Flurry.h"
#import "CCUtils.h"

#define kMenuHeight 50
#define kHudZ 3
#define kPauseMenuZ 4
#define kGameZ 0

#define kTagStrokeTex 1
#define kComboLabelStroke 2

#define kTagPauseMenu 10
#define kTagPauseBackground 11
#define kTagPauseMenuBackground 12
#define kTagPauseText 13

@interface GamePlayLayer (private)
-(void)checkWin;
-(void)hideLastCardShown:(Card*)cardTapped;
@end

@implementation GamePlayLayer

+(id)scene:(DifficultyMode)diff{
    // 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	GamePlayLayer *layer = [GamePlayLayer node];
	layer.difficultyMode = diff;
	// add layer as a child to scene
	[scene addChild: layer];
    return scene;
}

#pragma mark -
#pragma mark init events

-(void)initPauseButtonMenu{
    CGSize winsize = [[CCDirector sharedDirector] winSize];
    _pauseButton = [CCMenuItemSprite itemFromSpriteFileName:@"pause.png" block:^(id sender) {
        [self pauseGame];
    }];
    _pauseButton.scale = 0.5;
    _pauseButtonMenu= [[CCMenu menuWithItems:_pauseButton, nil] retain];

    _pauseButtonMenu.position = ccp(winsize.width - 5 - _pauseButton.boundingBox.size.width/2, winsize.height - _pauseButton.boundingBox.size.height/2);
    _pauseButtonMenu.opacity = 0;
    _pauseButtonMenu.isTouchEnabled = NO;
    [self addChild:_pauseButtonMenu z:kHudZ];    
}

-(void)initPauseMenu{
    CGSize winsize = [[CCDirector sharedDirector] winSize];
    CCMenuItemSprite* play = [CCMenuItemSprite itemFromSpriteFileName:@"play.png" block:^(id sender) {
        [self resumeGame];
    }];
    [play runAction:[CCRepeatForever actionWithAction:[CCUtils animationForButton]]];
    CCMenuItemSprite* restart = [CCMenuItemSprite itemFromSpriteFileName:@"restart.png" block:^(id sender) {
        [self reset];
    }];
    [restart runAction:[CCRepeatForever actionWithAction:[CCUtils animationForButton]]];
    restart.scale = 0.90;
    CCMenuItemSprite* mainMenu = [CCMenuItemSprite itemFromSpriteFileName:@"menu.png" block:^(id sender) {
        [self mainMenuSelected];
    }];
    [mainMenu runAction:[CCRepeatForever actionWithAction:[CCUtils animationForButton]]];
    
    CCMenu *pauseMenu = [CCMenu menuWithItems: restart,mainMenu,play, nil];
    [pauseMenu alignItemsHorizontallyWithPadding:50];
    pauseMenu.position = ccp(winsize.width/2,winsize.height + kMenuHeight/2);
    _pauseMenuLayer = [[CCLayer node] retain];
    CCSprite* menuBackground = [CCSprite spriteWithFile:@"menu_background.png" rect:CGRectMake(0, 0, winsize.width, kMenuHeight)];
    menuBackground.position = pauseMenu.position;
    
    CCSprite* pauseBack = [CCSprite spriteWithFile:@"paused_background.png"];
    pauseBack.opacity = 0;
    pauseBack.position = ccp(winsize.width/2, winsize.height/2);
    CCLabelTTF* pausedText = [CCLabelTTF labelWithString:@"PAUSED" fontName:[MonkeyClientData getTextFontName] fontSize:35];
    pausedText.color = kColorOrange;
    pausedText.position = pauseBack.position;
    pausedText.opacity = 0;
    [_pauseMenuLayer addChild:pauseBack z:-1 tag:kTagPauseBackground];
    [_pauseMenuLayer addChild:pausedText z:0 tag:kTagPauseText];
    [_pauseMenuLayer addChild:menuBackground z:-1 tag:kTagPauseMenuBackground];
    [_pauseMenuLayer addChild:pauseMenu z:0 tag:kTagPauseMenu];
    [self addChild:_pauseMenuLayer z: kPauseMenuZ];
    
}

-(void)initHud{
    CGSize winsize = [[CCDirector sharedDirector] winSize];
    NSString* fontName = [MonkeyClientData getTextFontName];
    
    NSString* str = @"Match the cards\nand\nsave the monkey!";
    float fontSize = 20;
    CGSize size = [str sizeWithFont:[UIFont fontWithName:fontName size:fontSize] constrainedToSize:CGSizeMake(winsize.width * 3/4, winsize.height/2)];
    _matchTheCardsLabel = [[CCLabelTTF labelWithString:str dimensions:size alignment:UITextAlignmentCenter lineBreakMode:UILineBreakModeWordWrap fontName:fontName fontSize:fontSize] retain];
    _matchTheCardsLabel.position = ccp(winsize.width/2,winsize.height/2);
    _matchTheCardsLabel.color = ccORANGE;
    CCSprite* tex = [CCUtils createStroke:_matchTheCardsLabel size:3 color:ccBLACK];
    tex.position = _matchTheCardsLabel.position;
    [self addChild:tex z:kHudZ tag:kTagStrokeTex];
    [self addChild:_matchTheCardsLabel z:kHudZ];
    
    _comboLabel = [[CCLabelTTF labelWithString:@"Unbelievable!" fontName:fontName fontSize:20] retain];
    _comboLabel.visible = NO;
    _comboLabel.color = ccORANGE;
    [self addChild:_comboLabel z:kHudZ];
    
    _hurryUpLabel = [[CCLabelTTF labelWithString:@"Hurry Up!!" fontName:fontName fontSize:35] retain];
    _hurryUpLabel.position = ccp(winsize.width/2,25);
    _hurryUpLabel.scale = 0;
    [self addChild:_hurryUpLabel z:kHudZ];
    
    _movesLabel = [[CCLabelTTF alloc] initWithString:@"Moves:" dimensions:CGSizeMake(100,_pauseButton.boundingBox.size.height) alignment:UITextAlignmentCenter fontName:fontName fontSize:14];
    float height = winsize.height - 15;
    _movesLabel.position = ccp(winsize.width/2, height);
    _movesLabel.color = kColorOrange;
    [self addChild:_movesLabel z:kHudZ];
    
    _difficultyLabel = [[CCLabelTTF alloc] initWithString:@"Impossible" dimensions:CGSizeMake(100,_pauseButton.boundingBox.size.height) alignment:UITextAlignmentLeft fontName:fontName fontSize:14];
    _difficultyLabel.position = ccp(5+ _difficultyLabel.boundingBox.size.width/2,height);
    [self addChild:_difficultyLabel z:kHudZ];
    _comboLabel.position = ccp(winsize.width/4
                               ,_movesLabel.position.y);
}

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init])) {
        _inputEnabled = NO;
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        CCSprite *background = [CCSprite spriteWithFile:@"background.png"];
        background.anchorPoint = ccp(0,1);
        background.position = ccp(0,winSize.height);
        [self addChild:background z:-2];
        
        [self initPauseButtonMenu];
        [self initPauseMenu];
        [self initHud];
	}
	return self;
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
    [_comboLabel release];
    [_cardManager release];
    [_monkeyRunNode release];
    [_pauseMenuLayer release];
    [_pauseButtonMenu release];
    [_pauseButton release];
    [_movesLabel release];
    [_difficultyLabel release];
    [_hurryUpLabel release];
    [_matchTheCardsLabel release];
	// don't forget to call "super dealloc"
	[super dealloc];
}

#pragma mark -
#pragma mark life cycle events

-(void)onEnter{
    [super onEnter];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reset) name:MonkeyNotificationLeavingApp object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pauseGame) name:MonkeyNotificationAdRunning object:nil];
    _difficultyLabel.visible = NO;
    _matchTheCardsLabel.opacity = 255;
}

-(void)onEnterTransitionDidFinish{
    [super onEnterTransitionDidFinish];
    [Flurry logEvent:@"Game play screen shown"];
    [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:INT_MIN+1 swallowsTouches:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:MonkeyNotificationGamePlayShown object:nil];
    [self reset];

    [_matchTheCardsLabel runAction:[CCSequence actions:[CCDelayTime actionWithDuration:2], [CCFadeOut actionWithDuration:0.5], nil]];
    [[self getChildByTag:kTagStrokeTex] runAction:[CCSequence actions:[CCDelayTime actionWithDuration:2], [CCFadeOut actionWithDuration:0.5], nil]];
}

-(void)onExit{
    [super onExit];
    [[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark -
#pragma mark start and stop

-(void)startMonkeyRun{
    _pauseButtonMenu.opacity = 255;
    _pauseButtonMenu.isTouchEnabled = YES;
    _monkeyRunNode.isPaused = NO;
    _inputEnabled = YES;
    [Flurry logEvent:@"New Game Started"];
}

-(void)setDifficultyMode:(DifficultyMode)difficultyMode{
    if (!_cardManager) {
        _monkeyRunNode = [[MonkeyRunNode alloc] init];
        _monkeyRunNode.delegate = self;
        [self addChild:_monkeyRunNode z:kGameZ];        
        
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        _cardManager = [[CardManager alloc] initWithScreenRect:CGRectMake(5, 55, winSize.width-10, winSize.height-kMenuHeight - 5 - _pauseButton.boundingBox.size.height)
                                                DifficultyMode:difficultyMode];
        [self addChild:_cardManager z:kGameZ];        
    }else {
        _cardManager.difficultyMode = difficultyMode;
    }
}

-(DifficultyMode)difficultyMode{
    return _cardManager.difficultyMode;
}

-(void)pauseGame{
    if (!_inputEnabled) return;
    _inputEnabled = NO;
    _monkeyRunNode.isPaused = YES;
    _pauseButton.isEnabled = NO;
    [_pauseButtonMenu runAction:[CCFadeOut actionWithDuration:kAnimationDuration]];
    
    id moveAction = [CCMoveBy actionWithDuration:kAnimationDuration position:ccp(0, -kMenuHeight)];
    [[_pauseMenuLayer getChildByTag:kTagPauseMenu] runAction:[[moveAction copy] autorelease]];
    [[_pauseMenuLayer getChildByTag:kTagPauseMenuBackground] runAction:[[moveAction copy] autorelease]];
    id fadeInAction = [CCFadeIn actionWithDuration:kAnimationDuration];
    [[_pauseMenuLayer getChildByTag:kTagPauseText] runAction:[[fadeInAction copy] autorelease]];
    [[_pauseMenuLayer getChildByTag:kTagPauseBackground] runAction:[[fadeInAction copy] autorelease]];

    [Flurry logEvent:@"Game Paused"];
}

-(void)resumeGameActions{
    id moveAction = [CCMoveBy actionWithDuration:kAnimationDuration position:ccp(0, kMenuHeight)];
    [[_pauseMenuLayer getChildByTag:kTagPauseMenu] runAction:[[moveAction copy] autorelease]];
    [[_pauseMenuLayer getChildByTag:kTagPauseMenuBackground] runAction:[[moveAction copy] autorelease]];
    id fadeOutAction = [CCFadeOut actionWithDuration:kAnimationDuration];
    [[_pauseMenuLayer getChildByTag:kTagPauseText] runAction:[[fadeOutAction copy] autorelease]];
    [[_pauseMenuLayer getChildByTag:kTagPauseBackground] runAction:[[fadeOutAction copy] autorelease]];
}

-(void)resumeGame{
    _inputEnabled = YES;
   
    _monkeyRunNode.isPaused = NO;
    [_pauseButtonMenu runAction:[CCFadeIn actionWithDuration:kAnimationDuration]];
    _pauseButton.isEnabled = YES;
    
    [self resumeGameActions];
  
    [Flurry logEvent:@"Game Resumed"];
}

-(void)reset{
    [self stopAllActions];
    [_hurryUpLabel stopAllActions];
    [_comboLabel stopAllActions];
    [_pauseButtonMenu stopAllActions];
    
    [[SimpleAudioEngine sharedEngine] resumeBackgroundMusic];
    [_monkeyRunNode reset];
    [_cardManager reset];

    _pauseButtonMenu.opacity = 0;
    _pauseButtonMenu.isTouchEnabled = NO;
    _monkeyRunNode.difficultyAdjustment = [MonkeyClientData getTimeForLevel:_cardManager.difficultyMode];
    _monkeyRunNode.isPaused = YES;    
    _monkeyRunNode.totalTimeTaken = 0;
    _comboScore = 0;
    _comboLabel.visible = NO;
    _currentCombo = 0;
    _moves = 0;
    _hurryUpLabel.scale = 0;
    [_movesLabel setString:@"Moves: "];
    [_cardManager showAllCards];
    [_lastCardShown release];
    _lastCardShown = nil;

    [_movesLabel setString:@"Moves: "];

    [_difficultyLabel setString:[MonkeyClientData getDifficultyString:self.difficultyMode]];    
    _difficultyLabel.visible = YES;
    _difficultyLabel.color = [MonkeyClientData colorForDifficulty:self.difficultyMode];

    id wait1 = [CCDelayTime actionWithDuration:3];
    id wait2 = nil;
    if (_cardManager.difficultyMode == DifficultyModeVeryHard || _cardManager.difficultyMode == DifficultyModeImpossible) {
        wait2 = [CCSpawn actions:[CCDelayTime actionWithDuration:_cardManager.columns], [self shuffleCardsAction], nil];        
    }else{
        wait2 = [CCDelayTime actionWithDuration:1];        
    }
    
    id wait3 = [CCSpawn actions:[CCDelayTime actionWithDuration:3], 
                [CCCallBlock actionWithBlock:^{
                    [self startCountdown];
                }], 
                nil];
    id block1 = [CCCallBlock actionWithBlock:^{
        [_cardManager hideAllCards];
    }];
    
    id wait4 = [CCDelayTime actionWithDuration:kAnimationDuration];    
    id block2 = [CCCallBlock actionWithBlock:^{
        [self startMonkeyRun];
    }];    

    [self runAction:[CCSequence actions:wait1, wait2, wait3, block1, wait4, block2, nil]];
    
    if (!_pauseButton.isEnabled) {
        [self resumeGameActions];
        _pauseButton.isEnabled = YES;
    }
    [Flurry logEvent:@"Game Reset"];
}

#pragma mark -
#pragma mark touch events

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint location = [self convertTouchToNodeSpace:touch];
#if DEBUG
    if (CGRectContainsPoint(CGRectMake(280, 0, 320, 40), location)) {
        _comboScore = (_cardManager.rows * _cardManager.columns) /2;
        _comboScore = (_comboScore *(_comboScore + 1)) *50;
        [self showScore];
        return YES;
    }
    if (CGRectContainsPoint(CGRectMake(0, 0, 40, 40), location)) {
        [self monkeyCaught];
        return YES;
    }
#endif
    if (!_inputEnabled || _cardManager.isWon || _monkeyRunNode.isPaused) return NO;
    
    return CGRectContainsPoint(_cardManager.screenRect, location);
}
- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
}
- (void)ccTouchCancelled:(UITouch *)touch withEvent:(UIEvent *)event {
}
- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    if (!_inputEnabled || _cardManager.isWon || _monkeyRunNode.isPaused) return;
    
    CGPoint location = [self convertTouchToNodeSpace:touch];
        
    Card* cardTapped = [_cardManager cardContainingPoint:location];
    if (!cardTapped || cardTapped.isShown) {
        return;
    }
    _moves++;
    [_movesLabel setString:[NSString stringWithFormat:@"Moves: %d",_moves]];
    [cardTapped setIsShown:YES animated:YES];
    if (!_lastCardShown) {
        _lastCardShown = [cardTapped retain];
    }else {
        if ([_lastCardShown matchesCard:cardTapped]) {
            [self increaseCurrentCombo];
            _comboScore+= (_currentCombo *100);
            _lastCardShown.isMatched = YES;
            cardTapped.isMatched = YES;
            _inputEnabled = YES;
            CCNode* emitter = [CCUtils starParticleSystem];
            emitter.position = ccpAdd(_lastCardShown.position, ccp(_lastCardShown.boundingBox.size.width/2,_lastCardShown.boundingBox.size.height/2));
            [self addChild:emitter];
            emitter = [CCUtils starParticleSystem];
            emitter.position = ccpAdd(cardTapped.position, ccp(cardTapped.boundingBox.size.width/2,cardTapped.boundingBox.size.height/2));
            [self addChild:emitter];
            [_lastCardShown release];
            _lastCardShown = nil;
            [self checkWin];
            //[_monkeyRunNode speedUpMonkey];
        }else {
            _currentCombo = 0;
            _inputEnabled = NO;
            [[SoundManager sharedSoundManager] playFailSound];
            //[_monkeyRunNode speedUpChaser];
            id wait = [CCDelayTime actionWithDuration:1];
            id block = [CCCallBlock actionWithBlock:^{
                [self hideLastCardShown:cardTapped];
            } ];
            [self runAction:[CCSequence actions:wait, block, nil]];
        }
    }
}

#pragma mark -
#pragma mark win lose

-(void)checkWin{
    if (_cardManager.isWon) {
        _pauseButtonMenu.opacity = 0;
        _pauseButtonMenu.isTouchEnabled = NO;
        [[NSNotificationCenter defaultCenter] postNotificationName:MonkeyNotificationGamePlayNormal object:nil];
        DLog(@"You win: %f",[_monkeyRunNode distanceBetweenMonkeyAndChaser]);
        [self showScore];
        [Appirater userDidSignificantEvent:NO];
        [[SimpleAudioEngine sharedEngine] pauseBackgroundMusic];
        [[SoundManager sharedSoundManager] playLastCheerSound];
    }else{
        [[SoundManager sharedSoundManager] playCheerSound];
    }
}

-(void)showScore{
    _monkeyRunNode.isPaused = YES;
    int movesScore = ((2.5*_cardManager.rows * _cardManager.columns) - _moves) * 2 *[MonkeyClientData getTimeForLevel:_cardManager.difficultyMode];
    if (movesScore< 0) {
        movesScore = 0;
    }
    int timeScore = ([MonkeyClientData getTimeForLevel:_cardManager.difficultyMode] - _monkeyRunNode.totalTimeTaken) *100;
    if (timeScore<0) {
        timeScore =0;
    }
    timeScore += [_monkeyRunNode distanceBetweenMonkeyAndChaser]*100 * [MonkeyClientData getTimeForLevel:_cardManager.difficultyMode];    
    
    CCScene *scene = [CCScene node];
	GameScoreLayer *layer = [GameScoreLayer node];
    [layer setTimeBonus:timeScore comboScore:_comboScore moveBonus:movesScore difficultyMode:self.difficultyMode];
    [layer setTimeTaken:_monkeyRunNode.totalTimeTaken];
    [layer setMovesTaken:_moves minimumMoves:_cardManager.rows * _cardManager.columns];
	[scene addChild: layer];

    [[CCDirector sharedDirector] replaceScene:[CCTransitionFadeDown transitionWithDuration:1 scene:scene]];
    
    NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:[_monkeyRunNode distanceBetweenMonkeyAndChaser]],@"Distance between monkey and chaser", 
                          [NSNumber numberWithInt:movesScore],@"Move Score",
                          [NSNumber numberWithInt:timeScore], @"Time Score",
                          [MonkeyClientData getDifficultyString:self.difficultyMode], @"Difficulty",nil];
    [Flurry logEvent:@"Game Won" withParameters:dict];
}

-(void)hideLastCardShown:(Card*)cardTapped{
    [_lastCardShown setIsShown:NO animated:YES];
    [cardTapped setIsShown:NO animated:YES];
    [_lastCardShown release];
    _lastCardShown = nil;
    _inputEnabled = YES;
}

-(void)monkeyCaught{
    _inputEnabled = NO;
    _monkeyRunNode.isPaused = YES;
    [[SimpleAudioEngine sharedEngine] pauseBackgroundMusic];

    CCScene *scene = [CCScene node];
	GameScoreLayer *layer = [GameScoreLayer node];
    [[SoundManager sharedSoundManager] playGameLostSound];
    [layer showLoseMenu:self.difficultyMode];
	[scene addChild: layer];

    [[CCDirector sharedDirector] replaceScene:[CCTransitionFadeDown transitionWithDuration:1 scene:scene]];
    
    NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          [MonkeyClientData getDifficultyString:self.difficultyMode], @"Difficulty",nil];
    [Flurry logEvent:@"Game Lost" withParameters:dict];
}

-(void)chaserNear{
    [[NSNotificationCenter defaultCenter] postNotificationName:MonkeyNotificationGamePlayCrucial object:nil];
    _hurryUpLabel.scale = 0.00001;
    _hurryUpLabel.color = ccc3(255, 32, 32);
    _hurryUpLabel.string = @"Hurry Up!!!";
    id wait1 = [CCDelayTime actionWithDuration:2*kAnimationDuration];
    id show = [CCScaleBy actionWithDuration:6*kAnimationDuration scale:1/_hurryUpLabel.scale];
    show = [CCEaseElasticOut actionWithAction:show];
    id wait2 = [CCDelayTime actionWithDuration:15*kAnimationDuration];
    id hide = [CCScaleTo actionWithDuration:kAnimationDuration scale:0];
    [_hurryUpLabel runAction:[CCSequence actions:wait1,show,wait2,hide, nil]];
    [Flurry logEvent:@"Chaser Near"];
}

-(void)startCountdown{
    int countDown = 3;
    NSMutableArray* actions = [NSMutableArray arrayWithCapacity:3];
    for (int i=countDown; i>=0; i--) {
        id block = [CCCallBlock actionWithBlock:^{
            ccColor3B colors[] = {ccc3(255, 0, 0),
                ccc3(255, 255, 0),
                ccc3(0, 255, 0)
            };
            if (i == 0) {
                _hurryUpLabel.string = @"Match!";
            }else {
                _hurryUpLabel.string = [NSString stringWithFormat:@"%d..",i];
                _hurryUpLabel.color = colors[3 - i];
            }
            _hurryUpLabel.scale = 0.00001;
        }];
        id show = [CCScaleBy actionWithDuration:0.3 scale:1/0.00001];
        show = [CCEaseElasticOut actionWithAction:show];
        id wait = [CCDelayTime actionWithDuration:0.4];
        id hide = [CCScaleTo actionWithDuration:0.3 scale:0];
        [actions addObject:[CCSequence actions:block, show, wait, hide, nil]];
    }
    [_hurryUpLabel runAction:[CCSequence actionsWithArray:actions]];
}

-(void)scoreNodeDidSelectRestart{
    [self reset];
    [Flurry logEvent:@"Restart(Game play) Selected"];
}

-(void)mainMenuSelected{
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFadeDown transitionWithDuration:1 scene:[GameMenuLayer scene]]];
    [Flurry logEvent:@"Main menu(Game play) Selected"];
}

-(id)shuffleCardsAction{
    NSMutableArray* indicies = [[NSMutableArray alloc] initWithCapacity:_cardManager.columns*_cardManager.rows];
    for (int i =0; i<_cardManager.columns*_cardManager.rows; i++) {
        [indicies addObject:[NSNumber numberWithInt:i]];
    }
    [indicies shuffle];
    
    NSMutableArray* shuffleActions = [[[NSMutableArray alloc] initWithCapacity:_cardManager.columns] autorelease];
    for (int i =0; i<_cardManager.columns; i++) {
        int index1 = [[indicies objectAtIndex:2*i] intValue];
        int index2 = [[indicies objectAtIndex:2*i+1] intValue];
        [shuffleActions addObject:[_cardManager getShuffleActionIndex1:index1 andIndex2:index2]];
        [shuffleActions addObject:[CCDelayTime actionWithDuration:2*kShuffleAnimationDuration]];
    }
    [indicies release];
    return [CCSequence actionsWithArray:shuffleActions];
}

-(void)increaseCurrentCombo{
    _currentCombo++;
    const int threshhold = 1;
    if (_currentCombo<threshhold) {
        return;
    }
    NSString *comboString = nil;
    switch (_currentCombo) {
        case threshhold:
            comboString = @"Good";
            break;
        case threshhold+1:
            comboString = @"Great!";
            break;
        case threshhold+2:
            comboString = @"Excellent!!";
            break;
        case threshhold+3:
            comboString = @"Wonderful!!!";
            break;
        case threshhold+4:
            comboString = @"Super!!!";
            break;
        default:
            comboString = @"UNBELIEVABLE!!!";
            break;
    }
    [_comboLabel stopAllActions];
    _comboLabel.visible = YES;
    _comboLabel.scale = 0;
    _comboLabel.opacity = 0;
    _comboLabel.rotation = -5;
    _comboLabel.string = comboString;
    
//    [self removeChild:[self getChildByTag:kComboLabelStroke] cleanup:YES];
//    CCSprite* stroke = [CCUtils createStroke:_comboLabel size:2 color:ccWHITE];
//    [self addChild:stroke z:_comboLabel.zOrder -1 tag:kComboLabelStroke];
    
    [self animateComboLabel:_comboLabel];
    //[self animateComboLabel:stroke];
}

-(void)animateComboLabel:(CCSprite*)sprite{
    id block = [CCCallBlock actionWithBlock:^{
        sprite.color = ccc3(200 + rand()/56,
                                 200 + rand()/56,
                                 200 + rand()/56);
    }];
    [sprite runAction:[CCRepeatForever actionWithAction:[CCSequence actionOne:[CCDelayTime actionWithDuration:0.1] two:block]]];
    
    id action1 = [CCSpawn actions:[CCScaleTo actionWithDuration:kAnimationDuration scale:1],
                  [CCFadeIn actionWithDuration:kAnimationDuration], nil];
    id wait = [CCDelayTime actionWithDuration:4];
    id action2 = [CCSpawn actions:[CCScaleTo actionWithDuration:kAnimationDuration scaleX:20 scaleY:2],
                  [CCFadeOut actionWithDuration:kAnimationDuration], nil];
    block = [CCCallBlock actionWithBlock:^{
        sprite.visible = NO;
        [sprite stopAllActions];
    }];
    [sprite runAction:[CCSequence actions:action1, wait, action2, block, nil]];
}

@end
