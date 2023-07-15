//
//  RootViewController.m
//  moneky
//
//  Created by Sood, Abhishek on 8/30/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//

//
// RootViewController + iAd
// If you want to support iAd, use this class as the controller of your iAd
//

#import "cocos2d.h"

#import "RootViewController.h"
#import "MonkeyNotificationDefinitions.h"
#import "MonkeyClientData.h"
#import "Flurry.h"
#import "ScoreReporter.h"
#import <QuartzCore/QuartzCore.h>
#import "ShareViewController.h"

#define kAlertResetAchievements 1

@implementation RootViewController

@synthesize adBannerView,closeButton;
@synthesize hintView,infoLabel,titleLabel,hideTimer;

- (void) showAlertWithTitle: (NSString*) title message: (NSString*) message
{
	UIAlertView* alert= [[[UIAlertView alloc] initWithTitle: title message: message 
                                                   delegate: self cancelButtonTitle: @"OK" otherButtonTitles: nil] autorelease];
	[alert show];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[super viewDidLoad];
    self.adBannerView.requiredContentSizeIdentifiers = [NSSet setWithObject:ADBannerContentSizeIdentifierPortrait];
    self.adBannerView.currentContentSizeIdentifier = ADBannerContentSizeIdentifierPortrait;
    self.adBannerView.delegate=self;
    self.adBannerView.frame = CGRectOffset(self.adBannerView.frame, 0, 50);
    self.closeButton.alpha = 0;
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuShown) name:MonkeyNotificationGameMenuShown object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gamePlayShown) name:MonkeyNotificationGamePlayShown object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gamePlayCrucial) name:MonkeyNotificationGamePlayCrucial object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gamePlayNormal) name:MonkeyNotificationGamePlayNormal object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showLeaderboard) name:MonkeyNotificationShowLeaderboards object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showAchievements) name:MonkeyNotificationShowAchievements object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetAchievements) name:MonkeyNotificationResetAchievements object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showHint:) name:MonkeyNotificationShowHint object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reportScore:) name:MonkeyNotificationReportScore object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sharePhoto:) name:MonkeyNotificationSharePhoto object:nil];
    [[MonkeyClientData sharedData] addObserver:self forKeyPath:@"purchased" options:NSKeyValueObservingOptionNew context:NULL];
    
    [self removeBannerAd];
    self.hintView.transform = CGAffineTransformMakeScale(0.001, 0.001);
    //self.hintView.hidden = NO;
    self.hintView.layer.cornerRadius = 5;
    self.hintView.layer.masksToBounds = YES;  
    if ([GameCenterManager isGameCenterAvailable]) {
        [[GameCenterManager sharedManager] setDelegate:self];
        [[GameCenterManager sharedManager] authenticateLocalUser];
    }
}

