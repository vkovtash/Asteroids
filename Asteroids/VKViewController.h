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

double distance(double x1, double y1, double x2, double y2);

@interface VKViewController : UIViewController <JSAnalogueStickDelegate>
@property (strong, nonatomic) NSMutableArray *asteroids;
@property (strong, nonatomic) NSMutableArray *missles;
@property (strong, nonatomic) NSMutableArray *stars;
@property (strong, nonatomic) VKShip *ship;
- (void) processGameStep:(NSTimeInterval) time;
@end
