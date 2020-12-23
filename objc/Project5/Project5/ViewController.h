//
//  ViewController.h
//  Project5
//
//  Created by Jinwoo Kim on 12/24/20.
//

#import <Cocoa/Cocoa.h>
#import <MapKit/MapKit.h>
#import "Pin.h"

@interface ViewController : NSViewController <MKMapViewDelegate>
@property (weak) IBOutlet NSTextField *questionLabel;
@property (weak) IBOutlet NSTextField *scoreLabel;
@property (weak) IBOutlet MKMapView *mapView;

@property NSMutableArray<Pin *> *cities;
@property Pin *currentCity;
@property (nonatomic) NSUInteger score;
@end

