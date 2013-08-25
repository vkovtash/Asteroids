//
//  VKViewController.m
//  HelloOpenGL
//
//  Created by kovtash on 25.08.13.
//
//

#import "VKViewController.h"
#import "VKGLView.h"
#import "VKAsteroid.h"

#define OFFSCREEN_WORLD_SIZE 100.0f
#define WORLD_SIZE_X 520.0f
#define WORLD_SIZE_Y 680.0f

@interface VKViewController ()
@property (strong ,nonatomic) VKGLView *glView;
@property (strong, nonatomic) NSThread *gameLoop;
@end

@implementation VKViewController

- (NSMutableArray *) asteroids{
    if (!_asteroids) {
        _asteroids = [NSMutableArray array];
    }
    return _asteroids;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.glView = [[VKGLView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.glView];
    [self prepareWorld];
    [self start];
}

- (void) prepareWorld{
    self.ship = [[VKShip alloc] init];
    self.ship.position = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2);
    self.ship.velocity = 200;
    self.ship.rotation = 180;
    self.ship.color = [UIColor yellowColor];
    
    [self.glView addGLObject:self.ship];
    
    VKAsteroid *asteroid00 = [[VKAsteroid alloc] init];
    asteroid00.position = CGPointMake(200, 200);
    asteroid00.direction = 30;
    asteroid00.velocity = 300;
    asteroid00.rotationVelocity = 50;
    [self.glView addGLObject:asteroid00];
    [self.asteroids addObject:asteroid00];
    
    VKAsteroid *asteroid01 = [[VKAsteroid alloc] init];
    asteroid01.position = CGPointMake(100, 100);
    asteroid01.direction = 130;
    asteroid01.velocity = 500;
    asteroid01.rotationVelocity = 130;
    [self.glView addGLObject:asteroid01];
    [self.asteroids addObject:asteroid01];
    
    VKAsteroid *asteroid02 = [[VKAsteroid alloc] init];
    asteroid02.position = CGPointMake(100, 400);
    asteroid02.direction = 320;
    asteroid02.velocity = 400;
    asteroid02.rotationVelocity = -200;
    [self.glView addGLObject:asteroid02];
    [self.asteroids addObject:asteroid02];
}

- (void) start{
    self.gameLoop = [[NSThread alloc] initWithTarget:self
                                            selector:@selector(loop:)
                                              object:self];
    [self.gameLoop start];
}

- (void) stop{
    [self.gameLoop cancel];
}

- (void) loop:(VKViewController *) gameController{
    NSThread *thread = [NSThread currentThread];
    NSDate *date = [NSDate date];
    NSTimeInterval lastRun = [date timeIntervalSinceNow];
    while (!thread.isCancelled) {
        [gameController processGameStep:lastRun-[date timeIntervalSinceNow]];
        lastRun = [date timeIntervalSinceNow];
    }
}

- (void) processGameStep:(NSTimeInterval) time{
    double x;
    double y;
    double rad;
    double distance;
    
    rad = self.ship.rotation * M_PI / 180;
    double offset_x = self.ship.velocity*time * sin(rad);
    double offset_y = self.ship.velocity*time * cos(rad);
    
    for (VKAsteroid *asteroid in self.asteroids) {
        rad = asteroid.direction * M_PI / 180;
        distance = asteroid.velocity*time;
        x = asteroid.position.x - distance * sin(rad) + offset_x;
        y = asteroid.position.y - distance * cos(rad) + offset_y;
        if (x > WORLD_SIZE_X - OFFSCREEN_WORLD_SIZE ) {
            x = x - WORLD_SIZE_X - OFFSCREEN_WORLD_SIZE;
        }
        else if (x < -OFFSCREEN_WORLD_SIZE){
            x = WORLD_SIZE_X - OFFSCREEN_WORLD_SIZE;
        }
        
        if (y > WORLD_SIZE_Y - OFFSCREEN_WORLD_SIZE) {
            y = y - WORLD_SIZE_Y - OFFSCREEN_WORLD_SIZE;
        }
        else if (y < -OFFSCREEN_WORLD_SIZE){
            y = WORLD_SIZE_Y - OFFSCREEN_WORLD_SIZE;
        }
        asteroid.position = CGPointMake(x, y);
        asteroid.rotation += asteroid.rotationVelocity * time;
    }
    
    [self checkCollision];
}

- (void) checkCollision{
    double distance;
    for (VKAsteroid *asteroid in self.asteroids){
        distance = sqrt(pow(asteroid.position.x-self.ship.position.x, 2)
                        + pow(asteroid.position.y - self.ship.position.y, 2));
        if (distance < 25) {
            [self stop];
            NSLog(@"collision");
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
