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
#import "SIAlertView.h"
#import "VKStar.h"

#define OFFSCREEN_WORLD_SIZE 100 //points
#define WORLD_SIZE_X 800 //points
#define WORLD_SIZE_Y 800 //points
#define GAME_LOOP_RATE 100 //loops per second
#define STAR_RADIUS 2 //points
#define STARS_COUNT 30
#define MAX_ASTEROID_SIZE 4 //in parts
#define ASTEROID_PART_SIZE 5 //points
#define SCORE_MULTIPLIER 5
#define INITIAL_ASTEROIDS_COUNT 10
#define SHIP_MAX_SPEED 200 //points per sec
#define MAX_MISSLE_DISTANCE 300 //points
#define MISSLE_SPEED 1800 //points per sec
#define MIN_ASTEROID_SPEED 50 //points per sec
#define MAX_ASTEROID_SPEED 200 //points per sec
#define MIN_ASTEROID_ROTATION_SPEED 50 //degrees per sec
#define MAX_ASTEROID_ROTATION_SPEED 180 //degrees per sec
#define COLLISION_RADIUS_MULTIPLIER 0.8f
#define FREE_SPACE_RADIUS 80 //points - radius around the ship that will be free of asteroids on the start


float distance(float x1, float y1, float x2, float y2){
    return sqrt(pow(x1 - x2, 2) + pow(y1 - y2, 2));
}

@interface VKViewController ()
@property (strong, nonatomic) VKGLView *glView;
@property (strong, nonatomic) NSThread *gameLoop;
@property (strong, nonatomic) UIButton *fireButton;
@property (strong, nonatomic) UIButton *accelerationButton;
@property (strong, nonatomic) JSAnalogueStick *joyStik;
@property (nonatomic) int points;
@property (strong, nonatomic) UILabel *pointsLabel;
@property (strong, nonatomic) UILabel *asteroidsCountLabel;
@end

@implementation VKViewController

#pragma mark - Publick properties

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

#pragma mark - Private properties

- (void) setPoints:(int)points{
    _points = points;
    self.pointsLabel.text = [NSString stringWithFormat:@"SCORE: %d",points];
    self.asteroidsCountLabel.text = [NSString stringWithFormat:@"ASTEROIDS: %d",self.asteroids.count];
}

#pragma mark - ViewController life cycle

- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.ship.position = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2);
    [self start];
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
    self.fireButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin;
    
    self.joyStik = [[JSAnalogueStick alloc] initWithFrame:CGRectMake(20,
                                                                     self.view.bounds.size.height-120,
                                                                     100,
                                                                     100)];
    self.joyStik.delegate = self;
    self.joyStik.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleRightMargin;
    
    self.pointsLabel = [[UILabel alloc] initWithFrame:CGRectMake(20,
                                                                 20,
                                                                 self.view.bounds.size.width-40,
                                                                 20)];
    self.pointsLabel.backgroundColor = [UIColor clearColor];
    self.pointsLabel.textColor = [UIColor yellowColor];
    self.pointsLabel.font = [UIFont fontWithName:@"Gill-Sans" size:18];
    
    self.asteroidsCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.bounds.size.width/2+20,
                                                                         20,
                                                                         self.view.bounds.size.width/2-20,
                                                                         20)];
    self.asteroidsCountLabel.backgroundColor = [UIColor clearColor];
    self.asteroidsCountLabel.textColor = [UIColor yellowColor];
    self.asteroidsCountLabel.font = [UIFont fontWithName:@"Gill-Sans" size:18];
    self.asteroidsCountLabel.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleLeftMargin;
    
    self.glView = [[VKGLView alloc] initWithFrame:CGRectMake(0,
                                                             0,
                                                             self.view.bounds.size.height,
                                                             self.view.bounds.size.width)];
    
    [self.view addSubview:self.glView];
    [self.view addSubview:self.fireButton];
    [self.view addSubview:self.joyStik];
    [self.view addSubview:self.pointsLabel];
    [self.view addSubview:self.asteroidsCountLabel];
    
    self.ship = [[VKShip alloc] init];
    self.ship.color = [UIColor yellowColor];
    [self.glView addGLObject:self.ship];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Factory methods

