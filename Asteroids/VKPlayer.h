//
//  VKPlayer.h
//  Asteroids
//
//  Created by kovtash on 27.08.13.
//
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface VKPlayer : NSObject <AVAudioPlayerDelegate>
@property (nonatomic, readonly) NSArray *audioFiles;
@property (readonly, nonatomic) AVAudioPlayer *audioPlayer;

- (void) play;
- (void) pause;
- (void) stop;
- (void) next;
- (void) shuffle;
- (void) appendAudioFile:(NSURL *) audioFile;
@end
