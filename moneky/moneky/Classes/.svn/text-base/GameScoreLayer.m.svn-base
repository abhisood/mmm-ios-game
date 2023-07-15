//
//  GameScoreLayer.m
//  moneky
//
//  Created by Sood, Abhishek on 10/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GameScoreLayer.h"
#import "GameMenuLayer.h"
#import "GamePlayLayer.h"
#import "MonkeyClientData.h"
#import "Flurry.h"
#import "MonkeyNotificationDefinitions.h"
#import "SoundManager.h"
#import "GameCenterManager.h"
#import <GameKit/GameKit.h>
#import "PlayerScoreNode.h"
#import "ccUtils.h"
#import "StarNode.h"

#define kScoreIncrement 3000
#define kTagRetrivingLabel 1
#define kTagStarNode 2
#define kTagDifficultyLabel 3

#define kTimeFactor3Star 1
#define kTimeFactor2Star 1.3
#define kTimeFactor1Star 1.6

#define kWinText @"Victory!!!"

@implementation GameScoreLayer

-(void)reset{
    _moveBonus.string = @"Move Bonus:";
    _timeBonus.string = @"Time Bonus:";
    _totalBonus.string = @"Total Score:";
    _moveBonus.visible = YES;
    _timeBonus.visible = YES;
    _totalBonus.visible = YES;
    _comboBonus.visible = YES;
    _winLabel.string = kWinText;
    _menu.opacity = 0;
    _diff = 0;
    _menu.isTouchEnabled = NO;
}

-(void)layoutItems:(CGFloat)startHeight{
    CGSize winSize = [CCDirector sharedDirector].winSize;
    CGFloat height = startHeight;
    [self getChildByTag:kTagStarNode].position = ccp(winSize.width/2, height);
    height -= 65;
    _winLabel.position = ccp(winSize.width/2,height);
    height -= 25;
    _timeTakenLabel.position = ccp(winSize.width/3,height);
    _movesTakenLabel.position = ccp(winSize.width*2/3,height);
    height -= 25;
    _moveBonus.position = ccp(winSize.width/2 +5,height);
    height -= 20;
    _timeBonus.position = ccp(winSize.width/2+5,height);
    height -= 20;
    _comboBonus.position = ccp(winSize.width/2+5,height);
    height -= 20;
    _totalBonus.position = ccp(winSize.width/2+5,height);
    height -= 45;
    _menu.position = ccp(winSize.width/2,height);
    height -= 100;
    [self getChildByTag:kTagRetrivingLabel].position = ccp(winSize.width/2,height);
}

