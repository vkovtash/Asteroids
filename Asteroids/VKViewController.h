//
//  VKViewController.h
//  Asteroids
//
//  Created by kovtash on 25.08.13.
//
//

#import <UIKit/UIKit.h>
#import "VKShip.h"
#import "JSAnalogueStick.h"

float distance(float x1, float y1, float x2, float y2);

@interface VKViewController : UIViewController <JSAnalogueStickDelegate>
@property (strong, nonatomic) NSMutableArray *asteroids;
@property (strong, nonatomic) NSMutableArray *missles;
@property (strong, nonatomic) NSMutableArray *stars;
@property (strong, nonatomic) VKShip *ship;
- (void) processGameStep:(NSTimeInterval) time;
@end
