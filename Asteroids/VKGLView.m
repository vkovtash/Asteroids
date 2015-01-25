//
//  VKGLView.m
//  Asteroids
//
//  Created by kovtash on 25.08.13.
//
//

#import "VKGLView.h"
#import "VKShip.h"

@interface VKGLView()
@property (strong, nonatomic) NSMutableArray *gameObjects;
@property (strong, nonatomic) CADisplayLink *displayLink;
@end

@implementation VKGLView{
    CAEAGLLayer* _eaglLayer;
    EAGLContext* _context;
    GLuint _colorRenderBuffer;
    GLuint _depthRenderBuffer;
}

@synthesize glViewSize = _glViewSize;

#define TEX_COORD_MAX   4

- (NSMutableArray *) gameObjects {
    if (!_gameObjects) {
        _gameObjects = [NSMutableArray array];
    }
    return _gameObjects;
}

+ (Class) layerClass {
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
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, _glViewSize.width, _glViewSize.height);
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
    glClearColor(0, 0, 0, 1.0);
}

- (void)render:(CADisplayLink*)displayLink {
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glViewport(0, 0, _glViewSize.width, _glViewSize.height);
    
    [self.gameObjects makeObjectsPerformSelector:@selector(render)];
    [_context presentRenderbuffer:GL_RENDERBUFFER];
}

-(void) addGLObject:(id <VKGLObject>)glObject {
    [glObject setGlView:self];
    [self.gameObjects addObject:glObject];
}

-(void) removeGLObject:(id <VKGLObject>)glObject {
    [self.gameObjects removeObjectIdenticalTo:glObject];
    [glObject setGlView:nil];
}

- (void) willResignActive {
    [self.displayLink invalidate];
    self.displayLink = nil;
}

- (void) setupDisplayLink {
    if (!self.displayLink) {
        self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(render:)];
        [self.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    }
}

- (instancetype) initWithGlViewSize:(CGSize)size {
    self = [super initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    if (self) {
        _glViewSize = size;
        
        [self setupLayer];
        [self setupContext];
        [self setupDepthBuffer];
        [self setupRenderBuffer];
        [self setupFrameBuffer];
        [self setupDisplayLink];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(willResignActive)
                                                     name:UIApplicationWillResignActiveNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(setupDisplayLink)
                                                     name:UIApplicationWillEnterForegroundNotification
                                                   object:nil];
        
        _projection = [CC3GLMatrix matrix];
        [_projection populateOrthoFromFrustumLeft:-_glViewSize.width / 2
                                         andRight:_glViewSize.width / 2
                                        andBottom:-_glViewSize.height / 2
                                           andTop:_glViewSize.height / 2
                                          andNear:0
                                           andFar:10];
    }
    return self;
}

- (void)dealloc {
    _context = nil;
}

@end
