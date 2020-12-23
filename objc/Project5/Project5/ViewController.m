//
//  ViewController.m
//  Project5
//
//  Created by Jinwoo Kim on 12/24/20.
//

#import "ViewController.h"

@implementation ViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSClickGestureRecognizer *recognizer = [[NSClickGestureRecognizer alloc] initWithTarget:self action:@selector(mapClicked:)];
    [self.mapView addGestureRecognizer:recognizer];
    
    [self startNewGame];
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

- (void)setScore:(NSUInteger)score {
    self.scoreLabel.stringValue = [NSString stringWithFormat:@"Score: %lu", score];
}

- (void)mapClicked:(NSClickGestureRecognizer *)recognizer {
    if (self.mapView.annotations.count == 0) {
        NSPoint location = [recognizer locationInView:self.mapView];
        CLLocationCoordinate2D coordinates = [self.mapView convertPoint:location toCoordinateFromView:self.mapView];
        [self addPin:coordinates];
    } else {
        NSArray<id<MKAnnotation>> *annotations = self.mapView.annotations;
        [self.mapView removeAnnotations:annotations];
        [self nextCity];
    }
}

- (void)addPin:(CLLocationCoordinate2D)coord {
    // make sure we have a city that we're looking for
    if (self.currentCity == nil) return;
    Pin *actual = self.currentCity;
    
    // create a pin representing the player's guess, and add it to the map
    Pin *guess = [Pin title:@"Your guess" coordinate:coord color:NSColor.redColor];
    [self.mapView addAnnotation:guess];
    
    // also add the correct answer
    [self.mapView addAnnotation:self.currentCity];
    
    // convert both coordinates to map points
    MKMapPoint point1 = MKMapPointMake(guess.coordinate.longitude, guess.coordinate.latitude);
    MKMapPoint point2 = MKMapPointMake(actual.coordinate.longitude, actual.coordinate.latitude);
    
    // calculate how many kilometers they were off, the substract that from 500
    CLLocationDistance actualDistance = MKMetersBetweenMapPoints(point1, point2);
    int distance = fabs(500 - actualDistance / 1000);
    
    // add that to their score; this will trigger the property observer
    self.score += distance;
    
    // add an annotation to the correct pin telling the player what they score
    actual.subtitle = [NSString stringWithFormat:@"You scored %d", distance];
    
    // tell the map view to select the correct answer, making it zoom in and show its title and subtitle
    [self.mapView selectAnnotation:actual animated:YES];
}

- (void)startNewGame {
    // clear the score
    self.score = 0;
    self.cities = [@[] mutableCopy];
    
    // create example cities
    [self.cities addObject:[Pin title:@"London" coordinate:CLLocationCoordinate2DMake(51.507222, -0.1275)]];
    [self.cities addObject:[Pin title:@"Oslo" coordinate:CLLocationCoordinate2DMake(59.95, 10.75)]];
    [self.cities addObject:[Pin title:@"Paris" coordinate:CLLocationCoordinate2DMake(48.8567, 2.3508)]];
    [self.cities addObject:[Pin title:@"Rome" coordinate:CLLocationCoordinate2DMake(41.9, 12.5)]];
    [self.cities addObject:[Pin title:@"Washington DC" coordinate:CLLocationCoordinate2DMake(38.895111, -77.036667)]];
    
    // start playing the game
    [self nextCity];
}

- (void)nextCity {
    Pin *city = [self.cities lastObject];
    
    if (city != nil) {
        [self.cities removeObject:city];
        
        // make this the city to guess
        self.currentCity = city;
        self.questionLabel.stringValue = [NSString stringWithFormat:@"Where is %@", city.title];
    } else {
        // no more cities!
        self.currentCity = nil;
        
        NSAlert *alert = [NSAlert new];
        alert.messageText = [NSString stringWithFormat:@"Final score: %lu", self.score];
        [alert runModal];
        
        // start a new game
        [self startNewGame];
    }
}

// MARK: - MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    // 1: Convert the annotation to a pin so we can read its color
    Pin *pin = (Pin *)annotation;
    if (pin == nil) return nil;
    
    // 2: Create an identifier string that will be used to share map pins
    NSString *identifier = @"Guess";
    
    // 3: Attempt to dequeue a pin from the re-use queue
    MKPinAnnotationView *annotationView = (MKPinAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
    
    if (annotationView == nil) {
        // 4: There was no pin to use; create a new one
        annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
    } else {
        // 5: We got back a pin to re-use, so update its annotation to the new annotation
        annotationView.annotation = annotation;
    }
    
    // 6: Customize the pin so that it can show a call out and has a color
    annotationView.canShowCallout = YES;
    annotationView.pinTintColor = pin.color;
    
    return annotationView;
}
@end
