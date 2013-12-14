//
//  PDGameLayer.m
//  PompaDroid
//
//  Created by harperzhang on 13-12-12.
//  Copyright (c) 2013年 harperzhang. All rights reserved.
//

#import "PDGameLayer.h"
#import "CCTMXLayer.h"
#import "CCSpriteFrameCache.h"
#import "CGPointExtension.h"
#import "PDGDMDefines.h"
#import "PDRobot.h"
#import "PDGameScene.h"
#import "SimpleAudioEngine.h"

@implementation PDGameLayer

- (id)init
{
    self = [super init];
    if (self) {
        [self initTileMap];
        
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"pd_sprites.plist"];
        _actors = [CCSpriteBatchNode batchNodeWithFile:@"pd_sprites.pvr.ccz"];
        [_actors.texture setAliasTexParameters];
        [self addChild:_actors z:-5];
        
        [self initHero];
        [self initRobots];
        
        self.isTouchEnabled = YES;
        
        // Load audio
        [[SimpleAudioEngine sharedEngine] preloadBackgroundMusic:@"latin_industries.aifc"];
        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"latin_industries.aifc"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"pd_hit0.caf"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"pd_hit1.caf"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"pd_herodeath.caf"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"pd_botdeath.caf"];
        
        // dpad
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dpadDidChange:) name:GPMDpadDidChangeNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dpadRightPressed:) name:GPMDpadRightDidPressedNotification object:nil];
        
        // buttons
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(buttonXPressed:) name:GPMButtonXDidPressedNotification object:nil];
        
        [self scheduleUpdate];
    }
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self unscheduleUpdate];
}

- (void)initTileMap
{
    _tileMap = [CCTMXTiledMap tiledMapWithTMXFile:@"pd_tilemap.tmx"];
    for (CCTMXLayer* child in [_tileMap children]) {
        [[child texture] setAliasTexParameters];
    }
    
    [self addChild:_tileMap z:-6];
}

- (void)initHero
{
    _hero = [PDHero node];
    [_actors addChild:_hero];
    _hero.position = ccp(_hero.centerToSides, 80);
    _hero.desiredPosition = _hero.position;
    [_hero idle];
}

- (void)initRobots
{
    int robotCount = 50;
    self.robots = [[CCArray alloc] initWithCapacity:robotCount];
    
    for (int i = 0; i != robotCount; ++i) {
        PDRobot* robot = [PDRobot node];
        [_actors addChild:robot];
        [_robots addObject:robot];
        
        int minX = SCREEN.width + robot.centerToSides;
        int maxX = _tileMap.mapSize.width * _tileMap.tileSize.width - robot.centerToSides;
        int minY = robot.centerToBottom;
        int maxY = 3 * _tileMap.tileSize.height + robot.centerToBottom;
        robot.scaleX = -1;
        robot.position = ccp(random_range(minX, maxX), random_range(minY, maxY));
        robot.desiredPosition = robot.position;
        [robot idle];
    }
}

-(void)endGame {
    CCLabelTTF *restartLabel = [CCLabelTTF labelWithString:@"RESTART" fontName:@"Arial" fontSize:30];
    CCMenuItemLabel *restartItem = [CCMenuItemLabel itemWithLabel:restartLabel target:self selector:@selector(restartGame)];
    CCMenu *menu = [CCMenu menuWithItems:restartItem, nil];
    menu.position = CENTER;
    menu.tag = 5;
    [_hud addChild:menu z:5];
}

-(void)restartGame
{
    [[CCDirector sharedDirector] replaceScene:[PDGameScene node]];
}

#pragma mark - Update
- (void)update:(ccTime)delta
{
    [_hero update:delta];
    [self updateRobots:delta];
    [self updatePositions];
    [self reorderActors];
    [self setViewPointCenter:_hero.position];
}

- (void)updatePositions
{
    float posX = MIN(_tileMap.mapSize.width * _tileMap.tileSize.width - _hero.centerToSides, MAX(_hero.centerToSides, _hero.desiredPosition.x));
    float posY = MIN(3 * _tileMap.tileSize.height + _hero.centerToBottom, MAX(_hero.centerToBottom, _hero.desiredPosition.y));
    _hero.position = ccp(posX, posY);
    
    PDRobot *robot;
    CCARRAY_FOREACH(_robots, robot) {
        posX = MIN(_tileMap.mapSize.width * _tileMap.tileSize.width - robot.centerToSides, MAX(robot.centerToSides, robot.desiredPosition.x));
        posY = MIN(3 * _tileMap.tileSize.height + robot.centerToBottom, MAX(robot.centerToBottom, robot.desiredPosition.y));
        robot.position = ccp(posX, posY);
    }
}

