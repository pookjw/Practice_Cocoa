//
//  AppDelegate.swift
//  Project13
//
//  Created by Jinwoo Kim on 1/8/21.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {



    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        NSColorPanel.shared.showsAlpha = true
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

