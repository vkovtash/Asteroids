//
//  ZIMJoystikButton.h
//  Asteroids
//
//  Created by Vladislav Kovtash on 27/06/16.
//
//

#import <UIKit/UIKit.h>

@interface ZIMJoystikButton : UIButton
- (void)setButtonColor:(UIColor *)color forState:(UIControlState)state;

+ (ZIMJoystikButton *)joystikButtonWithFrame:(CGRect)frame;
@end