- (void) makeAsteroidWithSize:(int) parts Position:(CGPoint) position{
    VKAsteroid *asteroid = [[VKAsteroid alloc] initWithRadius:parts * ASTEROID_PART_SIZE];
    asteroid.parts = parts;
    asteroid.position = position;
    asteroid.direction = arc4random_uniform(360);
    asteroid.velocity = MIN_ASTEROID_SPEED +
    arc4random_uniform(MAX_ASTEROID_SPEED - MIN_ASTEROID_SPEED);
    asteroid.rotationVelocity = MIN_ASTEROID_ROTATION_SPEED +
    arc4random_uniform(MAX_ASTEROID_ROTATION_SPEED - MIN_ASTEROID_ROTATION_SPEED);
    [self.glView addGLObject:asteroid];
    [self.asteroids addObject:asteroid];
}

#pragma mark - Game events

- (void) prepareWorld{
    int asteroids_count = INITIAL_ASTEROIDS_COUNT;
    float x, y;
    for (int i = 0; i < asteroids_count; i++) {
        x = arc4random_uniform((int)WORLD_SIZE_X);
        y = arc4random_uniform((int)WORLD_SIZE_Y);
        
        //ensure that any of asteroids will be placed over the ship on game start
        while (distance(x,y,self.ship.position.x, self.ship.position.y) < FREE_SPACE_RADIUS) {
            x = arc4random_uniform((int)WORLD_SIZE_X);
            y = arc4random_uniform((int)WORLD_SIZE_Y);
        }
        [self makeAsteroidWithSize:arc4random_uniform(MAX_ASTEROID_SIZE-2) + 3
                          Position:CGPointMake(x,y)];
    }
    
    if (!self.stars){
        self.stars = [NSMutableArray array];
        for (int i; i < STARS_COUNT; i++) {
            VKStar *star = [[VKStar alloc] initWithRadius:STAR_RADIUS];
            x = arc4random_uniform((int)WORLD_SIZE_X);
            y = arc4random_uniform((int)WORLD_SIZE_Y);
            star.position = CGPointMake(x, y);
            [self.stars addObject:star];
            [self.glView addGLObject:star];
        }
    }
}

- (void) clearWorld{
    for (VKAsteroid *asteroid in self.asteroids) {
        [asteroid removeFromGLView];
    }
    [self.asteroids removeAllObjects];
    
    for (VKMissle * missle in self.missles) {
        [missle removeFromGLView];
    }
    [self.missles removeAllObjects];
}

- (void) start{
    [self clearWorld];
    [self prepareWorld];
    self.points = 0;
    self.ship.velocity = 0;
    self.ship.rotation = 0;
    self.gameLoop = [[NSThread alloc] initWithTarget:self
                                            selector:@selector(loop:)
                                              object:self];
    [self.gameLoop setThreadPriority:1.0];
    [self.gameLoop start];
}

- (void) stop{
    [self.gameLoop cancel];
    self.ship.velocity = 0;
}

- (void) win{
    [self stop];
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"You win the Game!!!"
                                                     andMessage:[NSString stringWithFormat:@"You score is %d",self.points]];
    [alertView addButtonWithTitle:@"Restart Game"
                             type:SIAlertViewDidDismissNotification
                          handler:^(SIAlertView *alertView){
                              [self start];
                          }];
    [alertView show];
}

- (void) gameOver{
    [self stop];
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"The game is over."
                                                     andMessage:[NSString stringWithFormat:@"You score is %d",self.points]];
    [alertView addButtonWithTitle:@"Restart Game"
                             type:SIAlertViewDidDismissNotification
                          handler:^(SIAlertView *alertView){
                              [self start];
                          }];
    [alertView show];
}

- (void) fire{
    if (!self.gameLoop.isFinished) {
        VKMissle *missle = [[VKMissle alloc] init];
        missle.position = self.ship.position;
        missle.direction = self.ship.rotation;
        missle.velocity = MISSLE_SPEED;
        missle.rotation = self.ship.rotation;
        missle.leftDistance = MAX_MISSLE_DISTANCE;
        [self.glView addGLObject:missle];
        [self.missles addObject:missle];
    }
}

#pragma mark - game run loop

- (void) loop:(VKViewController *) gameController{
    NSThread *thread = [NSThread currentThread];
    NSTimeInterval interval = 1.0f/GAME_LOOP_RATE;
    while (!thread.isCancelled) {
        [gameController processGameStep:interval];
        [NSThread sleepForTimeInterval:interval];
    }
}

