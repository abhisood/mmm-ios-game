//
//  TrophyNode.m
//  moneky
//
//  Created by Sood, Abhishek on 10/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TrophyNode.h"
#import "MonkeyClientData.h"
#import "GameCenterManager.h"
#import "GameKit/GameKit.h"

#define delta 50

@interface Parameters : NSObject
@property(nonatomic,assign) float dx;
@property(nonatomic,assign) float dy;
@property(nonatomic,assign) float dRotation;
@end

@implementation Parameters
@synthesize dx, dy, dRotation;

-(id)init{
    self = [super init];
    if (self) {
        self.dx = rand()%2 == 0?-1:1;
        self.dy = rand()%2 == 0?-1:1;
        self.dRotation = rand()%2 == 0?-1:1;
        self.dx *= (1+rand()%delta);
        self.dy *= (1+rand()%delta);
        self.dRotation *= (1+rand()%delta);
    }
    return self;
}

@end

@implementation TrophyNode
@synthesize parameters;

-(id)init{
    self = [super init];
    if (self) {
        [[GameCenterManager sharedManager] addObserver:self forKeyPath:@"earnedAchievementCache" options:NSKeyValueObservingOptionInitial context:NULL];
        [[GameCenterManager sharedManager] addObserver:self forKeyPath:@"achievementDescriptionCache" options:NSKeyValueObservingOptionInitial context:NULL];
        self.parameters = [NSMutableDictionary dictionary];
        [self scheduleUpdate];
    }
    return self;
}

-(void)dealloc{
    [[GameCenterManager sharedManager] removeObserver:self forKeyPath:@"earnedAchievementCache"];
    [[GameCenterManager sharedManager] removeObserver:self forKeyPath:@"achievementDescriptionCache"];
    self.parameters = nil;
    [super dealloc];
}

-(void)onEnter{
    [self validateLabels];
    [self resetLabelPositions];
    [self unscheduleUpdate];
    [self performSelector:@selector(scheduleUpdate) withObject:nil afterDelay:.3];
    [super onEnter];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self validateLabels];
    });
}

-(void)update:(ccTime)dt{
    NSDictionary* earnedAchievements = [[GameCenterManager sharedManager] earnedAchievementCache];
    NSDictionary* achievementDescriptions = [[GameCenterManager sharedManager] achievementDescriptionCache];
    if (earnedAchievements == nil ||
        achievementDescriptions == nil) return;

    for (GKAchievement* ach in [earnedAchievements allValues]) {
        
        CCLabelTTF* label = (CCLabelTTF*)[self getChildByTag:ach.hash];
        Parameters* para = [self.parameters objectForKey:ach.identifier];
        label.position = ccpAdd(label.position, ccp(dt*para.dx,dt* para.dy));
        label.rotation +=(dt* para.dRotation);

        CGSize winSize = [[CCDirector sharedDirector] winSize];
        if (label.position.x <= 0) {
            para.dx = abs(para.dx);
        }else if(label.position.x >= winSize.width){
            para.dx = -1 * abs(para.dx);
        }
        if (label.position.y <= 0) {
            para.dy = abs(para.dy);
        }else if(label.position.y >= winSize.height){
            para.dy = -1 * abs(para.dy);
        }
        if (label.rotation <= -45) {
            para.dRotation = abs(para.dRotation);
        }else if (label.rotation >= 45) {
            para.dRotation = -1 * abs(para.dRotation);
        }

    }
}

-(void)validateLabels{
    NSDictionary* earnedAchievements = [[GameCenterManager sharedManager] earnedAchievementCache];
    NSDictionary* achievementDescriptions = [[GameCenterManager sharedManager] achievementDescriptionCache];
    DLog(@"Validating achievement labels");
    if (earnedAchievements == nil ||
        achievementDescriptions == nil) {
        self.visible = NO;
    }else {
        self.visible = YES;
        for (CCNode* n in self.children) {
            if ([n isKindOfClass:[CCLabelTTF class]]) {
                n.visible = NO;
            }
        }
        for (GKAchievement* ach in [earnedAchievements allValues]) {
            CCLabelTTF* label = (CCLabelTTF*)[self getChildByTag:ach.hash];
            if (ach.percentComplete >= 100) {
                GKAchievementDescription* desc = [achievementDescriptions objectForKey:ach.identifier];
                NSString* title = [NSString stringWithFormat:@"\"%@\"",desc.title];
                if (!label) {
                    label = [CCLabelTTF labelWithString:title fontName:[MonkeyClientData getTextFontName] fontSize:[self getRandomFontSize]];
                    label.color = [self getRandomColor];
                    label.position = [self getRandomPosition];
                    label.rotation = [self getRandomBetweenMin:-45 andMax:45];
                    label.opacity = 220;
                    label.tag = ach.hash;
                    [self addChild:label];
                    
                    Parameters* p = [[[Parameters alloc] init] autorelease];
                    [self.parameters setObject:p forKey:ach.identifier];
                }
                label.string = [NSString stringWithFormat:@"\"%@\"",desc.title];
                label.visible = YES;
            }
        }
    }
}

-(int)getRandomBetweenMin:(int)min andMax:(int)max{
    return min + (rand() % (int)(max - min));    
}

-(float)getRandomFontSize{
    return [self getRandomBetweenMin:10 andMax:14];
}

-(ccColor3B)getRandomColor{
    GLubyte r = [self getRandomBetweenMin:50 andMax:170];
    GLubyte g = [self getRandomBetweenMin:50 andMax:170];
    GLubyte b = [self getRandomBetweenMin:50 andMax:170];
    return ccc3(r, g, b);
}

-(CGPoint)getRandomPosition{
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    float x = [self getRandomBetweenMin:winSize.width*0.1 andMax:winSize.width*0.3];
    if (rand() % 2 ==0) {
        x += winSize.width/2;
    }
    float y = [self getRandomBetweenMin:winSize.height*0.1 andMax:winSize.height*0.9];
    return CGPointMake(x, y);
}

-(void)resetLabelPositions{
    CGSize winsize = [CCDirector sharedDirector].winSize;
    CGPoint position = ccp(winsize.width/2, winsize.height/2);
    int i=0;
    for (CCNode* n in self.children) {
        if ([n isKindOfClass:[CCLabelTTF class]] && n.visible) {
            n.position =ccpAdd(position, ccp(0,((i+1)/2)*15*(i%2==0? 1:-1)));
            n.rotation = 0;
            i++;
        }
    }
}

@end
