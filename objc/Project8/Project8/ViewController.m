//
//  ViewController.m
//  Project8
//
//  Created by Jinwoo Kim on 1/3/21.
//

#import "ViewController.h"

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createLevel];
    [self gameOver];
}

- (void)loadView {
    [super loadView];
    
    self.gridViewButtons = [@[] mutableCopy];
    self.gridSize = 10;
    self.gridMargin = 5;
    self.images = [@[@"elephant", @"giraffe", @"hippo", @"monkey", @"panda", @"parrot", @"penguin", @"pig", @"rabbit", @"snake"] mutableCopy];
    self.currentLevel = 1;
    
    self.visualEffectView = [NSVisualEffectView new];
    self.visualEffectView.translatesAutoresizingMaskIntoConstraints = NO;
    
    // enable the dark vibrancy effect
    self.visualEffectView.material = NSVisualEffectMaterialUnderWindowBackground;
//    NSApp.appearance = [NSAppearance appearanceNamed:NSAppearanceNameVibrantDark];
    
    // force it to remain active even the window loses focus
    self.visualEffectView.state = NSVisualEffectStateActive;
    
    [self.view addSubview:self.visualEffectView];
    
    // pin it to the edges of our window
    [[self.visualEffectView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor] setActive:YES];
    [[self.visualEffectView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor] setActive:YES];
    [[self.visualEffectView.topAnchor constraintEqualToAnchor:self.view.topAnchor] setActive:YES];
    [[self.visualEffectView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor] setActive:YES];
    
    NSTextField *title = [self createTitle];
    [self createGridViewRelativeTo:title];
}

- (NSTextField *)createTitle {
    NSString *titleString = @"Odd One Out";
    NSTextField *title = [NSTextField labelWithString:titleString];
    
    title.font = [NSFont systemFontOfSize:36 weight:NSFontWeightThin];
    title.textColor = NSColor.whiteColor;
    title.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.visualEffectView addSubview:title];
    
    [[title.topAnchor constraintEqualToAnchor:self.visualEffectView.topAnchor constant:self.gridMargin] setActive:YES];
    [[title.centerXAnchor constraintEqualToAnchor:self.visualEffectView.centerXAnchor] setActive:YES];
    
    return title;
}

- (NSArray<NSArray<NSButton *> *> *)createButtonArray {
    NSMutableArray<NSArray<NSButton *> *> *rows = [@[] mutableCopy];
    
    for (NSUInteger i = 0; i < self.gridSize; i++) {
        NSMutableArray<NSButton *> *row = [@[] mutableCopy];
        
        for (NSUInteger i = 0; i < self.gridSize; i++) {
            NSButton *button = [[NSButton alloc] initWithFrame:NSMakeRect(0, 0, 64, 64)];
            [button setButtonType:NSButtonTypeMomentaryChange];
//            [button setImage:[NSImage imageNamed:self.images[0]]];
            [button setImagePosition:NSImageOnly];
            [button setFocusRingType:NSFocusRingTypeNone];
            [button setBordered:NO];
            [button setAction:@selector(imageClicked:)];
            [button setTarget:self];
            [self.gridViewButtons addObject:button];
            [row addObject:button];
        }
        
        [rows addObject:row];
    }
    
    return rows;
}

- (void)createGridViewRelativeTo:(NSTextField *)title {
    NSArray<NSArray<NSButton *> *> *rows = [self createButtonArray];
    NSGridView *gridView = [NSGridView gridViewWithViews:rows];
    
    gridView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.visualEffectView addSubview:gridView];
    
    [[gridView.leadingAnchor constraintEqualToAnchor:self.visualEffectView.leadingAnchor constant:self.gridMargin] setActive:YES];
    [[gridView.trailingAnchor constraintEqualToAnchor:self.visualEffectView.trailingAnchor constant:-self.gridMargin] setActive:YES];
    [[gridView.topAnchor constraintEqualToAnchor:title.bottomAnchor constant:self.gridMargin] setActive:YES];
    [[gridView.bottomAnchor constraintEqualToAnchor:self.visualEffectView.bottomAnchor constant:-self.gridMargin] setActive:YES];
    
    gridView.columnSpacing = self.gridMargin / 2;
    gridView.rowSpacing = self.gridMargin / 2;
    
    for (NSUInteger i = 0; i < self.gridSize; i++) {
        [gridView rowAtIndex:i].height = 64;
        [gridView columnAtIndex:i].width = 64;
    }
}

