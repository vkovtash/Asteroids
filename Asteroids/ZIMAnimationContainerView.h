//
//  ZIMAnimationContainerView.h
//  Asteroids
//
//  Created by kovtash on 09.12.14.
//
//

#import <UIKit/UIKit.h>

@interface ZIMAnimationContainerView : UIView
@property (readonly, nonatomic) UIView *currentView;

- (void) setCurrentView:(UIView *)currentView;
- (void) replaceCurrentViewWithView:(UIView *)view;
@end
