//
//  ViewController.swift
//  Project13
//
//  Created by Jinwoo Kim on 1/8/21.
//

import Cocoa

class ViewController: NSViewController {
    
    @IBOutlet weak var imageView: NSImageView!
    @IBOutlet var caption: NSTextView!
    @IBOutlet weak var fontName: NSPopUpButton!
    @IBOutlet weak var fontSize: NSPopUpButton!
    @IBOutlet weak var fontColor: NSColorWell!
    @IBOutlet weak var backgroundImage: NSPopUpButton!
    @IBOutlet weak var backgroundColorStart: NSColorWell!
    @IBOutlet weak var backgroundColorEnd: NSColorWell!
    @IBOutlet weak var dropShadowStrength: NSSegmentedControl!
    @IBOutlet weak var dropShadowTarget: NSSegmentedControl!
    
    var screenshootImage: NSImage?
    
    var document: Document {
        let oughtToBeDocument = view.window?.windowController?.document as? Document
        assert(oughtToBeDocument != nil, "Unable to find the document for this view controller.")
        return oughtToBeDocument!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let recognizer = NSClickGestureRecognizer(target: self, action: #selector(importScreenshot))
        imageView.addGestureRecognizer(recognizer)
        
        loadFonts()
        loadBackgroundImages()
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        updateUI()
        generatePreview()
    }
    
//    @IBAction func changeFontSize(_ sender: NSMenuItem) {
//        document.screenshot.captionFontSize = fontSize.selectedTag()
//        generatePreview()
//    }
//
//    @IBAction func changeFontColor(_ sender: NSColorWell) {
//        document.screenshot.captionColor = fontColor.color
//        generatePreview()
//    }
//
//    @IBAction func changeBackgroundImage(_ sender: NSMenuItem) {
//        if backgroundImage.selectedTag() == 999 {
//            document.screenshot.backgroundImage = ""
//        } else {
//            document.screenshot.backgroundImage = backgroundImage.titleOfSelectedItem ?? ""
//        }
//
//        generatePreview()
//    }
//
//    @IBAction func changeBackgroundColorStart(_ sender: NSColorWell) {
//        document.screenshot.backgroundColorStart = backgroundColorStart.color
//        generatePreview()
//    }
//
//    @IBAction func changeBackgroundColorEnd(_ sender: NSColorWell) {
//        document.screenshot.backgroundColorEnd = backgroundColorEnd.color
//        generatePreview()
//    }
//
//    @IBAction func changeDropShadowStrength(_ sender: Any) {
//        document.screenshot.dropShadowStrength = dropShadowStrength.selectedSegment
//        generatePreview()
//    }
//
//    @IBAction func changeDropShadowTarget(_ sender: Any) {
//        document.screenshot.dropShadowTarget = dropShadowTarget.selectedSegment
//        generatePreview()
//    }
    
    //
    
    func loadFonts() {
        // find the list of fonts
        guard let fontFile = Bundle.main.url(forResource: "fonts", withExtension: nil) else { return }
        guard let fonts = try? String(contentsOf: fontFile) else { return }
        
        // split it up into an array by breaking on new lines
        let fontNames = fonts.components(separatedBy: "\n")
        
        // loop over every font
        for font in fontNames {
            if font.hasPrefix(" ") {
                // this is a font variation
                let item = NSMenuItem(title: font, action: #selector(changeFontName(_:)), keyEquivalent: "")
                item.target = self
                fontName.menu?.addItem(item)
            } else {
                // this is a font family
                let item = NSMenuItem(title: font, action: nil, keyEquivalent: "")
                item.target = self
                item.isEnabled = false
                fontName.menu?.addItem(item)
            }
        }
    }
    
    func loadBackgroundImages() {
        let allImages = ["Antique Wood", "Autumn Leaves", "Autumn Sunset", "Autumn by the Lake", "Beach and Palm Tree", "Blue Skies", "Bokeh (Blue)", "Bokeh (Golden)", "Bokeh (Green)", "Bokeh (Orange)", "Bokeh (Rainbow)", "Bokeh (White)", "Burning Fire", "Cherry Blossom", "Coffee Beans", "Cracked Earth", "Geometric Pattern 1", "Geometric Pattern 2", "Geometric Pattern 3", "Geometric Pattern 4", "Grass", "Halloween", "In the Forest", "Jute Pattern", "Polka Dots (Purple)", "Polka Dots (Teal)", "Red Bricks", "Red Hearts", "Red Rose", "Sandy Beach", "Sheet Music", "Snowy Mountain", "Spruce Tree Needles", "Summer Fruits", "Swimming Pool", "Tree Silhouette", "Tulip Field", "Vintage Floral", "Zebra Stripes"]
        
        for image in allImages {
            let item = NSMenuItem(title: image, action: #selector(changeBackgroundImage(_:)), keyEquivalent: "")
            item.target = self
            backgroundImage.menu?.addItem(item)
        }
    }
    
//    @objc func changeFontName(_ sender: NSMenuItem) {
//        document.screenshot.captionFontName = fontName.titleOfSelectedItem ?? ""
//        generatePreview()
//    }
    
    func generatePreview() {
        let image = NSImage(size: CGSize(width: 1242, height: 2208), flipped: false) { [unowned self] rect in
            guard let ctx = NSGraphicsContext.current?.cgContext else { return false }
            
            self.clearBackground(context: ctx, rect: rect)
            self.drawBackgroundImage(rect: rect)
            self.drawColorOverlay(rect: rect)
            let captionOffset = self.drawCaption(context: ctx, rect: rect)
            self.drawDevice(context: ctx, rect: rect, captionOffset: captionOffset)
            self.drawScreenshot(context: ctx, rect: rect, captionOffset: captionOffset)
            
            return true
        }
        
        imageView.image = image
    }
    
    func clearBackground(context: CGContext, rect: CGRect) {
        context.setFillColor(NSColor.white.cgColor)
        context.fill(rect)
    }
    
    func drawBackgroundImage(rect: CGRect) {
        // if they chose no background image, bail out
        if backgroundImage.selectedTag() == 999 { return }
        
        // if we can't get the current title, bail out
        guard let title = backgroundImage.titleOfSelectedItem else { return }
        
        // if we can't convert that title to an image, bail out
        guard let image = NSImage(named: title) else { return }
        
        // still here? Draw the image!
        // http://zathras.de/blog-nscompositingoperation-at-a-glance.htm
        image.draw(in: rect, from: .zero, operation: .sourceOver, fraction: 1)
    }
    
    func drawColorOverlay(rect: CGRect) {
        let gradient = NSGradient(starting: backgroundColorStart.color, ending: backgroundColorEnd.color)
        gradient?.draw(in: rect, angle: -90)
    }
    
    func createCaptionAttributes() -> [NSAttributedString.Key: Any]? {
        let ps = NSMutableParagraphStyle()
        ps.alignment = .center
        
        let fontSizes: [Int: CGFloat] = [0: 48, 1: 56, 2: 64, 3: 72, 4: 80, 5: 96, 6: 128]
        guard let baseFontSize = fontSizes[fontSize.selectedTag()] else { return nil }
        
        print(fontName.selectedItem?.title)
        let selectedFontName = fontName.selectedItem?.title.trimmingCharacters(in: .whitespacesAndNewlines) ?? "HelveticaNeue-Medium"
        print(selectedFontName)
        
        guard let font = NSFont(name: selectedFontName, size: baseFontSize) else { return nil }
        let color = fontColor.color
        
        return [NSAttributedString.Key.paragraphStyle: ps,
                NSAttributedString.Key.font: font,
                NSAttributedString.Key.foregroundColor: color]
    }
    
    func setShadow() {
        let shadow = NSShadow()
        shadow.shadowOffset = .zero
        shadow.shadowColor = NSColor.black
        shadow.shadowBlurRadius = 50
        
        // the shadow is now configured - activate it!
        shadow.set()
    }
    
    func drawCaption(context: CGContext, rect: CGRect) -> CGFloat {
        if dropShadowStrength.selectedSegment != 0 {
            // if the drop shadow is enabled
            if dropShadowTarget.selectedSegment == 0 || dropShadowTarget.selectedSegment == 2 {
                // and is set to "Text" or "Both"
                setShadow()
            }
        }
        
        // pull out the string to render
        let string = caption.textStorage?.string ?? ""
        
        // insert the rendering rect to keep the text off edges
        let insetRect = rect.insetBy(dx: 40, dy: 20)
        
        // combine the user's text with their attributes to create an attributed string
        let captionAttributes = createCaptionAttributes()
        let attributedString = NSAttributedString(string: string, attributes: captionAttributes)
        
        // draw the string in the inset rect
        attributedString.draw(in: insetRect)
        
        // if the shadow is set to "strong" then we'll draw the string again to make the shadow deeper
        if dropShadowStrength.selectedSegment == 2 {
            if dropShadowTarget.selectedSegment == 0 || dropShadowTarget.selectedSegment == 2 {
                attributedString.draw(in: insetRect)
            }
        }
        
        // clear the shadow so it doesn't affect other stuff
        let noShadow = NSShadow()
        noShadow.set()
        
        // calculate how much space this attributed string need
        let availableSpace = CGSize(width: insetRect.width, height: CGFloat.greatestFiniteMagnitude)
        let textFrame = attributedString.boundingRect(with: availableSpace, options: [.usesLineFragmentOrigin, .usesFontLeading])
        
        // send the height back to our caller
        return textFrame.height
    }
    
    func drawDevice(context: CGContext, rect: CGRect, captionOffset: CGFloat) {
        guard let image = NSImage(named: "iPhone") else { return }
        
        let offsetX = (rect.size.width - image.size.width) / 2
        var offsetY = (rect.size.height - image.size.height) / 2
        offsetY -= captionOffset
        
        if dropShadowStrength.selectedSegment != 0 {
            if dropShadowTarget.selectedSegment == 1 || dropShadowTarget.selectedSegment == 2 {
                setShadow()
            }
        }
        
        image.draw(at: CGPoint(x: offsetX, y: offsetY), from: .zero, operation: .sourceOver, fraction: 1)
        
        if dropShadowStrength.selectedSegment == 2 {
            if dropShadowTarget.selectedSegment == 1 || dropShadowTarget.selectedSegment == 2 {
                // create a stronger drop shadow by drawing again
                image.draw(at: CGPoint(x: offsetX, y: offsetY), from: .zero, operation: .sourceOver, fraction: 1)
            }
        }
        
        // clear the shadow so it doesn't affect other stuff
        let noShadow = NSShadow()
        noShadow.set()
    }
    
    @objc func importScreenshot() {
        let panel = NSOpenPanel()
        panel.allowedFileTypes = ["jpg", "png"]
        
        panel.begin { [unowned self] result in
            if result == .OK {
                guard let imageURL = panel.url else { return }
                self.screenshootImage = NSImage(contentsOf: imageURL)
                self.generatePreview()
            }
        }
    }
    
    func drawScreenshot(context: CGContext, rect: CGRect, captionOffset: CGFloat) {
        guard let screenshot = screenshootImage else { return }
        screenshot.size = CGSize(width: 891, height: 1584)
        
        let offsetY = 314 - captionOffset
        screenshot.draw(at: CGPoint(x: 176, y: offsetY), from: .zero, operation: .sourceOver, fraction: 1)
    }
    
    @IBAction func export(_ sender: Any) {
        guard let image = imageView.image else { return }
        guard let tiffData = image.tiffRepresentation else { return }
        guard let imageRep = NSBitmapImageRep(data: tiffData) else { return }
        guard let png = imageRep.representation(using: .png, properties: [:]) else { return }
        
        let panel = NSSavePanel()
        panel.allowedFileTypes = ["png"]
        
        panel.begin { result in
            if result == .OK {
                guard let url = panel.url else { return }
                
                do {
                    try png.write(to: url)
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    func updateUI() {
        caption.string = document.screenshot.caption
        fontName.selectItem(withTitle: document.screenshot.captionFontName)
        fontSize.selectItem(withTag: document.screenshot.captionFontSize)
        fontColor.color = document.screenshot.captionColor
        
        if !document.screenshot.backgroundImage.isEmpty {
            backgroundImage.selectItem(withTitle: document.screenshot.backgroundImage)
        }
        
        backgroundColorStart.color = document.screenshot.backgroundColorStart
        backgroundColorEnd.color = document.screenshot.backgroundColorEnd
        
        dropShadowStrength.selectedSegment = document.screenshot.dropShadowStrength
        dropShadowTarget.selectedSegment = document.screenshot.dropShadowTarget
    }
    
    // MARK: - Project 15
    
    @objc func changeFontName(_ sender: NSMenuItem) {
        setFontName(to: fontName.titleOfSelectedItem ?? "")
    }
    
    @objc func setFontName(to name: String) {
        // register the undo point with the current font name
        undoManager?.registerUndo(withTarget: self, selector: #selector(setFontName(to:)), object: document.screenshot.captionFontName)
        
        // update the font name
        document.screenshot.captionFontName = name
        
        // update the UI to match
        fontName.selectItem(withTitle: document.screenshot.captionFontName)
        
        // ensure the preview is updated
        generatePreview()
    }
    
    //
    
    @IBAction func changeFontSize(_ sender: NSMenuItem) {
        setFontSize(to: String(fontSize.selectedTag()))
    }
    
    @objc func setFontSize(to size: String) {
        undoManager?.registerUndo(withTarget: self, selector: #selector(setFontSize(to:)), object: String(document.screenshot.captionFontSize))
        
        document.screenshot.captionFontSize = Int(size)!
        fontSize.selectItem(withTag: document.screenshot.captionFontSize)
        generatePreview()
    }
    
    //
    
    @IBAction func changeFontColor(_ sender: NSColorWell) {
        setFontColor(to: fontColor.color)
    }
    
    @objc func setFontColor(to color: NSColor) {
        undoManager?.registerUndo(withTarget: self, selector: #selector(setFontColor(to:)), object: document.screenshot.captionColor)
        
        document.screenshot.captionColor = color
        fontColor.color = color
        generatePreview()
    }
    
    //
    
    @IBAction func changeBackgroundImage(_ sender: NSMenuItem) {
        if backgroundImage.selectedTag() == 999 {
            setBackgroundImage(to: "")
        } else {
            setBackgroundImage(to: backgroundImage.titleOfSelectedItem ?? "")
        }
    }
    
    @objc func setBackgroundImage(to name: String) {
        undoManager?.registerUndo(withTarget: self, selector: #selector(setBackgroundImage(to:)), object: document.screenshot.backgroundImage)
        
        document.screenshot.backgroundImage = name
        backgroundImage.selectItem(withTitle: name)
        generatePreview()
    }
    
    //
    
    @IBAction func changeBackgroundColorStart(_ sender: NSColorWell) {
        setBackgroundColorStart(to: backgroundColorStart.color)
    }
    
    @objc func setBackgroundColorStart(to color: NSColor) {
        undoManager?.registerUndo(withTarget: self, selector: #selector(setBackgroundColorStart(to:)), object: document.screenshot.backgroundColorStart)
        
        document.screenshot.backgroundColorStart = color
        backgroundColorStart.color = color
        generatePreview()
    }
    
    //
    
    @IBAction func changeBackgroundColorEnd(_ sender: NSColorWell) {
        document.screenshot.backgroundColorEnd = backgroundColorEnd.color
        generatePreview()
    }
    
    @objc func setBackgroundColorEnd(to color: NSColor) {
        undoManager?.registerUndo(withTarget: self, selector: #selector(setBackgroundColorEnd(to:)), object: document.screenshot.backgroundColorEnd)
        
        document.screenshot.backgroundColorEnd = color
        backgroundColorEnd.color = color
        generatePreview()
    }
    
    //
    
    @IBAction func changeDropShadowStrength(_ sender: Any) {
        setDropShadowStrength(to: String(dropShadowStrength.selectedSegment))
    }
    
    @objc func setDropShadowStrength(to strength: String) {
        undoManager?.registerUndo(withTarget: self, selector: #selector(setDropShadowStrength(to:)), object: String(document.screenshot.dropShadowStrength))
        
        document.screenshot.dropShadowStrength = Int(strength)!
        dropShadowStrength.selectedSegment = document.screenshot.dropShadowStrength
        generatePreview()
    }
    
    //
    
    @IBAction func changeDropShadowTarget(_ sender: Any) {
        setDropShadowTarget(to: String(dropShadowTarget.selectedSegment))
    }
    
    @objc func setDropShadowTarget(to target: String) {
        undoManager?.registerUndo(withTarget: self, selector: #selector(setDropShadowTarget(to:)), object: String(document.screenshot.dropShadowTarget))
        
        document.screenshot.dropShadowTarget = Int(target)!
        dropShadowTarget.selectedSegment = document.screenshot.dropShadowTarget
        generatePreview()
    }
}

extension ViewController: NSTextViewDelegate {
    func textDidChange(_ notification: Notification) {
        document.screenshot.caption = caption.string
        generatePreview()
    }
}
