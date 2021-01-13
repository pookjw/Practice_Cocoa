//
//  AppDelegate.m
//  Project13
//
//  Created by Jinwoo Kim on 1/11/21.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    NSColorPanel.sharedColorPanel.showsAlpha = YES;
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


@end
