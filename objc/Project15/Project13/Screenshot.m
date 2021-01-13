//
//  Screenshot.m
//  Project13
//
//  Created by Jinwoo Kim on 1/11/21.
//

#import "Screenshot.h"

@implementation Screenshot
- (instancetype)init {
    self = [super init];
    if (self) {
        self.caption = @"Your text here";
        self.captionFontName = @" HelveticaNeue-Medium";
        self.captionFontSize = 3;
        self.captionColor = NSColor.blackColor;
        self.backgroundImage = @"";
        self.backgroundColorStart = NSColor.clearColor;
        self.backgroundColorEnd = NSColor.clearColor;
        self.dropShadowStrength = 1;
        self.dropShadowTarget = 2;
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self.caption = (NSString *)[coder decodeObjectForKey:@"caption"];
    self.captionFontName = (NSString *)[coder decodeObjectForKey:@"captionFontName"];
    self.captionFontSize = [coder decodeIntForKey:@"captionFontSize"];
    self.captionColor = (NSColor *)[coder decodeObjectForKey:@"captionColor"];
    self.backgroundImage = (NSString *)[coder decodeObjectForKey:@"backgroundImage"];
    self.backgroundColorStart = (NSColor *)[coder decodeObjectForKey:@"backgroundColorStart"];
    self.backgroundColorEnd = (NSColor *)[coder decodeObjectForKey:@"backgroundColorEnd"];
    self.dropShadowStrength = [coder decodeIntForKey:@"dropShadowStrength"];
    self.dropShadowTarget = [coder decodeIntForKey:@"dropShadowTarget"];
    
    return self;
}

- (void)endodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.caption forKey:@"caption"];
    [coder encodeObject:self.captionFontName forKey:@"captionFontName"];
    [coder encodeInt:(int)self.captionFontSize forKey:@"captionFontSize"];
    [coder encodeObject:self.captionColor forKey:@"captionColor"];
    [coder encodeObject:self.backgroundImage forKey:@"backgroundImage"];
    [coder encodeObject:self.backgroundColorStart forKey:@"backgroundColorStart"];
    [coder encodeObject:self.backgroundColorEnd forKey:@"backgroundColorEnd"];
    [coder encodeInt:(int)self.dropShadowStrength forKey:@"dropShadowStrength"];
    [coder encodeInt:(int)self.dropShadowTarget forKey:@"dropShadowTarget"];
}
@end
