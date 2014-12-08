//
//  ZIMRingEnumertor.h
//  Asteroids
//
//  Created by kovtash on 08.12.14.
//
//

#import <Foundation/Foundation.h>

@interface ZIMRingEnumertor : NSEnumerator
@property (readonly, nonatomic) NSArray *array;

- (instancetype) initWithArray:(NSArray *)array;
@end


@interface NSArray(ZIMRingEnumertor)
- (ZIMRingEnumertor *) zim_ringEnumerator;
@end