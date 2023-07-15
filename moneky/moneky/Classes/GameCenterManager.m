/*
 
 File: GameCenterManager.m
 Abstract: Basic introduction to GameCenter
 
 Version: 1.1
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple Inc.
 ("Apple") in consideration of your agreement to the following terms, and your
 use, installation, modification or redistribution of this Apple software
 constitutes acceptance of these terms.  If you do not agree with these terms,
 please do not use, install, modify or redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and subject
 to these terms, Apple grants you a personal, non-exclusive license, under
 Apple's copyrights in this original Apple software (the "Apple Software"), to
 use, reproduce, modify and redistribute the Apple Software, with or without
 modifications, in source and/or binary forms; provided that if you redistribute
 the Apple Software in its entirety and without modifications, you must retain
 this notice and the following text and disclaimers in all such redistributions
 of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may be used
 to endorse or promote products derived from the Apple Software without specific
 prior written permission from Apple.  Except as expressly stated in this notice,
 no other rights or licenses, express or implied, are granted by Apple herein,
 including but not limited to any patent rights that may be infringed by your
 derivative works or by other works in which the Apple Software may be
 incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE MAKES NO
 WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED
 WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND OPERATION ALONE OR IN
 COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR
 CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
 GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, MODIFICATION AND/OR
 DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED AND WHETHER UNDER THEORY OF
 CONTRACT, TORT (INCLUDING NEGLIGENCE), STRICT LIABILITY OR OTHERWISE, EVEN IF
 APPLE HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2010 Apple Inc. All Rights Reserved.
 
 */

#import "GameCenterManager.h"
#import <GameKit/GameKit.h>
#import "ScoreReporter.h"
#import "MonkeyNotificationDefinitions.h"

static GameCenterManager* gcManager;

@implementation GameCenterManager

@synthesize earnedAchievementCache;
@synthesize achievementDescriptionCache;
@synthesize delegate;
@synthesize isAuthenticated;
@synthesize submitAchievementBlocks;
@synthesize requestingAcievements;
@synthesize friendPhotos,friendsScores,friends;

+(GameCenterManager*)sharedManager{
    if (!gcManager) {
        gcManager = [[GameCenterManager alloc] init];
    }
    return gcManager;
}

- (id) init
{
	self = [super init];
	if(self!= nil)
	{
		self.earnedAchievementCache= nil;
        self.submitAchievementBlocks = [NSMutableArray array];
        self.friendPhotos = [NSMutableDictionary dictionary];
        self.friends = [NSMutableDictionary dictionary];
        _reportingScoreCategory = nil;
	}
	return self;
}

- (void) dealloc
{
	self.earnedAchievementCache= nil;
    self.achievementDescriptionCache = nil;
    self.delegate = nil;
    self.submitAchievementBlocks = nil;
    self.friends = nil;
    self.friendPhotos = nil;
    self.friendsScores = nil;
	[super dealloc];
}

// NOTE:  GameCenter does not guarantee that callback blocks will be execute on the main thread.
// As such, your application needs to be very careful in how it handles references to view
// controllers.  If a view controller is referenced in a block that executes on a secondary queue,
// that view controller may be released (and dealloc'd) outside the main queue.  This is true
// even if the actual block is scheduled on the main thread.  In concrete terms, this code
// snippet is not safe, even though viewController is dispatching to the main queue:
//
//	[object doSomethingWithCallback:  ^()
//	{
//		dispatch_async(dispatch_get_main_queue(), ^(void)
//		{
//			[viewController doSomething];
//		});
//	}];
//
// UIKit view controllers should only be accessed on the main thread, so the snippet above may
// lead to subtle and hard to trace bugs.  Many solutions to this problem exist.  In this sample,
// I'm bottlenecking everything through  "callDelegateOnMainThread" which calls "callDelegate". 
// Because "callDelegate" is the only method to access the delegate, I can ensure that delegate
// is not visible in any of my block callbacks.

