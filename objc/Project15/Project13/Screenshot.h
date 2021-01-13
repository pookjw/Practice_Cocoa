//
//  Screenshot.h
//  Project13
//
//  Created by Jinwoo Kim on 1/11/21.
//

#import <Cocoa/Cocoa.h>

@interface Screenshot : NSObject
@property NSString *caption;
@property NSString *captionFontName;
@property NSInteger captionFontSize;
@property NSColor *captionColor;
@property NSString *backgroundImage;
@property NSColor *backgroundColorStart;
@property NSColor *backgroundColorEnd;
@property NSInteger dropShadowStrength;
@property NSInteger dropShadowTarget;
@end
