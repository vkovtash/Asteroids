//
//  ZIMGameWorldController.m
//  Asteroids
//
//  Created by kovtash on 08.12.14.
//
//

#import "ZIMGameWorldController.h"
#import "VKAsteroid.h"
#import "VKMissle.h"
#import "VKStar.h"

static CGFloat kDefaultWorldSideSize = 2200;
static NSUInteger kDefaultInitialAsteroidsCount = 15;

#define FREE_SPACE_RADIUS 80.0f //points - radius around the ship that will be free of asteroids on the start
#define GAME_LOOP_RATE 60.0f //loops per second
#define ASTEROID_MAX_SIZE 4.0f //in parts
#define ASTEROID_PART_SIZE 5 //points
#define ASTEROID_MIN_SPEED 50.0f //points per sec
#define ASTEROID_MAX_SPEED 200.0f //points per sec
#define ASTEROID_MIN_ROTATION_SPEED 50.0f //degrees per sec
#define ASTEROID_MAX_ROTATION_SPEED 180.0f //degrees per sec
#define MISSLE_MAX_DISTANCE 300.0f //points
#define MISSLE_SPEED 1800.0f //points per sec
#define SHIP_MAX_SPEED 400.0f //points per sec
#define SHIP_ACCELERATION_RATE 200.0f //poins per sec^2c
#define STAR_RADIUS 2.0f //points
#define STARS_DENCITY 1 //starts per start STARS_GENERATOR_PART_SIZE
#define STARS_GENERATOR_PART_SIZE 160.0f //points
#define COLLISION_RADIUS_MULTIPLIER 0.8f


static inline double distance(double x1, double y1, double x2, double y2){
    return sqrt(pow(x1 - x2, 2) + pow(y1 - y2, 2));
}

@interface ZIMGameWorldController()
@property (strong, nonatomic) NSMutableArray *asteroids;
@property (strong, nonatomic) NSMutableArray *missles;
@property (strong, nonatomic) NSMutableArray *stars;
@property (strong, nonatomic) NSThread *gameThread;
@end

@implementation ZIMGameWorldController

- (instancetype) initWithGlViewSize:(CGSize)size worldSize:(CGSize)worldSize {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _glView = [[VKGLView alloc] initWithGlViewSize:size];
    _ship = [[VKShip alloc] init];
    _asteroids = [NSMutableArray array];
    _missles = [NSMutableArray array];
    
    _worldSize = worldSize;
    _initialAsteroidsCount = kDefaultInitialAsteroidsCount;
    
    _ship.color = [UIColor yellowColor];
    _ship.maxSpeed = SHIP_MAX_SPEED;
    _ship.accelerationRate = SHIP_ACCELERATION_RATE;
    
    [_glView addGLObject:_ship];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(pause)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    [self reset];
    return self;
}

- (instancetype) initWithGlViewSize:(CGSize)size {
    return [self initWithGlViewSize:size worldSize:CGSizeMake(kDefaultWorldSideSize, kDefaultWorldSideSize)];
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL) isExecuting {
    return self.gameThread.isExecuting;
}

- (NSUInteger) currentAsteroidsCount {
    return self.asteroids.count;
}

- (void) reset {
    [self pause];
    [self clearWorld];
    [self prepareWorld];
    _isFinished = NO;
    self.ship.x_velocity = 0;
    self.ship.y_velocity = 0;
    self.ship.accelerating = NO;
    self.ship.rotation = 0;
    self.ship.position = CGPointMake(self.glView.glViewSize.width / 2,
                                     self.glView.glViewSize.height / 2);
}

- (void) pause {
    if (self.isExecuting && !self.isFinished) {
        _isPaused = YES;
        [self.gameThread cancel];
        self.gameThread = nil;
    }
}

- (void) resume {
    if (!self.isExecuting && !self.isFinished) {
        _isPaused = NO;
        self.gameThread = [[NSThread alloc] initWithTarget:self
                                                  selector:@selector(loop)
                                                    object:nil];
        self.gameThread.threadPriority = 1.0;
        [self.gameThread start];
        [self.delegate controllerDidResumeGame:self];
    }
}

#pragma mark - Factory methods

