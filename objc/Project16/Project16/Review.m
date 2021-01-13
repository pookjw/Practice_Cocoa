//
//  Review.m
//  Project16
//
//  Created by Jinwoo Kim on 1/13/21.
//

#import "Review.h"

@implementation Review
- (instancetype)init {
    self = [super init];
    if (self) {
        self.title = @"Enter the title";
        self.author = @"Enter the author";
        self.rating = 0;
        self.text = [NSAttributedString new];
    }
    return self;
}
@end
