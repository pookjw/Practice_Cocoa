//
//  ViewController.h
//  Project4
//
//  Created by Jinwoo Kim on 12/22/20.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
#import "WindowController.h"
#import "NSTouchBarItemProjectIdentifiers.h"

@interface ViewController : NSViewController <WKNavigationDelegate, NSGestureRecognizerDelegate, NSTouchBarDelegate, NSSharingServicePickerTouchBarItemDelegate>
@property (strong) NSStackView *rows;
@property (strong) WKWebView *selectedWebView;
@end

