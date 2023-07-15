//
//  PlayerScoreNode.h
//  moneky
//
//  Created by Sood, Abhishek on 12/14/12.
//
//

#import "cocos2d.h"

@interface PlayerScore : NSObject
@property(nonatomic,copy) NSString* playerID;
@property(nonatomic,copy) NSString* name;
@property(nonatomic,copy) NSString* score;
@property(nonatomic,retain) UIImage* photo;
@property(nonatomic,assign) uint rank;
@property(nonatomic,assign) uint64_t time;

@end

@interface PlayerScoreNode:CCNode<CCTargetedTouchDelegate>{
    CCNode *_scrollNode;
    CGPoint _touchStartPoint;
    NSMutableDictionary *_playerScoreNodes;
    NSMutableDictionary *_playerScores;
}

-(id)initWithPlayerScores:(NSArray*)players;

@end

@interface PlayerScoreNodeSingle : CCNode{
    CCLabelTTF *_positionIndexLabel;
    CCLabelTTF *_name;
    CCLabelTTF *_score;
    CCLabelTTF *_time;
    CCSprite *_photo;
    PlayerScore *_player;
}

-(id)initWithPlayerScore:(PlayerScore*)player;

@end
