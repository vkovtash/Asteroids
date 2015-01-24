//
//  VKMisslesArray.m
//  Asteroids
//
//  Created by kovtash on 24.01.15.
//
//

#import "VKMisslesArray.h"

#define MISSLE_SIZE 5

@interface VKMissleProperties() {
    double _direction_radians;
}
@end

@implementation VKMissleProperties

- (void) setDirection:(float)direction {
    if (_direction != direction) {
        _direction = direction;
        _direction_radians = _direction * M_PI / 180;
        [self applyDirectionAndVelocity];
    }
}

- (void) setVelocity:(float)velocity {
    if (_velocity != velocity) {
        _velocity = velocity;
        [self applyDirectionAndVelocity];
    }
}

- (void) applyDirectionAndVelocity {
    _x_velocity = self.velocity * sin(_direction_radians);
    _y_velocity = self.velocity * cos(_direction_radians);
}

- (void) decreaseLeftDistanceWithTimeInterval:(NSTimeInterval)timeInterval {
    if (_leftDistance > 0) {
        _leftDistance -= _velocity * timeInterval;
    }
}

@end


@implementation VKMisslesArray

- (id) init {
    self = [self initWithRadius:MISSLE_SIZE];
    return self;
}

- (id) initWithRadius:(float)radius {
    self = [super init];
    if (self) {
        _radius = radius;
        Vertex vertices[4] = {
            {{-radius/2, -radius, 0}},
            {{0, radius, 0}},
            {{radius/2, -radius, 0}},
            {{0, -radius/2, 0}}
        };
        
        GLubyte indices[6] = {0, 1, 2, 2, 3, 0};
        
        [self setVertexBuffer:4 vertices:vertices];
        [self setIndexBuffer:6 indices:indices];
    }
    return self;
}

@end
