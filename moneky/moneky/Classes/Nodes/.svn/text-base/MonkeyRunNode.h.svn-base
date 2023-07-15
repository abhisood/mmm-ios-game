//
//  MonkeyRunNode.h
//  moneky
//
//  Created by Sood, Abhishek on 9/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@protocol MonkeyRunNodeDelegate <NSObject>

-(void)monkeyCaught;
-(void)chaserNear;

@end

@interface MonkeyRunNode : CCNode{
    CCSprite* _monkey;
    CCSprite* _chaser;
    CCAction* _monkeyRun;
    CCAction* _chaserRun;
    CGPoint _chaserVelocity;
    CGPoint _chaserSpeedUp;
    CGPoint _monkeySpeedUp;
    float _chaserSpeedFactor;
    float _difficultyAdjustment;
}

@property(nonatomic,assign)id<MonkeyRunNodeDelegate> delegate;
@property(nonatomic,assign)BOOL isPaused;
@property(nonatomic,assign)float difficultyAdjustment;
@property(nonatomic,assign)float totalTimeTaken;

-(void)speedUpMonkey;
-(void)speedUpChaser;
-(float)distanceBetweenMonkeyAndChaser;
-(void)reset;

@end
