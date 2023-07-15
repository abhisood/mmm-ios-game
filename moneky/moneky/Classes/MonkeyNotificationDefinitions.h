//
//  MonkeyNotificationDefinitions.h
//  moneky
//
//  Created by Sood, Abhishek on 9/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kHintNotificationInfo @"_HintNotificationInfo"
#define kHintNotificationTitle @"_HintNotificationTitle"
#define kHintNotificationIsError @"_HintNotificationIsError"

#define kScoreNotificationDifficulty @"_ScoreNotificationDifficulty"
#define kScoreNotificationBonus @"_ScoreNotificationBonus"
#define kScoreNotificationTime @"_ScoreNotificationTime"
#define kScoreNotificationPerfect @"_ScoreNotificationPerfect"

#define kPhotoNotificationPlayerID @"_kPhotoNotificationPlayerID"

#define kPhotoShareNotificationPhotoID @"_kPhotoShareNotificationPhotoID"
#define kPhotoShareNotificationTextID @"_kPhotoShareNotificationTextID"

extern NSString* const MonkeyNotificationGameMenuShown;
extern NSString* const MonkeyNotificationGamePlayShown;
extern NSString* const MonkeyNotificationGamePlayCrucial;
extern NSString* const MonkeyNotificationGamePlayNormal;
extern NSString* const MonkeyNotificationAdRunning;
extern NSString* const MonkeyNotificationLeavingApp;
extern NSString* const MonkeyNotificationAdFinished;
extern NSString* const MonkeyNotificationShowLeaderboards;
extern NSString* const MonkeyNotificationShowAchievements;
extern NSString* const MonkeyNotificationResetAchievements;
extern NSString* const MonkeyNotificationShowHint;
extern NSString* const MonkeyNotificationReportScore;
extern NSString* const MonkeyNotificationPhotoUpdated;
extern NSString* const MonkeyNotificationGameCenterPlayerLoaded;
extern NSString* const MonkeyNotificationSharePhoto;

void postHintNotification(id object, NSString* title, NSString* info, bool isError);

void postScoreNotification(id object, DifficultyMode diffMode, int bonus, float timeTaken, bool perfect);

void postPhotoUpdatedNotification(id object, NSString* playerID);

void postSharePhotoNotification(id object, UIImage* photo, NSString* text);