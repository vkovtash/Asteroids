//
//  ZIMGameWorldController.m
//  Asteroids
//
//  Created by kovtash on 08.12.14.
//
//

#import "ZIMGameWorldController.h"
#import "VKStarsArray.h"
#import "VKMisslesArray.h"
#import "VKGameReusableObjectsArray.h"
#import "VKAsteroidProperties.h"

static CGFloat kDefaultWorldSideSize = 2200; //in points
static NSUInteger kDefaultInitialAsteroidsCount = 15;
static CGFloat kDefaultAsteroidMaxSize = 20;  //in parts
static CGFloat kAsteroidPartArea = 50;
static CGFloat kShipCollisionRadiusMultiplier = 0.75;

#define FREE_SPACE_RADIUS 80.0f //points - radius around the ship that will be free of asteroids on the start
#define GAME_LOOP_RATE 60.0f //loops per second
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


static inline double distance(CGPoint p1, CGPoint p2) {
    return sqrt(pow(p1.x - p2.x, 2) + pow(p1.y - p2.y, 2));
}

@interface ZIMGameWorldController()
@property (strong, nonatomic) VKGameReusableObjectsArray *asteroids;
@property (strong, nonatomic) VKMisslesArray *missles;
@property (strong, nonatomic) VKStarsArray *stars;
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
    _asteroids = [VKGameReusableObjectsArray new];
    _missles = [VKMisslesArray new];
    
    _worldSize = worldSize;
    _initialAsteroidsCount = kDefaultInitialAsteroidsCount;
    _asteroidMaxSize = kDefaultAsteroidMaxSize;
    
    _ship.color = [UIColor yellowColor];
    _ship.maxSpeed = SHIP_MAX_SPEED;
    _ship.accelerationRate = SHIP_ACCELERATION_RATE;
    
    [_glView addGLObject:_ship];
    [_glView addGLObject:_missles];
    [_glView addGLObject:_asteroids];
    
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
    return self.asteroids.objectsProperties.count;
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

- (void) spawnAsteroid {
    [self makeAsteroidWithSize:[self chooseAsteroidSize]
                      Position:[self worldCoordinatesFor:CGPointMake(self.ship.position.x + self.worldSize.width / 2,
                                                                     self.ship.position.y + self.worldSize.height / 2)]];
}

#pragma mark - Factory methods

- (void) makeAsteroidWithSize:(int)parts Position:(CGPoint)position {
    VKAsteroidProperties *asteroid = [[VKAsteroidProperties alloc] initWithRadius:sqrt(parts * kAsteroidPartArea) position:position];
    asteroid.parts = parts;
    asteroid.direction = arc4random_uniform(360);
    asteroid.velocity = ASTEROID_MIN_SPEED + arc4random_uniform(ASTEROID_MAX_SPEED - ASTEROID_MIN_SPEED);
    asteroid.rotationVelocity = ASTEROID_MIN_ROTATION_SPEED + arc4random_uniform(ASTEROID_MAX_ROTATION_SPEED - ASTEROID_MIN_ROTATION_SPEED);
    [self.asteroids appendObjectProperties:asteroid];
}

- (int) chooseAsteroidSize {
    int sizeDistorsion = 5;
    return _asteroidMaxSize - sizeDistorsion + arc4random_uniform(sizeDistorsion);
}

#pragma mark - Game events

- (void) prepareWorld {
    for (int i = 0; i < self.initialAsteroidsCount; i++) {
        CGPoint point = CGPointMake(arc4random_uniform((int)self.worldSize.width),
                                    arc4random_uniform((int)self.worldSize.height));
        //ensure that any of asteroids will be placed over the ship on game start
        while (distance(point, self.ship.position) < FREE_SPACE_RADIUS) {
            point.x = arc4random_uniform((int)self.worldSize.width);
            point.y = arc4random_uniform((int)self.worldSize.height);
        }
        [self makeAsteroidWithSize:[self chooseAsteroidSize]
                          Position:point];
    }
    
    if (!self.stars){
        self.stars = [[VKStarsArray alloc] initWithRadius:STAR_RADIUS];
        [self.glView addGLObject:self.stars];
        
        int part_size = STARS_GENERATOR_PART_SIZE;
        int x_parts = self.worldSize.width / part_size + 1;
        int y_parts = self.worldSize.height / part_size + 1;
        int stars_per_part = STARS_DENCITY;
        
        CGPoint star_position;
        
        for (int x = 0; x < x_parts; x++) {
            for (int y = 0; y < y_parts; y++) {
                for (int i = 0; i < stars_per_part; i++) {
                    star_position.x = x * part_size + arc4random_uniform(part_size);
                    star_position.y = y * part_size + arc4random_uniform(part_size);
                    VKGameObjectProperties *star = [VKGameObjectProperties propertiesWithPosition:[self worldCoordinatesFor:star_position]];
                    [self.stars appendObjectProperties:star];
                }
            }
        }
    }
}

