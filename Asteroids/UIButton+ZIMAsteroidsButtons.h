//
//  UIButton+ZIMAsteroidsButtons.h
//  Asteroids
//
//  Created by kovtash on 09.12.14.
//
//

#import <UIKit/UIKit.h>

@class JSAnalogueStick;

@interface UIButton (ZIMAsteroidsButtons)
+ (UIButton *)zim_fireButton;
+ (UIButton *)zim_accelerationButton;
+ (UIButton *)zim_playButton;
+ (UIButton *)zim_pauseButton;
@end
