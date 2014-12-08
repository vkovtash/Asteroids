//
//  VKViewController.m
//  Asteroids
//
//  Created by kovtash on 25.08.13.
//
//

#import "VKViewController.h"
#import "VKGLView.h"
#import "VKAsteroid.h"
#import "VKMissle.h"
#import "VKStar.h"
#import "VKPlayer.h"
#import "SIAlertView.h"
#import "ZIMSFXController.h"
#import "ZIMGameWorldController.h"

@interface VKViewController ()
@property (nonatomic,strong) VKPlayer *audioPlayer;
@property (strong, nonatomic) UIButton *fireButton;
@property (strong, nonatomic) UIButton *accelerationButton;
@property (strong, nonatomic) JSAnalogueStick *joyStik;
@property (nonatomic) int level;
@property (nonatomic) int points;
@property (strong, nonatomic) UILabel *pointsLabel;
@property (strong, nonatomic) UILabel *asteroidsCountLabel;
@property (strong, nonatomic) UILabel *levelLabel;
@property (strong, nonatomic) ZIMSFXController *sfxController;
@property (strong, nonatomic) ZIMGameWorldController *worldController;
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

- (void) setPoints:(int)points{
    _points = points;
    self.pointsLabel.text = [NSString stringWithFormat:@"SCORE: %d",points];
    //self.asteroidsCountLabel.text = [NSString stringWithFormat:@"ASTEROIDS: %luu", (unsigned long)self.asteroids.count];
}

- (void) setLevel:(int)level{
    _level = level;
    self.levelLabel.text = [NSString stringWithFormat:@"LEVEL %d",level];
}

#pragma mark - ViewController life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.sfxController = [ZIMSFXController new];
    
    //int views
    
    self.fireButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.fireButton.frame = CGRectMake(self.view.bounds.size.width-160,
                                       self.view.bounds.size.height-90,
                                       60,
                                       60);
    [self.fireButton setImage:[UIImage imageNamed:@"button"]
                     forState:UIControlStateNormal];
    [self.fireButton setImage:[UIImage imageNamed:@"button-pressed"] forState:UIControlStateSelected];
    [self.fireButton addTarget:self action:@selector(fire) forControlEvents:UIControlEventTouchDown];
    self.fireButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin;
    
    UILabel *fireLabel = [[UILabel alloc] initWithFrame:self.fireButton.bounds];
    fireLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    fireLabel.backgroundColor = [UIColor clearColor];
    fireLabel.textAlignment = NSTextAlignmentCenter;
    fireLabel.textColor = [UIColor darkGrayColor];
    fireLabel.shadowColor = [UIColor whiteColor];
    fireLabel.shadowOffset = CGSizeMake(0, 1);
    fireLabel.text = @"fire";
    [self.fireButton addSubview:fireLabel];
    
    self.accelerationButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.accelerationButton.frame = CGRectMake(self.view.bounds.size.width-80,
                                       self.view.bounds.size.height-120,
                                       60,
                                       60);
    [self.accelerationButton setImage:[UIImage imageNamed:@"button"]
                     forState:UIControlStateNormal];
    [self.accelerationButton setImage:[UIImage imageNamed:@"button-pressed"] forState:UIControlStateSelected];
    [self.accelerationButton addTarget:self action:@selector(startAcceleration) forControlEvents:UIControlEventTouchDown];
    [self.accelerationButton addTarget:self action:@selector(stopAcceleration) forControlEvents:UIControlEventTouchUpInside];
    self.accelerationButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin;
    
    UILabel *accelLabel = [[UILabel alloc] initWithFrame:self.fireButton.bounds];
    accelLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    accelLabel.backgroundColor = [UIColor clearColor];
    accelLabel.textAlignment = NSTextAlignmentCenter;
    accelLabel.textColor = [UIColor darkGrayColor];
    accelLabel.shadowColor = [UIColor whiteColor];
    accelLabel.shadowOffset = CGSizeMake(0, 1);
    accelLabel.text = @"accel";
    [self.accelerationButton addSubview:accelLabel];
    
    self.joyStik = [[JSAnalogueStick alloc] initWithFrame:CGRectMake(20,
                                                                     self.view.bounds.size.height-120,
                                                                     100,
                                                                     100)];
    self.joyStik.delegate = self;
    self.joyStik.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleRightMargin;
    
    self.pointsLabel = [[UILabel alloc] initWithFrame:CGRectMake(20,
                                                                 20,
                                                                 self.view.bounds.size.width-40,
                                                                 20)];
    self.pointsLabel.backgroundColor = [UIColor clearColor];
    self.pointsLabel.textColor = [UIColor yellowColor];
    self.pointsLabel.font = [UIFont fontWithName:@"STHeitiTC-Light" size:18];
    
    self.asteroidsCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.bounds.size.width-140,
                                                                         20,
                                                                         140,
                                                                         20)];
    self.asteroidsCountLabel.backgroundColor = [UIColor clearColor];
    self.asteroidsCountLabel.textColor = [UIColor yellowColor];
    self.asteroidsCountLabel.font = [UIFont fontWithName:@"STHeitiTC-Light" size:18];
    self.asteroidsCountLabel.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleLeftMargin;
    
    self.levelLabel = [[UILabel alloc] initWithFrame:CGRectMake(20,
                                                                20,
                                                                self.view.bounds.size.width - 40,
                                                                20)];
    self.levelLabel.backgroundColor = [UIColor clearColor];
    self.levelLabel.textColor = [UIColor yellowColor];
    self.levelLabel.font = [UIFont fontWithName:@"STHeitiTC-Medium" size:20];
    self.levelLabel.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleWidth;
    self.levelLabel.textAlignment = NSTextAlignmentCenter;
   
    
    self.worldController = [[ZIMGameWorldController alloc] initWithGlViewSize:self.view.bounds.size];
    
    [self.view addSubview:self.worldController.glView];
    [self.view addSubview:self.fireButton];
    [self.view addSubview:self.accelerationButton];
    [self.view addSubview:self.joyStik];
    [self.view addSubview:self.pointsLabel];
    [self.view addSubview:self.asteroidsCountLabel];
    [self.view addSubview:self.levelLabel];
    
    // init game state
    
    self.level = 1;
    self.points = 0;
}

- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self start];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) start{
    [self.worldController resume];
    [self.audioPlayer play];
}

- (void) stop{
    [self.audioPlayer stop];
    [self.audioPlayer next];
    [self.worldController pause];
}

- (void) pause {
    /*[self.audioPlayer pause];
    [self.gameLoop cancel];*/
}

- (void) resume {
    /*self.gameLoop = [[NSThread alloc] initWithTarget:self
                                            selector:@selector(loop:)
                                              object:self];
    self.gameLoop.threadPriority = 1.0;
    [self.audioPlayer play];
    [self.gameLoop start];*/
}

- (void) fire {
    [self.worldController fire];
}

- (void) levelDone{
    [self stop];
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"Level Done"
                                                     andMessage:[NSString stringWithFormat:@"Your score is %d", self.points]];
    [alertView addButtonWithTitle:@"Next level"
                             type:SIAlertViewDidDismissNotification
                          handler:^(SIAlertView *alertView){
                              self.level += 1;
                              [self start];
                          }];
    [alertView show];
}

- (void) gameOver{
    [self.sfxController death];
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"Game Over"
                                                     andMessage:[NSString stringWithFormat:@"Your score is %d", self.points]];
    [alertView addButtonWithTitle:@"Try again"
                             type:SIAlertViewDidDismissNotification
                          handler:^(SIAlertView *alertView){
                              self.points = 0;
                              self.level = 1;
                              [self start];
                          }];
    [alertView show];
    [self stop];
}

- (void) startAcceleration{
    self.worldController.ship.accelerating = YES;
}

- (void) stopAcceleration{
    self.worldController.ship.accelerating = NO;
}

#pragma mark - JSAnalogueStickDelegate

- (void)analogueStickDidChangeValue:(JSAnalogueStick *)analogueStick{
    //Setting ship direcrion and velocity
    //if (!self.gameLoop.isFinished) {
        double acceleration = sqrt(pow(self.joyStik.xValue, 2)
                                  + pow(self.joyStik.yValue, 2));
        
        if (acceleration != 0) {
            double rotation = acosf(self.joyStik.yValue/acceleration) * 180/M_PI;
            if (self.joyStik.xValue > 0) {
                rotation = 360 - rotation;
            }
            self.worldController.ship.rotation = rotation;
        }
    //}
}

@end
