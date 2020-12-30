//
//  NSMutableArray+moveItem.m
//  Project7
//
//  Created by Jinwoo Kim on 12/30/20.
//

#import "NSMutableArray+moveItem.h"

@implementation NSMutableArray (Category)
- (void)moveItemFrom:(NSUInteger)fromIndex to:(NSUInteger)toIndex {
    id item = self[fromIndex];
    [self removeObjectAtIndex:fromIndex];
    
    if (toIndex <= fromIndex) {
        [self insertObject:item atIndex:toIndex];
    } else {
        [self insertObject:item atIndex:toIndex - 1];
    }
}
@end
