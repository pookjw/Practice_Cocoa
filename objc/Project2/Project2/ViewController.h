//
//  ViewController.h
//  Project2
//
//  Created by Jinwoo Kim on 11/22/20.
//

#import <Cocoa/Cocoa.h>

@interface ViewController : NSViewController <NSTableViewDataSource, NSTableViewDelegate>
@property (strong) IBOutlet NSTableView *tableView;
@property (strong) IBOutlet NSTextField *guess;
@property (strong) IBOutlet NSButton *submitGuess;
@property NSString *answer;
@property NSMutableArray<NSString *> *guesses;
@end

