//
//  UIButton+ZIMAsteroidsButtons.m
//  Asteroids
//
//  Created by kovtash on 09.12.14.
//
//

#import "UIButton+ZIMAsteroidsButtons.h"
#import "ZIMJoystikButton.h"

@implementation UIButton (ZIMAsteroidsButtons)

+ (UIButton *)zim_fireButton {
    UIColor *normalColor = [UIColor colorWithRed:1 green:0.4 blue:0.37 alpha:0.5];
    UIColor *highlightedColor = [UIColor colorWithRed:1 green:0.4 blue:0.37 alpha:0.7];
    NSString *title = @"FIRE";
    UIFont *titleFont = [UIFont fontWithName:@"Orbitron" size:9];

    NSAttributedString *normalTitle =
        [[NSAttributedString alloc] initWithString:title
                                        attributes:@{
                                                     NSForegroundColorAttributeName: normalColor,
                                                     NSFontAttributeName: titleFont
                                                     }];

    NSAttributedString *highlightedTitle =
        [[NSAttributedString alloc] initWithString:title
                                        attributes:@{
                                                     NSForegroundColorAttributeName: highlightedColor,
                                                     NSFontAttributeName: titleFont
                                                     }];

    ZIMJoystikButton *button = [ZIMJoystikButton joystikButtonWithFrame:CGRectMake(0, 0, 90, 90)];
    button.contentEdgeInsets = UIEdgeInsetsMake(15, 15, 15, 15);
    [button setButtonColor:normalColor forState:UIControlStateNormal];
    [button setButtonColor:highlightedColor forState:UIControlStateHighlighted];
    [button setAttributedTitle:normalTitle forState:UIControlStateNormal];
    [button setAttributedTitle:highlightedTitle forState:UIControlStateHighlighted];
    return button;
}

+ (UIButton *)zim_accelerationButton {
    UIColor *normalColor = [UIColor colorWithRed:0.2 green:0.8 blue:0.3 alpha:0.5];
    UIColor *highlightedColor = [UIColor colorWithRed:0.2 green:0.8 blue:0.3 alpha:0.7];
    NSString *title = @"ACCEL";
    UIFont *titleFont = [UIFont fontWithName:@"Orbitron" size:9];

    NSAttributedString *normalTitle =
        [[NSAttributedString alloc] initWithString:title
                                        attributes:@{
                                                     NSForegroundColorAttributeName: normalColor,
                                                     NSFontAttributeName: titleFont
                                                     }];

    NSAttributedString *highlightedTitle =
        [[NSAttributedString alloc] initWithString:title
                                        attributes:@{
                                                     NSForegroundColorAttributeName: highlightedColor,
                                                     NSFontAttributeName: titleFont
                                                     }];

    ZIMJoystikButton *button = [ZIMJoystikButton joystikButtonWithFrame:CGRectMake(0, 0, 90, 90)];
    button.contentEdgeInsets = UIEdgeInsetsMake(15, 15, 15, 15);
    [button setButtonColor:normalColor forState:UIControlStateNormal];
    [button setButtonColor:highlightedColor forState:UIControlStateHighlighted];
    [button setAttributedTitle:normalTitle forState:UIControlStateNormal];
    [button setAttributedTitle:highlightedTitle forState:UIControlStateHighlighted];
    return button;
}

+ (UIButton *)zim_playButton {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 50, 50);
    [button setImage:[[UIImage imageNamed:@"btn_play"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    button.contentEdgeInsets = UIEdgeInsetsMake(12, 15, 12, 9);
    return button;
}

+ (UIButton *)zim_pauseButton {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 50, 50);
    button.contentEdgeInsets = UIEdgeInsetsMake(12, 12, 12, 12);
    [button setImage:[[UIImage imageNamed:@"btn_pause"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    return button;
}

@end
