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


#pragma mark - Private properties

- (VKPlayer *) audioPlayer{
    if (_audioPlayer == nil) {
        _audioPlayer = [[VKPlayer alloc] init];
        NSBundle *mainBundle = [NSBundle mainBundle];
        [_audioPlayer appendAudioFile:[NSURL fileURLWithPath:[mainBundle pathForResource:@"All_of_Us" ofType:@"m4a"]]];
        [_audioPlayer appendAudioFile:[NSURL fileURLWithPath:[mainBundle pathForResource:@"Come_and_Find_Me" ofType:@"m4a"]]];
        [_audioPlayer appendAudioFile:[NSURL fileURLWithPath:[mainBundle pathForResource:@"Digital_Native" ofType:@"m4a"]]];
        [_audioPlayer appendAudioFile:[NSURL fileURLWithPath:[mainBundle pathForResource:@"HHavok-intro" ofType:@"m4a"]]];
        [_audioPlayer appendAudioFile:[NSURL fileURLWithPath:[mainBundle pathForResource:@"HHavok-main" ofType:@"m4a"]]];
        [_audioPlayer appendAudioFile:[NSURL fileURLWithPath:[mainBundle pathForResource:@"Underclocked" ofType:@"m4a"]]];
        [_audioPlayer appendAudioFile:[NSURL fileURLWithPath:[mainBundle pathForResource:@"We're_the_Resistors" ofType:@"m4a"]]];
        [_audioPlayer appendAudioFile:[NSURL fileURLWithPath:[mainBundle pathForResource:@"Searching" ofType:@"m4a"]]];
        [_audioPlayer shuffle];
    }
    return _audioPlayer;
}

- (void) setPoints:(int)points {
    _points = points;
    self.pointsLabel.text = [NSString stringWithFormat:@"%d", points];
}

#pragma mark - ViewController life cycle

- (void) viewDidLoad {
    [super viewDidLoad];
    
    self.sfxController = [ZIMSFXController new];
    
    //int views
    
    CGRect bounds = self.view.bounds;
    
    self.fireButton = [UIButton zim_fireButton];
    self.fireButton.center = CGPointMake(bounds.size.width - 130, bounds.size.height - 60);
    [self.fireButton addTarget:self action:@selector(fire) forControlEvents:UIControlEventTouchDown];
    
    self.accelerationButton = [UIButton zim_accelerationButton];
    self.accelerationButton.center = CGPointMake(bounds.size.width - 50, bounds.size.height - 90);
    [self.accelerationButton addTarget:self action:@selector(startAcceleration) forControlEvents:UIControlEventTouchDown];
    [self.accelerationButton addTarget:self action:@selector(stopAcceleration) forControlEvents:UIControlEventTouchUpInside];
    
    self.playButton = [UIButton zim_playButton];
    [self.playButton addTarget:self action:@selector(resume) forControlEvents:UIControlEventTouchUpInside];
    
    self.pauseButton = [UIButton zim_pauseButton];
    [self.pauseButton addTarget:self action:@selector(pause) forControlEvents:UIControlEventTouchUpInside];
    
    self.joyStik = [[JSAnalogueStick alloc] initWithFrame:CGRectMake(20,
                                                                     self.view.bounds.size.height - 120,
                                                                     100,
                                                                     100)];
    self.joyStik.delegate = self;
    self.joyStik.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleRightMargin;
    
    self.controlContainerView.layer.cornerRadius = self.controlContainerView.bounds.size.height / 2;
    self.controlContainerView.layer.borderWidth = 1;
    self.controlContainerView.layer.borderColor = [UIColor yellowColor].CGColor;
    
    CGSize window = [[UIApplication sharedApplication].delegate window].bounds.size;
    window.width *= 1.5;
    window.height *= 1.5;
   
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
}

- (void) fire {
    [self.sfxController blast];
    [self.worldController fire];
}

- (void) startAcceleration{
    self.worldController.ship.accelerating = YES;
}

- (void) stopAcceleration{
    self.worldController.ship.accelerating = NO;
}

- (void) refreshAsteroidsLabel {
    self.asteroidsCountLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)self.worldController.currentAsteroidsCount];
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
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.worldController spawnAsteroid];
            [self refreshAsteroidsLabel];
        });
    }
    
    self.points = newPoints;
    [self refreshAsteroidsLabel];
}

#pragma mark - JSAnalogueStickDelegate

- (void) analogueStickDidChangeValue:(JSAnalogueStick *)analogueStick {
    //Setting ship direcrion and velocity
    if (self.worldController.isExecuting) {
        double acceleration = sqrt(pow(analogueStick.xValue, 2)
                                  + pow(analogueStick.yValue, 2));
        
        if (acceleration != 0) {
            double rotation = acosf(analogueStick.yValue/acceleration) * 180 / M_PI;
            if (analogueStick.xValue > 0) {
                rotation = 360 - rotation;
            }
            self.worldController.ship.rotation = rotation;
        }
    }
}

@end
