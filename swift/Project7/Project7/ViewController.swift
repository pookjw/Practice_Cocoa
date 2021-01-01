//
//  ViewController.swift
//  Project7
//
//  Created by Jinwoo Kim on 12/29/20.
//

import Cocoa
import AVFoundation

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
    
    func exportFinished(error: Error?) {
        let message: String
        
        if let error = error {
            message = "Error: \(error.localizedDescription)"
        } else {
            message = "Success!"
        }
        
        let alert = NSAlert()
        alert.messageText = message
        alert.runModal()
    }
    
    func createText(frame: CGRect) -> CALayer {
        // create a dictionary of text attributes
        let attrs = [NSAttributedString.Key.font: NSFont.boldSystemFont(ofSize: 24),
                     NSAttributedString.Key.foregroundColor: NSColor.green]
        
        // combine those attributes with our message
        let text = NSAttributedString(string: "Copyright © 2017 Hacking with Swift", attributes: attrs)
        
        // figure out how big the full string is
        let textSize = text.size()
        
        // create the text layer
        let textLayer = CATextLayer()
        
        // make the text layer the correct size
        textLayer.bounds = CGRect(origin: .zero, size: textSize)
        
        // make it align itself by its bottom-right corner
        // https://rhammer.tistory.com/316
        textLayer.anchorPoint = CGPoint(x: 1, y: 1)
        
        // position it just up from the bottom-right of the render frame
        textLayer.position = CGPoint(x: frame.maxX - 10, y: textSize.height + 10)
        
        // give it the attributed string we created
        textLayer.string = text
        
        // force it to render immediately
        textLayer.display()
        
        // send it back to be added to the final render
        return textLayer
    }
    
    func createSlideshow(frame: CGRect, duration: CFTimeInterval) -> CALayer {
        // create the layer for our slideshow
        let imageLayer = CALayer()
        
        // position it so it fills its space and is centered
        imageLayer.bounds = frame
        imageLayer.position = CGPoint(x: imageLayer.bounds.midX, y: imageLayer.bounds.midY)
        
        // make it stretch its contents to fit
        imageLayer.contentsGravity = .resizeAspectFill
        
        // create a keyframe animation of the `contents` property
        let fadeAnim = CAKeyframeAnimation(keyPath: "contents")
        
        // tell it to last as long as we need
        fadeAnim.duration = duration
        
        // configure the properties as mentioned above
        fadeAnim.isRemovedOnCompletion = false
        fadeAnim.beginTime = AVCoreAnimationBeginTimeAtZero
        
        // prepare an array of all the `NSImage` objects we want to show
        var values = [NSImage]()
        
        // loop through every photo, adding it twice so we're not constantly animating
        for photo in photos {
            if let image = NSImage(contentsOfFile: photo.path) {
                values.append(image)
                values.append(image)
            }
        }
        
        // assign that array to the animation
        fadeAnim.values = values
        
        // then add the animation to the layer
        imageLayer.add(fadeAnim, forKey: nil)
        
        return imageLayer
    }
    
    func createVideoLayer(in parentLayer: CALayer, composition: AVMutableComposition, videoComposition: AVMutableVideoComposition, timeRange: CMTimeRange) -> CALayer {
        // create a layer for the video
        let videoLayer = CALayer()
        
        // configure our post-processing animation tool
        videoComposition.animationTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: videoLayer, in: parentLayer)
        
        // prepare to add the black.mp4 video
        let mutableCompositionVideoTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
        
        // find and load the black.mp4 video
        let trackURL = Bundle.main.url(forResource: "black", withExtension: "mp4")!
        let asset = AVAsset(url: trackURL)
        
        // pull out its video
        let track = asset.tracks[0]
        
        // insert it into the track, filling all the time we need
        try! mutableCompositionVideoTrack?.insertTimeRange(timeRange, of: track, at: .zero)
        
        // send the video layer back
        return videoLayer
    }
    
    func exportMovie(at size: NSSize) throws {
        // 1: we're going to hard code the video 8 seconds
        let videoDuration = 8.0
        let timeRange = CMTimeRange(start: .zero, duration: CMTime(seconds: videoDuration, preferredTimescale: 600))
        
        // 2: create a URL we can save our video to, then delete it if it already exists
        let savePath = photosDirectory.appendingPathComponent("video.mp4")
        let fm = FileManager.default
        
        if fm.fileExists(atPath: savePath.path) {
            try fm.removeItem(at: savePath)
        }
        
        // 3: create a composition for our entire render
        let mutableComposition = AVMutableComposition()
        
        // 4: create a video composition for our post-processing video work (this is the only thing we're doing)
        let videoComposition = AVMutableVideoComposition()
        videoComposition.renderSize = size
        videoComposition.frameDuration = CMTime(value: 1, timescale: 30)
        
        // 5: create a master `CALayer` that will hold all the child layers
        let parentLayer = CALayer()
        parentLayer.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        
        // 6: add all three child layers to the master layer
        parentLayer.addSublayer(createVideoLayer(in: parentLayer, composition: mutableComposition, videoComposition: videoComposition, timeRange: timeRange))
        parentLayer.addSublayer(createSlideshow(frame: parentLayer.frame, duration: videoDuration))
        parentLayer.addSublayer(createText(frame: parentLayer.frame))
        
        // 7: create video rendering instructions saying how long a video we want
        let instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = timeRange
        videoComposition.instructions = [instruction]
        
        // 8: create an export session for our whole composition, requesting maximum quality
        let exportSession = AVAssetExportSession(asset: mutableComposition, presetName: AVAssetExportPresetHighestQuality)!
        
        // 9: point the export session at the URL to our save file, pass it the post-processing work, and ask for an MPEG4 in return
        exportSession.outputURL = savePath
        exportSession.videoComposition = videoComposition
        exportSession.outputFileType = .mp4
        
        // 10: start the export
        exportSession.exportAsynchronously { [unowned self] in
            DispatchQueue.main.async {
                // the export has finished - call `exportFinished()`
                self.exportFinished(error: exportSession.error)
            }
        }
    }
    
    @IBAction func runExport(_ sender: NSMenuItem) {
        let size: CGSize
        
        if sender.tag == 720 {
            size = CGSize(width: 1280, height: 720)
        } else {
            size = CGSize(width: 1920, height: 1080)
        }
        
        do {
            try exportMovie(at: size)
        } catch {
            print("Error")
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