-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init])) {
        CCSprite *background = [CCSprite spriteWithFile:@"background.png"];
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        background.position = ccp(winSize.width/2,winSize.height/2);
        [self addChild:background z:-2];
        
        CCMenuItemSprite* restart = [CCMenuItemSprite itemFromSpriteFileName:@"restart.png" block:^(id sender) {
            [self restartSelected];
        }];
        
        CCMenuItemSprite* mainMenu = [CCMenuItemSprite itemFromSpriteFileName:@"menu.png" block:^(id sender) {
            [self mainMenuSelected];
        }];

        mainMenu.scale = 1.2;
        restart.scale = 0.90 * mainMenu.scale;
        [mainMenu runAction:[CCRepeatForever actionWithAction:[CCUtils animationForButton]]];
        [restart runAction:[CCRepeatForever actionWithAction:[CCUtils animationForButton]]];
//        CCMenuItemFont* facebook = [CCMenuItemFont itemFromString:@"Share on FB!" block:^(id sender) {
//            [self facebookSelected];
//        }];
//        facebook.color = kColorRed;
//        CCMenuItemFont* tweetScore = [CCMenuItemFont itemFromString:@"Tweet Your score!" block:^(id sender) {
//            [self twitterSelected];
//        }];
//        tweetScore.color = kColorGreen;
        _menu = [[CCMenu menuWithItems:restart, mainMenu, nil] retain];
        [_menu alignItemsHorizontallyWithPadding:50];
        
//        _winLabel = [[CCLabelTTF labelWithString:kWinText fontName:kMenuFont fontSize:25] retain];
        _winLabel = [[CCLabelTTF labelWithString:kWinText dimensions:CGSizeMake(winSize.width*2/3, 200) alignment:UITextAlignmentCenter lineBreakMode:UILineBreakModeWordWrap fontName:kMenuFont fontSize:25] retain];
        _winLabel.anchorPoint = ccp(0.5, 0.9);
        
        StarNode* node = [[[StarNode alloc] init] autorelease];
        node.visible = NO;
        [self addChild:node z:2 tag:kTagStarNode];
        
        CGSize size = CGSizeMake(200, 20);
        NSString* fontName = [MonkeyClientData getTextFontName];
        int fontSize = 13;
        _timeTakenLabel = [[CCLabelTTF labelWithString:@"Time:" dimensions:size alignment:UITextAlignmentCenter fontName:fontName fontSize:fontSize+2] retain];
        _timeTakenLabel.color = ccBLACK;

        _movesTakenLabel = [[CCLabelTTF labelWithString:@"Moves:" dimensions:size alignment:UITextAlignmentCenter fontName:fontName fontSize:fontSize+2] retain];
        _movesTakenLabel.color = ccBLACK;

        
        UIFont* font = [UIFont fontWithName:fontName size:fontSize];
        size = [@"Move Bonus: 00000" sizeWithFont:font];
        size.width += 10;
        _moveBonus = [[CCLabelTTF labelWithString:@"Move Bonus:" dimensions:size alignment:UITextAlignmentLeft fontName:fontName fontSize:fontSize] retain];
        _moveBonus.color = ccBLACK;
        
        size = [@"Time Bonus: 00000" sizeWithFont:font];
        size.width += 10;
        _timeBonus = [[CCLabelTTF labelWithString:@"Time Bonus:" dimensions:size alignment:UITextAlignmentLeft fontName:fontName fontSize:fontSize] retain];
        _timeBonus.color = ccBLACK;
        
        size = [@"Combo Bonus: 00000" sizeWithFont:font];
        size.width += 26;
        _comboBonus = [[CCLabelTTF labelWithString:@"Combo Bonus:" dimensions:size alignment:UITextAlignmentLeft fontName:fontName fontSize:fontSize] retain];
        _comboBonus.color = ccBLACK;
        
        font = [UIFont fontWithName:fontName size:fontSize+4];
        size = [@"Total Bonus: 00000" sizeWithFont:font];
        size.width += 10;
        _totalBonus = [[CCLabelTTF labelWithString:@"Total Bonus:" dimensions:size alignment:UITextAlignmentLeft fontName:fontName fontSize:fontSize+4] retain];
        _totalBonus.color = kColorOrange;
        
        CCLabelTTF* diffLabel = [CCLabelTTF labelWithString:@"  Difficulty: Impossible  " fontName:fontName fontSize:fontSize+2];
        diffLabel.color = kColorOrange;
        diffLabel.tag = kTagDifficultyLabel;
        diffLabel.position = ccp(winSize.width/2, winSize.height - diffLabel.boundingBox.size.height);

        [self addChild:diffLabel];
        [self addChild:_timeTakenLabel];
        [self addChild:_movesTakenLabel];
        [self addChild:_moveBonus];
        [self addChild:_totalBonus];
        [self addChild:_timeBonus];
        [self addChild:_comboBonus];
        [self addChild:_winLabel];
        [self addChild:_menu];
        [self reset];
        
        NSString* connectString = @"Connect with GameCenter\nto view leaderboards!";
        CGSize actualSize = [connectString sizeWithFont:[UIFont fontWithName:fontName
                                                                        size:fontSize+1]
                            constrainedToSize:CGSizeMake(winSize.width *2/3, 35)
								lineBreakMode:UILineBreakModeWordWrap];
        
        CCLabelTTF* loadingHighScores = [CCLabelTTF labelWithString:connectString dimensions:actualSize alignment:UITextAlignmentCenter lineBreakMode:UILineBreakModeCharacterWrap fontName:fontName fontSize:fontSize+1];
        loadingHighScores.color = kColorRed;
        loadingHighScores.tag = kTagRetrivingLabel;
        [self addChild:loadingHighScores];
        
        _requestSent = NO;
        [self layoutItems:winSize.height * 7/8];
	}
	return self;
}

