//
//  ZIMGameWorldController.h
//  Asteroids
//
//  Created by kovtash on 08.12.14.
//
//

#import <Foundation/Foundation.h>
#import "VKShip.h"
#import "VKAsteroidProperties.h"

@class ZIMGameWorldController;


@protocol ZIMGameWorldControllerDelegate <NSObject>

- (void) controllerDidFinishGame:(ZIMGameWorldController *)controller;
- (void) controllerDidPauseGame:(ZIMGameWorldController *)controller;
- (void) controllerDidResumeGame:(ZIMGameWorldController *)controller;

- (void) controller:(ZIMGameWorldController *)controller didDetectAsteroidHit:(VKAsteroidProperties *)asteroid;
@end

@interface ZIMGameWorldController : NSObject
@property (assign, nonatomic) NSUInteger initialAsteroidsCount;
@property (assign, nonatomic) CGFloat asteroidMaxSize;
@property (readonly, nonatomic) CGSize worldSize;
@property (readonly, nonatomic) VKShip *ship;
@property (readonly, nonatomic) VKGLView *glView;
@property (readonly, nonatomic) NSUInteger currentAsteroidsCount;
@property (readonly, nonatomic) BOOL isExecuting;
@property (readonly, nonatomic) BOOL isPaused;
@property (readonly, nonatomic) BOOL isFinished;
@property (weak, nonatomic) id<ZIMGameWorldControllerDelegate> delegate;

- (instancetype) initWithGlViewSize:(CGSize)size;
- (instancetype) initWithGlViewSize:(CGSize)size worldSize:(CGSize)worldSize;

- (void) fire;

- (void) spawnAsteroid;
- (void) reset;
- (void) pause;
- (void) resume;
@end
