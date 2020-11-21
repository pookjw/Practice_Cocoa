//
//  DetailViewController.h
//  Practice1
//
//  Created by Jinwoo Kim on 11/18/20.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface DetailViewController : NSViewController
@property (strong) IBOutlet NSImageView *imageView;
- (void)imageSelected:(NSString*)name;
@end

NS_ASSUME_NONNULL_END
