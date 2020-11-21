//
//  DetailViewController.m
//  Practice1
//
//  Created by Jinwoo Kim on 11/18/20.
//

#import "DetailViewController.h"

@interface DetailViewController ()

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
