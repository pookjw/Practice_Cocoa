//
//  Pin.m
//  Project5
//
//  Created by Jinwoo Kim on 12/24/20.
//

#import "Pin.h"

@implementation Pin
+ (Pin *)title:(NSString *)title coordinate:(CLLocationCoordinate2D)coordinate color:(NSColor *)color {
    Pin *new = [Pin new];
    new.title = title;
    new.coordinate = coordinate;
    new.color = color;
    return new;
}

+ (Pin *)title:(NSString *)title coordinate:(CLLocationCoordinate2D)coordinate {
    Pin *new = [Pin
                title:title
                coordinate:coordinate
                color:NSColor.greenColor];
    return new;
}
@end
