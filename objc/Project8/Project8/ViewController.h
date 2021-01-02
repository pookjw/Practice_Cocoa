//
//  ViewController.h
//  Project8
//
//  Created by Jinwoo Kim on 1/3/21.
//

#import <Cocoa/Cocoa.h>
#import "NSMutableArray+Shuffling.h"
#import "GameOverView.h"

@interface ViewController : NSViewController
@property NSVisualEffectView *visualEffectView;
@property NSMutableArray<NSButton *> *gridViewButtons;
@property NSUInteger gridSize;
@property CGFloat gridMargin;
@property NSMutableArray<NSString *> *images;
@property NSUInteger currentLevel;
@property GameOverView *gameOverView;
@end