-(void)removeBannerAd{
    if ([[MonkeyClientData sharedData].purchased boolValue]) {
        [self.adBannerView removeFromSuperview];
        self.adBannerView = nil;
        [self.closeButton removeFromSuperview];
        self.closeButton = nil;
    }
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if ([keyPath isEqualToString:@"purchased"]) {
        [self removeBannerAd];
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

-(void)gamePlayNormal{
    _gamePlayCrucial = NO;
    [self showBannerAdWithCancelButton:YES];
}

-(void)gamePlayCrucial{
    _gamePlayCrucial = YES;
    [self hideBannerAd:nil];
}

-(void)menuShown{
    _gamePlayCrucial = NO;
    [self showBannerAdWithCancelButton:NO];
}

-(void)gamePlayShown{
    [self showBannerAdWithCancelButton:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return ( ! UIInterfaceOrientationIsLandscape( interfaceOrientation ) );
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.adBannerView = nil;
    self.closeButton = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[MonkeyClientData sharedData] removeObserver:self forKeyPath:@"purchased"];
}


- (void)dealloc {
    self.hintView = nil;
    self.infoLabel = nil;
    self.titleLabel = nil;
    [self.hideTimer invalidate];
    self.hideTimer = nil;
    [adBannerView release];
    [closeButton release];
    [super dealloc];
}

#pragma mark -
#pragma mark Notification methods

-(void)sharePhoto:(NSNotification *) notification{
    NSAssert(notification.userInfo != nil,@"user info should not be nil when posting hint notification");
    ShareViewController *vc = [[ShareViewController alloc] initWithNibName:@"ShareViewController" bundle:nil];
    vc.image = [notification.userInfo objectForKey:kPhotoShareNotificationPhotoID];
    vc.text = [notification.userInfo objectForKey:kPhotoShareNotificationTextID];
    UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [self presentModalViewController:nav animated:YES];
    [vc release];
    [nav release];
}

-(void)showHint:(NSNotification *) notification{
    NSAssert(notification.userInfo != nil,@"user info should not be nil when posting hint notification");
    NSString* info = [notification.userInfo objectForKey:kHintNotificationInfo];
    NSString* title =[notification.userInfo objectForKey:kHintNotificationTitle]; 
    bool isError = [[notification.userInfo objectForKey:kHintNotificationIsError] boolValue];
    
    if (isError) {
        [self showError:info andTitle:title];
    }else {
        [self showConfirmation:info andTitle:title];
    }
}

-(void)reportScore:(NSNotification *) notification{
    NSAssert(notification.userInfo != nil,@"user info should not be nil when posting score report notification");
    if (![[GameCenterManager sharedManager] isAuthenticated]) {
        return;
    }
    DifficultyMode diff = [[notification.userInfo objectForKey:kScoreNotificationDifficulty] intValue]; 
    float timeTaken = [[notification.userInfo objectForKey:kScoreNotificationTime] floatValue];
    int bonus =[[notification.userInfo objectForKey:kScoreNotificationBonus] intValue]; 
    bool perfect = [[notification.userInfo objectForKey:kScoreNotificationPerfect] boolValue];
    
    NSString* leaderBoard = [ScoreReporter getLeaderBoardForDifficulty:diff];
    [[GameCenterManager sharedManager] reportScore:bonus time:timeTaken forCategory:leaderBoard];
    
    NSArray* achievementsUnlocked = [ScoreReporter checkAchievementsUnlocked:diff bonus:bonus timeTaken:timeTaken andPerfect:perfect];
    for (MonkeyAchievement* achievement in achievementsUnlocked) {
        [[GameCenterManager sharedManager]  submitAchievement:achievement.identifier percentComplete:achievement.percentage];
    }
}


#pragma mark -
#pragma mark HintView methods

-(void)showError:(NSString*)error andTitle:(NSString*)title{
    self.hintView.backgroundColor = [UIColor colorWithRed:189.0/255.0 green:10/255.0 blue:5/255.0 alpha:0.9];
    [self showHintView:error andTitle:title];
    NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:title, @"Title", error, @"Error Text", nil];
    [Flurry logEvent:@"Error Shown" withParameters:dict];
}

-(void)showConfirmation:(NSString*)info andTitle:(NSString*)title{
    UIColor* green = [UIColor colorWithRed:89.0/255.0 green:119.0/255.0 blue:39.0/255.0 alpha:0.9];
    self.hintView.backgroundColor = green;
    [self showHintView:info andTitle:title];
}

-(void)showHintView:(NSString*)info andTitle:(NSString*)title{
    if (self.hideTimer && self.hideTimer.isValid) {
        [self.hideTimer invalidate];
        self.hideTimer = nil;
//        self.hintView.transform = CGAffineTransformMakeScale(0.001, 0.001);
    }
    self.infoLabel.text = info;
    self.titleLabel.text = title;
    //self.hintView.hidden = NO;
    [UIView animateWithDuration:0.5f 
                     animations:^{
                         self.hintView.transform = CGAffineTransformMakeScale(1, 1);
                     } 
                     completion:^(BOOL finished) {
                         self.hideTimer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(dismissHintView) userInfo:nil repeats:NO];
                     }];
}

