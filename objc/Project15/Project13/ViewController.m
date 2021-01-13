//
//  ViewController.m
//  Project13
//
//  Created by Jinwoo Kim on 1/11/21.
//

#import "ViewController.h"

@implementation ViewController

- (Document *)document {
    Document *oughtToBeDocument = self.view.window.windowController.document;
    NSAssert((oughtToBeDocument != nil), @"Unable to find the document for this view controller.");
    return oughtToBeDocument;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    NSClickGestureRecognizer *recongnizer = [[NSClickGestureRecognizer alloc] initWithTarget:self action:@selector(importScreenshot)];
    [self.imageView addGestureRecognizer:recongnizer];
    [self loadFonts];
    [self loadBackgroundImages];
}

- (void)viewWillAppear {
    [super viewWillAppear];
    [self updateUI];
    [self generatePreview];
}

- (void)importScreenshot {
    NSOpenPanel *panel = [NSOpenPanel new];
    panel.allowedFileTypes = @[@"jpg", @"png"];
    
    [panel beginWithCompletionHandler:^(NSModalResponse result){
        if (result == NSModalResponseOK) {
            NSURL *imageURL = panel.URL;
            if (imageURL == nil) return;
            self.screenshotImage = [[NSImage alloc] initWithContentsOfURL:imageURL];
            [self generatePreview];
        }
    }];
}

- (void)loadFonts {
    // find the list of fonts
    NSURL *fontFile = [NSBundle.mainBundle URLForResource:@"fonts" withExtension:nil];
    if (fontFile == nil) return;
    NSString *fonts = [[NSString alloc] initWithContentsOfURL:fontFile encoding:0 error:nil];
    if (fonts == nil) return;
    
    // split it up into an array by breaking on new lines
    NSArray<NSString *> *fontNames = [fonts componentsSeparatedByString:@"\n"];
    
    // loop over every font
    [fontNames enumerateObjectsUsingBlock:^(NSString * _Nonnull font, NSUInteger idx, BOOL *stop){
        if ([font hasPrefix:@" "]) {
            // this is a font variation
            NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:font action:@selector(changeFontName:) keyEquivalent:@""];
            item.target = self;
            [self.fontName.menu addItem:item];
        } else {
            // this is a font family
            NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:font action:nil keyEquivalent:@""];
            item.target = self;
            [item setEnabled:NO];
            [self.fontName.menu addItem:item];
        }
    }];
}

- (void)updateUI {
    self.caption.string = self.document.screenshot.caption;
    [self.fontName selectItemWithTitle:self.document.screenshot.captionFontName];
    [self.fontSize selectItemWithTag:self.document.screenshot.captionFontSize];
    self.fontColor.color = self.document.screenshot.captionColor;
    
    if (self.document.screenshot.backgroundImage.length != 0) {
        [self.backgroundImage selectItemWithTitle:self.document.screenshot.backgroundImage];
    }
    
    self.backgroundColorStart.color = self.document.screenshot.backgroundColorStart;
    self.backgroundColorEnd.color = self.document.screenshot.backgroundColorEnd;
    
    self.dropShadowStrength.selectedSegment = self.document.screenshot.dropShadowStrength;
    self.dropShadowTarget.selectedSegment = self.document.screenshot.dropShadowTarget;
}

- (void)loadBackgroundImages {
    NSArray<NSString *> *allImages = @[@"Antique Wood", @"Autumn Leaves", @"Autumn Sunset", @"Autumn by the Lake", @"Beach and Palm Tree", @"Blue Skies", @"Bokeh (Blue)", @"Bokeh (Golden)", @"Bokeh (Green)", @"Bokeh (Orange)", @"Bokeh (Rainbow)", @"Bokeh (White)", @"Burning Fire", @"Cherry Blossom", @"Coffee Beans", @"Cracked Earth", @"Geometric Pattern 1", @"Geometric Pattern 2", @"Geometric Pattern 3", @"Geometric Pattern 4", @"Grass", @"Halloween", @"In the Forest", @"Jute Pattern", @"Polka Dots (Purple)", @"Polka Dots (Teal)", @"Red Bricks", @"Red Hearts", @"Red Rose", @"Sandy Beach", @"Sheet Music", @"Snowy Mountain", @"Spruce Tree Needles", @"Summer Fruits", @"Swimming Pool", @"Tree Silhouette", @"Tulip Field", @"Vintage Floral", @"Zebra Stripes"];
    
    [allImages enumerateObjectsUsingBlock:^(NSString * _Nonnull image, NSUInteger idx, BOOL *stop){
        NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:image action:@selector(changeBackgroundImage:) keyEquivalent:@""];
        item.target = self;
        [self.backgroundImage.menu addItem:item];
    }];
}

