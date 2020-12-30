//
//  ViewController.swift
//  Project6
//
//  Created by Jinwoo Kim on 12/29/20.
//

import Cocoa

class ViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
//        createVFL()
//        createAnchors()
//        createStackView()
//        createStackView2()
        createGridView()
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    func makeView(_ number: Int) -> NSView {
        let vw = NSTextField(labelWithString: "View #\(number)")
        vw.translatesAutoresizingMaskIntoConstraints = false
        vw.alignment = .center
        vw.wantsLayer = true
        vw.layer?.backgroundColor = NSColor.cyan.cgColor
        return vw
    }
    
    func createVFL() {
        // set up a dictionary of strings and views
        let textFields: [String: NSView] = [
            "view0": makeView(0),
            "view1": makeView(1),
            "view2": makeView(2),
            "view3": makeView(3)
        ]
        
        // loop over each item
        for (name, textField) in textFields {
            // add it to our view
            view.addSubview(textField)
            
            // add horizontal contraints saying that this view should stretch from edge to edge
            view.addConstraints(
                NSLayoutConstraint.constraints(
                    withVisualFormat: "H:|[\(name)]|",
                    options: [],
                    metrics: nil,
                    views: textFields
                )
            )
        }
        
        // add another set of constraints that cause the views to be aligned vertically, one above the other
        view.addConstraints(
            NSLayoutConstraint.constraints(
                withVisualFormat: "V:|[view0]-[view1]-[view2]-[view3]|",
                options: [],
                metrics: nil,
                views: textFields
            )
        )
    }
    
    func createAnchors() {
        // create a variable to track the previous view we placed
        var previous: NSView!
        
        // create four views and put them into an array
        let views = [makeView(0), makeView(1), makeView(2), makeView(3)]
        
        for vw in views {
            // add this child to our main view, making it fill the horizontal space and be 88 points high
            view.addSubview(vw)
            
            vw.widthAnchor.constraint(equalToConstant: 88).isActive = true
            vw.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            
            if previous != nil {
                // we have a previous view - position us 10 points vertically away from it
                vw.topAnchor.constraint(equalTo: previous.bottomAnchor, constant: 10).isActive = true
            } else {
                // we don't have a previous view - position us against the top edge
                vw.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            }
            
            // set the previous view to be the current one, for the next loop iteration
            previous = vw
        }
        
        // make the final view sit against the bottom edge of our main view
        
        previous.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    func createStackView() {
        // create a stack view from four text fields
        let stackView = NSStackView(views: [makeView(0), makeView(1), makeView(2), makeView(3)])
        
        // make them take up an equal amount of space
        stackView.distribution = .fillEqually
        
        // make the views line up vertically
        stackView.orientation = .vertical
        
        // set this to false so we can create our own Auto Layout constraints
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        
        // make the stack view sit directly against all four edges
        stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        stackView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    func createStackView2() {
        // create a stack view from four text fields
        let stackView = NSStackView(views: [makeView(0), makeView(1), makeView(2), makeView(3)])
        
        // make them take up an equal amount of space
        stackView.distribution = .fillEqually
        
        // make the views line up vertically
        stackView.orientation = .vertical
        
        // set this to false so we can create our own Auto Layout constraints
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        
        // resize window freely
        for view in stackView.arrangedSubviews {
            view.setContentHuggingPriority(NSLayoutConstraint.Priority(1), for: .horizontal)
            view.setContentHuggingPriority(NSLayoutConstraint.Priority(1), for: .vertical)
        }
        
        // make the stack view sit directly against all four edges
        stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        stackView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    func createGridView() {
        // create our concise empty cell
        let empty = NSGridCell.emptyContentView
        
        // create a grid of views
        let gridView = NSGridView(views: [
            [makeView(0)],
            [makeView(1), empty, makeView(2)],
            [makeView(3), makeView(4), makeView(5), makeView(6)],
            [makeView(7), empty, makeView(8)],
            [makeView(9)]
        ])
        
        // make that we'll create our own constraints
        gridView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(gridView)
        
        // pin the grid to the edges of our main view
        gridView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        gridView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        gridView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        gridView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        // define heights
        gridView.row(at: 0).height = 32
        gridView.row(at: 1).height = 32
        gridView.row(at: 2).height = 32
        gridView.row(at: 3).height = 32
        gridView.row(at: 4).height = 32
        
        // define widths
        gridView.column(at: 0).width = 128
        gridView.column(at: 1).width = 128
        gridView.column(at: 2).width = 128
        gridView.column(at: 3).width = 128
        
        // define alignments
        gridView.row(at: 0).mergeCells(in: NSRange(location: 0, length: 4))
        gridView.row(at: 1).mergeCells(in: NSRange(location: 0, length: 2))
        gridView.row(at: 1).mergeCells(in: NSRange(location: 2, length: 2))
        gridView.row(at: 3).mergeCells(in: NSRange(location: 0, length: 2))
        gridView.row(at: 3).mergeCells(in: NSRange(location: 2, length: 2))
        gridView.row(at: 4).mergeCells(in: NSRange(location: 0, length: 4))
        
        gridView.row(at: 0).yPlacement = .center
        gridView.row(at: 1).yPlacement = .center
        gridView.row(at: 2).yPlacement = .center
        gridView.row(at: 3).yPlacement = .center
        gridView.row(at: 4).yPlacement = .center
        
        gridView.column(at: 0).xPlacement = .center
        gridView.column(at: 1).xPlacement = .center
        gridView.column(at: 2).xPlacement = .center
        gridView.column(at: 3).xPlacement = .center
    }
}

