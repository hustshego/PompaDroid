//
//  PDGameLayer.h
//  PompaDroid
//
//  Created by harperzhang on 13-12-12.
//  Copyright (c) 2013年 harperzhang. All rights reserved.
//

#import "CCLayer.h"
#import "CCTMXTiledMap.h"
#import "CCSpriteBatchNode.h"
#import "PDHero.h"

@interface PDGameLayer : CCLayer
{
    CCTMXTiledMap*  _tileMap;
    CCSpriteBatchNode*  _actors;
    
    PDHero*  _hero;
}

@property (nonatomic, strong) CCArray*  robots;

@end
