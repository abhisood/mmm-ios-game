//
//  StarNode.m
//  moneky
//
//  Created by Sood, Abhishek on 12/17/12.
//
//

#import "StarNode.h"
#import "cocos2d.h"
#import "ccUtils.h"

enum _tags {
    TagStarGreyLeft = 1,
    TagStarGreyRight = 2,
    TagStarGreyCenter = 3,
    TagStarYellowLeft = 4,
    TagStarYellowRight = 5,
    TagStarYellowCenter = 6,
};

@implementation StarNode

-(id)init{
    self = [super init];
    if (self) {
        NSString* starGrey = @"star-grey.png";
        NSString* starYellow = @"star-yellow.png";
        
        CCSprite* greyLeft = [CCSprite spriteWithFile:starGrey];
        CCSprite* greyRight = [CCSprite spriteWithFile:starGrey];
        CCSprite* greyCenter = [CCSprite spriteWithFile:starGrey];
        CCSprite* yellowLeft = [CCSprite spriteWithFile:starYellow];
        CCSprite* yellowRight = [CCSprite spriteWithFile:starYellow];
        CCSprite* yellowCenter = [CCSprite spriteWithFile:starYellow];
        
        greyLeft.rotation = -5;
        greyRight.rotation = 5;
        yellowLeft.rotation = greyLeft.rotation;
        yellowRight.rotation = greyRight.rotation;
        
        greyLeft.position = ccp(-greyLeft.contentSize.width + 5,-greyLeft.contentSize.height/4 );
        greyRight.position = ccp(-greyLeft.position.x,greyLeft.position.y);
        yellowLeft.position = greyLeft.position;
        yellowRight.position = greyRight.position;
        
        self.contentSize = CGRectUnion(greyLeft.boundingBox, CGRectUnion(greyCenter.boundingBox, greyRight.boundingBox)).size;
        
        [self addChild:greyLeft z:1 tag:TagStarGreyLeft];
        [self addChild:greyRight z:1 tag:TagStarGreyRight];
        [self addChild:greyCenter z:1 tag:TagStarGreyCenter];
        [self addChild:yellowLeft z:1 tag:TagStarYellowLeft];
        [self addChild:yellowRight z:1 tag:TagStarYellowRight];
        [self addChild:yellowCenter z:1 tag:TagStarYellowCenter];
        
        [self reset];
//        self.anchorPoint = ccp(0.5,0.5);
    }
    return self;
}

-(void)reset{
    [self getChildByTag:TagStarYellowLeft].visible = NO;
    [self getChildByTag:TagStarYellowRight].visible = NO;
    [self getChildByTag:TagStarYellowCenter].visible = NO;
}

-(void)internalSetStarYellow:(int)index{
    CCNode* yellow = [self getChildByTag:index+3];
    if (!yellow.visible) {
        yellow.visible = YES;
        CCParticleSystem* ps = [CCUtils starParticleSystem];
        ps.position = yellow.position;
        [self addChild:ps z:2];
    }
}

-(void)setStarYellow:(int)index{
    NSAssert(index>0 && index<=3, @"invalid index");
    for (int i=0; i<=index; i++) {
        [self internalSetStarYellow:i];
    }
}

-(void)hideParticles{
    for (CCNode* n in self.children) {
        if ([n isKindOfClass:[CCParticleSystem class]]) {
            n.visible = NO;
        }
    }
}

@end
