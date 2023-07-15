//
//  MonkeyClientData.m
//  moneky
//
//  Created by Sood, Abhishek on 9/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MonkeyClientData.h"
#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "GameKit/GameKit.h"
#import "MonkeyNotificationDefinitions.h"

NSString* const MonkeyGameURL = @"http://MonkeyMatchMayhem.com";

static MonkeyClientData* data;

@implementation MonkeyClientData

@dynamic purchased;
@dynamic effectsOn;
@dynamic musicOn;


+(NSString *)getTextFontName{
    if ([UIFont fontWithName:@"Chalkduster" size:10]) {
        return @"Chalkduster";
    }else{
        return @"AmericanTypewriter";
    }
}

+(float)getTimeForLevel:(DifficultyMode)diff{
    return 2* [MonkeyClientData getTimeForAchievement:diff];
}

+(float)getTimeForAchievement:(DifficultyMode)diff{
    switch (diff) {
        case DifficultyModeVeryEasy:
            return 15;
        case DifficultyModeEasy:
            return 25;
        case DifficultyModeNormal:
            return 50;
        case DifficultyModeHard:
            return 60;
        case DifficultyModeVeryHard:
            return 75;
        case DifficultyModeImpossible:
            return 90;
        default:
            NSAssert(NO, @"Should not happen ever");
            break;
    }
}

+(NSString *)getDifficultyString:(DifficultyMode)diff{
    switch (diff) {
        case DifficultyModeVeryEasy:
            return @"Very Easy";
            
        case DifficultyModeEasy:
            return @"Easy";
            
        case DifficultyModeNormal:
            return @"Normal";
            
        case DifficultyModeHard:
            return @"Hard";
            
        case DifficultyModeVeryHard:
            return @"Very Hard";
            
        case DifficultyModeImpossible:
            return @"Impossible";
            
        default:
            break;
    }
    return nil;
}

+(NSString *)getLeaderboardCategory:(DifficultyMode)diff{
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
            break;
    }
    return @"leaderboard_total_score";
}

+(ccColor3B)colorForDifficulty:(DifficultyMode)diff{
    switch (diff) {
        case DifficultyModeVeryEasy:
            return ccc3(15, 220, 0);
        case DifficultyModeEasy:
            return ccc3(60, 220, 0);
        case DifficultyModeNormal:
            return ccc3(100, 160, 0);
        case DifficultyModeHard:
            return ccc3(160, 100, 0);
        case DifficultyModeVeryHard:
            return ccc3(200, 60, 0);
        case DifficultyModeImpossible:
            return ccc3(220, 15, 0);
        default:
            return ccBLACK;
    }
}

+(MonkeyClientData*)sharedData{
    if (!data) {
        data = [[MonkeyClientData alloc] init];
    }
    return data;
}

-(id)init{
    self = [super init];
    if (self) {
        NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithInt:0],NSStringFromSelector(@selector(purchased)),
                              [NSNumber numberWithInt:1],NSStringFromSelector(@selector(effectsOn)),
                              [NSNumber numberWithInt:1],NSStringFromSelector(@selector(musicOn)),
                              nil];
        [[NSUserDefaults standardUserDefaults] registerDefaults:dict];
        _managedObjectContext = [[(AppDelegate*)[UIApplication sharedApplication].delegate managedObjectContext] retain];
    }
    return self;
}

-(void)dealloc{
    [_managedObjectContext release];
    [_currentPlayer release];
    [super dealloc];
}

-(void)addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(void *)context{
    [[NSUserDefaults standardUserDefaults] addObserver:observer forKeyPath:keyPath options:options context:context];
}


- (void)removeObserver:(NSObject*)anObserver forKeyPath:(NSString*)keyPath
{
    // Forward on to NSUserDefaults
    @try {
        [[NSUserDefaults standardUserDefaults] removeObserver:anObserver forKeyPath:keyPath];
    }
    @catch (NSException *exception) {
        DLog(@"main: Caught %@: %@", [exception name], [exception reason]);
    }
    @finally {
        
    }
}