-(void)onEnter{
    [super onEnter];
    CCLabelTTF* diffLabel = (CCLabelTTF*)[self getChildByTag:kTagDifficultyLabel];
    diffLabel.string = [NSString stringWithFormat:@"Difficulty: %@",[MonkeyClientData getDifficultyString:_diff]];
    diffLabel.color = [MonkeyClientData colorForDifficulty:_diff];

    if (![GameCenterManager isGameCenterAvailable]) {
        [self getChildByTag:kTagRetrivingLabel].visible = NO;
        [self layoutItems:[CCDirector sharedDirector].winSize.height*3/4];
    }
    if (_win) {
        postScoreNotification(self, _diff, _finalTotalBonus, _timeTaken, self.isPerfect);
    }else{
        _winLabel.position = ccp(_winLabel.position.x,[CCDirector sharedDirector].winSize.height/2 + 80);
        _menu.position = ccp(_winLabel.position.x,[CCDirector sharedDirector].winSize.height/2 - 25);
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:MonkeyNotificationGameMenuShown object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadFriendsScore) name:MonkeyNotificationGameCenterPlayerLoaded object:nil];
    [self loadFriendsScore];
}

-(void)loadFriendsScore{
    if (!_requestSent && [GameCenterManager isGameCenterAvailable]) {
        if ([[GameCenterManager sharedManager] isAuthenticated]) {
            CCLabelTTF* loadingHighScores = (CCLabelTTF*)[self getChildByTag:kTagRetrivingLabel];
            loadingHighScores.string = @"Loading High Scores...";
            loadingHighScores.color = ccGREEN;
            id fadeIn = [CCFadeTo actionWithDuration:0.5 opacity:255];
            id fadeOut = [CCFadeTo actionWithDuration:0.5 opacity:140];
            [loadingHighScores runAction:[CCRepeatForever actionWithAction:[CCSequence actions:fadeIn, fadeOut, nil]]];
            
            DLog(@"Requsting friend scores");
            _requestSent = YES;
            [[GameCenterManager sharedManager] friendsHighScoresForCategory:[MonkeyClientData getLeaderboardCategory:_diff] onCompletion:^{
                [self showFriendScores];
            } onError:^{
                loadingHighScores.string = @"Failed to get High Scores";
                [loadingHighScores stopAllActions];
                loadingHighScores.opacity = 255;
                loadingHighScores.color = kColorRed;
            }];
        }
    }
}

-(void)onEnterTransitionDidFinish{
    [super onEnterTransitionDidFinish];
    _menu.opacity = 0; 
    if (_win) {
        [self scheduleUpdate];
    }else {
        [_menu runAction:[CCFadeIn actionWithDuration:kAnimationDuration]];
        _menu.isTouchEnabled = YES;
    }
    NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:_win],@"Win", nil];
    [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:INT_MIN+1 swallowsTouches:YES];
    [Flurry logEvent:@"GameScore Screen Shown" withParameters:dict];
}

