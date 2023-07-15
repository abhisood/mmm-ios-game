//
//  MonkeyNotificationDefinitions.m
//  moneky
//
//  Created by Sood, Abhishek on 9/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MonkeyNotificationDefinitions.h"

NSString* const MonkeyNotificationGameMenuShown = @"_MonkeyNotificationGameMenuShown";
NSString* const MonkeyNotificationGamePlayShown = @"_MonkeyNotificationGamePlayShown";
NSString* const MonkeyNotificationGamePlayCrucial = @"_MonkeyNotificationGamePlayCrucial";
NSString* const MonkeyNotificationGamePlayNormal = @"_MonkeyNotificationGamePlayNormal";
NSString* const MonkeyNotificationAdRunning = @"_MonkeyNotificationAdRunning";
NSString* const MonkeyNotificationAdFinished = @"_MonkeyNotificationAdFinished";
NSString* const MonkeyNotificationLeavingApp = @"_MonkeyNotificationLeavingApp";
NSString* const MonkeyNotificationShowLeaderboards = @"_MonkeyNotificationShowLeaderboards";
NSString* const MonkeyNotificationShowAchievements = @"_MonkeyNotificationShowAchievements";
NSString* const MonkeyNotificationResetAchievements = @"_MonkeyNotificationResetAchievements";
NSString* const MonkeyNotificationShowHint = @"_MonkeyNotificationShowHint";
NSString* const MonkeyNotificationReportScore = @"_MonkeyNotificationReportScore";
NSString* const MonkeyNotificationPhotoUpdated = @"_MonkeyNotificationPhotoUpdated";
NSString* const MonkeyNotificationGameCenterPlayerLoaded = @"_MonkeyNotificationGameCenterPlayerLoaded";
NSString* const MonkeyNotificationSharePhoto = @"_MonkeyNotificationSharePhoto";

void postHintNotification(id object,NSString* title, NSString* info, bool isError){
    NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          title, kHintNotificationTitle,
                          info, kHintNotificationInfo,
                          [NSNumber numberWithBool:isError], kHintNotificationIsError, nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:MonkeyNotificationShowHint object:object userInfo:dict];

}

void postScoreNotification(id object, DifficultyMode diffMode, int bonus, float timeTaken, bool perfect){
    NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          [NSNumber numberWithInt:diffMode], kScoreNotificationDifficulty,
                          [NSNumber numberWithInt:bonus], kScoreNotificationBonus,
                          [NSNumber numberWithFloat:timeTaken], kScoreNotificationTime,
                          [NSNumber numberWithBool:perfect], kScoreNotificationPerfect, nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:MonkeyNotificationReportScore object:object userInfo:dict];    
}

void postPhotoUpdatedNotification(id object, NSString* playerID){
    NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          playerID, kPhotoNotificationPlayerID, nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:MonkeyNotificationPhotoUpdated object:object userInfo:dict];
}

void postSharePhotoNotification(id object, UIImage* image, NSString* text){
    NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          image, kPhotoShareNotificationPhotoID,
                          text, kPhotoShareNotificationTextID, nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:MonkeyNotificationSharePhoto object:object userInfo:dict];
}