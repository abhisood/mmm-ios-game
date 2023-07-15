//
//  SoundManager.m
//  moneky
//
//  Created by Sood, Abhishek on 9/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SoundManager.h"
#import "SimpleAudioEngine.h"

static SoundManager* sharedSoundManager;

@implementation SoundManager


+(SoundManager*)sharedSoundManager{
    if (!sharedSoundManager) {
        sharedSoundManager = [[SoundManager alloc] init];
    }
    return sharedSoundManager;
}

-(void)playCheerSound{
    int i = rand() % 7;
    [[SimpleAudioEngine sharedEngine] playEffect:[NSString stringWithFormat:@"cheer%d.mp3",i]];
}

-(void)playLastCheerSound{
    [[SimpleAudioEngine sharedEngine] playEffect:@"last_match.mp3"];
}

-(void)playFailSound{
    [[SimpleAudioEngine sharedEngine] playEffect:@"fail0.mp3"];
}

-(void)playGameLostSound{
    [[SimpleAudioEngine sharedEngine] playEffect:@"gameLost.mp3"];
}

-(void)playPerfectSound{
    [[SimpleAudioEngine sharedEngine] playEffect:@"cheer6.mp3"];
}


@end
