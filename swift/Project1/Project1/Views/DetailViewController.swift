//
//  DetailViewController.swift
//  Project1
//
//  Created by Jinwoo Kim on 11/18/20.
//

import Cocoa

class DetailViewController: NSViewController {
    @IBOutlet var imageView: NSImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    func imageSelected(name: String) {
        imageView.image = NSImage(named: name)
    }
}
