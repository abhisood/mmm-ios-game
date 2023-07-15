//
//  CardManager.h
//  moneky
//
//  Created by Sood, Abhishek on 8/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"

@class Card;

@interface CardManager : CCNode{
    NSMutableArray* _cards;
    int _rows, _columns;  
    DifficultyMode _difficultyMode;
    CGRect _screenRect;
    bool _ready;
}

@property(nonatomic,assign) DifficultyMode difficultyMode;
@property(nonatomic,assign) CGRect screenRect;
@property(nonatomic,readonly) int rows;
@property(nonatomic,readonly) int columns;

-(id)initWithScreenRect:(CGRect)rect DifficultyMode:(DifficultyMode)diff;

-(void)reset;
-(BOOL)isWon;
-(Card*)cardContainingPoint:(CGPoint)point;
-(void)showAllCards;
-(void)hideAllCards;
-(id)getShuffleActionIndex1:(int)index1 andIndex2:(int)index2;


@end