- (void) callDelegate: (SEL) selector withArg: (id) arg error: (NSError*) err
{
	assert([NSThread isMainThread]);
	if([delegate respondsToSelector: selector]) {
		if(arg != NULL){
			[delegate performSelector: selector withObject: arg withObject: err];
		}
		else{
			[delegate performSelector: selector withObject: err];
		}
	}
	else{
		DLog(@"Missed Method: %@",NSStringFromSelector(selector));
	}
}

- (void) callDelegateOnMainThread: (SEL) selector withArg: (id) arg error: (NSError*) err
{
	dispatch_async(dispatch_get_main_queue(), ^(void){
                       [self callDelegate: selector withArg: arg error: err];
                   });
}

+ (BOOL) isGameCenterAvailable
{
	// check for presence of GKLocalPlayer API
	Class gcClass = (NSClassFromString(@"GKLocalPlayer"));
	
	// check if the device is running iOS 4.1 or later
	NSString *reqSysVer = @"4.1";
	NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
	BOOL osVersionSupported = ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending);
	
	return (gcClass && osVersionSupported);
}

-(void)reloadAchievementCache:(onReturnBlock)onReturn{      
    if (self.achievementDescriptionCache != nil && self.earnedAchievementCache != nil) {
        self.requestingAcievements = NO;
        for (onReturnBlock block in self.submitAchievementBlocks) {
            block();
        }
        [self.submitAchievementBlocks removeAllObjects];
        if (onReturn) onReturn();
        return;
    }
    if (onReturn) [self.submitAchievementBlocks addObject:[[onReturn copy]autorelease]];
    if (self.requestingAcievements) {
        return;
    }
    self.requestingAcievements =  YES;
    [GKAchievement loadAchievementsWithCompletionHandler: ^(NSArray *scores, NSError *error){
        if(error == NULL){
            NSMutableDictionary* tempCache= [NSMutableDictionary dictionaryWithCapacity: [scores count]];
            for (GKAchievement* score in scores){
                [tempCache setObject: score forKey: score.identifier];
                if (score.percentComplete >=100) {
                    DLog(@"Achievement Unlocked: %@",score.identifier);
                }
            }
            self.earnedAchievementCache= tempCache;
            [self reloadAchievementCache:nil];
        }else{
            DLog(@"Unable to get achievements cache: %@",[error localizedDescription]);
        }  
    }];
    
    [GKAchievementDescription loadAchievementDescriptionsWithCompletionHandler:^(NSArray *descriptions, NSError *error) {
        if (error != nil) {
            DLog(@"Error getting achievement descriptions: %@", error);
        }
        NSMutableDictionary *achievementDescriptions = [[[NSMutableDictionary alloc] init] autorelease];
        for (GKAchievementDescription *achievementDescription in descriptions) {
            [achievementDescriptions setObject:achievementDescription forKey:achievementDescription.identifier];
        }
        self.achievementDescriptionCache = achievementDescriptions;
        [self reloadAchievementCache:nil];
    }];

}

- (void) authenticateLocalUser
{
	if(!self.isAuthenticated){
        
		[[GKLocalPlayer localPlayer] authenticateWithCompletionHandler:^(NSError *error){
            if (error == nil) {
                self.achievementDescriptionCache = nil;
                self.earnedAchievementCache = nil;
                [self reloadAchievementCache:^{
                    dispatch_async(dispatch_get_main_queue(), ^(void){
                        [ScoreReporter syncAchievements:self.earnedAchievementCache];
                    });
                }];
                [self loadPlayerPhoto:[GKLocalPlayer localPlayer]];
            }
             [self callDelegateOnMainThread: @selector(processGameCenterAuth:) withArg: NULL error: error];
         }];
	}
}

