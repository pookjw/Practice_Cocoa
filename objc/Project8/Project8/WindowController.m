//
//  WindowController.m
//  Project8
//
//  Created by Jinwoo Kim on 1/3/21.
//

#import "WindowController.h"

@interface WindowController ()

@end

@implementation WindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    [self.window setStyleMask:self.window.styleMask | NSWindowStyleMaskFullSizeContentView];
    self.window.titlebarAppearsTransparent = YES;
    self.window.titleVisibility = NSWindowTitleHidden;
    [self.window setMovableByWindowBackground:YES];
}

@end
