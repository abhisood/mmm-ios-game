//
//  ScoreReporter.m
//  moneky
//
//  Created by Sood, Abhishek on 10/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ScoreReporter.h"
#import "MonkeyClientData.h"
#import "Player.h"
#import "GameKit/GameKit.h"

@implementation MonkeyAchievement

@synthesize identifier = _identifier;
@synthesize percentage = _percentage;

+(id)achievementWithIdentifier:(NSString*)identifier andPercentage:(uint)percetage{
    return [[[MonkeyAchievement alloc] initWithIdentifier:identifier andPercentage:percetage] autorelease];
}

-(id)initWithIdentifier:(NSString *)identifier andPercentage:(uint)percentage{
    self = [super init];
    if(self){
        _identifier = identifier;
        if(percentage > 100) percentage = 100;
        _percentage = percentage;
    }
    return  self;
}

@end

@implementation ScoreReporter

+(NSString*)getLeaderBoardForDifficulty:(DifficultyMode)diff{
    switch (diff) {
        case DifficultyModeVeryEasy:
            return @"leaderboard_very_easy";
        case DifficultyModeEasy:
            return @"leaderboard_easy";
        case DifficultyModeNormal:
            return @"leaderboard_normal";
        case DifficultyModeHard:
            return @"leaderboard_hard";
        case DifficultyModeVeryHard:
            return @"leaderboard_very_hard";
        case DifficultyModeImpossible:
            return @"leaderboard_impossible";            
        default:
            NSAssert(NO, @"Should not happen ever");
            break;
    }
}

+(NSString*)getDiffString:(DifficultyMode)diff{
    switch (diff) {
        case DifficultyModeVeryEasy:
            return @"very_easy";
        case DifficultyModeEasy:
            return @"easy";
        case DifficultyModeNormal:
            return @"normal";
        case DifficultyModeHard:
            return @"hard";
        case DifficultyModeVeryHard:
            return @"very_hard";
        case DifficultyModeImpossible:
            return @"impossible";            
        default:
            NSAssert(NO, @"Should not happen ever");
            break;
    }
}

+(void)addWinAchievements:(NSMutableArray*)array diffString:(NSString*)diffString wins:(int)wins{
    [array addObject:[MonkeyAchievement achievementWithIdentifier:[NSString stringWithFormat:@"achievement_win_%@_1",diffString] andPercentage:wins*100]];
    //[array addObject:[MonkeyAchievement achievementWithIdentifier:[NSString stringWithFormat:@"achievement_win_%@_5",diffString] andPercentage:wins*20]];
    [array addObject:[MonkeyAchievement achievementWithIdentifier:[NSString stringWithFormat:@"achievement_win_%@_10",diffString] andPercentage:wins*10]];
}

+(void)addTimeAchievement:(NSMutableArray*)array diffString:(NSString*)diffString{
    [array addObject:[MonkeyAchievement achievementWithIdentifier:[NSString stringWithFormat:@"achievement_time_%@",diffString] andPercentage:100]];
}


+(NSArray*)checkAchievementsUnlocked:(DifficultyMode)diff bonus:(int)bonus timeTaken:(float)time andPerfect:(bool)perfect{
    NSMutableArray *achievements = [[NSMutableArray alloc] init];
    NSString* diffString = [ScoreReporter getDiffString:diff];
    int wins = 0;
    
    Player *player = [MonkeyClientData sharedData].currentPlayer;
    NSAssert(player != nil, @"current player cannot be nil");
    if (bonus>0) {
        wins = [player winsForDifficulty:diff];
        [player setWins:wins+1 ForDifficulty:diff];
        if (perfect) {
            player.winPerfect = [NSNumber numberWithInt:[player.winPerfect intValue] + 1];
        }
        if (time < [MonkeyClientData getTimeForAchievement:diff]) {
            [ScoreReporter addTimeAchievement:achievements diffString:diffString];                
        }
        [[MonkeyClientData sharedData] saveManagedObjectContext];
    }
    wins = [player winsForDifficulty:diff];
    [ScoreReporter addWinAchievements:achievements diffString:diffString wins:wins];
            
    wins = [player.winPerfect intValue];
    [achievements addObject:[MonkeyAchievement achievementWithIdentifier:@"achievement_score_perfect_1" andPercentage:wins*100]];
    [achievements addObject:[MonkeyAchievement achievementWithIdentifier:@"achievement_score_perfect_5" andPercentage:wins*20]];
    [achievements addObject:[MonkeyAchievement achievementWithIdentifier:@"achievement_score_perfect_10" andPercentage:wins*10]];

    return [achievements autorelease];
}

+(void)syncAchievements:(NSDictionary*)earnedAchievementsCache{
    Player *player = [MonkeyClientData sharedData].currentPlayer;
    NSAssert(player,@"current player cannot be nil");
    for (int i =DifficultyModeVeryEasy; i<=DifficultyModeImpossible;i++){
        NSString* diffString = [ScoreReporter getDiffString:i];
        NSString* achID = [NSString stringWithFormat:@"achievement_win_%@_10",diffString];
        GKAchievement* achievement= [earnedAchievementsCache objectForKey:achID ];
        if (achievement != nil) {
            int winsPlayer = [player winsForDifficulty:i];
            int winsAchieved = achievement.percentComplete/10;
            if (winsAchieved > winsPlayer) {
                [player setWins:winsAchieved ForDifficulty:i];
            }            
        }
    }
    GKAchievement* achievement= [earnedAchievementsCache objectForKey:@"achievement_score_perfect_10"];
    if (achievement != nil) {
        int winsPlayer = [player.winPerfect intValue];
        int winsAchieved = achievement.percentComplete/10;
        if (winsAchieved > winsPlayer) {
            player.winPerfect = [NSNumber numberWithInt:winsAchieved];
        }
    }
    [[MonkeyClientData sharedData] saveManagedObjectContext];
}


@end
