//
//  VKViewController.m
//  Asteroids
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
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

#define WORLD_SIZE_X 1200 //points
#define WORLD_SIZE_Y 1200 //points
#define FREE_SPACE_RADIUS 80 //points - radius around the ship that will be free of asteroids on the start
#define INITIAL_ASTEROIDS_COUNT 10
#define OFFSCREEN_WORLD_SIZE 100 //points
#define SCORE_MULTIPLIER 5
#define GAME_LOOP_RATE 100 //loops per second
#define ASTEROID_MAX_SIZE 4 //in parts
#define ASTEROID_PART_SIZE 5 //points
#define ASTEROID_MIN_SPEED 50 //points per sec
#define ASTEROID_MAX_SPEED 200 //points per sec
#define ASTEROID_MIN_ROTATION_SPEED 50 //degrees per sec
#define ASTEROID_MAX_ROTATION_SPEED 180 //degrees per sec
#define MISSLE_MAX_DISTANCE 300 //points
#define MISSLE_SPEED 1800 //points per se
#define SHIP_MAX_SPEED 400 //points per sec
#define SHIP_ACCELERATION_RATE 200 //poins per sec^2c
#define STAR_RADIUS 2 //points
#define STARS_COUNT 30
#define COLLISION_RADIUS_MULTIPLIER 0.8f


float distance(float x1, float y1, float x2, float y2){
    return sqrt(pow(x1 - x2, 2) + pow(y1 - y2, 2));
}

@interface VKViewController () {
    SystemSoundID blast;
    SystemSoundID explosion;
    SystemSoundID death;
}
@property (strong, nonatomic) VKGLView *glView;
@property (nonatomic,strong) AVAudioPlayer *audioPlayer;
@property (strong, nonatomic) NSThread *gameLoop;
@property (strong, nonatomic) UIButton *fireButton;
@property (strong, nonatomic) UIButton *accelerationButton;
@property (strong, nonatomic) JSAnalogueStick *joyStik;
@property (nonatomic) int level;
@property (nonatomic) int points;
@property (strong, nonatomic) UILabel *pointsLabel;
@property (strong, nonatomic) UILabel *asteroidsCountLabel;
@property (strong, nonatomic) UILabel *levelLabel;
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

- (AVAudioPlayer *) audioPlayer{
    if (_audioPlayer == nil) {
        NSError *error = nil;
        _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/Searching.m4a",
                                                                                            [[NSBundle mainBundle] resourcePath]]] error:&error];
        
        if (error != nil){
            NSLog(@"Error loading audio %@",error.description);
        }
        
        if (self.audioPlayer != nil) {
            [self.audioPlayer prepareToPlay];
            self.audioPlayer.numberOfLoops = -1; //Infinite
            [self.audioPlayer setVolume:1.0];
        }
    }
    return _audioPlayer;
}

- (void) setPoints:(int)points{
    _points = points;
    self.pointsLabel.text = [NSString stringWithFormat:@"SCORE: %d",points];
    self.asteroidsCountLabel.text = [NSString stringWithFormat:@"ASTEROIDS: %d",self.asteroids.count];
}

