//
//  VKViewController.m
//  Asteroids
//
//  Created by kovtash on 25.08.13.
//
//

#import "VKViewController.h"
#import "VKPlayer.h"
#import "ZIMSFXController.h"
#import "ZIMGameWorldController.h"
#import "JSAnalogueStick.h"
#import <QuartzCore/QuartzCore.h>
#import "UIButton+ZIMAsteroidsButtons.h"
#import "ZIMAnimationContainerView.h"
#import "VKPlayer+ZIMAsteroidsPlaylist.h"
#import "JSAnalogueStick+ZIMStick.h"


static CGFloat kScoreMultiplier = 5;
static int kSpawnStep = 1000;

@interface VKViewController () <ZIMGameWorldControllerDelegate, JSAnalogueStickDelegate>
@property (assign, nonatomic) int points;
@property (strong, nonatomic) VKPlayer *audioPlayer;
@property (strong, nonatomic) ZIMSFXController *sfxController;
@property (strong, nonatomic) ZIMGameWorldController *worldController;
@property (strong, nonatomic) UIButton *fireButton;
@property (strong, nonatomic) UIButton *accelerationButton;
@property (strong, nonatomic) UIButton *playButton;
@property (strong, nonatomic) UIButton *pauseButton;
@property (strong, nonatomic) JSAnalogueStick *joyStik;
@property (strong, nonatomic) IBOutlet UILabel *pointsLabel;
@property (strong, nonatomic) IBOutlet UILabel *asteroidsCountLabel;
@property (strong, nonatomic) IBOutlet ZIMAnimationContainerView *controlContainerView;
@end

@implementation VKViewController

#pragma mark - ViewController life cycle

- (void) viewDidLoad {
    [super viewDidLoad];
    
    self.audioPlayer = [VKPlayer playerWithAsteroidsPlaylist];
    self.sfxController = [ZIMSFXController new];
    
    //int views
    
    CGRect bounds = self.view.bounds;
    
    CGFloat visibleWorldHeight;
    CGPoint fireButtonCenter, accelButtonCenter, joyStikCenter;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        visibleWorldHeight = 500;
        fireButtonCenter = CGPointMake(bounds.size.width - 135, bounds.size.height - 60);
        accelButtonCenter = CGPointMake(bounds.size.width - 45, bounds.size.height - 90);
        joyStikCenter = CGPointMake(70, bounds.size.height - 70);
    }
    else {
        visibleWorldHeight = 600;
        fireButtonCenter = CGPointMake(bounds.size.width - 135, bounds.size.height - 100);
        accelButtonCenter = CGPointMake(bounds.size.width - 45, bounds.size.height - 130);
        joyStikCenter = CGPointMake(90, bounds.size.height - 110);
    }
    
    self.fireButton = [UIButton zim_fireButton];
    self.fireButton.center = fireButtonCenter;
    self.fireButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin;
    [self.fireButton addTarget:self action:@selector(fire) forControlEvents:UIControlEventTouchDown];
    [self.fireButton addTarget:self action:@selector(fireCancel) forControlEvents:UIControlEventTouchUpInside|UIControlEventTouchUpOutside];
    
    self.accelerationButton = [UIButton zim_accelerationButton];
    self.accelerationButton.center = accelButtonCenter;
    self.accelerationButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin;
    [self.accelerationButton addTarget:self action:@selector(startAcceleration) forControlEvents:UIControlEventTouchDown];
    [self.accelerationButton addTarget:self action:@selector(stopAcceleration) forControlEvents:UIControlEventTouchUpInside];
    
    self.playButton = [UIButton zim_playButton];
    [self.playButton addTarget:self action:@selector(resume) forControlEvents:UIControlEventTouchUpInside];
    
    self.pauseButton = [UIButton zim_pauseButton];
    [self.pauseButton addTarget:self action:@selector(pause) forControlEvents:UIControlEventTouchUpInside];
    
    self.joyStik = [JSAnalogueStick zim_stick];
    self.joyStik.center = joyStikCenter;
    self.joyStik.delegate = self;
    self.joyStik.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleRightMargin;
    
    self.controlContainerView.layer.cornerRadius = self.controlContainerView.bounds.size.height / 2;
    self.controlContainerView.layer.borderWidth = 1;
    self.controlContainerView.layer.borderColor = [UIColor yellowColor].CGColor;
    
    CGSize window = [[UIApplication sharedApplication].delegate window].bounds.size;
    window.width *= visibleWorldHeight / window.height;
    window.height = visibleWorldHeight;
   
    self.worldController = [[ZIMGameWorldController alloc] initWithGlViewSize:window];
    self.worldController.glView.frame = [[UIApplication sharedApplication].delegate window].bounds;
    self.worldController.delegate = self;
    
    [self.view addSubview:self.worldController.glView];
    [self.view addSubview:self.fireButton];
    [self.view addSubview:self.accelerationButton];
    [self.view addSubview:self.joyStik];
    [self.controlContainerView setCurrentView:self.playButton];
    
    // init game state
    self.points = 0;
    
    [self.view sendSubviewToBack:self.worldController.glView];
    [self.worldController reset];
    [self.audioPlayer stop];

    [self refreshAsteroidsLabel];
}

