//
//  NSMutableArray+Shuffling.m
//  Project8
//
//  Created by Jinwoo Kim on 1/3/21.
//

#import "NSMutableArray+Shuffling.h"

// https://stackoverflow.com/a/56656

@implementation NSMutableArray (Shuffling)
- (void)shuffle {
    if (self.count <= 1) return;
    for (NSUInteger i = 0; i < self.count - 1; ++i) {
        NSInteger remainingCount = self.count - i;
        NSInteger exchangeIndex = i + arc4random_uniform((u_int32_t)remainingCount);
        [self exchangeObjectAtIndex:i withObjectAtIndex:exchangeIndex];
    }
}
@end
