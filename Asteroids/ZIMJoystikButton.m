//
//  ZIMJoystikButton.m
//  Asteroids
//
//  Created by Vladislav Kovtash on 27/06/16.
//
//

#import "ZIMJoystikButton.h"

@interface ZIMJoystikButton()
@property (strong, nonatomic) NSMutableDictionary *buttonColors;
@property (strong, nonatomic) CAShapeLayer *shape;
@end

@implementation ZIMJoystikButton

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self zimJoystikButtonInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self zimJoystikButtonInit];
    }
    return self;
}

+ (ZIMJoystikButton *)joystikButtonWithFrame:(CGRect)frame {
    ZIMJoystikButton *button = [ZIMJoystikButton buttonWithType:UIButtonTypeCustom];
    button.frame = frame;
    return button;
}

- (void)zimJoystikButtonInit {
    _shape = [CAShapeLayer new];
    [self.layer addSublayer:_shape];
}

- (NSMutableDictionary *)buttonColors {
    if (!_buttonColors) {
        _buttonColors = [NSMutableDictionary new];
    }
    return _buttonColors;
}

- (void)setButtonColor:(UIColor *)color forState:(UIControlState)state {
    self.buttonColors[@(state)] = color;
    [self updateButtonColor];
}

- (void)setEnabled:(BOOL)enabled {
    [super setEnabled:enabled];
    [self updateButtonColor];
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    [self updateButtonColor];
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    [self updateButtonColor];
}

- (void)updateButtonColor {
    UIColor *color = self.buttonColors[@(self.state)];
    if (!color) {
        color = self.buttonColors[@(UIControlStateNormal)];
    }

    self.shape.fillColor = color.CGColor;
    self.shape.strokeColor = color.CGColor;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.shape.frame = self.bounds;

    CGRect pathBounds = self.bounds;
    UIEdgeInsets insets = self.contentEdgeInsets;

    pathBounds.size.height -= insets.top + insets.bottom;
    pathBounds.size.width -= insets.left + insets.right;
    pathBounds.origin.x += insets.left;
    pathBounds.origin.y += insets.top;

    self.shape.path = [UIBezierPath bezierPathWithOvalInRect:pathBounds].CGPath;
}

@end
