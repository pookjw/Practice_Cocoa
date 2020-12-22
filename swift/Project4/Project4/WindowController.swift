//
//  WindowController.swift
//  Project4
//
//  Created by Jinwoo Kim on 12/22/20.
//

import Cocoa

class WindowController: NSWindowController {
    @IBOutlet weak var addressEntry: NSTextField!
    
    override func windowDidLoad() {
        super.windowDidLoad()
        window?.titleVisibility = .hidden
    }

    override func cancelOperation(_ sender: Any?) {
        window?.makeFirstResponder(self.contentViewController)
    }
}
