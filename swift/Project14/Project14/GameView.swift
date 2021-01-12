//
//  GameView.swift
//  Project14
//
//  Created by Jinwoo Kim on 1/12/21.
//

import SpriteKit

class GameView: SKView {
    override func resetCursorRects() {
        super.resetCursorRects()
        
        if let targetImage = NSImage(named: "cursor") {
            let cursor = NSCursor(image: targetImage, hotSpot: CGPoint(x: targetImage.size.width / 2, y: targetImage.size.height / 2))
            addCursorRect(frame, cursor: cursor)
        }
    }
}
