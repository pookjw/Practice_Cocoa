//
//  AppDelegate.h
//  Project10
//
//  Created by Jinwoo Kim on 1/4/21.
//

#import <Cocoa/Cocoa.h>
#import "ViewController.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>
@property NSStatusItem *statusItem;
@property NSDictionary *feed;
@property NSInteger displayMode;
@property NSTimer *updateDisplayTimer;
@property NSTimer *fetchFeedTimer;
@end

