//
//  Ball.m
//  Project17
//
//  Created by Jinwoo Kim on 1/15/21.
//

#import "Ball.h"

@implementation Ball

- (instancetype)init {
    self = [super init];
    if (self) {
        self.row = -1;
        self.col = -1;
    }
    return self;
}

@end
