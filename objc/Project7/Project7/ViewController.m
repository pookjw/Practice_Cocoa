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

//

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