- (void)generateLayoutWith:(NSUInteger)items {
    // reset the game board
    for (NSButton *button in self.gridViewButtons) {
        button.tag = 0;
        button.image = nil;
    }
    
    // randomize the buttons and animal images
    [self.gridViewButtons shuffle];
    [self.images shuffle];
    
    // create our two properties to place animals in pairs
    NSUInteger numUsed = 0;
    NSUInteger itemCount = 1;
    
    // create the odd animal by hand, giving it the tag 2, "correct answer"
    NSButton *firstButton = self.gridViewButtons[0];
    firstButton.tag = 2;
    firstButton.image = [NSImage imageNamed:self.images[0]];
    
    // now create all the rest of the animals
    for (NSUInteger i = 1; i < items; i++) {
        // pull out the button at this location and give it the tag 1. "wrong answer"
        NSButton *currentButton = self.gridViewButtons[i];
        currentButton.tag = 2;
        
        // set its image to be the current animal
//        currentButton.image = [NSImage imageNamed:self.images[itemCount]];
        [currentButton setImage:[NSImage imageNamed:self.images[itemCount]]];
        
        // mark that we've placed another animal in this pair
        numUsed += 1;
        
        // if we have placed two animals of this type
        if (numUsed == 2) {
            // reset the counter
            numUsed = 0;
            
            // place the next animal type
            itemCount += 1;
        }
        
        // if we've reached the end of the animal types
        if (itemCount == self.images.count) {
            // go back to the start 1, not 0, because we don't want to place the odd animal
            itemCount = 1;
        }
    }
}

- (void)gameOver {
    self.gameOverView = [GameOverView new];
    self.gameOverView.alphaValue = 0;
    self.gameOverView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.gameOverView];
    
    [[self.gameOverView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor] setActive:YES];
    [[self.gameOverView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor] setActive:YES];
    [[self.gameOverView.topAnchor constraintEqualToAnchor:self.view.topAnchor] setActive:YES];
    [[self.gameOverView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor] setActive:YES];
    
    [self.gameOverView layoutSubtreeIfNeeded];
    [self.gameOverView startEmitting];
    [self.gameOverView animator].alphaValue = 1;
}

- (void)createLevel {
    switch (self.currentLevel) {
        case 1:
            [self generateLayoutWith:5];
            break;
        case 2:
            [self generateLayoutWith:15];
            break;
        case 3:
            [self generateLayoutWith:25];
            break;
        case 4:
            [self generateLayoutWith:35];
            break;
        case 5:
            [self generateLayoutWith:49];
            break;
        case 6:
            [self generateLayoutWith:65];
            break;
        case 7:
            [self generateLayoutWith:81];
            break;
        case 8:
            [self generateLayoutWith:100];
            break;
        default:
            [self gameOver];
            break;
    }
}

- (void)imageClicked:(NSButton *)sender {
    // bail out if the user clicked an invisible button
    if (sender.tag == 0) return;
    
    if (sender.tag == 1) {
        NSLog(@"Wrong");
        // they clicked the wrong animal
        if (self.currentLevel > 1) {
            // take the current level down by 1 if we can
            self.currentLevel -= 1;
        }
        
        // create a new layout
        [self createLevel];
    } else {
        NSLog(@"Correct");
        // they clicked the correct animal
        if (self.currentLevel < 9) {
            // take the current level up by 1 if we can
            self.currentLevel += 1;
            [self createLevel];
        }
    }
}
@end
