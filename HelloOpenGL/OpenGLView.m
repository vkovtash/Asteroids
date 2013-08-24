//
//  OpenGLView.m
//  HelloOpenGL
//
//  Created by Ray Wenderlich on 5/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "OpenGLView.h"
#import "VKShip.h"
#import "VKAsteroid.h"

@interface OpenGLView()
@property (strong, nonatomic) CC3GLMatrix *projection;
@property (strong, nonatomic) NSMutableArray *gameObjects;
@end

@implementation OpenGLView

#define TEX_COORD_MAX   4

- (NSMutableArray *) gameObjects{
    if (!_gameObjects) {
        _gameObjects = [NSMutableArray array];
    }
    return _gameObjects;
}

+ (Class)layerClass {
    return [CAEAGLLayer class];
}

- (void)setupLayer {
    _eaglLayer = (CAEAGLLayer*) self.layer;
    _eaglLayer.opaque = YES;
}

- (void)setupContext {   
    EAGLRenderingAPI api = kEAGLRenderingAPIOpenGLES2;
    _context = [[EAGLContext alloc] initWithAPI:api];
    if (!_context) {
        NSLog(@"Failed to initialize OpenGLES 2.0 context");
        exit(1);
    }
    
    if (![EAGLContext setCurrentContext:_context]) {
        NSLog(@"Failed to set current OpenGL context");
        exit(1);
    }
}

- (void)setupRenderBuffer {
    glGenRenderbuffers(1, &_colorRenderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderBuffer);        
    [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:_eaglLayer];    
}

- (void)setupDepthBuffer {
    glGenRenderbuffers(1, &_depthRenderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _depthRenderBuffer);
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, self.frame.size.width, self.frame.size.height);    
}

- (void)setupFrameBuffer {    
    GLuint framebuffer;
    glGenFramebuffers(1, &framebuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, framebuffer);   
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _colorRenderBuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, _depthRenderBuffer);
    
    glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
    glEnable(GL_BLEND);
    glEnable(GL_DEPTH_TEST); 
    glClearColor(0, 104.0/255.0, 55.0/255.0, 1.0);
}

- (void)render:(CADisplayLink*)displayLink {
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glViewport(0, 0, self.frame.size.width, self.frame.size.height);
    
    [self.gameObjects makeObjectsPerformSelector:@selector(render)];
    
    [_context presentRenderbuffer:GL_RENDERBUFFER];
}

- (void)setupDisplayLink {
    CADisplayLink* displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(render:)];
    [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];    
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {        
        [self setupLayer];        
        [self setupContext];    
        [self setupDepthBuffer];
        [self setupRenderBuffer];        
        [self setupFrameBuffer];
        [self setupDisplayLink];
        
        _projection = [CC3GLMatrix matrix];
        [_projection populateOrthoFromFrustumLeft:-self.frame.size.width/2
                                        andRight:self.frame.size.width/2
                                       andBottom:-self.frame.size.height/2
                                          andTop:self.frame.size.height/2
                                         andNear:0
                                          andFar:10];
        VKShip *ship = [[VKShip alloc] initWithViewSize:self.frame.size Projection:_projection];
        ship.position = CGPointMake(100, 100);
        ship.rotation = 90;
        ship.color = [UIColor yellowColor];
        [self.gameObjects addObject:ship];
        
        VKAsteroid *asteroid = [[VKAsteroid alloc] initWithViewSize:self.frame.size Projection:_projection];
        asteroid.position = CGPointMake(200, 200);
        [self.gameObjects addObject:asteroid];
    }
    return self;
}

- (void)dealloc
{
    _context = nil;
}

@end
