//
//  VKPlayer.m
//  Asteroids
//
//  Created by kovtash on 27.08.13.
//
//

#import "VKPlayer.h"

@interface VKPlayer()
@property (strong, nonatomic) NSMutableArray *internalAudioFiles;
@property (nonatomic,strong) AVAudioPlayer *audioPlayer;
@property (nonatomic) NSUInteger currentIndex;
@end

@implementation VKPlayer

- (NSMutableArray *) internalAudioFiles{
    if (!_internalAudioFiles) {
        _internalAudioFiles = [NSMutableArray array];
    }
    return _internalAudioFiles;
}

- (NSArray *) audioFiles{
    return [self.internalAudioFiles copy];
}

- (void) prepareToPlay{
    if(self.internalAudioFiles.count){
        if (self.currentIndex >= self.internalAudioFiles.count) {
            self.currentIndex = 0;
        }
        NSURL *fileToPlay = [self.internalAudioFiles objectAtIndex:self.currentIndex];
        
        NSError *error = nil;
        
        self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:fileToPlay
                                                              error:&error];
        
        if (error != nil){
            NSLog(@"Error loading audio %@", error.description);
        }
        
        if (self.audioPlayer != nil) {
            self.audioPlayer.delegate = self;
            [self.audioPlayer prepareToPlay];
            [self.audioPlayer setVolume:1.0];
        }
    }
    else{
        NSLog(@"There is no audio files");
    }
}

- (void) play{
    if (!self.audioPlayer) {
        [self prepareToPlay];
    }
    [self.audioPlayer play];
}

- (void) pause{
    [self.audioPlayer pause];
}

- (void) stop{
    [self.audioPlayer stop];
    self.audioPlayer = nil;
}

- (void) next{
    [self.audioPlayer stop];
    self.currentIndex++;
    [self.audioPlayer play];
}

- (void) shuffle{
    for (int i = 0; i < self.internalAudioFiles.count; ++i) {
        [self.internalAudioFiles exchangeObjectAtIndex:i
                                     withObjectAtIndex:arc4random_uniform(self.internalAudioFiles.count)];
    }
}

- (void) appendAudioFile:(NSURL *) audioFile{
    [self.internalAudioFiles addObject:audioFile];
}

#pragma mark - AVAudioPlayerDelegate

- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player withOptions:(NSUInteger)flags{
    [self next];
}

@end

















