//
//  ZIMSFXController.m
//  Asteroids
//
//  Created by kovtash on 08.12.14.
//
//

#import "ZIMSFXController.h"
#import "ZIMRingEnumertor.h"
@import AVFoundation;

static NSUInteger const kBlastEffecsBufferSize = 5;
static NSUInteger const kExplosionEffecsBufferSize = 3;

@interface ZIMSFXController()
@property (strong, nonatomic) ZIMRingEnumertor *explosionEffects;
@property (strong, nonatomic) ZIMRingEnumertor *blastEffects;
@property (strong, nonatomic) AVAudioPlayer *deathEffect;
@property (nonatomic) dispatch_queue_t sfxQueue;
@end

@implementation ZIMSFXController

- (instancetype) init {
    self = [super init];
    
    if (!self) {
        return nil;
    }
    
    _sfxQueue = dispatch_queue_create("zim.sfx.play_queue", DISPATCH_QUEUE_CONCURRENT);
    
    NSData *blastFileData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"blast" ofType:@"m4a"]];
    NSMutableArray *blastEffects = [NSMutableArray array];
    for (int i = 0; i < kBlastEffecsBufferSize; i++) {
        AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithData:blastFileData error:nil];
        [player prepareToPlay];
        [blastEffects addObject:player];
    }
    
    _blastEffects = [blastEffects zim_ringEnumerator];
    
    NSData *explosionFileData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"explosion" ofType:@"m4a"]];
    NSMutableArray *explosionEffects = [NSMutableArray array];
    for (int i = 0; i < kExplosionEffecsBufferSize; i++) {
        AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithData:explosionFileData error:nil];
        [player prepareToPlay];
        [explosionEffects addObject:player];
    }
    
    _explosionEffects = [explosionEffects zim_ringEnumerator];
    
    _deathEffect = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL URLWithString:[[NSBundle mainBundle] pathForResource:@"death" ofType:@"m4a"]]
                                                          error:nil];
    [_deathEffect prepareToPlay];
    
    [self setVolume:1.0];
    
    return self;
}

- (void) blast {
    __weak __typeof(&*self) weakSelf = self;
    dispatch_async(self.sfxQueue, ^{
        [(AVAudioPlayer *)[weakSelf.blastEffects nextObject] play];
    });
}

- (void) explosion {
    __weak __typeof(&*self) weakSelf = self;
    dispatch_async(self.sfxQueue, ^{
        [(AVAudioPlayer *)[weakSelf.explosionEffects nextObject] play];
    });
}

- (void) death {
    __weak __typeof(&*self) weakSelf = self;
    dispatch_async(self.sfxQueue, ^{
        [weakSelf.deathEffect play];
    });
}

- (void) setVolume:(float)volume {
    self.deathEffect.volume = volume;
    
    for (AVAudioPlayer *player in self.blastEffects.allObjects) {
        player.volume = volume;
    }
    
    for (AVAudioPlayer *player in self.explosionEffects.allObjects) {
        player.volume = volume;
    }
}

@end
