//
//  PlayerScoreNode.m
//  moneky
//
//  Created by Sood, Abhishek on 12/14/12.
//
//

#import "PlayerScoreNode.h"
#import "MonkeyClientData.h"
#import "GameKit/GameKit.h"
#import "MonkeyNotificationDefinitions.h"
#import "GameCenterManager.h"
#import "ccUtils.h"

@implementation PlayerScore

@synthesize name,rank,photo,score,playerID,time;

@end

#define kWidth 80
#define kHeight 90
#define kVerticalMargin 5

@implementation PlayerScoreNode
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_playerScoreNodes release];
    [_playerScores release];
    [_scrollNode release];
    [super dealloc];
}

-(id)initWithPlayerScores:(NSArray *)players{
    self = [super init];
    if (self) {
        _playerScores = [[NSMutableDictionary dictionaryWithCapacity:players.count] retain];
        _playerScoreNodes = [[NSMutableDictionary dictionaryWithCapacity:players.count] retain];
        [_scrollNode release];
        _scrollNode = [[CCNode node] retain];
        [self addChild:_scrollNode];
        CGFloat x = 10;
        for (PlayerScore* player in players) {
            [_playerScores setObject:player forKey:player.playerID];
            PlayerScoreNodeSingle* node = [[PlayerScoreNodeSingle alloc] initWithPlayerScore:player];
            [_scrollNode addChild:node];
            node.position = ccp(x,0);
            x += (kWidth + 10);
            [_playerScoreNodes setObject:node forKey:player.playerID];
            [node release];
        }
        _scrollNode.contentSize = CGSizeMake(x,kHeight);
        CGFloat scrollNodeX = 0;
        if (_scrollNode.contentSize.width < [CCDirector sharedDirector].winSize.width ) {
            scrollNodeX = [CCDirector sharedDirector].winSize.width - _scrollNode.contentSize.width;
            scrollNodeX /= 2;
        }
        _scrollNode.position = ccp(scrollNodeX,10);
        
        CCLabelTTF *highScoreLabel = [CCLabelTTF labelWithString:@"HIGH SCORES" fontName:kMenuFont fontSize:18];
        self.contentSize = CGSizeMake([CCDirector sharedDirector].winSize.width, kHeight + kVerticalMargin *3 + highScoreLabel.boundingBox.size.height);
        
        highScoreLabel.position = ccp(self.contentSize.width/2,self.contentSize.height - highScoreLabel.boundingBox.size.height/2 - kVerticalMargin);
        highScoreLabel.color = kColorGreen;
        [self addChild:highScoreLabel];
        
        CCSprite* background = [CCSprite spriteWithFile:@"back_tex.png"];
        background.contentSize = self.contentSize;
        background.position = ccp(self.contentSize.width/2,self.contentSize.height/2);
        ccTexParams params = {GL_LINEAR,GL_LINEAR,GL_REPEAT,GL_REPEAT};
        [background.texture setTexParameters:&params];
        [background setTextureRect: CGRectMake(0.0, 0.0, self.contentSize.width, self.contentSize.height)];
        [self addChild:background z:-1];
        _touchStartPoint = CGPointZero;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatePhoto:) name:MonkeyNotificationPhotoUpdated object:nil];
    }
    return self;
}

-(void)updatePhoto:(NSNotification *) notification{
    NSAssert(notification.userInfo != nil,@"user info should not be nil when posting photo update notification");
    NSString* playerId = [notification.userInfo objectForKey:kPhotoNotificationPlayerID];
    PlayerScore* playerScore = [_playerScores objectForKey:playerId];
    if (playerScore) {
        UIImage* newImage = [[GameCenterManager sharedManager].friendPhotos objectForKey:playerId];
        if (playerScore.photo != newImage) {
            playerScore.photo = newImage;
        }
    }
}

