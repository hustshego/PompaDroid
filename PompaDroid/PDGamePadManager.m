//
//  PDGamePadManager.m
//  PompaDroid
//
//  Created by harperzhang on 13-12-12.
//  Copyright (c) 2013年 harperzhang. All rights reserved.
//

#import "PDGamePadManager.h"
#import <GameController/GameController.h>
#import "PDGDMDefines.h"

@interface PDGamePadManager()
{
    GCController* __weak  _gameController;
}

@end

@implementation PDGamePadManager

+ (PDGamePadManager*)sharedInstance
{
    static PDGamePadManager* instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[PDGamePadManager alloc] init];
    });
    
    return instance;
}

- (id)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gamepadDidConnect:) name:GCControllerDidConnectNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gamepadDidDisconnect:) name:GCControllerDidDisconnectNotification object:nil];
    }
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - action listeners
- (void)registerActionListeners
{
    [self registerDPadActions];
    [self registerButtonActions];
    [self registerShoulderActions];
}

- (void)registerDPadActions
{
    [_gameController.gamepad.dpad setValueChangedHandler:^(GCControllerDirectionPad *dpad, float xValue, float yValue) {
        [[NSNotificationCenter defaultCenter] postNotificationName:GPMDpadDidChangeNotification
                                                            object:self
                                                          userInfo:@{@"x" : [NSNumber numberWithFloat:xValue],
                                                                     @"y" : [NSNumber numberWithFloat:yValue]}];
    }];
    
//    // UP
//    [_gameController.gamepad.dpad.up setValueChangedHandler:^(GCControllerButtonInput *button, float value, BOOL pressed) {
//        if (pressed) {
//            [[NSNotificationCenter defaultCenter] postNotificationName:GPMDpadUpDidPressedNotification object:self userInfo:nil];
//        }
//    }];
//    
//    // DOWN
//    [_gameController.gamepad.dpad.down setValueChangedHandler:^(GCControllerButtonInput *button, float value, BOOL pressed) {
//        if (pressed) {
//            [[NSNotificationCenter defaultCenter] postNotificationName:GPMDpadDownDidPressedNotification object:self userInfo:nil];
//        }
//    }];
//    
//    // LEFT
//    [_gameController.gamepad.dpad.left setValueChangedHandler:^(GCControllerButtonInput *button, float value, BOOL pressed) {
//        if (pressed) {
//            [[NSNotificationCenter defaultCenter] postNotificationName:GPMDpadLeftDidPressedNotification object:self userInfo:nil];
//        }
//    }];
//    
//    // RIGHT
//    [_gameController.gamepad.dpad.right setValueChangedHandler:^(GCControllerButtonInput *button, float value, BOOL pressed) {
//        if (pressed) {
//            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:@"x:%f, y:%f", 5.0, 0.0] delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
//            [alert show];
//            [[NSNotificationCenter defaultCenter] postNotificationName:GPMDpadRightDidPressedNotification object:self userInfo:nil];
//        }
//    }];
}

- (void)registerButtonActions
{
    // X
    [_gameController.gamepad.buttonX setValueChangedHandler:^(GCControllerButtonInput *button, float value, BOOL pressed) {
        if (pressed) {
            [[NSNotificationCenter defaultCenter] postNotificationName:GPMButtonXDidPressedNotification object:self userInfo:nil];
        }
    }];
    
    // Y
    [_gameController.gamepad.buttonY setValueChangedHandler:^(GCControllerButtonInput *button, float value, BOOL pressed) {
        if (pressed) {
            [[NSNotificationCenter defaultCenter] postNotificationName:GPMButtonYDidPressedNotification object:self userInfo:nil];
        }
    }];
    
    // A
    [_gameController.gamepad.buttonA setValueChangedHandler:^(GCControllerButtonInput *button, float value, BOOL pressed) {
        if (pressed) {
            [[NSNotificationCenter defaultCenter] postNotificationName:GPMButtonADidPressedNotification object:self userInfo:nil];
        }
    }];
    
    // B
    [_gameController.gamepad.buttonB setValueChangedHandler:^(GCControllerButtonInput *button, float value, BOOL pressed) {
        if (pressed) {
            [[NSNotificationCenter defaultCenter] postNotificationName:GPMButtonBDidPressedNotification object:self userInfo:nil];
        }
    }];
}

- (void)registerShoulderActions
{
    // left
    [_gameController.gamepad.leftShoulder setValueChangedHandler:^(GCControllerButtonInput *button, float value, BOOL pressed) {
        if (pressed) {
            [[NSNotificationCenter defaultCenter] postNotificationName:GPMLeftShoulderDidPressedNotification object:self userInfo:nil];
        }
    }];
    
    // right
    [_gameController.gamepad.leftShoulder setValueChangedHandler:^(GCControllerButtonInput *button, float value, BOOL pressed) {
        if (pressed) {
            [[NSNotificationCenter defaultCenter] postNotificationName:GPMRightShoulderDidPressedNotification object:self userInfo:nil];
        }
    }];
}

#pragma mark - Notifications
- (void)gamepadDidConnect:(NSNotification*)notification
{
    if (_gameController == nil) {
        _gameController = notification.object;
        
//        [_gameController.gamepad setValueChangedHandler:^(GCGamepad* gamepad, GCControllerElement* element) {

//        }];
        [self registerActionListeners];
    }
}

- (void)gamepadDidDisconnect:(NSNotification*)notification
{
    if (_gameController == notification.object) {
        _gameController = nil;
    }
}

@end
