//
//  VKAsteroid.m
//  Asteroids
//
//  Created by kovtash on 25.08.13.
//
//

#import "VKAsteroid.h"
#define ASTEROID_SIZE 20
#define ASTEROID_MIN_SIDES 6
#define ASTEROID_MAX_SIDES 12
#define ASTEROID_SIDE_STEP 3

@interface VKAsteroid(){
    Vertex *vertices;
    GLubyte *indices;
    double _direction_radians;
}
@end

@implementation VKAsteroid

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

- (id) init{
    self = [self initWithRadius:ASTEROID_SIZE];
    return self;
}

- (id) initWithRadius:(float) radius{
    self = [super init];
    if (self) {
        _radius = radius;
        int additionalSides = radius/ASTEROID_SIDE_STEP;
        if (additionalSides > ASTEROID_MAX_SIDES){
            additionalSides = ASTEROID_MAX_SIDES;
        }
        int sides = ASTEROID_MIN_SIDES + arc4random_uniform(additionalSides);
        float step = 2 * M_PI / sides;
        
        vertices = malloc(sizeof(Vertex)*sides);
        indices = malloc(sizeof(GLubyte)*sides + 1);
            
        for(int i = 0; i < sides; i++)
        {
            vertices[i] = (Vertex){
                cos(i * step) * radius * ((float)arc4random_uniform(10)/20 + 0.5),
                sin(i * step) * radius * ((float)arc4random_uniform(10)/20 + 0.5), 0};
            indices[i] = i;
        }
        indices[sides] = 0;
        
        [self setVertexBuffer:sides Vertices:vertices];
        [self setIndexBuffer:sides + 1 Indices:indices];
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
    free(vertices);
    free(indices);
}
@end