-(void)onExit{
    [[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
    [super onExit];
}

-(void)update:(ccTime)dt{
    int counter = (int)ceil(dt * kScoreIncrement);
    if (_finalTotalBonus > 30000) {
        counter += counter; // count faster for bigger scores
    }
    CCLabelTTF* label;
    NSString* str;
    switch (_counterMode) {
        case CounterModeMove:
            _currentMoveBonus += counter;
            if (_currentMoveBonus >= _finalMoveBonus) {
                _currentMoveBonus = _finalMoveBonus;
                _counterMode = CounterModeTime;
                if (_timeTaken <= [MonkeyClientData getTimeForAchievement:_diff]*kTimeFactor1Star) {
                    [(StarNode*)[self getChildByTag:kTagStarNode] setStarYellow:1];
                    [[SoundManager sharedSoundManager] playCheerSound];
                }
            }
            counter = _currentMoveBonus;
            str = @"Move Bonus";
            label = _moveBonus;
            break;
        case CounterModeTime:
            _currentTimeBonus += counter;
            if (_currentTimeBonus >= _finalTimeBonus) {
                _currentTimeBonus = _finalTimeBonus;
                _counterMode = CounterModeCombo;
                if (_timeTaken<= [MonkeyClientData getTimeForAchievement:_diff]*kTimeFactor2Star) {
                    [(StarNode*)[self getChildByTag:kTagStarNode] setStarYellow:2];
                    [[SoundManager sharedSoundManager] playCheerSound];
                }
            }
            counter = _currentTimeBonus;
            str = @"Time Bonus";
            label = _timeBonus;            
            break;
        case CounterModeCombo:
            _currentComboBonus += counter;
            if (_currentComboBonus >= _finalComboBonus) {
                _currentComboBonus = _finalComboBonus;
                _counterMode = CounterModeTotal;
                if ([self isPerfect]) {
                    [(StarNode*)[self getChildByTag:kTagStarNode] setStarYellow:3];
                    [[SoundManager sharedSoundManager] playPerfectSound];
                }
            }
            counter = _currentComboBonus;
            str = @"Combo Bonus";
            label = _comboBonus;
            break;
        case CounterModeTotal:
            _currentTotalBonus += counter;
            if (_currentTotalBonus >= _finalTotalBonus) {
                _currentTotalBonus = _finalTotalBonus;
                _counterMode = CounterModeNone;
            }
            counter = _currentTotalBonus;
            str = @"Total Score";
            label = _totalBonus;
            break;
        default:
            [_menu runAction:[CCFadeIn actionWithDuration:kAnimationDuration]];
            _menu.isTouchEnabled = YES;
            [self unscheduleUpdate];
            return;
    }
    label.string = [NSString stringWithFormat:@"%@: %d",str,counter];
}

-(void)dealloc{
    [_totalBonus release];
    [_moveBonus release];
    [_timeBonus release];
    [_menu release];
    [_timeTakenLabel release];
    [_movesTakenLabel release];
    [_winLabel release];
    [_comboBonus release];
    [_shareImage release];
    [super dealloc];
}

-(NSString*)getLoseText{
    NSArray* options = @[@"Better luck next time.",
    @"You almost had it!",
    @"You can do better than that!",
    @"Practice makes a man perfect, women are born perfect :P",
    @"Keep trying, this isn't so hard!",
    @"Focus man, Focus!"];
    
    int index = rand()%options.count;
    return [options objectAtIndex:index];
}

-(void)showLoseMenu:(DifficultyMode)diff{
    _diff = diff;
    _moveBonus.visible = NO;
    _timeBonus.visible = NO;
    _totalBonus.visible = NO;
    _comboBonus.visible = NO;
    _timeTakenLabel.visible = NO;
    _movesTakenLabel.visible = NO;
    _winLabel.string = [self getLoseText];
    _winLabel.color = kColorRed;
    _win = NO;
    [self getChildByTag:kTagStarNode].visible = NO;
}

-(void)setTimeBonus:(int)timeBonus comboScore:(int)comboScore moveBonus:(int)moveBonus difficultyMode:(DifficultyMode)diff{
    _diff = diff;
    _win = YES;
    _menu.opacity = 0;
    _finalTimeBonus = timeBonus;
    _finalMoveBonus = moveBonus;
    _finalComboBonus = comboScore;
    _finalTotalBonus = timeBonus + moveBonus + comboScore;
    _currentMoveBonus = 0;
    _currentTimeBonus = 0;
    _currentTotalBonus = 0;
    _currentComboBonus = 0;
    _counterMode = CounterModeMove;
    _winLabel.color = kColorGreen;
    _winLabel.string = kWinText;
    [self getChildByTag:kTagStarNode].visible = YES;

    Class shareClass = (NSClassFromString(@"UIActivityViewController"));
    if (shareClass) {
        [CCMenuItemFont setFontName:kMenuFont];
        [CCMenuItemFont setFontSize:35];
        CCMenuItemFont* shareItem = [CCMenuItemFont itemFromString:@"Share" block:^(id sender) {
            [self shareSelected];
        }];
        shareItem.color = kColorBlue;
        [shareItem runAction:[CCRepeatForever actionWithAction:[CCUtils animationForButton]]];
        [_menu addChild:shareItem];
        [_menu alignItemsHorizontallyWithPadding:25];
        _menu.opacity = 0;
    }
    
}

-(bool)isPerfect{
    return _timeTaken <= [MonkeyClientData getTimeForAchievement:_diff]*kTimeFactor3Star;
}

-(void)setMovesTaken:(uint)moves minimumMoves:(uint)minMoves{
    _movesTaken = moves;
    _minimumMoves = minMoves;
    _movesTakenLabel.string = [NSString stringWithFormat:@"Moves: %d",moves];
}

-(void)setTimeTaken:(float)time{
    _timeTaken = time;
    _timeTakenLabel.string = [NSString stringWithFormat:@"Time: %@",[CCUtils stringFromTime:time]];
}

-(void)mainMenuSelected{
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFadeDown transitionWithDuration:1 scene:[GameMenuLayer scene]]];
    [Flurry logEvent:@"Main menu(Game score) Selected"];
}

