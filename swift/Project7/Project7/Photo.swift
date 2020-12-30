//
//  Photo.swift
//  Project7
//
//  Created by Jinwoo Kim on 12/29/20.
//

import Cocoa

class Photo: NSCollectionViewItem {
    
    let selectedBorderThickness: CGFloat = 3
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.wantsLayer = true
        view.layer?.borderColor = NSColor.blue.cgColor
    }
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                view.layer?.borderWidth = selectedBorderThickness
            } else {
                view.layer?.borderWidth = 0
            }
        }
    }
    
    override var highlightState: NSCollectionViewItem.HighlightState {
        didSet {
            if highlightState == .forSelection {
                view.layer?.borderWidth = selectedBorderThickness
            } else {
                if !isSelected {
                    view.layer?.borderWidth = 0
                }
            }
        }
    }
}
