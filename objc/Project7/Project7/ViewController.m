//
//  ViewController.m
//  Project7
//
//  Created by Jinwoo Kim on 12/30/20.
//

#import "ViewController.h"

@implementation ViewController

@synthesize photoDirectory = _photoDirectory;
- (NSURL *)photoDirectory {
    NSFileManager *fm = NSFileManager.defaultManager;
    NSArray<NSURL *> *paths = [fm URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    NSURL *documentDirectory = paths[0];
    NSURL *saveDirectory = [documentDirectory URLByAppendingPathComponent:@"SlideMark"];
    
    if (![fm fileExistsAtPath:saveDirectory.path]) {
        [fm createDirectoryAtURL:saveDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return saveDirectory;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.photos = [@[] mutableCopy];
    
    [self.collectionView registerForDraggedTypes:@[NSPasteboardTypeURL]];
    
    NSFileManager *fm = NSFileManager.defaultManager;
    NSLog(@"%@", self.photoDirectory.path);
    NSArray<NSURL *> *files = [fm contentsOfDirectoryAtURL:self.photoDirectory includingPropertiesForKeys:nil options:0 error:nil];
    
    for (NSURL *file in files) {
        if ([file.pathExtension isEqualTo:@"jpg"] || [file.pathExtension isEqualTo:@"png"]) {
            [self.photos addObject:file];
        }
    }
}

- (void)keyUp:(NSEvent *)event {
    // bail out if we don't have any selected items
    if (self.collectionView.selectionIndexPaths.count <= 0) return;
    
    // convert the integer to a Unicode scalar, then to a string
    if ([event.charactersIgnoringModifiers isEqualTo:[NSString stringWithFormat:@"%c", NSDeleteCharacter]]) {
        NSFileManager *fm = NSFileManager.defaultManager;
        
        NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"item" ascending:YES];
        NSArray<NSIndexPath *> *deleteItems = [self.collectionView.selectionIndexPaths sortedArrayUsingDescriptors:[NSArray arrayWithObject:descriptor]];
        
        // loop over the selected items in reverse sorted order
        for (NSIndexPath *indexPath in deleteItems) {
            [fm trashItemAtURL:self.photos[indexPath.item] resultingItemURL:nil error:nil];
            [self.photos removeObjectAtIndex:indexPath.item];
        }
        
        // remove the items from the collection view
        [[self.collectionView animator] deleteItemsAtIndexPaths:self.collectionView.selectionIndexPaths];
    }
}

- (void)exportFinishedWithError:(NSError * _Nullable)error {
    NSString *message;
    
    if (error != nil) {
        message = [NSString stringWithFormat:@"Error: %@", error.localizedDescription];
    } else {
        message = @"Success";
    }
    
    NSAlert *alert = [NSAlert new];
    alert.messageText = message;
    [alert runModal];
}

- (CALayer *)createTextWithFrame:(CGRect)frame {
    // create a dictionary of text attributes
    NSDictionary<NSAttributedStringKey, id> *attrs = @{
        NSFontAttributeName: [NSFont boldSystemFontOfSize:24],
        NSForegroundColorAttributeName: [NSColor greenColor]
    };
    
    // combine those attributes with our message
    NSAttributedString *text = [[NSAttributedString alloc]
                                initWithString:@"Copyright © 2017 Hacking with Swift"
                                attributes:attrs];
    
    // figure out how big the full string is
    NSSize textSize = [text size];
    
    // create the text layer
    CATextLayer *textLayer = [CATextLayer new];
    
    // make the text layer the correct size
    textLayer.bounds = CGRectMake(0, 0, textSize.width, textSize.height);
    
    // make it align itself by its bottom-right corner
    // https://rhammer.tistory.com/316
    textLayer.anchorPoint = CGPointMake(1, 1);
    
    // position it just up from the bottom-right of the render frame
    textLayer.position = CGPointMake(CGRectGetMaxX(frame), textSize.height + 10);
    
    // give it the attributed string we created
    textLayer.string = text;
    
    // force it to render immediately
    [textLayer display];
    
    return textLayer;
}

- (CALayer *)createSlideshowWithFrame:(CGRect)frame duration:(CFTimeInterval)duration {
    // create the layer for our slideshow
    CALayer *imageLayer = [CALayer new];
    
    // position it so it fills its space and is centered
    imageLayer.bounds = frame;
    imageLayer.position = CGPointMake(CGRectGetMidX(imageLayer.bounds), CGRectGetMidY(imageLayer.bounds));
    
    // make it stretch its contents to fit
    imageLayer.contentsGravity = kCAGravityResizeAspectFill;
    
    // create a keyframe animation of the `contents` property
    CAKeyframeAnimation *fadeAnim = [CAKeyframeAnimation animationWithKeyPath:@"contents"];
    
    // tell it to last as long as we need
    fadeAnim.duration = duration;
    
    // configure the properties as mentioned above
    fadeAnim.removedOnCompletion = NO;
    fadeAnim.beginTime = AVCoreAnimationBeginTimeAtZero;
    
    // prepare an array of all the `NSImage` objects we want to show
    NSMutableArray<NSImage *> *values = [@[] mutableCopy];
    
    // loop through every photo, adding it twice so we're not constantly animating
    for (NSURL *photo in self.photos) {
        NSImage *image = [[NSImage alloc] initWithContentsOfURL:photo];
        if (image != nil) {
            [values addObject:image];
        }
    }
    
    // assign that array to the animation
    fadeAnim.values = values;
    
    // then add the animation to the layer
    [imageLayer addAnimation:fadeAnim forKey:nil];
    
    return imageLayer;
}

- (CALayer *)createVideoLayerIn:(CALayer *)parentLayer
                    composition:(AVMutableComposition *)composition
               videoComposition:(AVMutableVideoComposition *)videoComposition
                      timeRange:(CMTimeRange)timeRange {
    // create a layer for the video
    CALayer *videoLayer = [CALayer new];
    
    // configure our post-procesing animation tool
    videoComposition.animationTool = [AVVideoCompositionCoreAnimationTool
                                      videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer
                                      inLayer:parentLayer];
    
    // prepare to add the black.mp4 video
    AVMutableCompositionTrack *mutableCompositionVideoTrack = [composition
                                                          addMutableTrackWithMediaType:AVMediaTypeVideo
                                                          preferredTrackID:kCMPersistentTrackID_Invalid];
    
    // find and load the black.mp4 video
    NSURL *trackURL = [[NSBundle mainBundle] URLForResource:@"black" withExtension:@"mp4"];
    AVAsset *asset = [AVAsset assetWithURL:trackURL];
    
    // pull out its video
    AVAssetTrack *track = asset.tracks[0];
    
    // insert it into the track, filling all the time we need
    [mutableCompositionVideoTrack insertTimeRange:timeRange ofTrack:track atTime:kCMTimeZero error:nil];
    
    // send the video layer back
    return videoLayer;
}

- (void)exportMovieAt:(NSSize)size withError:(NSError **)error{
    // 1: we're going to hard code the video 8 seconds
    double videoDuration = 8.0;
    CMTimeRange timeRange = CMTimeRangeMake(kCMTimeZero, CMTimeMakeWithSeconds(videoDuration, 600));
    
    // 2: create a URL we can save our video to, then delete it if it already exists
    NSURL *savePath = [self.photoDirectory URLByAppendingPathComponent:@"video.mp4"];
    NSFileManager *fm = NSFileManager.defaultManager;
    
    if ([fm fileExistsAtPath:savePath.path]) {
        [fm removeItemAtURL:savePath error:error];
    }
    
    // 3: create a composition for our entire render
    AVMutableComposition *mutableComposition = [AVMutableComposition new];
    
    // 4: create a video composition for our post-processing video work (this is the only thing we're doing)
    AVMutableVideoComposition *videoComposition = [AVMutableVideoComposition new];
    videoComposition.renderSize = size;
    videoComposition.frameDuration = CMTimeMake(1, 30);
    
    // 5: create a master `CALayer` that will hold all the child layers
    CALayer *parentLayer = [CALayer new];
    parentLayer.frame = CGRectMake(0, 0, size.width, size.height);
    
    // 6: add all three child layers to the master layer
    [parentLayer addSublayer:[self createVideoLayerIn:parentLayer
                                          composition:mutableComposition
                                     videoComposition:videoComposition
                                            timeRange:timeRange]];
    [parentLayer addSublayer:[self createSlideshowWithFrame:parentLayer.frame duration:videoDuration]];
    [parentLayer addSublayer:[self createTextWithFrame:parentLayer.frame]];
    
    // 7: create video rendering instructions saying how long a video we want
    AVMutableVideoCompositionInstruction *instruction = [AVMutableVideoCompositionInstruction new];
    instruction.timeRange = timeRange;
    videoComposition.instructions = @[instruction];
    
    // 8: create an export session for our whole composition, requesting maximum quality
    AVAssetExportSession *exportSession = [AVAssetExportSession exportSessionWithAsset:mutableComposition presetName:AVAssetExportPresetHighestQuality];
    
    // 9: point the export session at the URL to our save file, pass it the post-processing work, and ask for an MPEG4 in return
    exportSession.outputURL = savePath;
    exportSession.videoComposition = videoComposition;
    exportSession.outputFileType = AVFileTypeMPEG4;
    
    __weak ViewController *weakSelf = self;
    // 10: start the export
    [exportSession exportAsynchronouslyWithCompletionHandler:^() {
        dispatch_async(dispatch_get_main_queue(), ^{
            // the export has finished - call `exportFinishedWithError:`
            [weakSelf exportFinishedWithError:exportSession.error];
        });
    }];
}

- (IBAction)runExport:(NSMenuItem *)sender {
    CGSize size;
    
    if (sender.tag == 720) {
        size = CGSizeMake(1280, 720);
    } else {
        size = CGSizeMake(1920, 1080);
    }
    
    NSError *error = nil;
    [self exportMovieAt:size withError:&error];
    if (error != nil) NSLog(@"Error");
}

#pragma mark NSCollectionViewDataSource, NSCollectionViewDelegate

- (NSInteger)collectionView:(NSCollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section
{
    return self.photos.count;
}

- (NSCollectionViewItem *)collectionView:(NSCollectionView *)collectionView
     itemForRepresentedObjectAtIndexPath:(NSIndexPath *)indexPath
{
    NSCollectionViewItem *item = [collectionView makeItemWithIdentifier:@"Photo" forIndexPath:indexPath];
    Photo *pictureItem = (Photo *)item;
    
    if (pictureItem == nil) return nil;
    
    NSData *data = [[NSData alloc] initWithContentsOfFile:self.photos[indexPath.item].path];
    NSImage *image = [[NSImage alloc] initWithData:data];
    pictureItem.imageView.image = image;
    
    return pictureItem;
}

- (NSDragOperation)collectionView:(NSCollectionView *)collectionView
                     validateDrop:(id<NSDraggingInfo>)draggingInfo
                proposedIndexPath:(NSIndexPath * _Nonnull __autoreleasing *)proposedDropIndexPath dropOperation:(NSCollectionViewDropOperation *)proposedDropOperation
{
    return NSDragOperationMove;
}

- (void)collectionView:(NSCollectionView *)collectionView
       draggingSession:(NSDraggingSession *)session
      willBeginAtPoint:(NSPoint)screenPoint
  forItemsAtIndexPaths:(NSSet<NSIndexPath *> *)indexPaths
{
    self.itemBeingDragged = indexPaths;
}

- (void)collectionView:(NSCollectionView *)collectionView
       draggingSession:(NSDraggingSession *)session
          endedAtPoint:(NSPoint)screenPoint
         dragOperation:(NSDragOperation)operation
{
    self.itemBeingDragged = nil;
}

- (BOOL)collectionView:(NSCollectionView *)collectionView
            acceptDrop:(id<NSDraggingInfo>)draggingInfo
             indexPath:(NSIndexPath *)indexPath
         dropOperation:(NSCollectionViewDropOperation)dropOperation
{
    if (self.itemBeingDragged != nil) {
        // this is an internal drag
        NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"item" ascending:YES];
        NSArray<NSIndexPath *> *moveItems = [self.itemBeingDragged sortedArrayUsingDescriptors:[NSArray arrayWithObject:descriptor]];
        [self performInternalDragWith:moveItems to:indexPath];
    } else {
        // this is an external drag
        NSPasteboard *pasteboard = draggingInfo.draggingPasteboard;
        NSArray<NSPasteboardItem *> *items = pasteboard.pasteboardItems;
        if (items == nil) return YES;
        [self performExternalDragWith:items at:indexPath];
    }
    
    return YES;
}

- (void)performInternalDragWith:(NSArray<NSIndexPath *> *)items to:(NSIndexPath *)indexPath {
    // keep track of where we're moving to
    NSUInteger targetIndex = indexPath.item;
    
    for (NSIndexPath *fromIndexPath in items) {
        // figure out where we're moving from
        NSUInteger fromItemIndex = fromIndexPath.item;
        
        // this is a move toward the front of the array
        if (fromItemIndex > targetIndex) {
            // call our array extension to perform the move
            [self.photos moveItemFrom:fromItemIndex to:targetIndex];
            
            // move it in the collection view too
            [self.collectionView moveItemAtIndexPath:[NSIndexPath indexPathForItem:fromItemIndex inSection:0]
                                         toIndexPath:[NSIndexPath indexPathForItem:targetIndex inSection:0]];
            
            // update our destination position
            targetIndex += 1;
        }
    }
    
    // reset the target position - we want to move to the slot before the item the user chose
    targetIndex = indexPath.item - 1;
    
    // loop backwards over our items
    for (NSIndexPath *fromIndexPath in [items reverseObjectEnumerator]) {
        NSUInteger fromItemIndex = fromIndexPath.item;
        
        // this is a move toward the back of the array
        if (fromItemIndex < targetIndex) {
            // call our array extension to perform the move
            [self.photos moveItemFrom:fromItemIndex to:targetIndex];
            
            // move it in the collection view too
            [self.collectionView moveItemAtIndexPath:[NSIndexPath indexPathForItem:fromItemIndex inSection:0]
                                         toIndexPath:[NSIndexPath indexPathForItem:targetIndex inSection:0]];
            
            // update our destination position
            targetIndex -= 1;
        }
    }
}

- (void)performExternalDragWith:(NSArray<NSPasteboardItem *> *)items at:(NSIndexPath *)indexPath {
    NSFileManager *fm = NSFileManager.defaultManager;
    
    // 1. loop over every item on the drag and drop pasteboard
    for (NSPasteboardItem *item in items) {
        // 2. pull out the string containing the URL for this item
        NSString *stringURL = [item stringForType:NSPasteboardTypeFileURL];
        if (stringURL == nil) continue;
        
        // 3. attempt to convert the string into a real URL
        NSURL *sourceURL = [NSURL URLWithString:stringURL];
        if (sourceURL == nil) continue;
        
        // 4. create a destination URL by combining `photoDirectory` with the last path component
        NSURL *destinationURL = [self.photoDirectory URLByAppendingPathComponent:sourceURL.lastPathComponent];
        
        [fm copyItemAtURL:sourceURL toURL:destinationURL error:nil];
        
        // 6. update the array and collection view
        [self.photos insertObject:destinationURL atIndex:indexPath.item];
        [self.collectionView insertItemsAtIndexPaths:[[NSSet alloc] initWithArray:@[indexPath]]];
    }
}

- (id<NSPasteboardWriting>)collectionView:(NSCollectionView *)collectionView pasteboardWriterForItemAtIndexPath:(NSIndexPath *)indexPath {
    return (id<NSPasteboardWriting>)self.photos[indexPath.item];
}
@end