- (BOOL) prefersStatusBarHidden {
    return YES;
}

- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - private API

- (void) setPoints:(int)points {
    _points = points;
    self.pointsLabel.text = [NSString stringWithFormat:@"%d", points];
}

- (void) stop {
    [self.audioPlayer stop];
    [self.worldController pause];
}

- (void) pause {
    [self.worldController pause];
}

- (void) resume {
    if (self.worldController.isFinished) {
        [self.worldController reset];
        [self.audioPlayer next];
        
        self.points = 0;
        [self refreshAsteroidsLabel];
    }
    [self.worldController resume];
    self.worldController.firePressed = self.fireButton.isTouchInside;
    self.worldController.ship.accelerating = self.accelerationButton.isTouchInside;
}

- (void) fire {
    self.worldController.firePressed = YES;
}

- (void) fireCancel {
    self.worldController.firePressed = NO;
}

- (void) startAcceleration{
    self.worldController.ship.accelerating = YES;
}

- (void) stopAcceleration{
    self.worldController.ship.accelerating = NO;
}

- (void) refreshAsteroidsLabel {
    self.asteroidsCountLabel.text = [NSString stringWithFormat:@" %lu", (unsigned long)self.worldController.currentAsteroidsCount];
}

#pragma mark - ZIMGameWorldControllerDelegate

- (void) controllerDidResumeGame:(ZIMGameWorldController *)controller {
    [self.audioPlayer play];
    [self.controlContainerView replaceCurrentViewWithView:self.pauseButton];
}

- (void) controllerDidPauseGame:(ZIMGameWorldController *)controller {
    [self.audioPlayer pause];
    [self.controlContainerView replaceCurrentViewWithView:self.playButton];
}

- (void) controllerDidFinishGame:(ZIMGameWorldController *)controller {
    [self.audioPlayer stop];
    [self.sfxController explosion];
    [self.controlContainerView replaceCurrentViewWithView:self.playButton];
}

- (void) controller:(ZIMGameWorldController *)controller didDetectAsteroidHit:(VKAsteroid *)asteroid {
    [self.sfxController explosion];
    
    int newPoints = self.points + kScoreMultiplier * (controller.asteroidMaxSize - asteroid.parts + 1);
    
    if (self.points / kSpawnStep != newPoints / kSpawnStep ||
        self.worldController.currentAsteroidsCount < self.worldController.initialAsteroidsCount) {

        __weak __typeof(&*self) weakSelf = self;
        __weak ZIMGameWorldController *weakController = self.worldController;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakController spawnAsteroid];
            [weakSelf refreshAsteroidsLabel];
        });
    }
    
    self.points = newPoints;
    [self refreshAsteroidsLabel];
}

- (void) controller:(ZIMGameWorldController *)controller didLaunchMissle:(VKMissle *)missle {
    [self.sfxController blast];
}

#pragma mark - JSAnalogueStickDelegate

- (void) analogueStickDidChangeValue:(JSAnalogueStick *)analogueStick {
    if (self.worldController.isExecuting) {
        self.worldController.ship.rotation = 360 - analogueStick.angle;
    }
}

@end