- (void) setLevel:(int)level{
    _level = level;
    self.levelLabel.text = [NSString stringWithFormat:@"LEVEL %d",level];
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
    
    //int views
    
    self.fireButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.fireButton.frame = CGRectMake(self.view.bounds.size.width-160,
                                       self.view.bounds.size.height-90,
                                       60,
                                       60);
    [self.fireButton setImage:[UIImage imageNamed:@"button"]
                     forState:UIControlStateNormal];
    [self.fireButton setImage:[UIImage imageNamed:@"button-pressed"] forState:UIControlStateSelected];
    [self.fireButton addTarget:self action:@selector(fire) forControlEvents:UIControlEventTouchDown];
    self.fireButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin;
    
    UILabel *fireLabel = [[UILabel alloc] initWithFrame:self.fireButton.bounds];
    fireLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    fireLabel.backgroundColor = [UIColor clearColor];
    fireLabel.textAlignment = NSTextAlignmentCenter;
    fireLabel.textColor = [UIColor darkGrayColor];
    fireLabel.shadowColor = [UIColor whiteColor];
    fireLabel.shadowOffset = CGSizeMake(0, 1);
    fireLabel.text = @"fire";
    [self.fireButton addSubview:fireLabel];
    
    self.accelerationButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.accelerationButton.frame = CGRectMake(self.view.bounds.size.width-80,
                                       self.view.bounds.size.height-120,
                                       60,
                                       60);
    [self.accelerationButton setImage:[UIImage imageNamed:@"button"]
                     forState:UIControlStateNormal];
    [self.accelerationButton setImage:[UIImage imageNamed:@"button-pressed"] forState:UIControlStateSelected];
    [self.accelerationButton addTarget:self action:@selector(startAcceleration) forControlEvents:UIControlEventTouchDown];
    [self.accelerationButton addTarget:self action:@selector(stopAcceleration) forControlEvents:UIControlEventTouchUpInside];
    self.accelerationButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin;
    
    UILabel *accelLabel = [[UILabel alloc] initWithFrame:self.fireButton.bounds];
    accelLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    accelLabel.backgroundColor = [UIColor clearColor];
    accelLabel.textAlignment = NSTextAlignmentCenter;
    accelLabel.textColor = [UIColor darkGrayColor];
    accelLabel.shadowColor = [UIColor whiteColor];
    accelLabel.shadowOffset = CGSizeMake(0, 1);
    accelLabel.text = @"accel";
    [self.accelerationButton addSubview:accelLabel];
    
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
    self.pointsLabel.font = [UIFont fontWithName:@"STHeitiTC-Light" size:18];
    
    self.asteroidsCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.bounds.size.width-140,
                                                                         20,
                                                                         140,
                                                                         20)];
    self.asteroidsCountLabel.backgroundColor = [UIColor clearColor];
    self.asteroidsCountLabel.textColor = [UIColor yellowColor];
    self.asteroidsCountLabel.font = [UIFont fontWithName:@"STHeitiTC-Light" size:18];
    self.asteroidsCountLabel.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleLeftMargin;
    
    self.levelLabel = [[UILabel alloc] initWithFrame:CGRectMake(20,
                                                                20,
                                                                self.view.bounds.size.width - 40,
                                                                20)];
    self.levelLabel.backgroundColor = [UIColor clearColor];
    self.levelLabel.textColor = [UIColor yellowColor];
    self.levelLabel.font = [UIFont fontWithName:@"STHeitiTC-Medium" size:20];
    self.levelLabel.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleWidth;
    self.levelLabel.textAlignment = NSTextAlignmentCenter;
   
    self.glView = [[VKGLView alloc] initWithFrame:CGRectMake(0,
                                                             0,
                                                             self.view.bounds.size.height,
                                                             self.view.bounds.size.width)];
    
    [self.view addSubview:self.glView];
    [self.view addSubview:self.fireButton];
    [self.view addSubview:self.accelerationButton];
    [self.view addSubview:self.joyStik];
    [self.view addSubview:self.pointsLabel];
    [self.view addSubview:self.asteroidsCountLabel];
    [self.view addSubview:self.levelLabel];
    
    //Sound effects
    
    NSString *path  = [[NSBundle mainBundle] pathForResource:@"blast" ofType:@"m4a"];
    NSURL *pathURL = [NSURL fileURLWithPath : path];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef) pathURL, &blast);
    
    path  = [[NSBundle mainBundle] pathForResource:@"explosion" ofType:@"m4a"];
    pathURL = [NSURL fileURLWithPath : path];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef) pathURL, &explosion);
    
    path  = [[NSBundle mainBundle] pathForResource:@"death" ofType:@"m4a"];
    pathURL = [NSURL fileURLWithPath : path];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef) pathURL, &death);
    
    // init game state
    
    self.level = 1;
    self.points = 0;
    self.ship = [[VKShip alloc] init];
    self.ship.color = [UIColor yellowColor];
    self.ship.maxSpeed = SHIP_MAX_SPEED;
    self.ship.accelerationRate = SHIP_ACCELERATION_RATE;
    
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
    asteroid.velocity = ASTEROID_MIN_SPEED +
    arc4random_uniform(ASTEROID_MAX_SPEED - ASTEROID_MIN_SPEED);
    asteroid.rotationVelocity = ASTEROID_MIN_ROTATION_SPEED +
    arc4random_uniform(ASTEROID_MAX_ROTATION_SPEED - ASTEROID_MIN_ROTATION_SPEED);
    [self.glView addGLObject:asteroid];
    [self.asteroids addObject:asteroid];
}

#pragma mark - Game events

