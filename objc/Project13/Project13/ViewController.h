//
//  ViewController.h
//  Project13
//
//  Created by Jinwoo Kim on 1/11/21.
//

#import <Cocoa/Cocoa.h>
#import "Document.h"
#import "Screenshot.h"

@interface ViewController : NSViewController <NSTextViewDelegate>
@property (readonly) Document *document;
@property NSImage *screenshotImage;
@property (weak) IBOutlet NSImageView *imageView;
@property (unsafe_unretained) IBOutlet NSTextView *caption;
@property (weak) IBOutlet NSPopUpButton *fontName;
@property (weak) IBOutlet NSPopUpButton *fontSize;
@property (weak) IBOutlet NSColorWell *fontColor;
@property (weak) IBOutlet NSPopUpButton *backgroundImage;
@property (weak) IBOutlet NSColorWell *backgroundColorStart;
@property (weak) IBOutlet NSColorWell *backgroundColorEnd;
@property (weak) IBOutlet NSSegmentedControl *dropShadowStrength;
@property (weak) IBOutlet NSSegmentedControl *dropShadowTarget;
@end

