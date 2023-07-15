//
//  MonkeyRunNode.m
//  moneky
//
//  Created by Sood, Abhishek on 9/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MonkeyRunNode.h"

#define kchaserFileName @"close.png"
#define kmonkeyFileName @"Icon-Small.png"
#define kMonkeySpeed 50 
#define kMountainSpeedFactor 0.05
#define kTreesSpeedFactor 0.2

@implementation MonkeyRunNode

@synthesize delegate, isPaused;
@synthesize difficultyAdjustment = _difficultyAdjustment;
@synthesize totalTimeTaken;

-(id)init{
    self = [super init];
    if (self) {
        _monkeySpeedUp = ccp(0.8 * kMonkeySpeed, 0);        
        
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:
         @"animation_frames.plist"];
        CCSpriteBatchNode *spriteSheet = [CCSpriteBatchNode 
                                          batchNodeWithFile:@"animation_frames.png"];
        [self addChild:spriteSheet];
        
        NSMutableArray *monkeyRunAnimFrames = [NSMutableArray array];
        for(int i = 0; i <= 9; ++i) {
            [monkeyRunAnimFrames addObject:
             [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
              [NSString stringWithFormat:@"monkey_run_%d.png", i]]];
        }
        _monkeyRun = [[CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:[CCAnimation animationWithFrames:monkeyRunAnimFrames delay:0.1f] restoreOriginalFrame:NO]] retain];
        
        NSMutableArray *chaserRunAnimFrames = [NSMutableArray array];
        for(int i = 0; i <= 11; ++i) {
            [chaserRunAnimFrames addObject:
             [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
              [NSString stringWithFormat:@"chaser_run_%d.png", i]]];
        }
        _chaserRun = [[CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:[CCAnimation animationWithFrames:chaserRunAnimFrames delay:0.1f] restoreOriginalFrame:NO]] retain];

        _chaser = [[CCSprite spriteWithSpriteFrameName:@"chaser_run_0.png"] retain];
        _monkey = [[CCSprite spriteWithSpriteFrameName:@"monkey_run_0.png"] retain];
        
        [spriteSheet addChild:_monkey];
        [spriteSheet addChild:_chaser];
        
        [self scheduleUpdate];
        [self reset];
    }
    return self;
}

-(void)reset{
    CGSize winsize = [[CCDirector sharedDirector] winSize];
    int h = 10;
    _monkey.position = ccp(winsize.width*14/15, _monkey.boundingBox.size.height/2 + h );
    _chaser.position = ccp(winsize.width/15,  _chaser.boundingBox.size.height/2 + h +5);
    [self setIsPaused:YES];
}

-(void)update:(ccTime)dt{
    if (!self.isPaused) {
        if (_monkey.position.x - _chaser.position.x < 5) {
            [delegate monkeyCaught];
        }
        CGFloat oldx = _chaser.position.x;
        _chaser.position = ccpAdd(_chaser.position, ccpMult(_chaserVelocity, dt));
        self.totalTimeTaken += dt;
        CGFloat crossOver = [[CCDirector sharedDirector] winSize].width * 2/3.3;
        if (oldx <= crossOver && _chaser.position.x >= crossOver ) {
            [delegate chaserNear];
        }
    }
}

-(void)setIsPaused:(BOOL)isP{
    isPaused = isP;
    if (!isPaused) {
        [_monkey runAction:_monkeyRun];
        [_chaser runAction:_chaserRun];
    }else {
        [_monkey stopAllActions];
        [_chaser stopAllActions];
    }
}

-(void)dealloc{
    [_monkey release];
    [_chaser release];
    [_monkeyRun release];
    [_chaserRun release];
    [super dealloc];
}

-(void)log{
    DLog(@"Chaser Speed %@",NSStringFromCGPoint(_chaserVelocity));
}

-(void)speedUpChaser{
    _chaserVelocity = ccpAdd(_chaserVelocity,_chaserSpeedUp);
    id wait = [CCDelayTime actionWithDuration:3];
    id block = [CCCallBlock actionWithBlock:^{
        [self speedDownChaser];
    }];
    [self runAction:[CCSequence actions:wait, block, nil]];
}

-(void)speedDownChaser{
    _chaserVelocity = ccpSub(_chaserVelocity,_chaserSpeedUp);
}

-(void)speedUpMonkey{
    _chaserVelocity = ccpSub(_chaserVelocity, ccpMult(_monkeySpeedUp, _chaserSpeedFactor));
    id wait = [CCDelayTime actionWithDuration:3];
    id block = [CCCallBlock actionWithBlock:^{
        [self speedDownMonkey];
    }];
    [self runAction:[CCSequence actions:wait, block, nil]];
    [self log];
}

-(void)speedDownMonkey{
    _chaserVelocity = ccpAdd(_chaserVelocity, ccpMult(_monkeySpeedUp, _chaserSpeedFactor));
    [self log];
}

-(float)distanceBetweenMonkeyAndChaser{
    return (_monkey.position.x - _chaser.position.x)/[[CCDirector sharedDirector] winSize].width;
}

-(void)setDifficultyAdjustment:(float)difficultyAdjustment{
    _difficultyAdjustment = difficultyAdjustment;
    float chaserSpeed = (_monkey.position.x - _chaser.position.x)/(difficultyAdjustment);
    DLog(@"chaser speed: %f",chaserSpeed);
    _chaserSpeedFactor = 0.5 * chaserSpeed/_monkeySpeedUp.x;
    _chaserVelocity = ccp(chaserSpeed, 0);
    _chaserSpeedUp = ccp(0.5 * chaserSpeed, 0);
    [self log];
}

@end
