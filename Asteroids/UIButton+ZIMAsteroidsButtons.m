//
//  UIButton+ZIMAsteroidsButtons.m
//  Asteroids
//
//  Created by kovtash on 09.12.14.
//
//

#import "UIButton+ZIMAsteroidsButtons.h"

@implementation UIButton (ZIMAsteroidsButtons)

+ (UIButton *) zim_fireButton {
    return [self zim_gamepadButtonWithText:@"fire"];
}

+ (UIButton *) zim_accelerationButton {
    return [self zim_gamepadButtonWithText:@"accel"];
}

+ (UIButton *) zim_gamepadButtonWithText:(NSString *)text {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 60, 60);
    button.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin;
    
    [button setImage:[UIImage imageNamed:@"button"] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:@"button-pressed"] forState:UIControlStateSelected];
    
    UILabel *buttonLabel = [[UILabel alloc] initWithFrame:button.bounds];
    buttonLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    buttonLabel.backgroundColor = [UIColor clearColor];
    buttonLabel.textAlignment = NSTextAlignmentCenter;
    buttonLabel.textColor = [UIColor darkGrayColor];
    buttonLabel.shadowColor = [UIColor whiteColor];
    buttonLabel.shadowOffset = CGSizeMake(0, 1);
    buttonLabel.text = text;
    
    [button addSubview:buttonLabel];
    
    return button;
}

+ (UIButton *) zim_playButton {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 40, 40);
    [button setImage:[[UIImage imageNamed:@"btn_play"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    button.contentEdgeInsets = UIEdgeInsetsMake(2, 5, 2, -1);
    return button;
}

+ (UIButton *) zim_pauseButton {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 40, 40);
    button.contentEdgeInsets = UIEdgeInsetsMake(2, 2, 2, 2);
    [button setImage:[[UIImage imageNamed:@"btn_pause"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    return button;
}

@end