//
//  JSAnalogueStick.m
//  Controller
//
//  Created by James Addyman on 29/03/2013.
//  Copyright (c) 2013 James Addyman. All rights reserved.
//

#import "JSAnalogueStick.h"

#define RADIUS (self.bounds.size.width / 2)
#define M_180_PI 57.29577951308232286464772187173366547
#define M_2PI 6.28318530717958623199592693708837032

@implementation JSAnalogueStick

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		[self commonInit];
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	if ((self = [super initWithCoder:aDecoder])) {
		[self commonInit];
	}
	return self;
}

- (void)commonInit {
    _backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"analogue_bg"]];
    _backgroundImageView.frame = self.bounds;
	[self addSubview:_backgroundImageView];
	
    CGFloat center = RADIUS;
	_handleImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"analogue_handle"]];
    _handleImageView.bounds = CGRectMake(0, 0,
                                         [_backgroundImageView bounds].size.width / 1.5,
                                         [_backgroundImageView bounds].size.height / 1.5);
    _handleImageView.center= CGPointMake(center, center);
    
	[self addSubview:_handleImageView];
	
	_xValue = 0;
	_yValue = 0;
    _distance = 0;
    _angle = 0;
    _radians = 0;
}

- (void) addGuides {
    UIView *vGuide = [[UIView alloc] initWithFrame:CGRectMake(self.bounds.size.width/2 - 1, 0, 2, self.bounds.size.height)];
    UIView *hGuide = [[UIView alloc] initWithFrame:CGRectMake(0, self.bounds.size.height/2 - 1, self.bounds.size.width, 2)];
    vGuide.backgroundColor = [UIColor redColor];
    hGuide.backgroundColor = [UIColor redColor];
    
    [self addSubview:vGuide];
    [self addSubview:hGuide];
}

- (void) updateStateWithEventLocation:(CGPoint)location {
    CGFloat radius = RADIUS;
    CGFloat x = location.x - radius;
    CGFloat y = location.y - radius;
    int xSing = x < 0 ? -1 : 1;
    int ySing = y < 0 ? -1 : 1;
    
    CGFloat distance = sqrt(x * x + y * y);
    _radians = acosf(y / distance);
    _radians += M_PI;
    if (x > 0) {
        _radians = M_2PI - _radians;
    }
    
    if (distance > radius) {
        CGFloat angle = asin(x * xSing / distance);
        
        distance = radius;
        CGFloat nx = distance * sin(angle);
        CGFloat ny = distance * sin ((M_PI_2 - angle));
        
        x = nx * xSing;
        y = ny * ySing;
    }
    
    _distance = distance / radius;
    _xValue = x / radius;
    _yValue = y / radius;
    
    _angle = _radians * M_180_PI;
}

- (CGPoint) normalizedLocation {
    CGFloat radius = RADIUS;
    return CGPointMake(_xValue * radius + radius, _yValue * radius + radius);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	CGPoint location = [[touches anyObject] locationInView:self];
	
    [self updateStateWithEventLocation:location];
	_handleImageView.center = [self normalizedLocation];
	
	if ([self.delegate respondsToSelector:@selector(analogueStickDidChangeValue:)]) {
		[self.delegate analogueStickDidChangeValue:self];
	}
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	CGPoint location = [[touches anyObject] locationInView:self];
	
    [self updateStateWithEventLocation:location];
    _handleImageView.center = [self normalizedLocation];
	
	if ([self.delegate respondsToSelector:@selector(analogueStickDidChangeValue:)]) {
		[self.delegate analogueStickDidChangeValue:self];
	}
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	_xValue = 0.0;
	_yValue = 0.0;
    _distance = 0.0;
	
    CGFloat center = RADIUS;
    _handleImageView.center = CGPointMake(center, center);
	
	if ([self.delegate respondsToSelector:@selector(analogueStickDidChangeValue:)]) {
		[self.delegate analogueStickDidChangeValue:self];
	}
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	_xValue = 0.0;
	_yValue = 0.0;
    _distance = 0.0;

    CGFloat center = RADIUS;
    _handleImageView.center = CGPointMake(center, center);
	
    if ([self.delegate respondsToSelector:@selector(analogueStickDidChangeValue:)]) {
		[self.delegate analogueStickDidChangeValue:self];
	}
}

@end