- (void) clearWorld {
    [self.asteroids removeAllObjects];
    [self.missles removeAllObjects];
}

- (void) fire {
    if (!self.gameThread.isExecuting) {
        return;
    }
    
    VKMissleProperties *missle = [VKMissleProperties new];
    missle.position = self.ship.position;
    missle.direction = self.ship.rotation;
    missle.velocity = MISSLE_SPEED;
    missle.rotation = self.ship.rotation;
    missle.leftDistance = MISSLE_MAX_DISTANCE;
    [self.missles appendObjectProperties:missle];
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
    CGPoint position;
    
    //moving ship
    if (self.ship.accelerating) {
        [self.ship accelerateWithTimeInterval:time];
    }
    double offset_x = self.ship.x_velocity * time;
    double offset_y = self.ship.y_velocity * time;
    
    //moving asteroids
    NSArray *asteroids = [self.asteroids.objectsProperties copy];
    
    for (VKAsteroidProperties *asteroid in asteroids) {
        position.x = asteroid.position.x - asteroid.x_velocity * time + offset_x;
        position.y = asteroid.position.y - asteroid.y_velocity * time + offset_y;
        asteroid.position = [self worldCoordinatesFor:position];
        [asteroid rotateWithTimeInterval:time];
        asteroid.distance = distance(asteroid.position, self.ship.position);
    }
    
    //moving missles
    NSArray *missles = [self.missles.objectsProperties copy];
    
    for (VKMissleProperties *missle in missles) {
        if (missle.leftDistance > 0) {
            position.x = missle.position.x - missle.x_velocity * time + offset_x;
            position.y = missle.position.y - missle.y_velocity * time + offset_y;
            missle.position = [self worldCoordinatesFor:position];
            [missle decreaseLeftDistanceWithTimeInterval:time];
        }
        else{
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self.missles removeObjectProperties:missle];
            });
        }
    }
    
    //moving starts
    for (VKGameObjectProperties *star in self.stars.objectsProperties) {
        position.x = star.position.x + offset_x;
        position.y = star.position.y + offset_y;
        star.position = [self worldCoordinatesFor:position];
    }
    
    [self checkHit:missles Asteroids:asteroids];
    return ![self checkCollision:asteroids];
}

#pragma mark - collision detection

- (BOOL) checkCollision:(NSArray *)asteroids {
    float ship_radius = _ship.radius;
    for (VKAsteroidProperties *asteroid in asteroids){
        if (asteroid.distance < (asteroid.radius + ship_radius) * kShipCollisionRadiusMultiplier) {
            return YES;
        }
    }
    return NO;
}

- (void) checkHit:(NSArray *)missles Asteroids:(NSArray *)asteroids {
    double distance_value;
    float missle_radius = _missles.radius;
    for (VKAsteroidProperties *asteroid in asteroids) {
        if (asteroid.distance > MISSLE_MAX_DISTANCE) {
            continue;
        }
        
        for (VKMissleProperties *missle in missles) {
            distance_value = distance(asteroid.position, missle.position);
            if (distance_value < asteroid.radius + missle_radius) {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [self.asteroids removeObjectProperties:asteroid];
                    [self.missles removeObjectProperties:missle];
                    [self splitAsteroid:asteroid];
                    [self.delegate controller:self didDetectAsteroidHit:asteroid];
                });
                break;
            }
        }
    }
}

- (void) splitAsteroid:(VKAsteroidProperties *)asteroid {
    if (asteroid.parts < 2) {
        return;
    }
    
    int newAsteroidSize;
    int parts = asteroid.parts;
    
    newAsteroidSize = arc4random_uniform(parts - 1) + 1;
    [self makeAsteroidWithSize:newAsteroidSize Position:asteroid.position];
    parts -= newAsteroidSize;
    
    while (parts > 0) {
        newAsteroidSize = arc4random_uniform(parts) + 1;
        [self makeAsteroidWithSize:newAsteroidSize Position:asteroid.position];
        parts -= newAsteroidSize;
    }
}

- (CGPoint) worldCoordinatesFor:(CGPoint)point {
    CGSize worldSize = self.worldSize;
    if (point.x > worldSize.width / 2) {
        point.x -= worldSize.width;
    }
    else if (point.x < -worldSize.width / 2){
        point.x += worldSize.width;
    }
    
    if (point.y > worldSize.height / 2) {
        point.y -= worldSize.height;
    }
    else if (point.y < -worldSize.height / 2){
        point.y += worldSize.height;
    }
    return point;
}

@end
