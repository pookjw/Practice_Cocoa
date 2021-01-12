//
//  GameView.m
//  Project14
//
//  Created by Jinwoo Kim on 1/12/21.
//

#import "GameView.h"

@implementation GameView

- (void)resetCursorRects {
    [super resetCursorRects];
    
    NSImage *targetImage = [NSImage imageNamed:@"cursor"];
    if (targetImage) {
        NSCursor *cursor = [[NSCursor alloc] initWithImage:targetImage
                                                   hotSpot:NSMakePoint(targetImage.size.width / 2, targetImage.size.height / 2)];
        
        [self addCursorRect:self.frame cursor:cursor];
    }
}

@end
