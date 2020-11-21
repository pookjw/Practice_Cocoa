//
//  DetailViewController.m
//  Practice1
//
//  Created by Jinwoo Kim on 11/18/20.
//

#import "DetailViewController.h"

@interface DetailViewController ()
@property (strong) IBOutlet NSImageView *imageView;
@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

- (void)imageSelected:(NSString*)name {
    [self.imageView setImage:[NSImage imageNamed:name]];
}

@end
