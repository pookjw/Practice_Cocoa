//
//  ViewController.swift
//  Project7
//
//  Created by Jinwoo Kim on 12/29/20.
//

import Cocoa

class ViewController: NSViewController {
    @IBOutlet weak var collectionView: NSCollectionView!
    
    lazy var photosDirectory: URL = {
        let fm = FileManager.default
        let paths = fm.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = paths[0]
        let saveDirectory = documentDirectory.appendingPathComponent("SlideMark")
        
        if !fm.fileExists(atPath: saveDirectory.path) {
            try? fm.createDirectory(at: saveDirectory, withIntermediateDirectories: true)
        }
        
        return saveDirectory
    }()
    
    var photos = [URL]()
    
    var itemsBeingDragged: Set<IndexPath>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.registerForDraggedTypes([NSPasteboard.PasteboardType(kUTTypeURL as String)])
//        collectionView.registerForDraggedTypes([NSPasteboard.PasteboardType.URL])

        do {
            let fm = FileManager.default
            print(photosDirectory.path)
            let files = try fm.contentsOfDirectory(at: photosDirectory, includingPropertiesForKeys: nil)
            
            for file in files {
                if file.pathExtension == "jpg" || file.pathExtension == "png" {
                    photos.append(file)
                }
            }
        } catch {
            // failed to read the save directory
            print("Set up error")
        }
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    //
    
    override func keyUp(with event: NSEvent) {
        // bail out if we don't have any selected items
        guard collectionView.selectionIndexPaths.count > 0 else { return }
        
        // convert the integer to a Unicode scalar, then to a string
        if event.charactersIgnoringModifiers == String(UnicodeScalar(NSDeleteCharacter)!) {
            let fm = FileManager.default
            
            // loop over the selected items in reverse sorted order
            for indexPath in collectionView.selectionIndexPaths.sorted() {
                do {
                    // move this item to the trash and remove it from the array
                    try fm.trashItem(at: photos[indexPath.item], resultingItemURL: nil)
                    photos.remove(at: indexPath.item)
                } catch {
                    print("Failed to delete \(photos[indexPath.item])")
                }
            }
            
            // remove the items from the collection view
            collectionView.animator().deleteItems(at: collectionView.selectionIndexPaths)
        }
    }
}

extension ViewController: NSCollectionViewDataSource, NSCollectionViewDelegate {
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier("Photo"), for: indexPath)
        guard let pictureItem = item as? Photo else { return item }
        
//        pictureItem.view.wantsLayer = true
//        pictureItem.view.layer?.backgroundColor = NSColor.red.cgColor
        
        let image = NSImage(contentsOf: photos[indexPath.item])
        pictureItem.imageView?.image = image
        
        return pictureItem
    }
    
    func collectionView(_ collectionView: NSCollectionView, validateDrop draggingInfo: NSDraggingInfo, proposedIndexPath proposedDropIndexPath: AutoreleasingUnsafeMutablePointer<NSIndexPath>, dropOperation proposedDropOperation: UnsafeMutablePointer<NSCollectionView.DropOperation>) -> NSDragOperation {
        return .move
    }
    
    func collectionView(_ collectionView: NSCollectionView, draggingSession session: NSDraggingSession, willBeginAt screenPoint: NSPoint, forItemsAt indexPaths: Set<IndexPath>) {
        print(#function)
        itemsBeingDragged = indexPaths
    }
    
    func collectionView(_ collectionView: NSCollectionView, draggingSession session: NSDraggingSession, endedAt screenPoint: NSPoint, dragOperation operation: NSDragOperation) {
        print(#function)
        itemsBeingDragged = nil
    }
    
    func collectionView(_ collectionView: NSCollectionView, acceptDrop draggingInfo: NSDraggingInfo, indexPath: IndexPath, dropOperation: NSCollectionView.DropOperation) -> Bool {
        print(draggingInfo.draggingPasteboard.string(forType: NSPasteboard.PasteboardType(kUTTypeFileURL as String)) ?? "nil")
        print(#function)
        if let moveItems = itemsBeingDragged?.sorted() {
            // this is an internal drag
            performInternalDrag(with: moveItems, to: indexPath)
        } else {
            // this is an external drag
            let pasteboard = draggingInfo.draggingPasteboard
            guard let items = pasteboard.pasteboardItems else { return true }
            performExternalDrag(with: items, at: indexPath)
        }
        
        return true
    }
    
    func performInternalDrag(with items: [IndexPath], to indexPath: IndexPath) {
        // keep track of where we're moving to
        var targetIndex = indexPath.item
        for fromIndexPath in items {
            // figure out where we're moving from
            let fromItemIndex = fromIndexPath.item
            
            // this is a move toward the front of the array
            if (fromItemIndex > targetIndex) {
                // call our array extension to perform the move
                photos.moveItem(from: fromItemIndex, to: targetIndex)
                
                // move it in the collection view too
                collectionView.moveItem(at: IndexPath(item: fromItemIndex, section: 0), to: IndexPath(item: targetIndex, section: 0))
                
                // update our destination position
                targetIndex += 1
            }
        }
        
        // reset the target position - we want to move to the slot before the item the user chose
        targetIndex = indexPath.item - 1
        
        // loop backwards over our items
        for fromIndexPath in items.reversed() {
            let fromItemIndex = fromIndexPath.item
            
            // this is a move toward the back of the array
            if (fromItemIndex < targetIndex) {
                // call our array extension to perform the move
                photos.moveItem(from: fromItemIndex, to: targetIndex)
                
                // move it in the collection view too
                let targetIndexPath = IndexPath(item: targetIndex, section: 0)
                collectionView.moveItem(at: IndexPath(item: fromItemIndex, section: 0), to: targetIndexPath)
                
                // update our destination position
                targetIndex -= 1
            }
        }
    }
    
    func performExternalDrag(with items: [NSPasteboardItem], at indexPath: IndexPath) {
        let fm = FileManager.default
        
        // 1. loop over every item on the drag and drop pasteboard
        for item in items {
            // 2. pull out the string containing the URL for this item
            guard let stringURL = item.string(forType: NSPasteboard.PasteboardType(kUTTypeFileURL as String)) else { continue }
            
            // 3. attempt to convert the string into a real URL
            guard let sourceURL = URL(string: stringURL) else { continue }
            
            // 4. create a destination URL by combining `photosDirectory` with the last path component
            let destinationURL = photosDirectory.appendingPathComponent(sourceURL.lastPathComponent)
            
            do {
                // 5. attempt to copy the file to our app's folder
                try fm.copyItem(at: sourceURL, to: destinationURL)
            } catch {
                print("Could not copy \(sourceURL)")
            }
            
            // 6. update the array and collection view
            photos.insert(destinationURL, at: indexPath.item)
            collectionView.insertItems(at: [indexPath])
        }
    }
    
    func collectionView(_ collectionView: NSCollectionView, pasteboardWriterForItemAt indexPath: IndexPath) -> NSPasteboardWriting? {
        return photos[indexPath.item] as NSPasteboardWriting?
    }
}
