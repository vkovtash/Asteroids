//
//  VKAsteroidProperties.m
//  Asteroids
//
//  Created by kovtash on 24.01.15.
//
//

#import "VKAsteroid.h"
#define ASTEROID_SIZE 20
#define ASTEROID_MIN_SIDES 6
#define ASTEROID_MAX_SIDES 12
#define ASTEROID_SIDE_STEP 3

@implementation VKAsteroid {
    double _direction_radians;
}

@synthesize verticies = _verticies;
@synthesize indices = _indices;
@synthesize verticiesCount = _verticiesCount;
@synthesize indicesCount = _indicesCount;

- (void) setDirection:(float)direction{
    if (_direction != direction) {
        _direction = direction;
        _direction_radians = _direction * M_PI / 180;
        [self applyDirectionAndVelocity];
    }
}

- (void) setVelocity:(float)velocity{
    if (_velocity != velocity) {
        _velocity = velocity;
        [self applyDirectionAndVelocity];
    }
}

- (id) init {
    self = [self initWithRadius:ASTEROID_SIZE position:CGPointMake(0, 0)];
    return self;
}

- (id) initWithRadius:(float)radius position:(CGPoint)position {
    self = [super initWithPosition:position rotation:0];
    if (self) {
        _radius = radius;
        int additionalSides = radius/ASTEROID_SIDE_STEP;
        if (additionalSides > ASTEROID_MAX_SIDES){
            additionalSides = ASTEROID_MAX_SIDES;
        }
        
        int sides = ASTEROID_MIN_SIDES + arc4random_uniform(additionalSides);
        _verticiesCount = sides;
        _indicesCount = _verticiesCount + 1;
        
        float step = 2 * M_PI / sides;
        
        _verticies = malloc(sizeof(Vertex) * _verticiesCount);
        _indices = malloc(sizeof(GLubyte) * _indicesCount);
        
        for(int i = 0; i < _verticiesCount; i++)
        {
            _verticies[i] = (Vertex){
                cos(i * step) * radius * ((float)arc4random_uniform(10)/20 + 0.5),
                sin(i * step) * radius * ((float)arc4random_uniform(10)/20 + 0.5), 0};
            _indices[i] = i;
        }
        _indices[_indicesCount - 1] = 0;
    }
    return self;
}

- (void) applyDirectionAndVelocity{
    _x_velocity = self.velocity * sin(_direction_radians);
    _y_velocity = self.velocity * cos(_direction_radians);
}

- (void) rotateWithTimeInterval:(NSTimeInterval) timeInterval{
    self.rotation += self.rotationVelocity * timeInterval;
}

- (void) dealloc{
    free(_verticies);
    free(_indices);
}
@end