- (void) reloadHighScoresForCategory: (NSString*) category
{
	GKLeaderboard* leaderBoard= [[[GKLeaderboard alloc] init] autorelease];
	leaderBoard.category= category;
	leaderBoard.timeScope= GKLeaderboardTimeScopeAllTime;
	leaderBoard.range= NSMakeRange(1, 1);
	
	[leaderBoard loadScoresWithCompletionHandler:  ^(NSArray *scores, NSError *error){
         [self callDelegateOnMainThread: @selector(reloadScoresComplete:error:) withArg: leaderBoard error: error];
     }];
}
//
//- (void) retrieveFriends:(onReturnBlock)onReturn{
//    return; // do nothing 
//    GKLocalPlayer *lp = [GKLocalPlayer localPlayer];
//    if (lp.authenticated){
//        [lp loadFriendsWithCompletionHandler:^(NSArray *friendsArray, NSError *error) {
//            if (friendsArray != nil){
//                [GKPlayer loadPlayersForIdentifiers:friendsArray withCompletionHandler:^(NSArray *players, NSError *error) {
//                    if (error != nil){
//                        DLog(@"Error: %@",[error description]);
//                        self.friends = nil;
//                    }
//                    if (players != nil){
//                        self.friends = players;
//                        [self.friendPhotos removeAllObjects];
//                        for (GKPlayer *p in players) {
//                            [self loadPlayerPhoto:p];
//                        }
//                    }
//                }];
//                onReturn();
//            }
//        }];
//    }
//}


-(void)loadPlayers: (NSArray *) identifiers onCompletion:(onReturnBlock)onReturn{
    if([identifiers count]<1){
        dispatch_async(dispatch_get_main_queue(), ^(void){
            onReturn();
        });
        return;
    }
    
    [GKPlayer loadPlayersForIdentifiers:identifiers
                  withCompletionHandler:^(NSArray *players, NSError *error) {
                      if (error != nil){
                          DLog(@"Error loading players");
                      }
                      if (players != nil){
                          for (GKPlayer* player in players) {
                              [self.friends setObject:player forKey:player.playerID];
                              [self loadPlayerPhoto:player];
                          }
                      }
                      dispatch_async(dispatch_get_main_queue(), ^(void){
                          onReturn();
                      });
                  }];
}

- (void) loadPlayerPhoto: (GKPlayer*) player
{
    if ([self.friendPhotos objectForKey:player.playerID]) {
        return;
    }
    [player loadPhotoForSize:GKPhotoSizeSmall withCompletionHandler:^(UIImage *photo, NSError *error) {
        if (photo != nil){
            [self.friendPhotos setObject:photo forKey:player.playerID];
            postPhotoUpdatedNotification(self, player.playerID);
        }
        if (error != nil){
            DLog(@"Error getting photo for player %@: %@", player.playerID,[error description]);
        }
    }];
}

-(void)friendsHighScoresForCategory:(NSString *)category scope:(GKLeaderboardPlayerScope)playerScope onCompletion:(onReturnBlock)onReturn onError:(onReturnBlock)onError{
    GKLeaderboard* leaderBoard= [[[GKLeaderboard alloc] init] autorelease];
	leaderBoard.category= category;
	leaderBoard.timeScope= GKLeaderboardTimeScopeAllTime;
    leaderBoard.playerScope = playerScope;
	leaderBoard.range= NSMakeRange(1, 10);
    self.friendsScores = nil;
	
	[leaderBoard loadScoresWithCompletionHandler:  ^(NSArray *scores, NSError *error){
        DLog(@"highscores loaded");
        if ([scores count] < 2 && playerScope != GKLeaderboardPlayerScopeGlobal) {
            DLog(@"loading global highscores.");
            [self friendsHighScoresForCategory:category scope:GKLeaderboardPlayerScopeGlobal onCompletion:onReturn onError:(onReturnBlock)onError];
            return;
        }
        self.friendsScores = scores;
        NSMutableArray* playerIds = [NSMutableArray arrayWithCapacity:[scores count]];
        for (GKScore *score in scores) {
            if ([self.friends objectForKey:score.playerID]) {
                [self loadPlayerPhoto:[self.friends objectForKey:score.playerID]];
            }else{
                [playerIds addObject:score.playerID];
            }
        }
        [self loadPlayers:playerIds onCompletion:onReturn];
        if (error != nil) {
            DLog(@"Error Retriving friends scores: %@",[error description]);
            dispatch_async(dispatch_get_main_queue(), ^(void){
                onError();
            });
        }
        [self callDelegateOnMainThread: @selector(reloadScoresComplete:error:) withArg: leaderBoard error: error];
    }];
}

