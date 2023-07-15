//
//  CardManager.m
//  moneky
//
//  Created by Sood, Abhishek on 8/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CardManager.h"
#import "NSMutableArray+shuffle.h"
#import "Card.h"

#define kCardHorizontalGap 10
#define kCardVerticalGap 10

#define kCardFileNamePrefix @"fruit_"

@interface CardManager(Private)

-(void)resetScreenRect;
-(void)resetDifficultyMode;
-(void)initializeCards;
-(void)layoutCards;
-(void)showAllCards;
-(void)HideAllCards;
@end

@implementation CardManager

@synthesize difficultyMode = _difficultyMode;
@synthesize screenRect = _screenRect;
@synthesize rows = _rows;
@synthesize columns = _columns;

-(id)initWithScreenRect:(CGRect)rect DifficultyMode:(DifficultyMode)diff{
    self = [super init];
    if (self) {
        _screenRect = rect;
        _difficultyMode = diff;
        [self resetDifficultyMode];
    }
    return self;
}

-(void)setScreenRect:(CGRect)screenRect{
    if (!CGRectEqualToRect(_screenRect, screenRect)) {
        _screenRect = screenRect;
        [self layoutCards];
    }
}

-(void)setDifficultyMode:(DifficultyMode)difficultyMode{
    if (_difficultyMode != difficultyMode) {
        _difficultyMode = difficultyMode;
        [self resetDifficultyMode];
    }
}

-(BOOL)isWon{
    for (Card* c in _cards) {
        if (!c.isMatched) return NO;
    }
    return YES;
}

-(void)initializeCards{
    int num = _rows*_columns;
    for (Card* c in _cards) {
        [self removeChild:c cleanup:YES];
    }
    [_cards release];
    
    _cards = [[NSMutableArray alloc] initWithCapacity:num];
    
    NSMutableArray* cardFileNameArray = [NSMutableArray arrayWithCapacity:num];
    for (int i =1; i<=20; i++) {
        [cardFileNameArray addObject:[NSString stringWithFormat:@"%@%02d.png", kCardFileNamePrefix, i]];
    }
    [cardFileNameArray shuffle];
    
    for (int i=0; i<num; i++) {
        int index = i/2;
        Card* c = [[Card alloc] initWithFile:[cardFileNameArray objectAtIndex:index] 
                                  cardNumber:index];
        [_cards addObject:c];
        [self addChild:c z:0];
        [c release];
    }
    [_cards shuffle];
}

-(void)showAllCards{
    _ready = NO;
    for (Card *c in _cards) {
        [c setIsShown:YES animated:YES];
    }
}

-(void)hideAllCards{
    for (Card *c in _cards) {
        [c setIsShown:NO animated:YES];
    }
    _ready = YES;
}

-(void)reset{
    [self initializeCards];
    [self layoutCards];
}

-(void)resetDifficultyMode{
    switch (self.difficultyMode) {
        case DifficultyModeVeryEasy:
            _columns = 4;
            _rows = 4;
            break;
        case DifficultyModeEasy:
            _columns = 4;
            _rows = 5;
            break;
        case DifficultyModeNormal:
            _columns = 5;
            _rows = 6;
            break;
        case DifficultyModeHard:
            _columns = 6;
            _rows = 6;
            break;
        case DifficultyModeVeryHard:
            _columns = 5;
            _rows = 6;
            break;
        case DifficultyModeImpossible:
            _columns = 6;
            _rows = 6;
            break;            
        default:
            break;
    }
}

-(void)layoutCards{
    float gapMultiplier = (1 - _rows/20.0f);
    gapMultiplier *=gapMultiplier;
    float hGap = kCardHorizontalGap * gapMultiplier;
    float vGap = kCardVerticalGap * gapMultiplier;
    float totalHorizontalGap = hGap * (_columns-1);
    float totalVerticalGap = vGap * (_rows-1);
    float cardWidth = (_screenRect.size.width - totalHorizontalGap)/_columns;
    float cardHeight = (_screenRect.size.height - totalVerticalGap)/_rows;
    float x = _screenRect.origin.x;
    float y = _screenRect.origin.y;
    for (Card* c in _cards) {
        c.cardSize = CGSizeMake(cardWidth, cardHeight);
        c.position = ccp(x, y);
        x += hGap + cardWidth;
        if (x >= _screenRect.size.width) {
            y += vGap + cardHeight;
            x = _screenRect.origin.x;
        }
    }
}

-(Card *)cardContainingPoint:(CGPoint)point{
    if (!_ready) return nil;
    
    for (Card* c in _cards) {
        if (!c.isAnimating && CGRectContainsPoint(c.boundingBox, point)) {
            return c;
        }
    }
    return nil;
}

-(id)getShuffleActionIndex1:(int)index1 andIndex2:(int)index2{
    Card* c1 = [_cards objectAtIndex:index1];
    Card* c2 = [_cards objectAtIndex:index2];
    
    id action1 = [CCCallBlock actionWithBlock:^{
        [self reorderChild:c1 z:1];
        [self reorderChild:c2 z:1];
        [c1 runAction:[CCMoveTo actionWithDuration:kShuffleAnimationDuration position:c2.position]];
        [c2 runAction:[CCMoveTo actionWithDuration:kShuffleAnimationDuration position:c1.position]];
    }];
    
    id action2 = [CCCallBlock actionWithBlock:^{
        [_cards exchangeObjectAtIndex:index1 withObjectAtIndex:index2]; 
        [self reorderChild:c1 z:0];
        [self reorderChild:c2 z:0];
    }];
    
    return [CCSequence actions:action1, action2, nil];
}

@end
