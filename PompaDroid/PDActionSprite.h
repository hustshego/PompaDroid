//
//  PDActionSprite.h
//  PompaDroid
//
//  Created by harperzhang on 13-12-12.
//  Copyright (c) 2013年 harperzhang. All rights reserved.
//

#import "CCSprite.h"

@interface PDActionSprite : CCSprite

//actions
@property(nonatomic,strong)id idleAction;
@property(nonatomic,strong)id attackAction;
@property(nonatomic,strong)id walkAction;
@property(nonatomic,strong)id hurtAction;
@property(nonatomic,strong)id knockedOutAction;

//states
@property(nonatomic,assign) ActionState actionState;

//attributes
@property(nonatomic,assign)float walkSpeed;
@property(nonatomic,assign)float hitPoints;
@property(nonatomic,assign)float damage;

//movement
@property(nonatomic,assign)CGPoint velocity;
@property(nonatomic,assign)CGPoint desiredPosition;

//measurements
@property(nonatomic,assign)float centerToSides;
@property(nonatomic,assign)float centerToBottom;

@property (nonatomic) BoundingBox  hitBox;
@property (nonatomic) BoundingBox  attackBox;

//action methods
-(void)idle;
-(void)attack;
-(void)hurtWithDamage:(float)damage;
-(void)knockout;
-(void)walkWithDirection:(CGPoint)direction;

- (BoundingBox)createBoundingBoxWithOrigin:(CGPoint)origin size:(CGSize)size;

//scheduled methods
-(void)update:(ccTime)dt;

@end
