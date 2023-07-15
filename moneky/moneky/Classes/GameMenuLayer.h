//
//  HelloWorldLayer.h
//  moneky
//
//  Created by Sood, Abhishek on 8/30/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//


// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"

// HelloWorldLayer
@interface GameMenuLayer : CCLayer
{
    CCMenu* _playMenu;
    CCMenu* _gameMenu;
    CCMenu* _infoMenu;
    CCMenu* _backMenu;
    CCSprite* _gameTitle;
    CCMenuItemFont *_play;
    NSMutableArray* _lockItems;
    bool _infoMenuShown;
}

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;

@end
