//
//  ViewController.m
//  Project6
//
//  Created by Jinwoo Kim on 12/30/20.
//

#import "ViewController.h"

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [self createVFL];
//    [self createAnchors];
//    [self createStackView];
//    [self createStackView2];
    [self createGridView];
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

- (NSView *)makeView:(NSUInteger)number {
    NSTextField *vw = [NSTextField labelWithString:[NSString stringWithFormat:@"View %lu", number]];
    vw.translatesAutoresizingMaskIntoConstraints = NO;
    vw.alignment = NSTextAlignmentCenter;
    vw.wantsLayer = YES;
    vw.layer.backgroundColor = NSColor.cyanColor.CGColor;
    return vw;
}

- (void)createVFL {
    // set up a dictionary of strings and views
    NSDictionary<NSString *, NSView *> *textFields = @{
        @"view0": [self makeView:0],
        @"view1": [self makeView:1],
        @"view2": [self makeView:2],
        @"view3": [self makeView:3]
    };
    
    // loop over each item
    [textFields enumerateKeysAndObjectsUsingBlock:^(NSString *name, NSView *textField, BOOL *stop) {
        // add it to our view
        [self.view addSubview:textField];
        
        // add horizontal constraints saying that this view should stretch from edge to edge
        NSArray<NSLayoutConstraint *> *constraints = [NSLayoutConstraint
                                                      constraintsWithVisualFormat:[NSString stringWithFormat:@"H:|[%@]|", name]
                                                      options:0
                                                      metrics:nil
                                                      views:textFields];
        [self.view addConstraints:constraints];
    }];
    
    // add another set of constraints that cause the views to be aligned vertically, one above the other
    NSArray<NSLayoutConstraint *> *constraints = [NSLayoutConstraint
                                                  constraintsWithVisualFormat:@"V:|[view0]-[view1]-[view2]-[view3]|"
                                                  options:0
                                                  metrics:nil
                                                  views:textFields];
    [self.view addConstraints:constraints];
}

- (void)createAnchors {
    // create a variable to track the previous view we placed
    NSView *previous;
    
    // create four views and put them into an array
    NSArray<NSView *> *views = @[
        [self makeView:0],
        [self makeView:1],
        [self makeView:2],
        [self makeView:3]
    ];
    
    for (NSView *vw in views) {
        // add this child to our main view, making it fill the horizontal space and be 88 points high
        [self.view addSubview:vw];
        
        [[vw.widthAnchor constraintEqualToConstant:88] setActive:YES];
        [[vw.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor] setActive:YES];
        
        if (previous != nil) {
            // we have a previous view - position us 10 points vertically away from it
            [[vw.topAnchor constraintEqualToAnchor:previous.bottomAnchor constant:10] setActive:YES];
        } else {
            // we don't have a previous view - position us against the top edge
            [[vw.topAnchor constraintEqualToAnchor:self.view.topAnchor] setActive:YES];
        }
        
        // set the previous view to be the current one, for the next loop iteration
        previous = vw;
    }
    
    // make the final view sit against the bottom edge of our main view
    [[previous.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor] setActive:YES];
}

- (void)createStackView {
    // create a stack view from four text fields
    NSStackView *stackView = [NSStackView stackViewWithViews:@[
        [self makeView:0],
        [self makeView:1],
        [self makeView:2],
        [self makeView:3]
    ]];
    
    // make them take up an equal amount of space
    stackView.distribution = NSStackViewDistributionFillEqually;
    
    // make the views line up vertically
    stackView.orientation = NSUserInterfaceLayoutOrientationVertical;
    
    // set this to false so we can create our own Auto Layout constraints
    stackView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:stackView];
    
    // make the stack view sit directly against all four edges
    [[stackView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor] setActive:YES];
    [[stackView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor] setActive:YES];
    [[stackView.topAnchor constraintEqualToAnchor:self.view.topAnchor] setActive:YES];
    [[stackView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor] setActive:YES];
}

