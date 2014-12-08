//
//  ZIMSFXController.h
//  Asteroids
//
//  Created by kovtash on 08.12.14.
//
//

#import <Foundation/Foundation.h>

@interface ZIMSFXController : NSObject
@property (assign, nonatomic) float volume;

- (void) blast;
- (void) explosion;
- (void) death;
@end
