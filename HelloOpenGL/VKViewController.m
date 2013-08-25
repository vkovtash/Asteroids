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
#define MAX_ASTEROID_SIZE 4
#define POINTS_MULTIPLIER 5
#define INITIAL_ASTEROIDS_COUNT 20

@interface VKViewController ()
@property (strong ,nonatomic) VKGLView *glView;
@property (strong, nonatomic) NSThread *gameLoop;
@property (strong ,nonatomic) UIButton *fireButton;
@property (strong ,nonatomic) JSAnalogueStick *joyStik;
@property (nonatomic) int points;
@property (strong, nonatomic) UILabel *pointsLabel;
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

- (void) setPoints:(int)points{
    _points = points;
    self.pointsLabel.text = [NSString stringWithFormat:@"Points: %d",points];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.fireButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.fireButton.frame = CGRectMake(self.view.bounds.size.width-90,
                                       self.view.bounds.size.height-90,
                                       60,
                                       60);
    [self.fireButton setImage:[UIImage imageNamed:@"button"]
                     forState:UIControlStateNormal];
    [self.fireButton setImage:[UIImage imageNamed:@"button-pressed"] forState:UIControlStateSelected];
    [self.fireButton addTarget:self action:@selector(fire) forControlEvents:UIControlEventTouchDown];
    
    self.joyStik = [[JSAnalogueStick alloc] initWithFrame:CGRectMake(20,
                                                                     self.view.bounds.size.height-120,
                                                                     100,
                                                                     100)];
    self.joyStik.delegate = self;
    
    self.pointsLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, 100, 20)];
    self.pointsLabel.backgroundColor = [UIColor clearColor];
    self.pointsLabel.textColor = [UIColor greenColor];
    self.pointsLabel.font = [UIFont fontWithName:@"Helvetica-Light" size:20];
    
    self.glView = [[VKGLView alloc] initWithFrame:self.view.bounds];
    
    [self.view addSubview:self.glView];
    [self.view addSubview:self.fireButton];
    [self.view addSubview:self.joyStik];
    [self.view addSubview:self.pointsLabel];
    [self start];
}

- (void) prepareWorld{
    self.ship = [[VKShip alloc] init];
    self.ship.position = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2);
    self.ship.velocity = 0;
    self.ship.rotation = 0;
    self.ship.color = [UIColor yellowColor];
    
    for (VKAsteroid *asteroid in self.asteroids) {
        [asteroid removeFromGLView];
    }
    [self.asteroids removeAllObjects];
    
    for (VKMissle * missle in self.missles) {
        [missle removeFromGLView];
    }
    [self.missles removeAllObjects];
    
    [self.glView addGLObject:self.ship];
    
    int asteroids_count = INITIAL_ASTEROIDS_COUNT;
    for (int i = 0; i<asteroids_count; i++) {
        [self makeAsteroidWithSize:arc4random_uniform(MAX_ASTEROID_SIZE-3) + 3
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
    self.points = 0;
    [self prepareWorld];
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
                    self.points += POINTS_MULTIPLIER*MAX_ASTEROID_SIZE - asteroid.parts * POINTS_MULTIPLIER;
                    for (int i=0; i<asteroid.parts; i++) {
                        [self makeAsteroidWithSize:asteroid.parts - 1
                                          Position:asteroid.position];
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
    if (!self.gameLoop.isFinished) {
        VKMissle *missle = [[VKMissle alloc] init];
        missle.position = self.ship.position;
        missle.direction = self.ship.rotation;
        missle.velocity = 1800.f;
        missle.rotation = self.ship.rotation;
        missle.leftDistance = 300;
        [self.glView addGLObject:missle];
        [self.missles addObject:missle];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)analogueStickDidChangeValue:(JSAnalogueStick *)analogueStick{
    if (!self.gameLoop.isFinished) {
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
}

@end