-(void)restartSelected{
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1 scene:[GamePlayLayer scene:_diff]]];
    [Flurry logEvent:@"Restart(Game score) Selected"];
}

-(void)showFriendScores{
    GameCenterManager* gameCenter = [GameCenterManager sharedManager];
    NSMutableArray *playerScores = [NSMutableArray arrayWithCapacity:gameCenter.friendsScores.count];
    for (GKScore *score in gameCenter.friendsScores) {
        GKPlayer* player = [gameCenter.friends objectForKey:score.playerID];
        PlayerScore* playerScore = [[PlayerScore alloc] init];
        playerScore.playerID = player.playerID;
        playerScore.name = player.alias;
        playerScore.score = score.formattedValue;
        playerScore.time = score.context;
        playerScore.photo = [gameCenter.friendPhotos objectForKey:score.playerID];
        playerScore.rank = score.rank;
        [playerScores addObject:[playerScore autorelease]];
    }
    
    PlayerScoreNode *scoreNode = [[PlayerScoreNode alloc] initWithPlayerScores:playerScores];
    CGFloat x = 0;
    scoreNode.position = ccp(x,-scoreNode.contentSize.height);
    [self addChild:scoreNode];
    [scoreNode runAction:[CCMoveTo actionWithDuration:0.5 position:ccp(x,50)]];
    [scoreNode release];
    [[self getChildByTag:kTagRetrivingLabel] stopAllActions];
    [[self getChildByTag:kTagRetrivingLabel] runAction:[CCFadeOut actionWithDuration:kAnimationDuration]];
}