- (void)generatePreview {
    __weak typeof(self) weakSelf = self;
    NSImage *image = [NSImage imageWithSize:CGSizeMake(1242, 2208) flipped:NO drawingHandler:^BOOL(NSRect rect){
        struct CGContext *ctx = [NSGraphicsContext.currentContext CGContext];
        if (ctx == nil) return NO;
        
        [weakSelf clearBackgroundInContext:&ctx rect:rect];
        [weakSelf drawBackgroundImageWithRect:rect];
        [weakSelf drawOverlayWithRect:rect];
        CGFloat captionOffset = [weakSelf drawCaptionInContext:&ctx rect:rect];
        [weakSelf drawDeviceInContext:&ctx rect:rect captionOffset:captionOffset];
        [weakSelf drawScreenshotInContext:&ctx rect:rect captionOffset:captionOffset];
        
        return YES;
    }];
    
    self.imageView.image = image;
}

- (void)clearBackgroundInContext:(struct CGContext **)context rect:(CGRect)rect {
    CGContextSetFillColorWithColor(*context, NSColor.whiteColor.CGColor);
    CGContextFillRect(*context, rect);
}

- (void)drawBackgroundImageWithRect:(CGRect)rect {
    // if they chose no background image, bail out
    if ([self.backgroundImage selectedTag] == 999) return;
    
    // if we can't get the current title, bail out
    NSString *title = self.backgroundImage.titleOfSelectedItem;
    if (title == nil) return;
    
    // if we can't convert that title to an image, bail out
    NSImage *image = [NSImage imageNamed:title];
    if (image == nil) return;
    
    // still here? Draw the image!
    // http://zathras.de/blog-nscompositingoperation-at-a-glance.htm
    [image drawInRect:rect fromRect:NSZeroRect operation:NSCompositingOperationSourceOver fraction:1];
}

- (void)drawOverlayWithRect:(CGRect)rect {
    NSGradient *gradient = [[NSGradient alloc] initWithStartingColor:self.backgroundColorStart.color endingColor:self.backgroundColorEnd.color];
    [gradient drawInRect:rect angle:-90];
}

- (NSDictionary<NSAttributedStringKey, id> *)createCaptionAttributes {
    NSMutableParagraphStyle *ps = [NSMutableParagraphStyle new];
    ps.alignment = NSTextAlignmentCenter;
    
    NSDictionary<NSNumber *, NSNumber *> *fontSizes = @{
        @0: @48, @1: @56, @2: @64, @3: @72, @4: @80, @5: @96, @6: @128
    };
    NSNumber *baseFontSizeNumber = fontSizes[[NSNumber numberWithInteger:[self.fontSize selectedTag]]];
    if (baseFontSizeNumber == nil) return nil;
    CGFloat baseFontSize = [baseFontSizeNumber floatValue];
    
    NSCharacterSet *dontWantChar = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString *selectedFontName = [self.fontName.selectedItem.title stringByTrimmingCharactersInSet:dontWantChar];
    if (selectedFontName == nil) selectedFontName = @"HelveticaNeue-Medium";
    
    NSFont *font = [NSFont fontWithName:selectedFontName size:baseFontSize];
    if (font == nil) return nil;
    NSColor *color = self.fontColor.color;
    
    return @{
        NSParagraphStyleAttributeName: ps,
        NSFontAttributeName: font,
        NSForegroundColorAttributeName: color
    };
}

