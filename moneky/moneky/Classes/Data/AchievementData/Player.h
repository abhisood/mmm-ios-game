//
//  Player.h
//  moneky
//
//  Created by Sood, Abhishek on 10/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Player : NSManagedObject

@property (nonatomic, retain) NSString * playerId;
@property (nonatomic, retain) NSString * playerName;
@property (nonatomic, retain) NSNumber * winVeryEasy;
@property (nonatomic, retain) NSNumber * winEasy;
@property (nonatomic, retain) NSNumber * winNormal;
@property (nonatomic, retain) NSNumber * winHard;
@property (nonatomic, retain) NSNumber * winVeryHard;
@property (nonatomic, retain) NSNumber * winImpossible;
@property (nonatomic, retain) NSNumber * winPerfect;


-(int)winsForDifficulty:(DifficultyMode)diff;

-(void)setWins:(int)wins ForDifficulty:(DifficultyMode)diff;

-(void)reset;

@end