- (NSMethodSignature*)methodSignatureForSelector:(SEL)aSelector
{
    if([NSStringFromSelector(aSelector) hasPrefix:@"set"])
    {
        return [NSMethodSignature signatureWithObjCTypes:"v@:@"];
    }
    
    return [NSMethodSignature signatureWithObjCTypes:"@@:"];
}

- (void)forwardInvocation:(NSInvocation*) anInvocation{
    NSString *selector = NSStringFromSelector(anInvocation.selector);
    NSUInteger argumentsCount = [[anInvocation methodSignature] numberOfArguments];
    if([selector hasPrefix:@"set"] && argumentsCount > 2)
    {
        NSRange firstChar, rest;
        firstChar.location  = 3;
        firstChar.length    = 1;
        rest.location       = 4;
        rest.length         = selector.length - 5;
        
        selector = [NSString stringWithFormat:@"%@%@",
                    [[selector substringWithRange:firstChar] lowercaseString],
                    [selector substringWithRange:rest]];
        
        id value;
        [anInvocation getArgument:&value atIndex:2];
        
        [[NSUserDefaults standardUserDefaults] setObject:value forKey:selector];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    else
    {
        selector = [NSString stringWithFormat:@"%@", selector];
        
        id value = [[NSUserDefaults standardUserDefaults] objectForKey:selector];
        [anInvocation setReturnValue:&value];
    }
}

-(void)resetAchievements{    
    NSAssert(_currentPlayer != nil, @"Can't reset achievements if current player is null");
    [_currentPlayer reset];
    [self saveManagedObjectContext];
}

-(void)loadPlayer{
    if (_currentPlayer != nil) {
        [_currentPlayer release];
        _currentPlayer = nil;
    }
    GKLocalPlayer* player = [GKLocalPlayer localPlayer];
    NSAssert(player.isAuthenticated, @"Can't load a player whos not authenticated");
    
    _currentPlayer = [[self fetchPlayer:player.playerID] retain];
    _currentPlayer.playerName = player.alias;
    [[NSNotificationCenter defaultCenter] postNotificationName:MonkeyNotificationGameCenterPlayerLoaded object:self];
    [self saveManagedObjectContext];
}

-(Player *)currentPlayer{
    return _currentPlayer;
}

#pragma mark -
#pragma mark core data
-(void)saveManagedObjectContext{
    NSError *error;
	if ( [_managedObjectContext hasChanges] && ![_managedObjectContext save:&error]) {
		// This is a serious error saying the record could not be saved.
		// Advise the user to restart the application
        DLog(@"Unable to save managed object context: %@",[error localizedDescription]);
	}
}

- (Player*)fetchPlayer:(NSString*)playerID{
	
	// Define our table/entity to use
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Player" inManagedObjectContext:_managedObjectContext];
	
	// Setup the fetch request
	NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
	[request setEntity:entity];
	[request setPredicate:[NSPredicate predicateWithFormat:@"playerId == %@",playerID]];
	
    //NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Player"];
	// Fetch the records and handle an error
	NSError *error;
	NSArray *results = [_managedObjectContext executeFetchRequest:request error:&error];
	
	if (!results ) {
		// Handle the error.
		// This is a serious error and should advise the user to restart the application
        DLog(@"Unable to execute fetch request: %@ %@",[error localizedDescription], error.debugDescription);
	}
    NSAssert([results count] <=1,@"Got multiple values for same player id in db\nID: %@\nValues: %@",playerID,results);
    
    // player does not exist
    if ([results count] == 0) {
        return [self addPlayer:playerID];
    }else {
        return [results objectAtIndex:0];
    }	
}

- (Player*)addPlayer:(NSString*)playerId {
	
	Player *player = (Player *)[NSEntityDescription insertNewObjectForEntityForName:@"Player" inManagedObjectContext:_managedObjectContext];
    player.playerId = playerId;
    [player reset];
    [self saveManagedObjectContext];
	return player;
}


@end
