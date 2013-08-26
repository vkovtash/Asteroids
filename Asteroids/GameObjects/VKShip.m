//
//  VKShip.m
//  HelloOpenGL
//
//  Created by kovtash on 25.08.13.
//
//

#import "VKShip.h"
#define DEFAULT_SHIP_SIZE 10
#define DEFAULT_ACCELERATION_RATE 200
#define DEFAULT_MAX_SPEED 400

@interface VKShip(){
    double _rotation_radians;
}
@end

@implementation VKShip

- (void) setRotation:(CGFloat)rotation{
    if (self.rotation != rotation) {
        [super setRotation:rotation];
        _rotation_radians = self.rotation * M_PI / 180;
    }
}

- (id) init{
    self = [self initWithRadius:DEFAULT_SHIP_SIZE];
    return self;
}

- (id) initWithRadius:(float) radius{
    self = [super init];
    if (self) {
        _radius = radius;
        self.maxSpeed = DEFAULT_MAX_SPEED;
        self.accelerationRate = DEFAULT_ACCELERATION_RATE;
        
        Vertex vertices[4] = {
            {{-radius, -radius, 0}},
            {{0, radius, 0}},
            {{radius, -radius, 0}},
            {{0, -radius/2, 0}}
        };
        
        GLubyte indices[6] = {0, 1, 2, 2, 3, 0};
        
        [self setVertexBuffer:4 Vertices:vertices];
        [self setIndexBuffer:6 Indices:indices];
    }
    return self;
}

- (void) accelerateWithTimeInterval:(NSTimeInterval) timeInterval{
    _x_velocity += self.accelerationRate * timeInterval * sin(_rotation_radians);
    
    if (_x_velocity < -_maxSpeed){
        _x_velocity = -_maxSpeed;
    }
    else if (_x_velocity > _maxSpeed){
        _x_velocity = _maxSpeed;
    }

    _y_velocity += self.accelerationRate * timeInterval * cos(_rotation_radians);
    
    if (_y_velocity < -_maxSpeed) {
        _y_velocity = -_maxSpeed;
    }
    else if (_y_velocity > _maxSpeed){
        _y_velocity = _maxSpeed;
    }
}

@end
