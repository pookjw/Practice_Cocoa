//
//  ViewController.h
//  Project10
//
//  Created by Jinwoo Kim on 1/4/21.
//

#import <Cocoa/Cocoa.h>
#import <MapKit/MapKit.h>

@interface ViewController : NSViewController
@property (weak) IBOutlet MKMapView *mapView;
@property (weak) IBOutlet NSTextField *apiKey;
@property (weak) IBOutlet NSPopUpButton *statusBarOption;
@property (weak) IBOutlet NSSegmentedControl *units;
@property (weak) IBOutlet NSButton *showPoweredBy;
@end

