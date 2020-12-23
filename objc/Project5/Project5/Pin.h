//
//  Pin.h
//  Project5
//
//  Created by Jinwoo Kim on 12/24/20.
//

#import <Cocoa/Cocoa.h>
#import <MapKit/MapKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface Pin : NSObject <MKAnnotation>
@property(nonatomic, copy, nullable) NSString *title;
@property(nonatomic, copy, nullable) NSString *subtitle;
@property(nonatomic) CLLocationCoordinate2D coordinate;
@property NSColor *color;

+ (Pin *)title:(NSString *)title coordinate:(CLLocationCoordinate2D)coordinate color:(NSColor *)color;
+ (Pin *)title:(NSString *)title coordinate:(CLLocationCoordinate2D)coordinate;
@end

NS_ASSUME_NONNULL_END