-(void)delayedLoadScore:(NSArray*)parms{
    [self friendsHighScoresForCategory:[parms objectAtIndex:0] onCompletion:[parms objectAtIndex:1] onError:[parms objectAtIndex:2]];
}

-(void)friendsHighScoresForCategory:(NSString *)category onCompletion:(onReturnBlock)onReturn onError:(onReturnBlock)onError{
    if (_reportingScoreCategory && [_reportingScoreCategory isEqualToString:category]) {
        DLog(@"Friend highscore load request delayed.");
        [self performSelector:@selector(delayedLoadScore:) withObject:[NSArray arrayWithObjects:category, [[onReturn copy] autorelease], [[onError copy] autorelease], nil] afterDelay:1];
        return;
    }
    [self friendsHighScoresForCategory:category scope:GKLeaderboardPlayerScopeFriendsOnly onCompletion:onReturn onError:(onReturnBlock)onError];
}


- (void) reportScore: (int64_t) score time:(float)time forCategory: (NSString*) category
{
    [_reportingScoreCategory release];
    _reportingScoreCategory = nil;
    _reportingScoreCategory = [category copy];
	GKScore *scoreReporter = [[[GKScore alloc] initWithCategory:category] autorelease];	
	scoreReporter.value = score;
    scoreReporter.context = time;
	[scoreReporter reportScoreWithCompletionHandler: ^(NSError *error){
        [_reportingScoreCategory release];
        _reportingScoreCategory = nil;
		 [self callDelegateOnMainThread: @selector(scoreReported:) withArg: NULL error: error];
	 }];
}

- (void) submitAchievement: (NSString*) identifier percentComplete: (double) percentComplete
{
	//GameCenter check for duplicate achievements when the achievement is submitted, but if you only want to report 
	// new achievements to the user, then you need to check if it's been earned 
	// before you submit.  Otherwise you'll end up with a race condition between loadAchievementsWithCompletionHandler
	// and reportAchievementWithCompletionHandler.  To avoid this, we fetch the current achievement list once,
	// then cache it and keep it updated with any new achievements.
    
    [self reloadAchievementCache:^{
        //Search the list for the ID we're using...
		GKAchievement* achievement= [self.earnedAchievementCache objectForKey: identifier];
		if(achievement != NULL){
			if((achievement.percentComplete >= 100.0) || (achievement.percentComplete >= percentComplete)){
				//Achievement has already been earned so we're done.
				achievement= NULL;
			}else {
                achievement.percentComplete= percentComplete;
            }
		}else{
			achievement= [[[GKAchievement alloc] initWithIdentifier: identifier] autorelease];
			achievement.percentComplete= percentComplete;
			//Add achievement to achievement cache...
			[self.earnedAchievementCache setObject: achievement forKey: achievement.identifier];
		}
		if(achievement!= NULL){
			//Submit the Achievement...
			[achievement reportAchievementWithCompletionHandler: ^(NSError *error){
                dispatch_async(dispatch_get_main_queue(), ^(void){
                    [self.delegate achievementSubmitted:achievement description:[self.achievementDescriptionCache objectForKey:achievement.identifier] error:error];
                });
            }];
		}
    }];
}

-(BOOL)isAuthenticated{
    return [GKLocalPlayer localPlayer].isAuthenticated;
}

- (void) resetAchievements{
	[GKAchievement resetAchievementsWithCompletionHandler: ^(NSError *error){
        self.earnedAchievementCache = nil;
        self.achievementDescriptionCache = nil;
        [self reloadAchievementCache:nil];
        [self callDelegateOnMainThread: @selector(achievementResetResult:) withArg: NULL error: error];
    }];
}

@end
