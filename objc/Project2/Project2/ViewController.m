//
//  ViewController.m
//  Project2
//
//  Created by Jinwoo Kim on 11/22/20.
//

#import "ViewController.h"

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.answer = @"";
    self.guesses = [@[] mutableCopy];
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

- (IBAction)submitGuess:(id)sender {
    NSString *guessString = self.guess.stringValue;
    NSMutableArray<NSString *> *guessArray = @[].mutableCopy;
    [guessString enumerateSubstringsInRange:NSMakeRange(0, guessString.length)
                                    options:NSStringEnumerationByComposedCharacterSequences
                                 usingBlock:^(NSString * _Nullable substring, NSRange substringRange, NSRange enclosingRange, BOOL * _Nonnull stop) {
                [guessArray addObject:substring];
    }];
    NSSet *guessSet = [NSSet setWithArray:guessArray];
    
//    NSLog(@"%@", guessSet);
    if ([guessSet count] != 4) return;
    if ([guessArray count] != 4) return;
    
    NSCharacterSet *badCharacters = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet];
    NSRange range = [guessString rangeOfCharacterFromSet:badCharacters];
    if (range.length != 0) return;
    
    [self.guesses insertObject:guessString atIndex:0];
    [self.tableView insertRowsAtIndexes:[NSIndexSet indexSetWithIndex:0] withAnimation:NSTableViewAnimationSlideDown];
    
    NSString *resultString = [self resultFor:guessString];
//    if ([guessArray containsObject:resultString]) {
        NSAlert *alert = [NSAlert new];
        alert.messageText = @"You win";
        alert.informativeText = @"Congratulations! Click OK to play again.";
        [alert runModal];
        [self startNewGame];
//    }
}

-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return [self.guesses count];
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSTableCellView *vw = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];
    
    if (vw == nil) return nil;
    
    if ([tableColumn isEqual:@"Guess"]) {
        vw.textField.stringValue = self.guesses[row];
    } else {
        vw.textField.stringValue = [self resultFor:self.guesses[row]];
    }
    
    return vw;
}

- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row {
    return NO;
}

- (NSString *)resultFor:(NSString* )guess {
    __block int bulls = 0;
    __block int cows = 0;
    
    NSArray<NSString *> *guessLetters = [guess componentsSeparatedByString:@""];
    NSArray<NSString *> *answerLetters = [self.answer componentsSeparatedByString:@""];
    
    [guessLetters enumerateObjectsUsingBlock:^(NSString *letter, NSUInteger idx, BOOL *stop) {
        if ([letter isEqual:answerLetters[idx]]) {
            bulls += 1;
        } else if ([answerLetters containsObject:letter]) {
            cows += 1;
        }
    }];
    
    return [NSString stringWithFormat:@"%db %dc", bulls, cows];
}

- (void)startNewGame {
    self.guess.stringValue = @"";
    [self.guesses removeAllObjects];
    
    NSMutableArray<NSNumber *> *numbers = [@[] mutableCopy];
    
    for (int i=0; i<10; i++) {
        [numbers addObject:[NSNumber numberWithInt:i]];
    }
    
    for (int i=0; i<4; i++) {
        int randomIndex = arc4random_uniform((int)[numbers count]);
        int randomNumber = [numbers[randomIndex] intValue];
        [numbers removeObjectAtIndex:randomIndex];
        self.answer = [self.answer stringByAppendingFormat:@"%d", randomNumber];
    }
    
    [self.tableView reloadData];
}

@end
