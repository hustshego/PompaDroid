//
//  PDGameScene.m
//  PompaDroid
//
//  Created by harperzhang on 13-12-12.
//  Copyright (c) 2013年 harperzhang. All rights reserved.
//

#import "PDGameScene.h"

@implementation PDGameScene

- (id)init
{
    self = [super init];
    if (self) {
        _gameLayer = [PDGameLayer node];
        [self addChild:_gameLayer z:0];
        
        _hudLayer = [PDHudLayer node];
        [self addChild:_hudLayer z:1];
    }
    
    return self;
}

@end