- (void) makeAsteroidWithSize:(int)parts Position:(CGPoint) position{
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

- (void) prepareWorld {
    double x, y;
    for (int i = 0; i < self.initialAsteroidsCount; i++) {
        x = arc4random_uniform((int)self.worldSize.width);
        y = arc4random_uniform((int)self.worldSize.height);
        
        //ensure that any of asteroids will be placed over the ship on game start
        while (distance(x,y,self.ship.position.x, self.ship.position.y) < FREE_SPACE_RADIUS) {
            x = arc4random_uniform((int)self.worldSize.width);
            y = arc4random_uniform((int)self.worldSize.height);
        }
        [self makeAsteroidWithSize:arc4random_uniform(ASTEROID_MAX_SIZE-2) + 3
                          Position:CGPointMake(x,y)];
    }
    
    if (!self.stars){
        self.stars = [NSMutableArray array];
        
        int part_size = STARS_GENERATOR_PART_SIZE;
        int x_parts = self.worldSize.width / part_size + 1;
        int y_parts = self.worldSize.height / part_size + 1;
        int stars_per_part = STARS_DENCITY;
        
        int star_x;
        int star_y;
        
        for (int x = 0; x < x_parts; x++) {
            for (int y = 0; y < y_parts; y++) {
                for (int i = 0; i < stars_per_part; i++) {
                    star_x = x * part_size + arc4random_uniform(part_size);
                    star_y = y * part_size + arc4random_uniform(part_size);
                    VKStar *star = [[VKStar alloc] initWithRadius:STAR_RADIUS];
                    star.position = [self worldCoordinatesForX:star_x Y:star_y];
                    [self.stars addObject:star];
                    [self.glView addGLObject:star];
                }
            }
        }
    }
}

- (void) clearWorld {
    for (VKAsteroid *asteroid in self.asteroids) {
        [asteroid removeFromGLView];
    }
    [self.asteroids removeAllObjects];
    
    for (VKMissle * missle in self.missles) {
        [missle removeFromGLView];
    }
    [self.missles removeAllObjects];
}

- (void) fire {
    if (!self.gameThread.isExecuting) {
        return;
    }
    
    VKMissle *missle = [[VKMissle alloc] init];
    missle.position = self.ship.position;
    missle.direction = self.ship.rotation;
    missle.velocity = MISSLE_SPEED;
    missle.rotation = self.ship.rotation;
    missle.leftDistance = MISSLE_MAX_DISTANCE;
    [self.glView addGLObject:missle];
    [self.missles addObject:missle];
}

#pragma mark - game run loop

- (void) loop {
    NSThread *thread = [NSThread currentThread];
    NSTimeInterval interval = 1.0f / GAME_LOOP_RATE;
    NSTimeInterval sleepFor;
    clock_t start;
    while (!thread.isCancelled) {
        start = clock();
        
        if (![self processGameStep:interval]) {
            break;
        }
        
        sleepFor = interval - (double)(clock() - start) / CLOCKS_PER_SEC;
        if (sleepFor > 0) {
            [NSThread sleepForTimeInterval:interval];
        }
    }
    
    __block BOOL isCancelled = thread.isCancelled;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (isCancelled) {
            _isPaused = YES;
            [self.delegate controllerDidPauseGame:self];
        }
        else {
            _isFinished = YES;
            [self.delegate controllerDidFinishGame:self];
        }
    });
}

- (BOOL) processGameStep:(NSTimeInterval)time {
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
    return ![self checkCollision:asteroids];
}

#pragma mark - collision detection

- (BOOL) checkCollision:(NSArray *)asteroids {
    double distance_value;
    for (VKAsteroid *asteroid in asteroids){
        distance_value = distance(asteroid.position.x, asteroid.position.y,
                                  self.ship.position.x, self.ship.position.y);
        if (distance_value < (asteroid.radius + self.ship.radius) * COLLISION_RADIUS_MULTIPLIER) {
            return YES;
        }
    }
    return NO;
}

- (void) checkHit:(NSArray *)missles Asteroids:(NSArray *)asteroids {
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
                    
                    [self.delegate controller:self didDetectAsteroidHit:asteroid];
                });
                break;
            }
        }
    }
}

- (CGPoint) worldCoordinatesForX:(double)x Y:(double)y {
    CGSize worldSize = self.worldSize;
    if (x > worldSize.width / 2) {
        x -= worldSize.width;
    }
    else if (x < -worldSize.width/2){
        x += worldSize.width;
    }
    
    if (y > worldSize.height / 2) {
        y -= worldSize.height;
    }
    else if (y < -worldSize.height/2){
        y += worldSize.height;
    }
    return CGPointMake(x, y);
}

@end
