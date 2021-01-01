//
//  ViewController.h
//  Project7
//
//  Created by Jinwoo Kim on 12/30/20.
//

#import <Cocoa/Cocoa.h>
#import <AVFoundation/AVFoundation.h>
#import "NSMutableArray+moveItem.h"
#import "Photo.h"

@interface ViewController : NSViewController <NSCollectionViewDataSource, NSCollectionViewDelegate> {
    @private NSURL *_photoDirectory;
}
@property (weak) IBOutlet NSCollectionView *collectionView;
@property (nonatomic) NSURL *photoDirectory;
@property NSMutableArray<NSURL *> *photos;
@property NSSet<NSIndexPath *> *itemBeingDragged;
@end

