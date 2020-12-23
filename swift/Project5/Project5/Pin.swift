//
//  Pin.swift
//  Project5
//
//  Created by Jinwoo Kim on 12/23/20.
//

import Cocoa
import MapKit

class Pin: NSObject, MKAnnotation {
    var title: String?
    var subtitle: String?
    var coordinate: CLLocationCoordinate2D
    var color: NSColor
    
    init(title: String, coordinate: CLLocationCoordinate2D, color: NSColor = .green) {
        self.title = title
        self.coordinate = coordinate
        self.color = color
    }
}
