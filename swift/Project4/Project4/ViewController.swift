//
//  ViewController.swift
//  Project4
//
//  Created by Jinwoo Kim on 12/22/20.
//

import Cocoa
import WebKit

class ViewController: NSViewController, WKNavigationDelegate, NSGestureRecognizerDelegate, NSTouchBarDelegate, NSSharingServicePickerTouchBarItemDelegate {
    
    var rows: NSStackView!
    var selectedWebView: WKWebView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // 1: Create the stack view and add it to our view
        rows = NSStackView()
        rows.orientation = .vertical
        rows.distribution = .fillEqually
        rows.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(rows)
        
        // 2: Create Auto Layout constraints that pin the stack view to the edges of its container
        rows.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        rows.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        rows.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        rows.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        // 3: Create an initial column that contains a single web view
        let column = NSStackView(views: [makeWebView()])
        column.distribution = .fillEqually
        
        // 4: Add this column to the `rows` stack view
        rows.addArrangedSubview(column)
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    func select(webView: WKWebView) {
        selectedWebView = webView
        selectedWebView.layer?.borderWidth = 4
        selectedWebView.layer?.borderColor = NSColor.blue.cgColor
        
        if let windowController = view.window?.windowController as? WindowController {
            windowController.addressEntry.stringValue = selectedWebView.url?.absoluteString ?? ""
        }
    }
    
    @objc func webViewClicked(recognizer: NSClickGestureRecognizer) {
        // get the web view that triggered this method
        guard let newSelectedWebView = recognizer.view as? WKWebView else { return }
        
        // deselect the currently selected web view if there is one
        if let selected = selectedWebView {
            selected.layer?.borderWidth = 0
        }
        
        // select the new one
        select(webView: newSelectedWebView)
    }
    
