//
//  SourceViewController.m
//  Practice1
//
//  Created by Jinwoo Kim on 11/18/20.
//

#import "SourceViewController.h"
#import "DetailViewController.h"

@interface SourceViewController ()
@property (strong) IBOutlet NSTableView *tableView;
@property NSMutableArray<NSString *> *pictures;
@end

@implementation SourceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *path = NSBundle.mainBundle.resourcePath;
    NSArray<NSString *> *items = [fm contentsOfDirectoryAtPath:path error:nil];
    self.pictures = [@[] mutableCopy];
    
    for (NSString *item in items) {
        @autoreleasepool {
            if ([item hasPrefix:@"nssl"]) [self.pictures addObject:item];
        }
    }
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return [self.pictures count];
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSTableCellView *vw = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];
    vw.textField.stringValue = self.pictures[row];
    return vw;
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    if (self.tableView.selectedRow == -1) return; // -1이면 아무것도 선택 안 됐다는 뜻
    NSSplitViewController *splitVC = self.parentViewController;
    DetailViewController *detail = splitVC.childViewControllers[1];
    [detail imageSelected:self.pictures[self.tableView.selectedRow]];
}

@end