- (void)setShadow {
    NSShadow *shadow = [NSShadow new];
    shadow.shadowOffset = NSZeroSize;
    shadow.shadowColor = NSColor.blackColor;
    shadow.shadowBlurRadius = 50;
    
    // the shadow is now configured - activate it!
    [shadow set];
}

- (CGFloat)drawCaptionInContext:(struct CGContext **)context rect:(CGRect)rect {
    if (self.dropShadowStrength.selectedSegment != 0) {
        // if the drop shadow is enabled
        if ((self.dropShadowTarget.selectedSegment == 0) || (self.dropShadowTarget.selectedSegment == 2)) {
            // and is set to "Text" or "Both"
            [self setShadow];
        }
    }
    
    // pull out the string to render
    NSString *string = self.caption.textStorage.string;
    if (string == nil) string = @"";
    
    // insert the rendering rect to keep the text off edges
    CGRect insetRect = CGRectInset(rect, 40, 20);
    
    // combine the user's text with their attributes to create an attributed string
    NSDictionary<NSAttributedStringKey, id> *captionAttributes = [self createCaptionAttributes];
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:string attributes:captionAttributes];
    
    // draw the string in the inset rect
    [attributedString drawInRect:rect];
    
    // if the shadow is set to "strong" then we'll draw the string again to make the shadow deeper
    if (self.dropShadowStrength.selectedSegment == 2) {
        // if the drop shadow is enabled
        if ((self.dropShadowTarget.selectedSegment == 0) || (self.dropShadowTarget.selectedSegment == 2)) {
            // and is set to "Text" or "Both"
            [self setShadow];
        }
    }
    
    // clear the shadow so it doesn't affect other stuff
    NSShadow *noShadow = [NSShadow new];
    [noShadow set];
    
    // calculate how much space this attributed string need
    CGSize availableSpace = CGSizeMake(insetRect.size.width, insetRect.size.height);
    CGRect textFrame = [attributedString
                        boundingRectWithSize:availableSpace
                        options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)];
    
    // send the height back to our caller
    return textFrame.size.height;
}

- (void)drawDeviceInContext:(struct CGContext **)context rect:(CGRect)rect captionOffset:(CGFloat)captionOffset {
    NSImage *image = [NSImage imageNamed:@"iPhone"];
    if (image == nil) return;
    
    CGFloat offsetX = (rect.size.width - image.size.width) / 2;
    CGFloat offsetY = (rect.size.height - image.size.height) / 2;
    offsetY -= captionOffset;
    
    if (self.dropShadowStrength.selectedSegment != 0) {
        if ((self.dropShadowTarget.selectedSegment == 1) || (self.dropShadowTarget.selectedSegment == 2)) {
            [self setShadow];
        }
    }
    
    [image drawAtPoint:CGPointMake(offsetX, offsetY) fromRect:NSZeroRect operation:NSCompositingOperationSourceOver fraction:1];
    
    if (self.dropShadowStrength.selectedSegment == 2) {
        if ((self.dropShadowTarget.selectedSegment == 1) || (self.dropShadowTarget.selectedSegment == 2)) {
            // create a stronger drop shadow by drawing again
            [image drawAtPoint:CGPointMake(offsetX, offsetY) fromRect:NSZeroRect operation:NSCompositingOperationSourceOver fraction:1];
        }
    }
    
    // clear the shadow so it doesn't affect other stuff
    NSShadow *noShadow = [NSShadow new];
    [noShadow set];
}

- (void)drawScreenshotInContext:(struct CGContext **)context rect:(CGRect)rect captionOffset:(CGFloat)captionOffset {
    NSImage *screenshot = self.screenshotImage;
    if (screenshot == nil) return;
    screenshot.size = CGSizeMake(891, 1584);
    
    CGFloat offsetY = 314 - captionOffset;
    [screenshot drawAtPoint:CGPointMake(176, offsetY) fromRect:CGRectZero operation:NSCompositingOperationSourceOver fraction:1];
}

