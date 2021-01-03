//
//  ViewController.m
//  Project10
//
//  Created by Jinwoo Kim on 1/4/21.
//

#import "ViewController.h"

@implementation ViewController

- (void)viewWillAppear {
    [super viewWillAppear];
    
    NSUserDefaults *defaults = NSUserDefaults.standardUserDefaults;
    double savedLatitude = [defaults doubleForKey:@"latitude"];
    double savedLongitude = [defaults doubleForKey:@"longitude"];
    NSString *savedAPIKey = [defaults stringForKey:@"apiKey"];
    NSInteger savedStatusBar = [defaults integerForKey:@"statusBarOption"];
    NSInteger savedUnits = [defaults integerForKey:@"units"];
    
    self.apiKey.stringValue = savedAPIKey;
    self.units.selectedSegment = savedUnits;
    
    // 2
    for (NSMenuItem *menuItem in self.statusBarOption.menu.itemArray) {
        if (menuItem.tag == savedStatusBar) {
            [self.statusBarOption selectItem:menuItem];
        }
    }
    
    // 3
    CLLocationCoordinate2D savedLocation = CLLocationCoordinate2DMake(savedLatitude, savedLongitude);
    [self addPinAt:savedLocation];
    self.mapView.centerCoordinate = savedLocation;
    
    // 4
    NSClickGestureRecognizer *recognizer = [[NSClickGestureRecognizer alloc] initWithTarget:self action:@selector(mapTapped:)];
    [self.mapView addGestureRecognizer:recognizer];
}

- (void)viewWillDisappear {
    [super viewWillDisappear];
    
    NSUserDefaults *defaults = NSUserDefaults.standardUserDefaults;
    id<MKAnnotation> annotation = self.mapView.annotations[0];
    
    [defaults setDouble:annotation.coordinate.latitude forKey:@"latitude"];
    [defaults setDouble:annotation.coordinate.longitude forKey:@"longitude"];
    [defaults setObject:self.apiKey.stringValue forKey:@"apiKey"];
    [defaults setInteger:self.units.selectedSegment forKey:@"units"];
    
    // 2
    NSInteger statusBarValue = -1;
    for (NSMenuItem *menuItem in self.statusBarOption.menu.itemArray) {
        if (menuItem.state == NSControlStateValueOn) {
            statusBarValue = menuItem.tag;
            break;
        }
    }
    
    [defaults setInteger:statusBarValue forKey:@"statusBarOption"];
    
    // 3
    NSNotificationCenter *nc = NSNotificationCenter.defaultCenter;
    [nc postNotificationName:@"SettingsChanged" object:nil];
}

- (void)addPinAt:(CLLocationCoordinate2D)coordinate {
    MKPointAnnotation *annotation = [MKPointAnnotation new];
    annotation.coordinate = coordinate;
    annotation.title = @"Your location";
    [self.mapView addAnnotation:annotation];
}

- (void)mapTapped:(NSClickGestureRecognizer *)recognizer {
    NSPoint location = [recognizer locationInView:self.mapView];
    CLLocationCoordinate2D coordinate = [self.mapView convertPoint:location toCoordinateFromView:self.mapView];
    [self addPinAt:coordinate];
}

- (IBAction)showPoweredByAction:(NSButton *)sender {
    NSURL *url = [NSURL URLWithString:@"https://darksky.net/poweredby/"];
    [NSWorkspace.sharedWorkspace openURL:url];
}

@end