- (void)setViewPointCenter:(CGPoint)position
{
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    
    int x = MAX(position.x, winSize.width / 2.0);
    int y = MAX(position.y, winSize.width / 2.0);
    x = MIN(x, _tileMap.mapSize.width * _tileMap.tileSize.width - winSize.width / 2.0);
    y = MIN(y, _tileMap.mapSize.height * _tileMap.tileSize.height - winSize.height / 2.0);
    
    CGPoint actualPosition = ccp(x, y);
    
    CGPoint centerOfView = ccp(winSize.width / 2.0, winSize.height / 2.0);
    CGPoint viewPoint = ccpSub(centerOfView, actualPosition);
    self.position = viewPoint;
}

-(void)reorderActors
{
    PDActionSprite *sprite;
    CCARRAY_FOREACH(_actors.children, sprite) {
        [_actors reorderChild:sprite z:(_tileMap.mapSize.height * _tileMap.tileSize.height) - sprite.position.y];
    }
}

-(void)updateRobots:(ccTime)dt {
    int alive = 0;
    PDRobot *robot;
    float distanceSQ;
    int randomChoice = 0;
    CCARRAY_FOREACH(_robots, robot) {
        [robot update:dt];
        if (robot.actionState != kActionStateKnockedOut) {
            //1
            alive++;
            
            //2
            if (CURTIME > robot.nextDecisionTime) {
                distanceSQ = ccpDistanceSQ(robot.position, _hero.position);
                
                //3
                if (distanceSQ <= 50 * 50) {
                    robot.nextDecisionTime = CURTIME + frandom_range(0.1, 0.5);
                    randomChoice = random_range(0, 1);
                    
                    if (randomChoice == 0) {
                        if (_hero.position.x > robot.position.x) {
                            robot.scaleX = 1.0;
                        } else {
                            robot.scaleX = -1.0;
                        }
                        
                        //4
                        [robot attack];
                        if (robot.actionState == kActionStateAttack) {
                            if (fabsf(_hero.position.y - robot.position.y) < 10) {
                                if (CGRectIntersectsRect(_hero.hitBox.actual, robot.attackBox.actual)) {
                                    [_hero hurtWithDamage:robot.damage];
                                    
                                    if (_hero.actionState == kActionStateKnockedOut
                                        && [_hud getChildByTag:5] == nil)
                                    {
                                        [self endGame];
                                    }
                                }
                            }
                        }
                    } else {
                        [robot idle];
                    }
                } else if (distanceSQ <= SCREEN.width * SCREEN.width) {
                    //5
                    robot.nextDecisionTime = CURTIME + frandom_range(0.5, 1.0);
                    randomChoice = random_range(0, 2);
                    if (randomChoice == 0) {
                        CGPoint moveDirection = ccpNormalize(ccpSub(_hero.position, robot.position));
                        [robot walkWithDirection:moveDirection];
                    } else {
                        [robot idle];
                    }
                }
            }
        }
    }
    
    if (alive == 0 && [_hud getChildByTag:5] == nil) {
        [self endGame];
    }
}

#pragma mark - Attack
- (void)attack
{
    [_hero attack];
    
    if (_hero.actionState == kActionStateAttack) {
        PDRobot* robot;
        CCARRAY_FOREACH(_robots, robot) {
            if (robot.actionState != kActionStateKnockedOut) {
                if (fabsf(_hero.position.y - robot.position.y) < 10) {
                    if (CGRectIntersectsRect(_hero.attackBox.actual, robot.hitBox.actual)) {
                        [robot hurtWithDamage:_hero.damage];
                    }
                }
            }
        }
    }
}

#pragma mark - Touch event
- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self attack];
}

#pragma mark - Dpad
- (void)dpadDidChange:(NSNotification*)notification
{
    NSDictionary* userInfo = notification.userInfo;
    CGFloat x = [userInfo[@"x"] floatValue];
    CGFloat y = [userInfo[@"y"] floatValue];

    if (x == 0.0 && y == 0.0) {
        // stoped
        [_hero idle];
    } else {
        [_hero walkWithDirection:ccp(x, y)];
    }
}

- (void)dpadRightPressed:(NSNotification*)notification
{
    [_hero walkWithDirection:ccp(5, 0)];
}

#pragma mark Button actions
- (void)buttonXPressed:(NSNotification*)notification
{
    [self attack];
}

@end