- (IBAction)export:(id)sender {
    NSImage *image = self.imageView.image;
    if (image == nil) return;
    NSData *tiffDafa = [image TIFFRepresentation];
    if (tiffDafa == nil) return;
    NSBitmapImageRep *imageRep = [NSBitmapImageRep imageRepWithData:tiffDafa];
    if (imageRep == nil) return;
    NSData *png = [imageRep representationUsingType:NSBitmapImageFileTypePNG properties:@{}];
    if (png == nil) return;
    
    NSSavePanel *panel = [NSSavePanel new];
    panel.allowedFileTypes = @[@"png"];
    
    [panel beginWithCompletionHandler:^(NSModalResponse result){
        if (result == NSModalResponseOK) {
            NSURL *url = panel.URL;
            if (url == nil) return;
            
            NSError *error;
            [png writeToURL:url options:0 error:&error];
            
            if (error != nil) NSLog(@"%@", error.localizedDescription);
        }
    }];
}

//- (IBAction)changeFontSize:(NSPopUpButton *)sender {
//    self.document.screenshot.captionFontSize = [self.fontSize selectedTag];
//    [self generatePreview];
//}
//
//- (IBAction)changeFontColor:(NSColorWell *)sender {
//    self.document.screenshot.captionColor = self.fontColor.color;
//    [self generatePreview];
//}
//
//- (IBAction)changeBackgroundImage:(NSPopUpButton *)sender {
//    if ([self.backgroundImage selectedTag] == 999) {
//        self.document.screenshot.backgroundImage = @"";
//    } else {
//        self.document.screenshot.backgroundImage = self.backgroundImage.titleOfSelectedItem;
//    }
//
//    [self generatePreview];
//}
//
//- (IBAction)changeBackgroundColorStart:(NSColorWell *)sender {
//    self.document.screenshot.backgroundColorStart = self.backgroundColorStart.color;
//    [self generatePreview];
//}
//
//- (IBAction)changeBackgroundColorEnd:(NSColorWell *)sender {
//    self.document.screenshot.backgroundColorEnd = self.backgroundColorEnd.color;
//    [self generatePreview];
//}
//
//- (IBAction)changeDropShadowStrength:(NSSegmentedControl *)sender {
//    self.document.screenshot.dropShadowStrength = self.dropShadowStrength.selectedTag;
//    [self generatePreview];
//}
//
//- (IBAction)changeDropShadowTarget:(NSSegmentedControl *)sender {
//    self.document.screenshot.dropShadowTarget = self.dropShadowTarget.selectedTag;
//    [self generatePreview];
//}
//
//- (void)changeFontName:(NSMenuItem *)sender {
//    self.document.screenshot.captionFontName = self.fontName.titleOfSelectedItem;
//    [self generatePreview];
//}

#pragma Project15

- (void)changeFontName:(NSMenuItem *)sender {
    [self setFontNameTo:self.fontName.titleOfSelectedItem ? self.fontName.titleOfSelectedItem : @""];
}

- (void)setFontNameTo:(NSString *)name {
    // register the undo point with the current font name
    [self.undoManager registerUndoWithTarget:self selector:@selector(setFontNameTo:) object:self.document.screenshot.captionFontName];
    
    // update the font name
    self.document.screenshot.captionFontName = name;
    
    // update the UI to match
    [self.fontName selectItemWithTitle:self.document.screenshot.captionFontName];
    
    // ensure thre preview is updated
    [self generatePreview];
}

//

- (IBAction)changeFontSize:(NSPopUpButton *)sender {
    [self setFontSizeTo:[NSString stringWithFormat:@"%lu", [self.fontSize selectedTag]]];
}

- (void)setFontSizeTo:(NSString *)size {
    [self.undoManager registerUndoWithTarget:self
                                    selector:@selector(setFontSizeTo:)
                                      object:[NSString stringWithFormat:@"%lu", self.document.screenshot.captionFontSize]];
    
    self.document.screenshot.captionFontSize = [size integerValue];
    [self.fontSize selectItemWithTag:self.document.screenshot.captionFontSize];
    [self generatePreview];
}

