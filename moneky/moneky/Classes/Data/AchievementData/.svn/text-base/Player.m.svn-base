//
//  Player.m
//  moneky
//
//  Created by Sood, Abhishek on 10/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Player.h"


@implementation Player

@dynamic playerId;
@dynamic playerName;
@dynamic winVeryEasy;
@dynamic winEasy;
@dynamic winNormal;
@dynamic winHard;
@dynamic winVeryHard;
@dynamic winImpossible;
@dynamic winPerfect;

-(int)winsForDifficulty:(DifficultyMode)diff{
    switch (diff) {
        case DifficultyModeVeryEasy:
            return [self.winVeryEasy intValue];
        case DifficultyModeEasy:
            return [self.winEasy intValue];
        case DifficultyModeNormal:
            return [self.winNormal intValue];
        case DifficultyModeHard:
            return [self.winHard intValue];
        case DifficultyModeVeryHard:
            return [self.winVeryHard intValue];
        case DifficultyModeImpossible:
            return [self.winImpossible intValue];
            
        default:
            assert(0);
            return 0;
    }
}

-(void)setWins:(int)wins ForDifficulty:(DifficultyMode)diff{
    switch (diff) {
        case DifficultyModeVeryEasy:
            self.winVeryEasy = [NSNumber numberWithInt:([self.winVeryEasy intValue] +1)];
            break;
        case DifficultyModeEasy:
            self.winEasy = [NSNumber numberWithInt:([self.winEasy intValue] +1)];
            break;
        case DifficultyModeNormal:
            self.winNormal = [NSNumber numberWithInt:([self.winNormal intValue] +1)];
            break;
        case DifficultyModeHard:
            self.winHard = [NSNumber numberWithInt:([self.winHard intValue] +1)];
            break;
        case DifficultyModeVeryHard:
            self.winVeryHard = [NSNumber numberWithInt:([self.winVeryHard intValue] +1)];
            break;
        case DifficultyModeImpossible:
            self.winImpossible = [NSNumber numberWithInt:([self.winImpossible intValue] +1)];
            break;
            
        default:
            assert(0);
    }
}

-(void)reset{
    NSNumber* num = [NSNumber numberWithInt:0];
    self.winVeryEasy = num;
    self.winEasy = num;
    self.winNormal = num;
    self.winHard = num;
    self.winNormal = num;
    self.winImpossible = num;
    self.winPerfect = num;
}

@end
