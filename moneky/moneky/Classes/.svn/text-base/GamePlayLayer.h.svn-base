//
//  GamePlayLayer.h
//  moneky
//
//  Created by Sood, Abhishek on 9/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"
#import "CardManager.h"
#import "MonkeyRunNode.h"

@interface GamePlayLayer : CCLayer<MonkeyRunNodeDelegate>{
    CardManager *_cardManager;
    Card* _lastCardShown;
    bool _inputEnabled;
    MonkeyRunNode* _monkeyRunNode;
    CCLayer* _pauseMenuLayer;
    CCMenu* _pauseButtonMenu;
    CCMenuItemSprite* _pauseButton;
    CCLabelTTF* _hurryUpLabel;
    uint _moves;
    uint _currentCombo;
    int _comboScore;
    CCLabelTTF* _movesLabel;
    CCLabelTTF* _difficultyLabel;
    CCLabelTTF* _matchTheCardsLabel;
    CCLabelTTF* _comboLabel;
}

@property(nonatomic,assign)DifficultyMode difficultyMode;

+(id)scene:(DifficultyMode)diff;

-(void)reset;

@end
