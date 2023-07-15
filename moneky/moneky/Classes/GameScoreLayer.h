//
//  GameScoreLayer.h
//  moneky
//
//  Created by Sood, Abhishek on 10/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

typedef enum CounterMode{
    CounterModeNone,
    CounterModeMove,
    CounterModeTime,
    CounterModeCombo,
    CounterModeTotal,
}CounterMode;

@interface GameScoreLayer : CCLayer{
    CCLabelTTF* _moveBonus;
    CCLabelTTF* _comboBonus;
    CCLabelTTF* _timeBonus;
    CCLabelTTF* _totalBonus;
    CCLabelTTF* _winLabel;
    CCLabelTTF* _timeTakenLabel;
    CCLabelTTF* _movesTakenLabel;
    CCMenu* _menu;
    DifficultyMode _diff;
    int _currentTimeBonus;
    int _currentMoveBonus;
    int _currentComboBonus;
    int _currentTotalBonus;
    bool _win;
    int _finalTimeBonus;
    int _finalMoveBonus;
    int _finalComboBonus;
    int _finalTotalBonus;
    CounterMode _counterMode;
    float _timeTaken;
    bool _requestSent;
    uint _movesTaken;
    uint _minimumMoves;
    UIImage* _shareImage;
}

@property(nonatomic,readonly,getter=isPerfect)bool perferct;

-(void)setTimeBonus:(int)timeBonus comboScore:(int)comboScore moveBonus:(int)moveBonus difficultyMode:(DifficultyMode)diff;
-(void)showLoseMenu:(DifficultyMode)diff;
-(void)setTimeTaken:(float)time;
-(void)setMovesTaken:(uint)moves minimumMoves:(uint)minMoves;

@end
