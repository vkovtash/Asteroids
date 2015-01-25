//
//  VKPlayer+ZIMAsteroidsPlaylist.m
//  Asteroids
//
//  Created by kovtash on 11.12.14.
//
//

#import "VKPlayer+ZIMAsteroidsPlaylist.h"

@implementation VKPlayer (ZIMAsteroidsPlaylist)
+ (instancetype) playerWithAsteroidsPlaylist {
    VKPlayer *audioPlayer = [VKPlayer new];
    NSBundle *mainBundle = [NSBundle mainBundle];
    [audioPlayer appendAudioFile:[NSURL fileURLWithPath:[mainBundle pathForResource:@"All_of_Us" ofType:@"m4a"]]];
    [audioPlayer appendAudioFile:[NSURL fileURLWithPath:[mainBundle pathForResource:@"Come_and_Find_Me" ofType:@"m4a"]]];
    [audioPlayer appendAudioFile:[NSURL fileURLWithPath:[mainBundle pathForResource:@"Digital_Native" ofType:@"m4a"]]];
    [audioPlayer appendAudioFile:[NSURL fileURLWithPath:[mainBundle pathForResource:@"HHavok-intro" ofType:@"m4a"]]];
    [audioPlayer appendAudioFile:[NSURL fileURLWithPath:[mainBundle pathForResource:@"HHavok-main" ofType:@"m4a"]]];
    [audioPlayer appendAudioFile:[NSURL fileURLWithPath:[mainBundle pathForResource:@"Underclocked" ofType:@"m4a"]]];
    [audioPlayer appendAudioFile:[NSURL fileURLWithPath:[mainBundle pathForResource:@"We're_the_Resistors" ofType:@"m4a"]]];
    [audioPlayer appendAudioFile:[NSURL fileURLWithPath:[mainBundle pathForResource:@"Searching" ofType:@"m4a"]]];
    [audioPlayer shuffle];
    return audioPlayer;
}
@end
