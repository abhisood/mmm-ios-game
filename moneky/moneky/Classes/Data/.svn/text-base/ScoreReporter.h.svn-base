//
//  ScoreReporter.h
//  moneky
//
//  Created by Sood, Abhishek on 10/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MonkeyAchievement : NSObject

@property(nonatomic,readonly)uint percentage;
@property(nonatomic,readonly)NSString* identifier;

+(id)achievementWithIdentifier:(NSString*)identifier andPercentage:(uint)percetage;

-(id)initWithIdentifier:(NSString*)identifier andPercentage:(uint)percetage;

@end



@interface ScoreReporter : NSObject

+(NSString*)getLeaderBoardForDifficulty:(DifficultyMode)diff;

// returns an array of achievements that might have been unlocked
+(NSArray*)checkAchievementsUnlocked:(DifficultyMode)diff bonus:(int)bonus timeTaken:(float)time andPerfect:(bool)perfect;

+(void)syncAchievements:(NSDictionary*)earnedAchievementsCache;

@end
