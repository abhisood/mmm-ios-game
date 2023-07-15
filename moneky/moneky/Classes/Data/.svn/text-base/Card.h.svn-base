//
//  Card.h
//  moneky
//
//  Created by Sood, Abhishek on 9/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface Card : CCNode{
    int _cardNumber;
    CCSprite *_top,*_cardSprite;
    BOOL _animating;
}

@property(readonly,nonatomic) int cardNumber;
@property(readonly,nonatomic) BOOL isAnimating;
@property(assign,nonatomic) BOOL isMatched;
@property(assign,nonatomic) CGSize cardSize;

-(id)initWithFile:(NSString *)filename cardNumber:(int)num;
-(BOOL)matchesCard:(Card*)c;
-(BOOL)isShown;
-(void)setIsShown:(BOOL)isShown animated:(BOOL)animated;

@end
