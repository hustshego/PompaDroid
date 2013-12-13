//
//  PDRobot.m
//  PompaDroid
//
//  Created by harperzhang on 13-12-13.
//  Copyright (c) 2013年 harperzhang. All rights reserved.
//

#import "PDRobot.h"

@implementation PDRobot

- (id)init
{
    self = [super initWithSpriteFrameName:@"robot_idle_00.png"];
    if (self) {
        int i;
        
        // idle
        CCArray* idleFrames = [CCArray arrayWithCapacity:5];
        for (i = 0; i != 5; ++i) {
            CCSpriteFrame* frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"robot_idle_%02d.png", i]];
            [idleFrames addObject:frame];
        }
        CCAnimation* idleAnimation = [CCAnimation animationWithSpriteFrames:[idleFrames getNSArray] delay:1.0 / 12.0];
        self.idleAction = [CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:idleAnimation]];
        
        // attack
        CCArray *attackFrames = [CCArray arrayWithCapacity:5];
        for (i = 0; i < 5; i++) {
            CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"robot_attack_%02d.png", i]];
            [attackFrames addObject:frame];
        }
        CCAnimation *attackAnimation = [CCAnimation animationWithSpriteFrames:[attackFrames getNSArray] delay:1.0/24.0];
        self.attackAction = [CCSequence actions:[CCAnimate actionWithAnimation:attackAnimation], [CCCallFunc actionWithTarget:self selector:@selector(idle)], nil];
        
        // walk
        CCArray *walkFrames = [CCArray arrayWithCapacity:6];
        for (i = 0; i < 6; i++) {
            CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"robot_walk_%02d.png", i]];
            [walkFrames addObject:frame];
        }
        CCAnimation *walkAnimation = [CCAnimation animationWithSpriteFrames:[walkFrames getNSArray] delay:1.0/12.0];
        self.walkAction = [CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:walkAnimation]];
        
        //hurt animation
        CCArray *hurtFrames = [CCArray arrayWithCapacity:8];
        for (i = 0; i < 3; i++) {
            CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"robot_hurt_%02d.png", i]];
            [hurtFrames addObject:frame];
        }
        CCAnimation *hurtAnimation = [CCAnimation animationWithSpriteFrames:[hurtFrames getNSArray] delay:1.0/12.0];
        self.hurtAction = [CCSequence actions:[CCAnimate actionWithAnimation:hurtAnimation], [CCCallFunc actionWithTarget:self selector:@selector(idle)], nil];
        
        //knocked out animation
        CCArray *knockedOutFrames = [CCArray arrayWithCapacity:5];
        for (i = 0; i < 5; i++) {
            CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"robot_knockout_%02d.png", i]];
            [knockedOutFrames addObject:frame];
        }
        CCAnimation *knockedOutAnimation = [CCAnimation animationWithSpriteFrames:[knockedOutFrames getNSArray] delay:1.0/12.0];
        self.knockedOutAction = [CCSequence actions:[CCAnimate actionWithAnimation:knockedOutAnimation], [CCBlink actionWithDuration:2.0 blinks:10.0], nil];
        
        self.walkSpeed = 80;
        self.centerToBottom = 39.0;
        self.centerToSides = 29.0;
        self.hitPoints = 100;
        self.damage = 10;
        
        self.nextDecisionTime = 0;
    }
    
    return self;
}

@end