-(void)onEnterTransitionDidFinish{
    [[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
    [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:INT_MIN+3 swallowsTouches:YES];
}

-(BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event{
    CGPoint point = [self convertTouchToNodeSpace:touch];
    CGRect rect = CGRectMake(0, 0, self.contentSize.width, self.contentSize.height);
    if (CGRectContainsPoint(rect, point)) {
        _touchStartPoint = point;
        return YES;
    }
    return NO;
}

-(void)ccTouchCancelled:(UITouch *)touch withEvent:(UIEvent *)event{
    _touchStartPoint = CGPointZero;
}

-(void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event{
    CGFloat screenWidth = [CCDirector sharedDirector].winSize.width;
    
    if (screenWidth > _scrollNode.contentSize.width) return;
    if (CGPointEqualToPoint(_touchStartPoint, CGPointZero)) return;
    
    CGPoint point = [self convertTouchToNodeSpace:touch];
    CGFloat diff = point.x - _touchStartPoint.x;
    DLog(@"diff %f",diff);
    if (abs(diff)>3) {
        diff *= 10;
        CGFloat newX = _scrollNode.position.x + diff;
        if (newX > 0) newX = 0;
        if ((newX + _scrollNode.contentSize.width)< screenWidth) {
            newX = screenWidth - _scrollNode.contentSize.width;
        }
        id action = [CCMoveBy actionWithDuration:0.5 position:ccp(newX - _scrollNode.position.x,0)];
        [_scrollNode runAction:action];
    }
    _touchStartPoint = CGPointZero;
}

-(void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event{
    CGFloat screenWidth = [CCDirector sharedDirector].winSize.width;
    
    if (screenWidth > _scrollNode.contentSize.width) return;
    if (CGPointEqualToPoint(_touchStartPoint, CGPointZero)) return;
    
    CGPoint movePoint = [self convertTouchToNodeSpace:touch];
    CGFloat diff = movePoint.x - _touchStartPoint.x;
    CGFloat newX = _scrollNode.position.x + diff;
    if (newX > 0) newX = 0;
    if ((newX + _scrollNode.contentSize.width)< screenWidth) {
        newX = screenWidth - _scrollNode.contentSize.width;
    }
    _scrollNode.position = ccp(newX, _scrollNode.position.y);
    _touchStartPoint = movePoint;
}

-(void)onExit{
    [[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
}

@end

#define kPhotoWidth 35
#define kPhotoHeight kPhotoWidth
#define kFontName [MonkeyClientData getTextFontName]
#define kNameFontSize 12
#define kPositionFontSize 28

@implementation PlayerScoreNodeSingle

static UIImage* defaultPic;

-(id)initWithPlayerScore:(PlayerScore *)player{
    self = [super init];
    if (self) {
        _player = [player retain];
        NSString* name = player.name;
        if ([name length]>10) {
            name = [NSString stringWithFormat:@"%@..",[name substringToIndex:8]];
        }
        _name = [[CCLabelTTF labelWithString:name fontName:kFontName fontSize:kNameFontSize] retain];
        _score = [[CCLabelTTF labelWithString:player.score fontName:kFontName fontSize:kNameFontSize] retain];
        _time = [[CCLabelTTF labelWithString:[CCUtils stringFromTime:player.time] fontName:kFontName fontSize:kNameFontSize] retain];
        _positionIndexLabel = [[CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d",player.rank] fontName:kFontName fontSize:kPositionFontSize] retain];
        
        _name.color = ccBLACK;
        _score.color = ccBLACK;
        _positionIndexLabel.color = ccBLACK;
        _time.color = ccBLACK;
        NSString* spriteName = @"score_bg.png";
        if ([_player.playerID isEqualToString:[GKLocalPlayer localPlayer].playerID]) {
            ccColor3B color = kColorRed;
            _name.color = color;
            _score.color = color;
            _positionIndexLabel.color = color;
            _time.color = color;
            spriteName = @"score_bg_user.png";
        }

        CCSprite* background = [CCSprite spriteWithFile:spriteName];
        
        background.scaleX = kWidth/background.boundingBox.size.width;
        background.scaleY = kHeight/background.boundingBox.size.height;
        background.position = ccp(kWidth/2,kHeight/2);
                
        [self addChild:background];
        [self addChild:_name];
        [self addChild:_score];
        [self addChild:_time];
        [self setImage:player.photo];
        [self addChild:_positionIndexLabel];
        [self setContentSize:CGSizeMake(kWidth, kHeight)];
        
        [player addObserver:self forKeyPath:@"photo" options:0 context:NULL];
    }
    return self;
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if ([keyPath isEqualToString:@"photo"]) {
        [self setImage:_player.photo];
    }
}

-(void)setContentSize:(CGSize)contentSize{
    [super setContentSize:contentSize];
    
    const CGFloat margin = 3;
    _name.position = ccp(contentSize.width/2,
                         contentSize.height - _name.boundingBox.size.height/2 - margin);
    CGFloat photoX = contentSize.width - _photo.boundingBox.size.width/2 -10;
    _photo.position = ccp(photoX,
                          _name.boundingBox.origin.y - _photo.boundingBox.size.height/2 - margin);
    _positionIndexLabel.position = ccp(contentSize.width/4,
                                       _photo.position.y - margin);
    _score.position = ccp(contentSize.width/2,_photo.boundingBox.origin.y - _score.boundingBox.size.height/2 - margin);

    _time.position = ccp(contentSize.width/2,_score.boundingBox.origin.y - _time.boundingBox.size.height/2 +2);
}

- (void)dealloc
{
    [_player removeObserver:self forKeyPath:@"photo"];
    [_name release];
    [_time release];
    [_positionIndexLabel release];
    [_photo release];
    [_score release];
    [super dealloc];
}

-(void)setImage:(UIImage *)image{
    CCSprite *newSprite = nil;
    if (!image) {
        if (!defaultPic) {
            defaultPic = [[UIImage imageNamed:@"photo.png"] retain];
        }
        newSprite = [[CCSprite alloc] initWithCGImage:[defaultPic CGImage] key:@"default_Pic_"];
    }else{
        newSprite = [[CCSprite alloc] initWithCGImage:[image CGImage] key:_player.playerID];
    }
    if (_photo) {
        newSprite.position = _photo.position;
        [_photo removeFromParentAndCleanup:YES];
        [_photo release];
    }
    _photo = newSprite;
    CGSize size = [_photo boundingBox].size;
    _photo.scaleX = kPhotoWidth/size.width;
    _photo.scaleY = kPhotoHeight/size.height;
    [self addChild:_photo];
}

@end