    func makeWebView() -> NSView {
        let webView = WKWebView()
        webView.navigationDelegate = self
        webView.wantsLayer = true
        webView.load(URLRequest(url: URL(string: "https://www.apple.com")!))
        
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
        
        let recognizer = NSClickGestureRecognizer(target: self, action: #selector(webViewClicked(recognizer:)))
        recognizer.numberOfClicksRequired = 2
        recognizer.delegate = self
        webView.addGestureRecognizer(recognizer)
        
        if selectedWebView == nil {
            select(webView: webView)
        }
        
        return webView
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        guard webView == selectedWebView else { return }
        
        if let windowController = view.window?.windowController as? WindowController {
            windowController.addressEntry.stringValue = webView.url?.absoluteString ?? ""
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: NSGestureRecognizer, shouldAttemptToRecognizeWith event: NSEvent) -> Bool {
        if gestureRecognizer.view == selectedWebView {
            return false
        } else {
            return true
        }
    }
    
    func touchBar(_ touchBar: NSTouchBar, makeItemForIdentifier identifier: NSTouchBarItem.Identifier) -> NSTouchBarItem? {
        switch identifier {
        case NSTouchBarItem.Identifier.enterAddress:
            let button = NSButton(title: "Enter a URL", target: self, action: #selector(selectAddressEntry))
            button.setContentHuggingPriority(NSLayoutConstraint.Priority(10), for: .horizontal)
            let customTouchBarItem = NSCustomTouchBarItem(identifier: identifier)
            customTouchBarItem.view = button
            return customTouchBarItem
        case NSTouchBarItem.Identifier.navigation:
            // load the back and forward images
            let back = NSImage(named: NSImage.touchBarGoBackTemplateName)!
            let forward = NSImage(named: NSImage.touchBarGoForwardTemplateName)!
            
            // create a segmented control out of them, calling our `navigatoinClicked()` method
            let segmentedControl = NSSegmentedControl(images: [back, forward], trackingMode: .momentary, target: self, action: #selector(navigationClicked(_:)))
            
            // wrap that inside a Touch Bar item
            let customTouchBarItem = NSCustomTouchBarItem(identifier: identifier)
            customTouchBarItem.view = segmentedControl
            
            // send it back
            return customTouchBarItem
        case NSTouchBarItem.Identifier.sharingPicker:
            let picker = NSSharingServicePickerTouchBarItem(identifier: identifier)
            picker.delegate = self
            return picker
        case NSTouchBarItem.Identifier.adjustRows:
            let control = NSSegmentedControl(labels: ["Add Row", "Remove Row"], trackingMode: .momentaryAccelerator, target: self, action: #selector(adjustRows(_:)))
            let customTouchBarItem = NSCustomTouchBarItem(identifier: identifier)
            customTouchBarItem.customizationLabel = "Rows"
            customTouchBarItem.view = control
            return customTouchBarItem
        case NSTouchBarItem.Identifier.adjustCols:
            let control = NSSegmentedControl(labels: ["Add Column", "Remove Column"], trackingMode: .momentaryAccelerator, target: self, action: #selector(adjustColumns(_:)))
            let customTouchBarItem = NSCustomTouchBarItem(identifier: identifier)
            customTouchBarItem.customizationLabel = "Columns"
            customTouchBarItem.view = control
            return customTouchBarItem
        case NSTouchBarItem.Identifier.adjustGrid:
            let popover = NSPopoverTouchBarItem(identifier: identifier)
            popover.collapsedRepresentationLabel = "Grid"
            popover.customizationLabel = "Adjust Grid"
            popover.popoverTouchBar = NSTouchBar()
            popover.popoverTouchBar.delegate = self
            popover.popoverTouchBar.defaultItemIdentifiers = [.adjustRows, .adjustCols]
            return popover
        default:
            return nil
        }
    }
    
    override func makeTouchBar() -> NSTouchBar? {
        // enable the Customize Touch Bar menu item
        NSApp.isAutomaticCustomizeTouchBarMenuItemEnabled = true
        
        // create a Touch Bar with a unique identifier, making `ViewController` its delegate
        let touchBar = NSTouchBar()
        touchBar.customizationIdentifier = NSTouchBar.CustomizationIdentifier("com.hackingwithswift.project4")
        touchBar.delegate = self
        
        // set up some meaningful defaults
        touchBar.defaultItemIdentifiers = [.navigation, .adjustGrid, .enterAddress, .sharingPicker]
        
        // make the address entry button sit in the center of the bar
        touchBar.principalItemIdentifier = .enterAddress
        
        // allow the user to customize these four controls
        touchBar.customizationAllowedItemIdentifiers = [.sharingPicker, .adjustGrid, .adjustCols, .adjustRows]
        
        // but don't let them take off the URL entry button
        touchBar.customizationRequiredItemIdentifiers = [.enterAddress]
        
        return touchBar
    }
    
    @objc func selectAddressEntry() {
        if let windowController = view.window?.windowController as? WindowController {
            windowController.window?.makeFirstResponder(windowController.addressEntry)
        }
    }
    
    func items(for pickerTouchBarItem: NSSharingServicePickerTouchBarItem) -> [Any] {
        guard let webView = selectedWebView else { return [] }
        guard let url = webView.url?.absoluteString else { return [] }
        return [url]
    }

    @IBAction func urlEntered(_ sender: NSTextField) {
        // bail out if we don't have a web view selected
        guard let selected = selectedWebView else { return }
        
        // attempt to convert the user's text into a URL
        if let url = URL(string: sender.stringValue) {
            // it worked - load it!
            selected.load(URLRequest(url: url))
        }
    }
    
    @IBAction func navigationClicked(_ sender: NSSegmentedControl) {
        // make sure we have a web view selected
        guard let selected = selectedWebView else { return }
        
        if sender.selectedSegment == 0 {
            // back was tapped
            selected.goBack()
        } else {
            // forward was tapped
            selected.goForward()
        }
    }
    
    @IBAction func adjustRows(_ sender: NSSegmentedControl) {
        if sender.selectedSegment == 0 {
            // we're adding anew row
            // count how many columns we have so far
            let columnCount = (rows.arrangedSubviews[0] as! NSStackView).arrangedSubviews.count
            
            // make a new array of webviews that contain the correct number of columns
            let viewArray = (0..<columnCount).map { _ in makeWebView() }
            
            // use that web view array to create a new stack view
            let row = NSStackView(views: viewArray)
            
            // make the stack view size its children equally, then add it to our `rows` array
            row.distribution = .fillEqually
            rows.addArrangedSubview(row)
        } else {
            // we're deleting a row
            // make sure we have at least two rows
            guard rows.arrangedSubviews.count > 1 else { return }
            
            // pull out the final row, and make sure it's a stack view
            guard let rowToRemove = rows.arrangedSubviews.last as? NSStackView else { return }
            
            // loop through each web view in the row, removing it from the screen
            for cell in rowToRemove.arrangedSubviews {
                cell.removeFromSuperview()
            }
            
            // finally, remove the whole stack view row
            rows.removeArrangedSubview(rowToRemove)
        }
    }
    
    @IBAction func adjustColumns(_ sender: NSSegmentedControl) {
        if sender.selectedSegment == 0 {
            // we need to add a column
            for case let row as NSStackView in rows.arrangedSubviews {
                // loop over each row and add a new web view to it
                row.addArrangedSubview(makeWebView())
            }
        } else {
            // we need to delete a column
            // pull out the first of our rows
            guard let firstRow = rows.arrangedSubviews.first as? NSStackView else { return }
            
            // make sure it has at least two columns
            guard firstRow.arrangedSubviews.count > 1 else { return }
            
            // if we are still here it means it's safe to delete a column
            for case let row as NSStackView in rows.arrangedSubviews {
                // loop over every row
                if let last = row.arrangedSubviews.last {
                    // pull out the last web view in this column and remove it using two-step process
                    row.removeArrangedSubview(last)
                    last.removeFromSuperview()
                }
            }
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let webView = object as? WKWebView else { return }
        guard let url = webView.url else { return }
        print("The URL \(url) loaded \(webView.estimatedProgress)")
    }
}

extension NSTouchBarItem.Identifier {
    static let navigation = NSTouchBarItem.Identifier("com.hackingwithswift.project4.navigation")
    static let enterAddress = NSTouchBarItem.Identifier("com.hackingwithswift.project4.enterAddress")
    static let sharingPicker = NSTouchBarItem.Identifier("com.hackingwithswift.project4.sharingPicker")
    static let adjustGrid = NSTouchBarItem.Identifier("com.hackingwithswift.project4.adjustGrid")
    static let adjustRows = NSTouchBarItem.Identifier("com.hackingwithswift.project4.adjustRows")
    static let adjustCols = NSTouchBarItem.Identifier("com.hackingwithswift.project4.adjustCols")
}
