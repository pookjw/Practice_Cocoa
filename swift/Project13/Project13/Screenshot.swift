//
//  Screenshot.swift
//  Project13
//
//  Created by Jinwoo Kim on 1/11/21.
//

import Cocoa

enum ScreenshotError: Error {
    case BadData
}

final class Screenshot: NSObject, NSCoding {
    var caption = "Your text here"
    var captionFontName = " HelveticaNeue-Medium"
    var captionFontSize = 3
    var captionColor = NSColor.black
    
    var backgroundImage = ""
    var backgroundColorStart = NSColor.clear
    var backgroundColorEnd = NSColor.clear
    
    var dropShadowStrength = 1
    var dropShadowTarget = 2
    
    
    override init() {
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        caption = aDecoder.decodeObject(forKey: "caption") as! String
        captionFontName = aDecoder.decodeObject(forKey: "captionFontName") as! String
        captionFontSize = aDecoder.decodeInteger(forKey: "captionFontSize")
        captionColor = aDecoder.decodeObject(forKey: "captionColor") as! NSColor
        
        backgroundImage = aDecoder.decodeObject(forKey: "backgroundImage") as! String
        backgroundColorStart = aDecoder.decodeObject(forKey: "backgroundColorStart") as! NSColor
        backgroundColorEnd = aDecoder.decodeObject(forKey: "backgroundColorEnd") as! NSColor
        
        dropShadowStrength = aDecoder.decodeInteger(forKey: "dropShadowStrength")
        dropShadowTarget = aDecoder.decodeInteger(forKey: "dropShadowTarget")
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(caption, forKey: "caption")
        aCoder.encode(captionFontName, forKey: "captionFontName")
        aCoder.encode(captionFontSize, forKey: "captionFontSize")
        aCoder.encode(captionColor, forKey: "captionColor")

        aCoder.encode(backgroundImage, forKey: "backgroundImage")
        aCoder.encode(backgroundColorStart, forKey: "backgroundColorStart")
        aCoder.encode(backgroundColorEnd, forKey: "backgroundColorEnd")

        aCoder.encode(dropShadowStrength, forKey: "dropShadowStrength")
        aCoder.encode(dropShadowTarget, forKey: "dropShadowTarget")
    }
}
