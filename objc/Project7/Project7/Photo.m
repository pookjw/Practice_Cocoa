//
//  Photo.m
//  Project7
//
//  Created by Jinwoo Kim on 12/30/20.
//

#import "Photo.h"

@implementation Photo

- (void)viewDidLoad {
    [super viewDidLoad];
    self.selectedBorderThickness = 3;
    self.view.wantsLayer = YES;
    self.view.layer.borderColor = NSColor.blueColor.CGColor;
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    if (selected) {
        self.view.layer.borderWidth = self.selectedBorderThickness;
    } else {
        self.view.layer.borderWidth = 0;
    }
}

- (void)setHighlightState:(NSCollectionViewItemHighlightState)highlightState {
    [super setHighlightState:highlightState];
    if (highlightState == NSCollectionViewItemHighlightForSelection) {
        self.view.layer.borderWidth = self.selectedBorderThickness;
    } else {
        if (!self.isSelected) {
            self.view.layer.borderWidth = 0;
        }
    }
}
@end
