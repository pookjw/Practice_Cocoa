//
//  ViewController.swift
//  Project10
//
//  Created by Jinwoo Kim on 1/3/21.
//

import Cocoa
import MapKit

class ViewController: NSViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var apiKey: NSTextField!
    @IBOutlet weak var statusBarOption: NSPopUpButton!
    @IBOutlet weak var units: NSSegmentedControl!
    @IBOutlet weak var showPoweredBy: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        let defaults = UserDefaults.standard
        let savedLatitude = defaults.double(forKey: "latitude")
        let savedLongitude = defaults.double(forKey: "longitude")
        let savedAPIKey = defaults.string(forKey: "apiKey") ?? ""
        let savedStatusBar = defaults.integer(forKey: "statusBarOption")
        let savedUnits = defaults.integer(forKey: "units")
        
        apiKey.stringValue = savedAPIKey
        units.selectedSegment = savedUnits
        
        // 2
        for menuItem in statusBarOption.menu!.items {
            if menuItem.tag == savedStatusBar {
                statusBarOption.select(menuItem)
            }
        }
        
        // 3
        let savedLocation = CLLocationCoordinate2D(latitude: savedLatitude, longitude: savedLongitude)
        addPin(at: savedLocation)
        mapView.centerCoordinate = savedLocation
        
        // 4
        let recognizer = NSClickGestureRecognizer(target: self, action: #selector(mapTapped(recognizer:)))
        mapView.addGestureRecognizer(recognizer)
    }
    
    override func viewWillDisappear() {
        super.viewWillDisappear()
        
        let defaults = UserDefaults.standard
        let annotation = mapView.annotations[0]
        
        defaults.set(annotation.coordinate.latitude, forKey: "latitude")
        defaults.set(annotation.coordinate.longitude, forKey: "longitude")
        defaults.set(apiKey.stringValue, forKey: "apiKey")
        defaults.set(units.selectedSegment, forKey: "units")
        
        // 2
        var statusBarValue = -1
        for menuItem in statusBarOption.menu!.items {
            if menuItem.state == .on {
                statusBarValue = menuItem.tag
                break
            }
        }
        
        defaults.set(statusBarValue, forKey: "statusBarOption")
        
        // 3
        let nc = NotificationCenter.default
        nc.post(name: Notification.Name("SettingsChanged"), object: nil)
    }
    
    func addPin(at coordinate: CLLocationCoordinate2D) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = "Your location"
        mapView.addAnnotation(annotation)
    }
    
    @objc func mapTapped(recognizer: NSClickGestureRecognizer) {
        let location = recognizer.location(in: mapView)
        let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
        addPin(at: coordinate)
    }
    
    @IBAction func showPoweredBy(_ sender: Any) {
        NSWorkspace.shared.open(URL(string: "https://darksky.net/poweredby/")!)
    }
}

