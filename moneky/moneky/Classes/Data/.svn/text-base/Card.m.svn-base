//
//  Card.m
//  moneky
//
//  Created by Sood, Abhishek on 9/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Card.h"

#define kcardTopFileName @"card_top.png"

@implementation Card

@synthesize cardNumber = _cardNumber;
@synthesize isAnimating = _animating;
@synthesize isMatched;
@synthesize cardSize;

-(id)initWithFile:(NSString *)filename cardNumber:(int)num{
    self = [super init];
    if (self) {
        _cardNumber = num;
        _top = [[CCSprite alloc] initWithFile:kcardTopFileName];
        _cardSprite = [[CCSprite alloc] initWithFile:filename];
        _cardSprite.visible = NO;
        [self addChild:_top];
        [self addChild:_cardSprite];
        self.contentSize = _cardSprite.boundingBox.size;
    }
    return self;
}

-(void)setPosition:(CGPoint)position{
    [super setPosition:position];
    CGSize s = self.contentSize;
    _cardSprite.position = ccp(s.width/2, s.height/2);
    _top.position = _cardSprite.position;
}

-(void)dealloc{
    [_top release];
    [_cardSprite release];
    [super dealloc];
}

-(BOOL)matchesCard:(Card*)c{
    return self.cardNumber == c.cardNumber;
}

-(BOOL)isShown{
    return _cardSprite.visible;
}

-(void)setIsShown:(BOOL)isShown animated:(BOOL)animated{
    if (self.isShown == isShown) return;
    
    if (!animated) {
        _cardSprite.visible = isShown;
        _top.visible = !isShown;
    }else {
        
        _animating = YES;
        id scaleDown = [CCScaleTo actionWithDuration:kAnimationDuration scaleX:0 scaleY:self.scaleY];
        id moveRight = [CCMoveTo actionWithDuration:kAnimationDuration position:ccpAdd(self.position, 
                                                                                       ccp(self.boundingBox.size.width/2, 0))];
        id group1 = [CCSpawn actions:scaleDown, moveRight, nil];
        id blockAction1 = [CCCallBlock actionWithBlock:^{
            _cardSprite.visible = isShown;
            _top.visible = !isShown;
        }];
        
        id scaleUp = [CCScaleTo actionWithDuration:kAnimationDuration scaleX:self.scaleX scaleY:self.scaleY];        
        id moveLeft = [CCMoveTo actionWithDuration:kAnimationDuration position:self.position];
        id group2 = [CCSpawn actions:scaleUp, moveLeft, nil];
        id blockAction2 = [CCCallBlock actionWithBlock:^{
            _animating = NO;
		}];
        
        [self runAction:[CCSequence actions:group1, blockAction1 ,group2, blockAction2, nil]];
    }
}

-(void)setCardSize:(CGSize)cSize{
    cardSize = cSize;
    self.contentSize = cSize;
    _top.scaleX = cSize.width / _top.contentSize.width;
    _top.scaleY = cSize.height / _top.contentSize.height;
    _top.scale = min(_top.scaleX, _top.scaleY);
    _cardSprite.scaleX = cSize.width / _cardSprite.contentSize.width;
    _cardSprite.scaleY = cSize.height / _cardSprite.contentSize.height;
    _cardSprite.scale = min(_cardSprite.scaleX, _cardSprite.scaleY);
}

@end