//

- (IBAction)changeFontColor:(NSColorWell *)sender {
    [self setFontColorTo:self.fontColor.color];
}

- (void)setFontColorTo:(NSColor *)color {
    [self.undoManager registerUndoWithTarget:self
                                    selector:@selector(setFontColorTo:)
                                      object:self.document.screenshot.captionColor];
    
    self.document.screenshot.captionColor = color;
    self.fontColor.color = color;
    [self generatePreview];
}

//

- (IBAction)changeBackgroundImage:(NSPopUpButton *)sender {
    if ([self.backgroundImage selectedTag] == 999) {
        [self setBackgroundImageTo:@""];
    } else {
        [self setBackgroundImageTo:self.backgroundImage.titleOfSelectedItem ? self.backgroundImage.titleOfSelectedItem : @""];
    }
}

- (void)setBackgroundImageTo:(NSString *)name {
    [self.undoManager registerUndoWithTarget:self
                                    selector:@selector(setBackgroundImageTo:)
                                      object:self.document.screenshot.backgroundImage];
    
    self.document.screenshot.backgroundImage = name;
    [self.backgroundImage selectItemWithTitle:name];
    [self generatePreview];
}

//

- (IBAction)changeBackgroundColorStart:(NSColorWell *)sender {
    [self setBackgroundColorStartTo:self.backgroundColorStart.color];
}

- (void)setBackgroundColorStartTo:(NSColor *)color {
    [self.undoManager registerUndoWithTarget:self
                                    selector:@selector(setBackgroundColorStartTo:)
                                      object:self.document.screenshot.backgroundColorStart];

    self.document.screenshot.backgroundColorStart = color;
    self.backgroundColorStart.color = color;
    [self generatePreview];
}

//

- (IBAction)changeBackgroundColorEnd:(NSColorWell *)sender {
    [self setBackgroundColorEndTo:self.backgroundColorEnd.color];
}

- (void)setBackgroundColorEndTo:(NSColor *)color {
    [self.undoManager registerUndoWithTarget:self
                                    selector:@selector(setBackgroundColorEndTo:)
                                      object:self.document.screenshot.backgroundColorEnd];
    
    self.document.screenshot.backgroundColorEnd = color;
    self.backgroundColorEnd.color = color;
    [self generatePreview];
}

//

- (IBAction)changeDropShadowStrength:(NSSegmentedControl *)sender {
    [self setDropShadowStrengthTo:[NSString stringWithFormat:@"%lu",
                                   self.dropShadowStrength.selectedSegment]];
}

- (void)setDropShadowStrengthTo:(NSString *)strength {
    [self.undoManager registerUndoWithTarget:self
                                    selector:@selector(setDropShadowStrengthTo:)
                                      object:[NSString stringWithFormat:@"%lu", self.dropShadowStrength.selectedSegment]];
    
    self.document.screenshot.dropShadowStrength = [strength integerValue];
    self.dropShadowStrength.selectedSegment = self.document.screenshot.dropShadowStrength;
    [self generatePreview];
}

//

- (IBAction)changeDropShadowTarget:(NSSegmentedControl *)sender {
    [self setDropShadowTargetTo:[NSString stringWithFormat:@"%lu",
                                 self.dropShadowTarget.selectedSegment]];
}

- (void)setDropShadowTargetTo:(NSString *)target {
    [self.undoManager registerUndoWithTarget:self
                                    selector:@selector(setDropShadowTargetTo:)
                                      object:[NSString stringWithFormat:@"%lu", self.dropShadowTarget.selectedSegment]];
    
    self.document.screenshot.dropShadowTarget = [target integerValue];
    self.dropShadowTarget.selectedSegment = self.document.screenshot.dropShadowTarget;
    [self generatePreview];
}

#pragma NSTextViewDelegate
- (void)textDidChange:(NSNotification *)notification {
    self.document.screenshot.caption = self.caption.string;
    [self generatePreview];
}
@end
