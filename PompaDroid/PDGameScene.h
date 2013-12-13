//
//  PDGameScene.h
//  PompaDroid
//
//  Created by harperzhang on 13-12-12.
//  Copyright (c) 2013年 harperzhang. All rights reserved.
//

#import "CCScene.h"
#import "PDGameLayer.h"
#import "PDHudLayer.h"

@interface PDGameScene : CCScene

@property (nonatomic, weak) PDGameLayer*  gameLayer;
@property (nonatomic, weak) PDHudLayer*   hudLayer;

@end