-(void)shareSelected{
    if (!_shareImage) {
        CGSize winSize = [CCDirector sharedDirector].winSize;
        
        CCSprite *background = [CCSprite spriteWithFile:@"background.png"];
        background.position = ccp(winSize.width/2,winSize.height/2);
        
        StarNode* starNode = (StarNode*)[self getChildByTag:kTagStarNode];
        [starNode hideParticles];
        
        CCSprite *icon = [CCSprite spriteWithFile:@"Icon@2x.png"];
        icon.rotation = -5;
        icon.position = ccp(winSize.width/3 - 10, winSize.height*4/5);
        
        UIFont* font = [UIFont fontWithName:kMenuFont size:35];
        NSString* text = @"Monkey\nMatch\nMayhem";
        CGSize size = [text sizeWithFont:font constrainedToSize:CGSizeMake(winSize.width*2/3, winSize.height/2) lineBreakMode:NSLineBreakByWordWrapping];
        CCLabelTTF* title = [CCLabelTTF labelWithString:text dimensions:size alignment:UITextAlignmentCenter lineBreakMode:UILineBreakModeWordWrap fontName:kMenuFont fontSize:35];
        title.position = ccp(winSize.width*2/3, icon.position.y);
        title.color = kColorBlue;
        
        CGFloat height = title.position.y - title.contentSize.height/2 - 40;
        CCLabelTTF* winLabel = nil;
        CCSprite* playerImage = nil;
        if ([GameCenterManager isGameCenterAvailable] && [GameCenterManager sharedManager].isAuthenticated) {
            GKPlayer* player = [GKLocalPlayer localPlayer];
            
            winLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%@'s\nReport Card",player.alias] dimensions:CGSizeMake(winSize.width*2/3, 50) alignment:UITextAlignmentCenter lineBreakMode:UILineBreakModeWordWrap fontName:[MonkeyClientData getTextFontName] fontSize:17];
            winLabel.color = kColorRed;

            UIImage* img = [[GameCenterManager sharedManager].friendPhotos objectForKey:player.playerID];
            playerImage = [CCSprite spriteWithCGImage:[img CGImage] key:player.playerID];
            playerImage.scale = 60/playerImage.contentSize.height;
            
            winLabel.position = ccp(winSize.width*2/3 - 25,height);
            playerImage.position = ccp(winSize.width/3 - 40,height);
        }else{
            winLabel = [CCLabelTTF labelWithString:@"Report Card" dimensions:CGSizeMake(winSize.width*2/3, 50) alignment:UITextAlignmentCenter lineBreakMode:UILineBreakModeWordWrap fontName:[MonkeyClientData getTextFontName] fontSize:17];
            winLabel.color = kColorRed;
            winLabel.position = ccp(winSize.width/2,height - 20);
        }
        
        ccDirectorProjection proj = [CCDirector sharedDirector].projection;
        [[CCDirector sharedDirector] setProjection:CCDirectorProjection2D];

        CCRenderTexture *renderer1 = [CCRenderTexture renderTextureWithWidth:winSize.width height:winSize.height pixelFormat:kCCTexture2DPixelFormat_RGBA8888];
        renderer1.sprite.blendFunc = _timeBonus.blendFunc;
        [renderer1 begin];

        [_winLabel visit];
        [_moveBonus visit];
        [_timeBonus visit];
        [_comboBonus visit];
        [_totalBonus visit];
        [_timeTakenLabel visit];
        [_movesTakenLabel visit];
        [starNode visit];

        [renderer1 end];
        
        height -= 65;
        CCNode* diffLabel =  [self getChildByTag:kTagDifficultyLabel];
        diffLabel.position = ccp(winSize.width/2, height);
       
        renderer1.sprite.anchorPoint = ccp(0,0);
        height -= (55 - (winSize.height - starNode.position.y));
        renderer1.sprite.position = ccp(0,height);

        CCRenderTexture *renderer = [CCRenderTexture renderTextureWithWidth:winSize.width height:winSize.height pixelFormat:kCCTexture2DPixelFormat_RGBA8888];
        renderer.sprite.blendFunc = _timeBonus.blendFunc;
        [renderer begin];
        
        [background visit];
        [icon visit];
        [title visit];
        [winLabel visit];
        if (playerImage) {
            [playerImage visit];
        }
        [diffLabel visit];
        [renderer1.sprite visit];
        
        [renderer end];
        _shareImage = [[renderer getUIImageFromBuffer] retain];
        [[CCDirector sharedDirector] setProjection:proj];
        diffLabel.position = ccp(winSize.width/2, winSize.height - diffLabel.boundingBox.size.height);
    }
    
    NSString* name = @"I have beaten";
    if ([GameCenterManager isGameCenterAvailable] && [GameCenterManager sharedManager].isAuthenticated) {
        GKPlayer* player = [GKLocalPlayer localPlayer];
        name = [NSString stringWithFormat:@"%@ beats",player.alias];
    }
    NSString* text = [NSString stringWithFormat:@"%@ MMM :)", name];
    postSharePhotoNotification(self, _shareImage, text);
    [Flurry logEvent:@"Share button pressed"];
}

-(BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event{
    _currentComboBonus = _finalComboBonus;
    _currentTimeBonus = _finalTimeBonus;
    _currentMoveBonus = _finalMoveBonus;
    _currentTotalBonus = _finalTotalBonus;
    return _currentTotalBonus != _finalTotalBonus;
}

@end
