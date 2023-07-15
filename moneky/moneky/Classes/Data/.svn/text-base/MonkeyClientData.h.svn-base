//
//  MonkeyClientData.h
//  moneky
//
//  Created by Sood, Abhishek on 9/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Player.h"
#import <CoreData/CoreData.h>

extern NSString* const MonkeyGameURL;

@interface MonkeyClientData : NSObject{
    Player* _currentPlayer;
    NSManagedObjectContext* _managedObjectContext;
}

+(MonkeyClientData*)sharedData;
+(NSString*)getTextFontName;
+(ccColor3B)colorForDifficulty:(DifficultyMode)diff;
+(NSString *)getDifficultyString:(DifficultyMode)diff;
+(NSString *)getLeaderboardCategory:(DifficultyMode)diff;
+(float)getTimeForAchievement:(DifficultyMode)diff;
+(float)getTimeForLevel:(DifficultyMode)diff;

@property(retain,nonatomic) NSNumber* purchased;
@property(readonly,nonatomic) Player* currentPlayer;
@property(retain,nonatomic) NSNumber* effectsOn;
@property(retain,nonatomic) NSNumber* musicOn;

-(void)loadPlayer;
-(void)resetAchievements;
-(void)saveManagedObjectContext;

@end
