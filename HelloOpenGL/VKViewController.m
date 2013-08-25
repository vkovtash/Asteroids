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
#import "VKMissle.h"

#define OFFSCREEN_WORLD_SIZE 100.0f
#define WORLD_SIZE_X 1000.0f
#define WORLD_SIZE_Y 1000.0f
#define GAME_LOOP_RATE 100 //loops per second

@interface VKViewController ()
@property (strong ,nonatomic) VKGLView *glView;
@property (strong, nonatomic) NSThread *gameLoop;
@property (strong ,nonatomic) JSButton *fireButton;
@property (strong ,nonatomic) JSAnalogueStick *joyStik;
@end

@implementation VKViewController

- (NSMutableArray *) asteroids{
    if (!_asteroids) {
        _asteroids = [NSMutableArray array];
    }
    return _asteroids;
}

- (NSMutableArray *) missles{
    if (!_missles) {
        _missles = [NSMutableArray array];
    }
    return _missles;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.fireButton = [[JSButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width-70,
                                                                 self.view.bounds.size.height-70,
                                                                 50,
                                                                 50)];
    [[self.fireButton titleLabel] setText:@"A"];
	[self.fireButton setBackgroundImage:[UIImage imageNamed:@"button"]];
	[self.fireButton setBackgroundImagePressed:[UIImage imageNamed:@"button-pressed"]];
    self.fireButton.delegate = self;
    
    self.joyStik = [[JSAnalogueStick alloc] initWithFrame:CGRectMake(20,
                                                                     self.view.bounds.size.height-120,
                                                                     100,
                                                                     100)];
    self.joyStik.delegate = self;
    
    self.glView = [[VKGLView alloc] initWithFrame:self.view.bounds];
    
    [self.view addSubview:self.glView];
    [self.view addSubview:self.fireButton];
    [self.view addSubview:self.joyStik];
    [self prepareWorld];
    [self start];
}

- (void) prepareWorld{
    self.ship = [[VKShip alloc] init];
    self.ship.position = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2);
    self.ship.velocity = 0;
    self.ship.rotation = 180;
    self.ship.color = [UIColor yellowColor];
    
    [self.glView addGLObject:self.ship];
    
    int asteroids_count = 10;
    for (int i = 0; i<asteroids_count; i++) {
        [self makeAsteroidWithSize:arc4random_uniform(5)+ 1
                          Position:CGPointMake(arc4random_uniform((int)WORLD_SIZE_X),
                                               arc4random_uniform((int)WORLD_SIZE_Y))];
    }
}

- (void) makeAsteroidWithSize:(int) parts Position:(CGPoint) position{
    VKAsteroid *asteroid = [[VKAsteroid alloc] initWithRadius:parts * 5];
    asteroid.parts = parts;
    asteroid.position = position;
    asteroid.direction = arc4random_uniform(360);
    asteroid.velocity = 50 + arc4random_uniform(150);
    asteroid.rotationVelocity = 50 + arc4random_uniform(100);
    [self.glView addGLObject:asteroid];
    [self.asteroids addObject:asteroid];
}

- (void) start{
    self.gameLoop = [[NSThread alloc] initWithTarget:self
                                            selector:@selector(loop:)
                                              object:self];
    [self.gameLoop setThreadPriority:1.0];
    [self.gameLoop start];
}

- (void) stop{
    [self.gameLoop cancel];
}

- (void) loop:(VKViewController *) gameController{
    NSThread *thread = [NSThread currentThread];
    NSTimeInterval interval = 1.0f/GAME_LOOP_RATE;
    while (!thread.isCancelled) {
        [gameController processGameStep:interval];
        [NSThread sleepForTimeInterval:interval];
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
    
    NSArray *asteroids = [self.asteroids copy];
    
    for (VKAsteroid *asteroid in asteroids) {
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
    
    NSArray *missles = [self.missles copy];
    
    for (VKMissle *missle in missles) {
        rad = missle.direction * M_PI/180;
        distance = missle.velocity*time;
        x = missle.position.x - distance * sin(rad) + offset_x;
        y = missle.position.y - distance * cos(rad) + offset_y;
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
        
        missle.leftDistance -= distance;
        if (missle.leftDistance < 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.glView removeGLObject:missle];
                [self.missles removeObject:missle];
            });
        }
        else{
            missle.position = CGPointMake(x, y);
        }
    }
    
    [self checkHit:missles Asteroids:asteroids];
    [self checkCollision:asteroids];
}

- (void) checkCollision:(NSArray *) asteroids{
    double distance;
    for (VKAsteroid *asteroid in asteroids){
        distance = sqrt(pow(asteroid.position.x-self.ship.position.x, 2)
                        + pow(asteroid.position.y - self.ship.position.y, 2));
        if (distance < asteroid.radius + 10) {
            [self stop];
        }
    }
}

- (void) checkHit:(NSArray *) missles Asteroids:(NSArray *) asteroids{
    double distance;
    for (VKMissle *missle in missles) {
        for (VKAsteroid *asteroid in asteroids){
            distance = sqrt(pow(asteroid.position.x-missle.position.x, 2)
                            + pow(asteroid.position.y - missle.position.y, 2));
            if (distance < asteroid.radius + 5) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    for (int i=0; i<asteroid.parts; i++) {
                        [self makeAsteroidWithSize:asteroid.parts-1 Position:asteroid.position];
                    }
                    [self.glView removeGLObject:asteroid];
                    [self.glView removeGLObject:missle];
                    [self.asteroids removeObject:asteroid];
                    [self.missles removeObject:missle];
                });
                break;
            }
        }
    }
}

- (void) fire{
    VKMissle *missle = [[VKMissle alloc] init];
    missle.position = self.ship.position;
    missle.direction = self.ship.rotation;
    missle.velocity = 1800.f;
    missle.rotation = self.ship.rotation;
    missle.leftDistance = 300;
    [self.glView addGLObject:missle];
    [self.missles addObject:missle];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - JSButtonDelegate

- (void)buttonPressed:(JSButton *)button
{
    if (button == self.fireButton)
	{
		[self fire];
		return;
	}
}

- (void) buttonReleased:(JSButton *)button{
    
}

- (void)analogueStickDidChangeValue:(JSAnalogueStick *)analogueStick{
    float acceleration = sqrt(pow(self.joyStik.xValue, 2)
                    + pow(self.joyStik.yValue, 2));
    
    if (acceleration != 0) {
        float rotation = acosf(self.joyStik.yValue/acceleration) * 180/M_PI;
        if (self.joyStik.xValue > 0) {
            rotation = 360 - rotation;
        }
        self.ship.rotation = rotation;
    }
    
    if (acceleration > 1) {
        acceleration = 1.0f;
    }
    self.ship.velocity = 200*acceleration;
}

@end