- (void)createStackView2 {
    // create a stack view from four text fields
    NSStackView *stackView = [NSStackView stackViewWithViews:@[
        [self makeView:0],
        [self makeView:1],
        [self makeView:2],
        [self makeView:3]
    ]];
    
    // make them take up an equal amount of space
    stackView.distribution = NSStackViewDistributionFillEqually;
    
    // make the views line up vertically
    stackView.orientation = NSUserInterfaceLayoutOrientationVertical;
    
    // set this to false so we can create our own Auto Layout constraints
    stackView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:stackView];
    
    // resize window freely
    for (NSView *view in stackView.arrangedSubviews) {
        [view setContentHuggingPriority:1 forOrientation:NSLayoutConstraintOrientationHorizontal];
        [view setContentHuggingPriority:1 forOrientation:NSLayoutConstraintOrientationVertical];
    }
    
    // make the stack view sit directly against all four edges
    [[stackView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor] setActive:YES];
    [[stackView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor] setActive:YES];
    [[stackView.topAnchor constraintEqualToAnchor:self.view.topAnchor] setActive:YES];
    [[stackView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor] setActive:YES];
}

- (void)createGridView {
    // create our concise empty cell
    NSView *empty = NSGridCell.emptyContentView;
    
    // create a grid of views
    NSGridView *gridView = [NSGridView gridViewWithViews:@[
        @[[self makeView:0]],
        @[[self makeView:1], empty, [self makeView:2]],
        @[[self makeView:3], [self makeView:4], [self makeView:5], [self makeView:6]],
        @[[self makeView:7], empty, [self makeView:8]],
        @[[self makeView:9]]
    ]];
    
    // make that we'll grid to the edges of our main view
    gridView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:gridView];
    
    // pin the grid to the edges of our main view
    [[gridView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor] setActive:YES];
    [[gridView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor] setActive:YES];
    [[gridView.topAnchor constraintEqualToAnchor:self.view.topAnchor] setActive:YES];
    [[gridView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor] setActive:YES];
    
    // define heights
    [[gridView rowAtIndex:0] setHeight:32];
    [[gridView rowAtIndex:1] setHeight:32];
    [[gridView rowAtIndex:2] setHeight:32];
    [[gridView rowAtIndex:3] setHeight:32];
    [[gridView rowAtIndex:4] setHeight:32];
    
    // define widths
    [[gridView columnAtIndex:0] setWidth:128];
    [[gridView columnAtIndex:1] setWidth:128];
    [[gridView columnAtIndex:2] setWidth:128];
    [[gridView columnAtIndex:3] setWidth:128];
    
    // define alignments
    [[gridView rowAtIndex:0] mergeCellsInRange:NSMakeRange(0, 4)];
    [[gridView rowAtIndex:1] mergeCellsInRange:NSMakeRange(0, 2)];
    [[gridView rowAtIndex:1] mergeCellsInRange:NSMakeRange(2, 2)];
    [[gridView rowAtIndex:3] mergeCellsInRange:NSMakeRange(0, 2)];
    [[gridView rowAtIndex:3] mergeCellsInRange:NSMakeRange(2, 2)];
    [[gridView rowAtIndex:4] mergeCellsInRange:NSMakeRange(0, 4)];
    
    [[gridView rowAtIndex:0] setYPlacement:NSGridCellPlacementCenter];
    [[gridView rowAtIndex:1] setYPlacement:NSGridCellPlacementCenter];
    [[gridView rowAtIndex:2] setYPlacement:NSGridCellPlacementCenter];
    [[gridView rowAtIndex:3] setYPlacement:NSGridCellPlacementCenter];
    [[gridView rowAtIndex:4] setYPlacement:NSGridCellPlacementCenter];
    
    [[gridView columnAtIndex:0] setXPlacement:NSGridCellPlacementCenter];
    [[gridView columnAtIndex:1] setXPlacement:NSGridCellPlacementCenter];
    [[gridView columnAtIndex:2] setXPlacement:NSGridCellPlacementCenter];
    [[gridView columnAtIndex:3] setXPlacement:NSGridCellPlacementCenter];
}
@end