- (void) processGameStep:(NSTimeInterval) time{
    if (self.gameLoop.isCancelled) {
        return;
    }
    double x;
    double y;
    double radians;
    double distance;
    
    //moving ship
    radians = self.ship.rotation * M_PI / 180;
    double offset_x = self.ship.velocity*time * sin(radians);
    double offset_y = self.ship.velocity*time * cos(radians);
    
    //moving asteroids
    NSArray *asteroids = [self.asteroids copy];
    
    for (VKAsteroid *asteroid in asteroids) {
        radians = asteroid.direction * M_PI / 180;
        distance = asteroid.velocity*time;
        x = asteroid.position.x - distance * sin(radians) + offset_x;
        y = asteroid.position.y - distance * cos(radians) + offset_y;
        asteroid.position = [self worldCoordinatesForX:x Y:y];
        asteroid.rotation += asteroid.rotationVelocity * time;
    }
    
    //moving missles
    NSArray *missles = [self.missles copy];
    
    for (VKMissle *missle in missles) {
        radians = missle.direction * M_PI/180;
        distance = missle.velocity*time;
        x = missle.position.x - distance * sin(radians) + offset_x;
        y = missle.position.y - distance * cos(radians) + offset_y;
        
        missle.leftDistance -= distance;
        if (missle.leftDistance < 0) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self.glView removeGLObject:missle];
                [self.missles removeObject:missle];
            });
        }
        else{
            missle.position = [self worldCoordinatesForX:x Y:y];
        }
    }
    
    //moving starts
    for (VKStar *star in self.stars) {
        x = star.position.x + offset_x;
        y = star.position.y + offset_y;
        star.position = [self worldCoordinatesForX:x Y:y];
    }
    
    [self checkHit:missles Asteroids:asteroids];
    [self checkCollision:asteroids];
}

- (CGPoint) worldCoordinatesForX:(float) x Y:(float) y{
    if (x > WORLD_SIZE_X - OFFSCREEN_WORLD_SIZE ) {
        x = -OFFSCREEN_WORLD_SIZE;
    }
    else if (x < -OFFSCREEN_WORLD_SIZE){
        x = WORLD_SIZE_X - OFFSCREEN_WORLD_SIZE;
    }
    
    if (y > WORLD_SIZE_Y - OFFSCREEN_WORLD_SIZE) {
        y = -OFFSCREEN_WORLD_SIZE;
    }
    else if (y < -OFFSCREEN_WORLD_SIZE){
        y = WORLD_SIZE_Y - OFFSCREEN_WORLD_SIZE;
    }
    return CGPointMake(x, y);
}

#pragma mark - collision detection

- (void) checkCollision:(NSArray *) asteroids{
    if (self.gameLoop.isCancelled) {
        return;
    }
    double distance_value;
    for (VKAsteroid *asteroid in asteroids){
        distance_value = distance(asteroid.position.x, asteroid.position.y,
                                  self.ship.position.x, self.ship.position.y);
        if (distance_value < (asteroid.radius + self.ship.radius) * COLLISION_RADIUS_MULTIPLIER) {
            [self gameOver];
        }
    }
}

- (void) checkHit:(NSArray *) missles Asteroids:(NSArray *) asteroids{
    if (self.gameLoop.isCancelled) {
        return;
    }
    double distance_value;
    for (VKMissle *missle in missles) {
        for (VKAsteroid *asteroid in asteroids){
            distance_value = distance(asteroid.position.x, asteroid.position.y,
                                      missle.position.x, missle.position.y);
            if (distance_value < asteroid.radius + missle.radius) {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [self.glView removeGLObject:asteroid];
                    [self.glView removeGLObject:missle];
                    [self.asteroids removeObject:asteroid];
                    [self.missles removeObject:missle];
                    
                    if (asteroid.parts > 1){
                        for (int i=0; i<asteroid.parts; i++) {
                            [self makeAsteroidWithSize:asteroid.parts - 1
                                              Position:asteroid.position];
                        }
                    }
                    
                    self.points += SCORE_MULTIPLIER * MAX_ASTEROID_SIZE - asteroid.parts * SCORE_MULTIPLIER;
                    if (self.asteroids.count == 0) {
                        dispatch_sync(dispatch_get_main_queue(), ^{
                            [self win];
                        });
                    }
                });
                break;
            }
        }
    }
}

#pragma mark - JSAnalogueStickDelegate

- (void)analogueStickDidChangeValue:(JSAnalogueStick *)analogueStick{
    //Setting ship direcrion and velocity
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
        self.ship.velocity = SHIP_MAX_SPEED*acceleration;
    }
}

@end
