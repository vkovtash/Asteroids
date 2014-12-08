//
//  ZIMRingEnumertor.m
//  Asteroids
//
//  Created by kovtash on 08.12.14.
//
//

#import "ZIMRingEnumertor.h"
#import <libkern/OSAtomic.h>

@interface ZIMRingEnumertor()
@property (readonly, nonatomic) int64_t currentIndex;
@end

@implementation ZIMRingEnumertor

- (instancetype) initWithArray:(NSArray *)array {
    self = [super init];
    if (self) {
        _array = array;
    }
    return self;
}

- (id) nextObject {
    int64_t nextIndex = OSAtomicIncrement64(&_currentIndex);
    return _array[nextIndex % _array.count];
}

- (NSArray *) allObjects {
    return [_array copy];
}

@end

@implementation NSArray(ZIMRingEnumertor)

- (ZIMRingEnumertor *) zim_ringEnumerator {
    return [[ZIMRingEnumertor alloc] initWithArray:self];
}

@end