- (void) prepareWorld{
    float x, y;
    for (int i = 0; i < INITIAL_ASTEROIDS_COUNT + self.level-1; i++) { //asteroids count increased with level
        x = arc4random_uniform((int)WORLD_SIZE_X);
        y = arc4random_uniform((int)WORLD_SIZE_Y);
        
        //ensure that any of asteroids will be placed over the ship on game start
        while (distance(x,y,self.ship.position.x, self.ship.position.y) < FREE_SPACE_RADIUS) {
            x = arc4random_uniform((int)WORLD_SIZE_X);
            y = arc4random_uniform((int)WORLD_SIZE_Y);
        }
        [self makeAsteroidWithSize:arc4random_uniform(ASTEROID_MAX_SIZE-2) + 3
                          Position:CGPointMake(x,y)];
    }
    
    self.asteroidsCountLabel.text = [NSString stringWithFormat:@"ASTEROIDS: %d",self.asteroids.count];
    
    if (!self.stars){
        self.stars = [NSMutableArray array];
        for (int i = 0; i < STARS_COUNT; i++) {
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
    self.ship.x_velocity = 0;
    self.ship.y_velocity = 0;
    self.ship.accelerating = NO;
    self.ship.rotation = 0;
    self.gameLoop = [[NSThread alloc] initWithTarget:self
                                            selector:@selector(loop:)
                                              object:self];
    [self.audioPlayer play];
    [self.gameLoop start];
}

- (void) stop{
    [self.audioPlayer stop];
    [self.gameLoop cancel];
    self.ship.x_velocity = 0;
    self.ship.y_velocity = 0;
    self.ship.accelerating = NO;
}

- (void) levelDone{
    [self stop];
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"Level Done"
                                                     andMessage:[NSString stringWithFormat:@"Your score is %d", self.points]];
    [alertView addButtonWithTitle:@"Next level"
                             type:SIAlertViewDidDismissNotification
                          handler:^(SIAlertView *alertView){
                              self.level += 1;
                              [self start];
                          }];
    [alertView show];
}

- (void) gameOver{
    [self stop];
    AudioServicesPlaySystemSound(death);
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"Game Over"
                                                     andMessage:[NSString stringWithFormat:@"Your score is %d", self.points]];
    [alertView addButtonWithTitle:@"Try again"
                             type:SIAlertViewDidDismissNotification
                          handler:^(SIAlertView *alertView){
                              self.points = 0;
                              self.level = 1;
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
        missle.leftDistance = MISSLE_MAX_DISTANCE;
        [self.glView addGLObject:missle];
        [self.missles addObject:missle];
        AudioServicesPlaySystemSound(blast);
    }
}

- (void) startAcceleration{
    self.ship.accelerating = YES;
}

- (void) stopAcceleration{
    self.ship.accelerating = NO;
}

#pragma mark - game run loop

- (void) loop:(VKViewController *) gameController{
    NSThread *thread = [NSThread currentThread];
    NSTimeInterval interval = 1.0f / GAME_LOOP_RATE;
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
    
    //moving ship
    if (self.ship.accelerating) {
        [self.ship accelerateWithTimeInterval:time];
    }
    double offset_x = self.ship.x_velocity * time;
    double offset_y = self.ship.y_velocity * time;
    
    //moving asteroids
    NSArray *asteroids = [self.asteroids copy];
    
    for (VKAsteroid *asteroid in asteroids) {
        x = asteroid.position.x - asteroid.x_velocity * time + offset_x;
        y = asteroid.position.y - asteroid.y_velocity * time + offset_y;
        asteroid.position = [self worldCoordinatesForX:x Y:y];
        [asteroid rotateWithTimeInterval:time];
    }
    
    //moving missles
    NSArray *missles = [self.missles copy];
    
    for (VKMissle *missle in missles) {        
        if (missle.leftDistance > 0) {
            x = missle.position.x - missle.x_velocity * time + offset_x;
            y = missle.position.y - missle.y_velocity * time + offset_y;
            missle.position = [self worldCoordinatesForX:x Y:y];
            [missle decreaseLeftDistanceWithTimeInterval:time];
        }
        else{
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self.glView removeGLObject:missle];
                [self.missles removeObject:missle];
            });
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
    if (x > WORLD_SIZE_X - OFFSCREEN_WORLD_SIZE) {
     x -= WORLD_SIZE_X;
     }
     else if (x < -OFFSCREEN_WORLD_SIZE){
     x += WORLD_SIZE_X - OFFSCREEN_WORLD_SIZE;
     }
     
     if (y > WORLD_SIZE_Y - OFFSCREEN_WORLD_SIZE) {
     y -= WORLD_SIZE_Y;
     }
     else if (y < -OFFSCREEN_WORLD_SIZE){
     y += WORLD_SIZE_Y - OFFSCREEN_WORLD_SIZE;
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
                    
                    AudioServicesPlaySystemSound(explosion);
                    
                    self.points += SCORE_MULTIPLIER * (ASTEROID_MAX_SIZE+1) - asteroid.parts * SCORE_MULTIPLIER;
                    if (self.asteroids.count == 0) {
                        [self levelDone];
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
    }
}

@end
