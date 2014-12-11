//
//  ZIMGameWorldController.h
//  Asteroids
//
//  Created by kovtash on 08.12.14.
//
//

#import <Foundation/Foundation.h>
#import "VKShip.h"
#import "VKAsteroid.h"

@class ZIMGameWorldController;


@protocol ZIMGameWorldControllerDelegate <NSObject>

- (void) controllerDidFinishGame:(ZIMGameWorldController *)controller;
- (void) controllerDidPauseGame:(ZIMGameWorldController *)controller;
- (void) controllerDidResumeGame:(ZIMGameWorldController *)controller;

- (void) controller:(ZIMGameWorldController *)controller didDetectAsteroidHit:(VKAsteroid *)asteroid;
@end

@interface ZIMGameWorldController : NSObject
@property (readonly, nonatomic) VKShip *ship;
@property (readonly, nonatomic) VKGLView *glView;
@property (weak, nonatomic) id<ZIMGameWorldControllerDelegate> delegate;
@property (readonly, nonatomic) BOOL isExecuting;
@property (readonly, nonatomic) BOOL isPaused;
@property (readonly, nonatomic) BOOL isFinished;
@property (readonly, nonatomic) NSUInteger asteroidsCount;

- (instancetype) initWithGlViewSize:(CGSize)size;

- (void) fire;

- (void) reset;
- (void) pause;
- (void) resume;
@end
