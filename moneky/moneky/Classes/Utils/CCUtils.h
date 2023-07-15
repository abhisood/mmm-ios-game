//
//  CCUtils.h
//  moneky
//
//  Created by Sood, Abhishek on 10/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface CCUtils : NSObject

+(CCSprite*) createStroke: (CCLabelTTF*) label   size:(float)size   color:(ccColor3B)cor;
+(NSString*) stringFromTime:(float)time;
+(id)animationForButton;
+(CCParticleSystem*)starParticleSystem;
@end


@interface CCMenuItemSprite (category)

+(id) itemFromSpriteFileName:(NSString*)spriteFileName block:(void(^)(id sender))block;
@end