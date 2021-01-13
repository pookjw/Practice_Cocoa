//
//  StarFormatter.m
//  Project16
//
//  Created by Jinwoo Kim on 1/13/21.
//

#import "StarFormatter.h"

@implementation StarFormatter
- (NSString *)stringForObjectValue:(id)obj {
    if (obj) {
        NSInteger number = [[NSString stringWithFormat:@"%@", obj] integerValue];
        if (number) {
            NSString *result = @"";
            for (NSInteger i = 0; i < number; i++) {
                result = [NSString stringWithFormat:@"%@⭐️", result];
            }
            return result;
        }
    }
    return @"";
}
@end
