//
//  JSAnalogueStick+ZIMStick.m
//  Asteroids
//
//  Created by Vladislav Kovtash on 27/06/16.
//
//

#import "JSAnalogueStick+ZIMStick.h"

@implementation JSAnalogueStick (ZIMStick)

+ (JSAnalogueStick *)zim_stick {
    JSAnalogueStick *joyStik = [[JSAnalogueStick alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    joyStik.backgroundImageView.image = nil;
    joyStik.handleImageView.image = nil;

    CGRect backgroundBounds = joyStik.backgroundImageView.bounds;
    CAShapeLayer *backgroundShape = [CAShapeLayer new];
    backgroundShape.frame = backgroundBounds;
    backgroundShape.path = [UIBezierPath bezierPathWithOvalInRect:backgroundBounds].CGPath;
    backgroundShape.fillColor = [UIColor colorWithWhite:0.7 alpha:0.3].CGColor;
    [joyStik.backgroundImageView.layer addSublayer:backgroundShape];

    CGRect handleBounds = joyStik.handleImageView.bounds;
    CAShapeLayer *handleShape = [CAShapeLayer new];
    handleShape.frame = handleBounds;
    handleShape.path = [UIBezierPath bezierPathWithOvalInRect:handleBounds].CGPath;
    handleShape.fillColor = [UIColor colorWithWhite:0.7 alpha:0.5].CGColor;
    handleShape.strokeColor = [UIColor colorWithWhite:0.7 alpha:0.5].CGColor;
    [joyStik.handleImageView.layer addSublayer:handleShape];

    return joyStik;
}

@end
