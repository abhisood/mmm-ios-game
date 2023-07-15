//
//  RootViewController.h
//  moneky
//
//  Created by Sood, Abhishek on 8/30/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iAD/iAD.h>
#import "GameCenterManager.h"
#import <GameKit/Gamekit.h>

@interface RootViewController : UIViewController <ADBannerViewDelegate,GKLeaderboardViewControllerDelegate, GKAchievementViewControllerDelegate, GameCenterManagerDelegate>{
    bool _showCancelButton;
    bool _adLoadSuccess;
    bool _adShown;
    bool _adRunning;
    bool _gamePlayCrucial;
}

@property(nonatomic,retain)IBOutlet ADBannerView *adBannerView;
@property(nonatomic,retain)IBOutlet UIButton *closeButton;
@property(nonatomic,retain)IBOutlet UIView *hintView;
@property(nonatomic,retain)IBOutlet UILabel *titleLabel;
@property(nonatomic,retain)IBOutlet UILabel *infoLabel;
@property(nonatomic,retain)NSTimer *hideTimer;

-(IBAction)hideBannerAd:(id)sender;

@end
