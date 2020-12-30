//
//  NSMutableArray+moveItem.h
//  Project7
//
//  Created by Jinwoo Kim on 12/30/20.
//

#import <Foundation/Foundation.h>

@interface NSMutableArray (Category)
- (void)moveItemFrom:(NSUInteger)fromIndex to:(NSUInteger)toIndex;
@end
