//
//  CCUtils.m
//  moneky
//
//  Created by Sood, Abhishek on 10/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCUtils.h"

@implementation CCUtils

+(CCSprite*) createStroke: (CCLabelTTF*) label   size:(float)size   color:(ccColor3B)cor
{
	CCRenderTexture* rt = [CCRenderTexture renderTextureWithWidth:label.texture.contentSize.width+size*2  height:label.texture.contentSize.height+size*2];
	
    CGPoint originalPos = [label position];
	ccColor3B originalColor = [label color];
    CGFloat originalRotaion = [label rotation];
    bool originalVisible = label.visible;
    GLubyte originalOpacity = label.opacity;
    
    label.visible = YES;
    label.rotation = 0;
    label.opacity = 255;
	[label setColor:cor];
	ccBlendFunc originalBlend = [label blendFunc];
	[label setBlendFunc:(ccBlendFunc) { GL_SRC_ALPHA, GL_ONE }];
	CGPoint center = ccp(label.texture.contentSize.width/2+size, label.texture.contentSize.height/2+size);
	[rt begin];
	for (int i=0; i<360; i+=15)
	{
		[label setPosition:ccp(center.x + sin(CC_DEGREES_TO_RADIANS(i))*size, center.y + cos(CC_DEGREES_TO_RADIANS(i))*size)];
		[label visit];
	}
	[rt end];
    
    label.opacity = originalOpacity;
    label.visible = originalVisible;
    label.rotation = originalRotaion;
	[label setPosition:originalPos];
	[label setColor:originalColor];
	[label setBlendFunc:originalBlend];
    
    CCSprite* s = rt.sprite;
    [s removeFromParentAndCleanup:YES];

    s.opacity = originalOpacity;
    s.visible = originalVisible;
    s.rotation = originalRotaion;
	[s setPosition:originalPos];
	[s setBlendFunc:originalBlend];

	return s;
}

+(NSString *)stringFromTime:(float)time{
    int min = time/60;
    int sec = time - min*60;
    return [NSString stringWithFormat:@"%d:%02d",min,sec];
}

+(id)animationForButton{
    float duration = 0.15;
//    id scaleUp = [CCScaleBy actionWithDuration:duration scaleX:0.02 scaleY:-0.02];
//    id scaleDown = [CCScaleBy actionWithDuration:duration scaleX:-0.02 scaleY:0.02];
    float scaleUp = 1.05;
    float scaleDown = 1/scaleUp;
    id scaleUpAction = [CCScaleBy actionWithDuration:duration
                                              scaleX:scaleUp
                                              scaleY:scaleDown];
    id scaleDownAction = [CCScaleBy actionWithDuration:duration
                                                scaleX:scaleDown
                                                scaleY:scaleUp];
    return [CCSequence actions:scaleUpAction, scaleDownAction, scaleDownAction, scaleUpAction, nil];
}

+(CCParticleSystem *)starParticleSystem{
    CCParticleSystem* emitter = [[[CCParticleSystemPoint alloc] initWithTotalParticles:60] autorelease];
    emitter.texture = [[CCTextureCache sharedTextureCache] addImage:@"star-grey.png"];
    emitter.scale = 0.3;
    emitter.autoRemoveOnFinish = YES;
    // duration
    emitter.duration = .5;
    
    // Gravity Mode
    emitter.emitterMode = kCCParticleModeGravity;
    
    // Gravity Mode: gravity
    emitter.gravity = ccp(0,-300);
    
    // Gravity Mode: speed of particles
    emitter.speed = 300;
    emitter.speedVar = 50;
    
    // angle
    emitter.angle = 90;
    emitter.angleVar = 120;
    
    // emitter position
    emitter.posVar = ccp(50,50);
    
    // life of particles
    emitter.life = 2;
    emitter.lifeVar = 1;
    
    // size, in pixels
    emitter.startSize = 30.0f;
    emitter.startSizeVar = 10.0f;
    emitter.endSize = kCCParticleStartSizeEqualToEndSize;
    
    // emits per second
    emitter.emissionRate =emitter.totalParticles/emitter.duration;
    
    // color of particles
    emitter.startColor = ccc4FFromccc4B(ccc4(127,127,0,127));
    emitter.startColorVar = ccc4FFromccc4B(ccc4(255, 255, 0, 150));
    emitter.endColor = ccc4FFromccc4B(ccc4(255,255,0,127));
    emitter.endColorVar = emitter.startColorVar;
    
    emitter.blendAdditive = NO;
    
    return emitter;
}

@end


@implementation CCMenuItemSprite (category)

+(id)itemFromSpriteFileName:(NSString *)spriteFileName block:(void (^)(id))block{
    CCSprite* normal = [CCSprite spriteWithFile:spriteFileName];
    CCSprite* selected = [CCSprite spriteWithFile:spriteFileName];
    selected.scale = 1.2;
    CCSprite* disabled = [CCSprite spriteWithFile:spriteFileName];
    disabled.color = ccGRAY;
    return [self itemFromNormalSprite:normal selectedSprite:selected disabledSprite:disabled block:block];
}

@end
