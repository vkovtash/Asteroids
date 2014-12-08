//
//  ZIMGameWorldController.h
//  Asteroids
//
//  Created by kovtash on 08.12.14.
//
//

#import <Foundation/Foundation.h>
#import "VKShip.h"

@interface ZIMGameWorldController : NSObject
@property (readonly, nonatomic) VKShip *ship;
@property (readonly, nonatomic) VKGLView *glView;

- (instancetype) initWithGlViewSize:(CGSize)size;

- (void) fire;

- (void) start;
- (void) stop;
@end
