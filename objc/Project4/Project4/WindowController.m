//
//  WindowController.m
//  Project4
//
//  Created by Jinwoo Kim on 12/22/20.
//

#import "WindowController.h"

@interface WindowController ()
@end

@implementation WindowController
- (void)windowDidLoad {
    [super windowDidLoad];
    self.window.titleVisibility = NSWindowTitleHidden;
}

- (void)cancelOperation:(id)sender {
    [self.window makeFirstResponder:self.contentViewController];
}
@end
