//
//  VKViewController.h
//  HelloOpenGL
//
//  Created by kovtash on 25.08.13.
//
//

#import <UIKit/UIKit.h>
#import "VKShip.h"

@interface VKViewController : UIViewController
@property (strong, nonatomic) NSMutableArray *asteroids;
@property (strong ,nonatomic) VKShip *ship;
- (void) processGameStep:(NSTimeInterval) time;
@end
