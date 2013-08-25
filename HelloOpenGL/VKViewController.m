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
@end

@implementation VKViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.glView = [[VKGLView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.glView];
    [self prepareWorld];
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
