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
    if (self.internalAudioFiles.count == 0) {
        NSLog(@"There is no audio files");
        return;
    }
    
    NSURL *fileToPlay = [self.internalAudioFiles objectAtIndex:self.currentIndex];
    NSError *error = nil;
    _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:fileToPlay
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
    _audioPlayer = nil;
}

- (void) next{
    BOOL shouldContinuePlayback = self.audioPlayer.isPlaying;
    [self stop];
    self.currentIndex = (self.currentIndex + 1) % self.internalAudioFiles.count;
    if (shouldContinuePlayback) {
        [self play];
    }
}

- (void) shuffle{    
    for (int i = 0; i < self.internalAudioFiles.count; i++) {
        [self.internalAudioFiles exchangeObjectAtIndex:i
                                     withObjectAtIndex:arc4random_uniform((int)self.internalAudioFiles.count)];
    }
}

- (void) appendAudioFile:(NSURL *) audioFile{
    [self.internalAudioFiles addObject:audioFile];
}

#pragma mark - AVAudioPlayerDelegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)successfully {
    [self next];
    if (!successfully) {
        [self play];
    }
}

@end

















