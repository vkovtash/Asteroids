//
//  VKViewController.h
//  HelloOpenGL
//
//  Created by kovtash on 25.08.13.
//
//

#import <UIKit/UIKit.h>
#import "VKShip.h"
#import "JSAnalogueStick.h"
#import "JSButton.h"

@interface VKViewController : UIViewController <JSAnalogueStickDelegate, JSButtonDelegate>
@property (strong, nonatomic) NSMutableArray *asteroids;
@property (strong, nonatomic) NSMutableArray *missles;
@property (strong ,nonatomic) VKShip *ship;
- (void) processGameStep:(NSTimeInterval) time;
@end
