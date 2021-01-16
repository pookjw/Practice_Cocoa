//
//  ViewController.m
//  Project4
//
//  Created by Jinwoo Kim on 12/22/20.
//

#import "ViewController.h"

@implementation ViewController
- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

// MARK: - Life Cycle and View Selection Methods
- (void)viewDidLoad {
    [super viewDidLoad];

    // 1: Create the stack view and add it to our view
    self.rows = [NSStackView new];
    self.rows.orientation = NSUserInterfaceLayoutOrientationVertical;
    self.rows.distribution = NSStackViewDistributionFillEqually;
    self.rows.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.rows];
    
    // 2: Create Auto Layout constaints that pin the stack view to the edges of its container
    [[self.rows.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor] setActive:YES];
    [[self.rows.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor] setActive:YES];
    [[self.rows.topAnchor constraintEqualToAnchor:self.view.topAnchor] setActive:YES];
    [[self.rows.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor] setActive:YES];
    
    // 3: Create an initial column that contains a single web view
    NSView *webView = [self makeWebView];
    NSStackView *column = [NSStackView stackViewWithViews:@[webView]];
    column.distribution = NSStackViewDistributionFillEqually;
    
    // 4: Add this column to the `rows` stack view
    [self.rows addArrangedSubview:column];
}

- (NSView *)makeWebView {
    WKWebView *webView = [WKWebView new];
    NSURL *url = [NSURL URLWithString:@"https://www.apple.com"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSClickGestureRecognizer *recognizer = [[NSClickGestureRecognizer alloc] initWithTarget:self action:@selector(webViewClicked:)];
    
    webView.navigationDelegate = self;
    webView.wantsLayer = YES;
    [webView loadRequest:request];
    
    [webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    
    recognizer.numberOfClicksRequired = 2;
    recognizer.delegate = self;
    [webView addGestureRecognizer:recognizer];
    
    if (self.selectedWebView == nil) [self select:webView];
    
    return webView;
}

- (void)webViewClicked:(NSClickGestureRecognizer *)recognizer {
    // get the web view that triggered this method
    WKWebView *newSelectedWebView = (WKWebView *)recognizer.view;
    if (newSelectedWebView == nil) return;
    
    // deselect the currently selected webview if there is one
    self.selectedWebView.layer.borderWidth = 0;
    
    // select the new one
    [self select:newSelectedWebView];
    
}

- (void)select:(WKWebView *)webView {
    self.selectedWebView = webView;
    self.selectedWebView.layer.borderWidth = 4;
    self.selectedWebView.layer.borderColor = NSColor.blueColor.CGColor;
    
    WindowController *windowController = self.view.window.windowController;
    
    if (windowController != nil) {
        windowController.addressEntry.stringValue = self.selectedWebView.URL.absoluteString;
    }
}

- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
    if (self.selectedWebView == nil) return;
    
    WindowController *windowController = self.view.window.windowController;
    if (windowController != nil) {
        windowController.addressEntry.stringValue = webView.URL.absoluteString;
    }
}

-(BOOL)gestureRecognizer:(NSGestureRecognizer *)gestureRecognizer shouldAttemptToRecognizeWithEvent:(NSEvent *)event {
    if (gestureRecognizer.view == self.selectedWebView) {
        return NO;
    }
    return YES;
}

// MARK: - Touch Bar
- (void)selectAddressEntry {
    WindowController *windowController = self.view.window.windowController;
    if (windowController == nil) return;
    [windowController.window makeFirstResponder:windowController.addressEntry];
}

- (nonnull NSArray *)itemsForSharingServicePickerTouchBarItem:(nonnull NSSharingServicePickerTouchBarItem *)pickerTouchBarItem {
    if (self.selectedWebView == nil) return @[];
    NSString *url = self.selectedWebView.URL.absoluteString;
    if (url == nil) return @[];
    return @[url];
}

- (NSTouchBar *)makeTouchBar {
    // enable the Customize Touch Bar menu item
    NSApp.automaticCustomizeTouchBarMenuItemEnabled = YES;
    
    // create a Touch Bar with a unique identifier, making `ViewController` its delegate
    NSTouchBar *touchBar = [NSTouchBar new];
    touchBar.customizationIdentifier = NSTouchBarCustomizationIdentifierProject;
    touchBar.delegate = self;
    
    // set up some meaningful defaults
    touchBar.defaultItemIdentifiers = @[
        NSTouchBarItemIdentifierNavigation,
        NSTouchBarItemIdentifierAdjustGrid,
        NSTouchBarItemIdentifierEnterAddress,
        NSTouchBarItemIdentifierSharingPicker
    ];
    
    // make the address entry button sit in the center of the bar
    touchBar.principalItemIdentifier = NSTouchBarItemIdentifierEnterAddress;
    
    // allow the user to customize these four controls
    touchBar.customizationAllowedItemIdentifiers = @[
        NSTouchBarItemIdentifierSharingPicker,
        NSTouchBarItemIdentifierAdjustGrid,
        NSTouchBarItemIdentifierAdjustCols,
        NSTouchBarItemIdentifierAdjustRows
    ];
    
    // but don't let them take off the URL entry button
    touchBar.customizationRequiredItemIdentifiers = @[NSTouchBarItemIdentifierEnterAddress];
    
    return touchBar;
}

- (NSTouchBarItem *)touchBar:(NSTouchBar *)touchBar makeItemForIdentifier:(NSTouchBarItemIdentifier)identifier {
    if (identifier == NSTouchBarItemIdentifierEnterAddress) {
        NSButton *button = [NSButton buttonWithTitle:@"Enter a URL" target:self action:@selector(selectAddressEntry)];
        NSCustomTouchBarItem *customTouchBarItem = [[NSCustomTouchBarItem alloc] initWithIdentifier:identifier];
        
        [button setContentHuggingPriority:10 forOrientation:NSLayoutConstraintOrientationHorizontal];
        customTouchBarItem.view = button;
        return customTouchBarItem;
    } else if (identifier == NSTouchBarItemIdentifierNavigation) {
        // load the back and forward images
        NSImage *back = [NSImage imageNamed:NSImageNameTouchBarGoBackTemplate];
        NSImage *forward = [NSImage imageNamed:NSImageNameGoForwardTemplate];
        
        // create a segmented control out of them, calling our `navigationClicked:` method
        NSSegmentedControl *segmentedControl = [NSSegmentedControl
                                                segmentedControlWithImages:@[back, forward]
                                                trackingMode:NSSegmentSwitchTrackingMomentary
                                                target:self
                                                action:@selector(navigationClicked:)];
        
        // wrap that inside a Touch Bar item
        NSCustomTouchBarItem *customTouchBarItem = [[NSCustomTouchBarItem alloc] initWithIdentifier:identifier];
        customTouchBarItem.view = segmentedControl;
        
        // send it back
        return customTouchBarItem;
    } else if (identifier == NSTouchBarItemIdentifierSharingPicker) {
        NSSharingServicePickerTouchBarItem *picker = [[NSSharingServicePickerTouchBarItem alloc] initWithIdentifier:identifier];
        picker.delegate = self;
        return picker;
    } else if (identifier == NSTouchBarItemIdentifierAdjustRows) {
        NSSegmentedControl *control = [NSSegmentedControl
                                       segmentedControlWithLabels:@[@"Add Row", @"Remove Row"]
                                       trackingMode:NSSegmentSwitchTrackingMomentaryAccelerator
                                       target:self
                                       action:@selector(adjustRows:)];
        NSCustomTouchBarItem *customTouchBarItem = [[NSCustomTouchBarItem alloc] initWithIdentifier:identifier];
        customTouchBarItem.customizationLabel = @"Rows";
        customTouchBarItem.view = control;
        return customTouchBarItem;
    } else if (identifier == NSTouchBarItemIdentifierAdjustCols) {
        NSSegmentedControl *control = [NSSegmentedControl
                                       segmentedControlWithLabels:@[@"Add Column", @"Remove Column"]
                                       trackingMode:NSSegmentSwitchTrackingMomentaryAccelerator
                                       target:self
                                       action:@selector(adjustColumns:)];
        NSCustomTouchBarItem *customTouchBarItem = [[NSCustomTouchBarItem alloc] initWithIdentifier:identifier];
        customTouchBarItem.customizationLabel = @"Column";
        customTouchBarItem.view = control;
        return customTouchBarItem;
    } else if (identifier == NSTouchBarItemIdentifierAdjustGrid) {
        NSPopoverTouchBarItem *popover = [[NSPopoverTouchBarItem alloc] initWithIdentifier:identifier];
        popover.collapsedRepresentationLabel = @"Grid";
        popover.customizationLabel = @"Adjust Grid";
        popover.popoverTouchBar = [NSTouchBar new];
        popover.popoverTouchBar.delegate = self;
        popover.popoverTouchBar.defaultItemIdentifiers = @[NSTouchBarItemIdentifierAdjustRows, NSTouchBarItemIdentifierAdjustCols];
        return popover;
    }
    return nil;
}

// MARK: - IBOAction
- (IBAction)urlEnterted:(NSTextField *)sender {
    // bail out if we don't have a webview selected
    if (self.selectedWebView == nil) return;
    
    // attempt to convert the user's text into a URL
    NSURL *url = [NSURL URLWithString:sender.stringValue];
    if (url == nil) return;
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    [self.selectedWebView loadRequest:request];
}

- (IBAction)navigationClicked:(NSSegmentedControl *)sender {
    // make sure we have a webview selected
    if (self.selectedWebView == nil) return;
    
    if (sender.selectedSegment == 0) [self.selectedWebView goBack];
    else [self.selectedWebView goForward];
}

- (IBAction)adjustRows:(NSSegmentedControl *)sender {
    if (sender.selectedSegment == 0) {
        // we're adding a new row
        // count how many columns we have so far
        NSStackView *firstStackView = (NSStackView *)self.rows.arrangedSubviews.firstObject;
        NSUInteger columnCount = firstStackView.arrangedSubviews.count;
        
        // make a new array of webviews that contain the correct number of columns
        NSMutableArray<NSView *> *viewArray = [@[] mutableCopy];
        for (NSUInteger i = 0; i < columnCount; i++) {
            [viewArray addObject:[self makeWebView]];
        }
        
        // use that web view array to create a new stackview
        NSStackView *row = [NSStackView stackViewWithViews:viewArray];
        
        // make the stack view size its children equally, then add it to our `rows` array
        row.distribution = NSStackViewDistributionFillEqually;
        [self.rows addArrangedSubview:row];
    } else {
        // we're deleting a row
        // make sure we have at least two rows
        if (self.rows.arrangedSubviews.count <= 1) return;
        
        // pull out the final row, and make sure it's a stackview
        NSStackView *rowToRemove = (NSStackView *)self.rows.arrangedSubviews.lastObject;
        if (rowToRemove == nil) return;
        
        // loop through each webview in the row, removing it form the screen
        for (NSView *cell in rowToRemove.arrangedSubviews) {
            [cell removeFromSuperview];
        }
        
        // finally, remove the whole stackview row
        [self.rows removeArrangedSubview:rowToRemove];
    }
}

- (IBAction)adjustColumns:(NSSegmentedControl *)sender {
    if (sender.selectedSegment == 0) {
        // we need to add a column
        for (NSStackView *row in self.rows.arrangedSubviews) {
            if (row == nil) continue;
            [row addArrangedSubview:[self makeWebView]];
        }
    } else {
        // we need to delete a column
        // pull out the first of our rows
        NSStackView *firstRow = (NSStackView *)self.rows.arrangedSubviews.firstObject;
        if (firstRow == nil) return;
        
        // make sure it has at least two columns
        if (firstRow.arrangedSubviews.count <= 1) return;
    
        // if we are still here it means it's safe to delete a column
        for (NSStackView *row in self.rows.arrangedSubviews) {
            if (row == nil) continue;
            NSView *last = row.arrangedSubviews.lastObject;
            if (last == nil) continue;
            [row removeArrangedSubview:last];
            [last removeFromSuperview];
        }
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    WKWebView *webView = (WKWebView *)object;
    if (webView == nil) return;
    NSURL *url = webView.URL;
    if (url == nil) return;
    NSLog(@"The URL %@ loaded %f", url.absoluteString, webView.estimatedProgress);
}
@end
