//
//  WindowController.m
//  Practice1
//
//  Created by Jinwoo Kim on 11/22/20.
//

#import "WindowController.h"
#import "DetailViewController.h"

@interface WindowController ()
@property (strong) IBOutlet NSButton *shareButton;
@end

@implementation WindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    [self.shareButton sendActionOn:NSEventMaskLeftMouseDown];
}

- (IBAction)shareClicked:(NSView *)sender {
    NSSplitViewController *split = (NSSplitViewController *)self.contentViewController;
    DetailViewController *detail = split.childViewControllers[1];
    NSImage *image = detail.imageView.image;
    
    NSSharingServicePicker *picker = [[NSSharingServicePicker alloc] initWithItems:@[image]];
    [picker showRelativeToRect:CGRectZero ofView:sender preferredEdge:NSRectEdgeMinY];
}


@end
