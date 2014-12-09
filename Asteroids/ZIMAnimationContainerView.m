//
//  ZIMAnimationContainerView.m
//  Asteroids
//
//  Created by kovtash on 09.12.14.
//
//

#import "ZIMAnimationContainerView.h"

static CGFloat kAnimationDuration = 0.2;

@implementation ZIMAnimationContainerView
@synthesize currentView = _currentView;

- (void) setCurrentView:(UIView *)currentView {
    if (_currentView != currentView) {
        [_currentView removeFromSuperview];
        _currentView = currentView;
        if (_currentView) {
            [self addSubview:_currentView];
            _currentView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
            _currentView.center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
        }
    }
}

- (void) replaceCurrentViewWithView:(UIView *)view {
    if (_currentView == view) {
        return;
    }
    
    [UIView animateWithDuration:kAnimationDuration animations:^{
        
        CGAffineTransform t = CGAffineTransformMakeScale(0.01, 0.01);
        t = CGAffineTransformRotate(t, M_PI);
        
        _currentView.transform = t;
    }
                     completion:^(BOOL finished)
    {
        if (!finished) {
            return;
        }
        
        CGAffineTransform t = _currentView.transform;
        _currentView.transform = CGAffineTransformIdentity;
        [self setCurrentView:view];
        
        if (!_currentView) {
            return;
        }
        
        _currentView.transform = t;
        [self addSubview:_currentView];
        
        [UIView animateWithDuration:kAnimationDuration animations:^{
            _currentView.transform = CGAffineTransformIdentity;
        }];
    }];
}
@end
