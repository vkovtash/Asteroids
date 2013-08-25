//
//  VKViewController.m
//  HelloOpenGL
//
//  Created by kovtash on 25.08.13.
//
//

#import "VKViewController.h"
#import "VKGLView.h"
#import "VKShip.h"
#import "VKAsteroid.h"

@interface VKViewController ()
@property (strong ,nonatomic) VKGLView *glView;
@property (strong, nonatomic) NSThread *gameLoop;
@end

@implementation VKViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.glView = [[VKGLView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.glView];
    [self prepareWorld];
    [self start];
}

- (void) prepareWorld{
    VKShip *ship = [[VKShip alloc] init];
    ship.position = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2);
    ship.color = [UIColor yellowColor];
    
    [self.glView addGLObject:ship];
    
    VKAsteroid *asteroid = [[VKAsteroid alloc] init];
    asteroid.position = CGPointMake(200, 200);
    [self.glView addGLObject:asteroid];
}

- (void) start{
    self.gameLoop = [[NSThread alloc] initWithTarget:self
                                            selector:@selector(loop:)
                                              object:self];
    [self.gameLoop start];
}

- (void) stop{
    [self.gameLoop cancel];
}

- (void) loop:(VKViewController *) gameController{
    NSThread *thread = [NSThread currentThread];
    while (thread.isExecuting) {
        [gameController processGameStep];
    }
}

- (void) processGameStep{
    NSLog(@"test");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