-(void)dismissHintView{
    DLog(@"Hint view dismissed. ----%@---%@---",self.titleLabel.text,self.infoLabel.text);
    [UIView animateWithDuration:0.5f 
                     animations:^{
                         self.hintView.transform = CGAffineTransformMakeScale(0.001, 0.001);
                     } completion:^(BOOL finished) {
                         //self.hintView.hidden = YES;
                     }];
}

#pragma mark -
#pragma mark ADBannerView methods

-(void)bannerViewDidLoadAd:(ADBannerView *)banner{
    [super viewDidLoad];
    
    _adLoadSuccess = YES;
    [self showBannerAdWithCancelButton:_showCancelButton];
    DLog(@"Banner loaded ad");
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error{
    _adLoadSuccess = NO;
    [self hideBannerAd:nil];
    DLog(@"Banner failed to load ad: \n%@", error.description);
}

-(void)bannerViewActionDidFinish:(ADBannerView *)banner{
    [[NSNotificationCenter defaultCenter] postNotificationName:MonkeyNotificationAdFinished object:nil];
    DLog(@"Banner finished ad");
}

-(void)bannerViewWillLoadAd:(ADBannerView *)banner{
    DLog(@"Banner will load ad");    
}

-(BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave{
    [[NSNotificationCenter defaultCenter] postNotificationName:MonkeyNotificationAdRunning object:nil];
    [Flurry logEvent:@"Banner Ad action begin"];
    return YES;
}

-(void)showBannerAdWithCancelButton:(bool)showCancelButton{
    _showCancelButton = showCancelButton;
    if (_adLoadSuccess && !_gamePlayCrucial) {
        [UIView animateWithDuration:0.5 animations:^{
            if (!_adShown) {
                _adShown = YES;
                self.adBannerView.frame = CGRectOffset(self.adBannerView.frame, 0, -50);
            }
            self.closeButton.alpha = showCancelButton?1:0;
        }];
    }
}

-(void)hideBannerAd:(id)sender{
    [UIView animateWithDuration:0.5 animations:^{
        if (_adShown) {
            _adShown = NO;
            self.adBannerView.frame = CGRectOffset(self.adBannerView.frame, 0, 50);
        }
        self.closeButton.alpha = 0;
    }];
}

#pragma mark -
#pragma mark highscore Methods

- (void) submitHighScore
{
    assert(0);
}

-(BOOL)isGameCenterUserAuthenticated{
    if (![GameCenterManager isGameCenterAvailable]) {
        return NO;
    }
    return [[GameCenterManager sharedManager] isAuthenticated];
}

#pragma mark GameCenter View Controllers
- (void)showGameCenterError{
    [self showError:@"Sign in the Game Center App to enable." andTitle:@"Game Center has been disabled."];
}

- (void) showLeaderboard{
    if (![self isGameCenterUserAuthenticated]){
        [self showGameCenterError];
        return;
    }
    
	GKLeaderboardViewController *leaderboardController = [[GKLeaderboardViewController alloc] init];
	if (leaderboardController != NULL) {
		leaderboardController.timeScope = GKLeaderboardTimeScopeAllTime;
		leaderboardController.leaderboardDelegate = self; 
		[self presentModalViewController: leaderboardController animated: YES];
        [Flurry logEvent:@"Leaderboards shown"];
	}
}

- (void)leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController{
	[self dismissModalViewControllerAnimated: YES];
	[viewController release];
}

- (void) showAchievements{
    if (![self isGameCenterUserAuthenticated]){
        [self showGameCenterError];
        return;
    }
	
    GKAchievementViewController *achievements = [[GKAchievementViewController alloc] init];
	if (achievements != NULL){
		achievements.achievementDelegate = self;
		[self presentModalViewController: achievements animated: YES];
        [Flurry logEvent:@"Achievements shown"];
	}
}

- (void)achievementViewControllerDidFinish:(GKAchievementViewController *)viewController{
	[self dismissModalViewControllerAnimated: YES];
	[viewController release];
}

- (void)resetAchievements{
    if (![self isGameCenterUserAuthenticated]){
        [self showGameCenterError];
        return;
    }
    UIAlertView* alert= [[[UIAlertView alloc] initWithTitle: @"Confirm" message: @"Are sure you want to reset your Achievements?" 
                                                   delegate: self 
                                          cancelButtonTitle: @"Cancel" 
                                          otherButtonTitles: @"Yes",nil] autorelease];
    alert.tag = kAlertResetAchievements;
    [alert show];
}

//Delegate method used by processGameCenterAuth to support looping waiting for game center authorization
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if (alertView.tag == kAlertResetAchievements) {
        if (buttonIndex == 1) {
            [[GameCenterManager sharedManager] resetAchievements];
        }
    }
}

#pragma mark -
#pragma mark GameCenterDelegateProtocol Methods
- (void) processGameCenterAuth: (NSError*) error
{
	if(error == nil){
        [[MonkeyClientData sharedData] loadPlayer];
	}else{
        if ([self isGameCenterUserAuthenticated]) {
            [[MonkeyClientData sharedData] loadPlayer];
            return;
        }
        if (error.code == GKErrorCancelled || 
            error.code == GKErrorUserDenied) {
            [self showGameCenterError];
            return;
        }
        [self showError:@"Unable to connect to GameCenter." andTitle:@"Game Center Login Failed!"];
        DLog(@"Game Center Login failerd %@",[error description]);
	}
}

- (void) mappedPlayerIDToPlayer: (GKPlayer*) player error: (NSError*) error;
{
	if((error == NULL) && (player != NULL)){
//		self.leaderboardHighScoreDescription= [NSString stringWithFormat: @"%@ got:", player.alias];
//		
//		if(self.cachedHighestScore != NULL)
//		{
//			self.leaderboardHighScoreString= self.cachedHighestScore;
//		}
//		else
//		{
//			self.leaderboardHighScoreString= @"-";
//		}
        
	}
	else
	{
//		self.leaderboardHighScoreDescription= @"GameCenter Scores Unavailable";
//		self.leaderboardHighScoreDescription=  @"-";
	}
}

- (void) reloadScoresComplete: (GKLeaderboard*) leaderBoard error: (NSError*) error;
{
	if(error != NULL)
	{
        DLog(@"Score loading failed %@",[error description]);
	}
}

- (void) scoreReported: (NSError*) error;
{
	if(error != NULL){
        [self showError:@"Unable to connect to GameCenter." andTitle:@"Unable to add score to Leaderboard!"];
        DLog(@"Score Report failed %@",[error description]);
	}
}



- (void) achievementSubmitted:(GKAchievement *)ach description:(GKAchievementDescription *)achDesc error:(NSError *)error{
	if((error == NULL) && (ach != NULL))
	{
        NSAssert(achDesc,@"Achievement description null for %@",ach.identifier);
		if(ach.percentComplete == 100.0)
		{
            NSString* title = [NSString stringWithFormat:@"Achievement Earned: %@",achDesc.title];
            NSString* message = achDesc.achievedDescription;
            [GKNotificationBanner showBannerWithTitle:title message: message
                                    completionHandler:^{
                
            }];
		}
        NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:ach.identifier,@"identifier", achDesc.title, @"title", achDesc.achievedDescription, @"description", nil];
        [Flurry logEvent:@"Achievement unlocked" withParameters:dict];
	}
	else
	{
        DLog(@"Achievement Submission Failed %@",[error description]);
        [self showError:@"Unable to connect to GameCenter." andTitle:@"Achievement Submission Failed!"];
	}
}

- (void) achievementResetResult: (NSError*) error{
	if(error != NULL)
	{
        DLog(@"Achievement Reset Failed! %@",[error description]);
        [self showError:@"Unable to connect to GameCenter." andTitle:@"Achievement Reset Failed!"];
	}else {
        [GKNotificationBanner  showBannerWithTitle:@"Achievements Reset!" message:nil completionHandler:^{
            
        }];
        [[MonkeyClientData sharedData] resetAchievements];
        [Flurry logEvent:@"Achievements Reset"];
    }
}



@end

