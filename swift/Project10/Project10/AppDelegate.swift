//
//  AppDelegate.swift
//  Project10
//
//  Created by Jinwoo Kim on 1/3/21.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    
    var feed: JSON?
    var displayMode = 0
    
    var updateDisplayTimer: Timer?
    var fetchFeedTimer: Timer?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        let defaultSettings = ["latitude": "51.507222", "longitude": "-0.1275", "apiKey": "", "statusBarOption": "-1", "units": "0"]
        UserDefaults.standard.register(defaults: defaultSettings)
        
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(loadSettings), name: Notification.Name("SettingsChanged"), object: nil)
        
        statusItem.button?.title = "Fetching..."
        statusItem.menu = NSMenu()
        addConfigurationMenuItem()
        
        loadSettings()
    }

    func addConfigurationMenuItem() {
        let separator = NSMenuItem(title: "Settings", action: #selector(showSettings(_:)), keyEquivalent: "")
        statusItem.menu?.addItem(separator)
    }
    
    @objc func showSettings(_ sender: NSMenuItem) {
        updateDisplayTimer?.invalidate()
        print("Invalidated updateDisplayTimer")
        
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateController(withIdentifier: "ViewController") as? ViewController else {
            return
        }
        
        let popoverview = NSPopover()
        popoverview.contentViewController = vc
        popoverview.behavior = .transient
        popoverview.show(relativeTo: statusItem.button!.bounds, of: statusItem.button!, preferredEdge: .maxY)
    }
    
    @objc func fetchFeed() {
        let defaults = UserDefaults.standard
        
        guard let apiKey = defaults.string(forKey: "apiKey") else { return }
        guard !apiKey.isEmpty else {
            statusItem.button?.title = "No API Key"
            return
        }
        
        DispatchQueue.global(qos: .utility).async { [unowned self] in
            // 1
//            let latitude = defaults.double(forKey: "latitude")
//            let longitude = defaults.double(forKey: "longitude")
//            var dataSource = "https://api.darksky.net/forecast/\(apiKey)/\(latitude),\(longitude)"

//            if defaults.integer(forKey: "units") == 0 {
//                dataSource += "?units=si"
//            }
            
            // 2
//            guard let url = URL(string: dataSource) else { return }
//            guard let data = try? String(contentsOf: url) else {
//                DispatchQueue.main.async { [unowned self] in
//                    self.statusItem.button?.title = "Bad API Call"
//                }
//                return
//            }
            
            // Due to Dark Sky is end of service, this project used example json file from https://gist.github.com/morozgrafix/d6bace8dc3ae7e3067de7ce8a6c1b8bd
            guard let url = Bundle.main.url(forResource: "darksky1", withExtension: "json") else { return }
            guard let data = try? String(contentsOfFile: url.path, encoding: .utf8) else {
                DispatchQueue.main.async { [unowned self] in
                    self.statusItem.button?.title = "Bad API Call"
                }
                return
            }
            
            // 3
            let newFeed = JSON(parseJSON: data)
            
            DispatchQueue.main.async {
                self.feed = newFeed
                self.updateDisplay()
                self.refreshSubmenuItems()
            }
            print("Fetched!")
        }
    }
    
    @objc func loadSettings() {
        fetchFeedTimer = Timer.scheduledTimer(timeInterval: 60 * 5, target: self, selector: #selector(fetchFeed), userInfo: nil, repeats: true)
        fetchFeedTimer?.tolerance = 60
        
        fetchFeed()
        
        displayMode = UserDefaults.standard.integer(forKey: "statusBarOption")
        configureUpdateDisplayTimer()
    }
    
    func updateDisplay() {
        guard let feed = feed else { return }
        var text = "Error"
        
        switch displayMode {
        case 0:
            // summary text
            if let summary = feed["currently"]["summary"].string {
                text = summary
            }
        case 1:
            // Show current temperature
            if let temperature = feed["currently"]["temperature"].int {
                text = "\(temperature)°"
            }
        case 2:
            // Show chance of rain
            if let rain = feed["currently"]["precipProbability"].double {
                text = "Rain: \(rain * 100)%"
            }
        case 3:
            // Show cloud cover
            if let cloud = feed["currently"]["cloudCover"].double {
                text = "Cloud: \(cloud * 100)%"
            }
        default:
            // This should not be reached
            print("displayMode Error: \(displayMode)")
            break
        }
        
        statusItem.button?.title = text
    }
    
    @objc func changeDisplayMode() {
        displayMode += 1
        
        if displayMode > 3 {
            displayMode = 0
        }
        
        updateDisplay()
    }
    
    func configureUpdateDisplayTimer() {
        guard let statusBarMode = UserDefaults.standard.string(forKey: "statusBarOption") else { return }
        
        if statusBarMode == "-1" {
            displayMode = 0
            updateDisplayTimer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(changeDisplayMode), userInfo: nil, repeats: true)
            print("Validated updateDisplayTimer")
        } else {
            updateDisplayTimer?.invalidate()
            print("Invalidated updateDisplayTimer")
        }
    }
    
    func refreshSubmenuItems() {
        guard let feed = feed else { return }
        statusItem.menu?.removeAllItems()
        
        for forcast in feed["hourly"]["data"].arrayValue.prefix(10) {
            let date = Date(timeIntervalSince1970: forcast["time"].doubleValue)
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            let formattedDate = formatter.string(from: date)
            
            let summary = forcast["summary"].stringValue
            let temperature = forcast["temperature"].intValue
            let title = "\(formattedDate): \(summary) (\(temperature))"
            
            let menuItem = NSMenuItem(title: title, action: nil, keyEquivalent: "")
            statusItem.menu?.addItem(menuItem)
        }
        
        statusItem.menu?.addItem(NSMenuItem.separator())
        addConfigurationMenuItem()
    }
}

