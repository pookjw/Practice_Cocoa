//
//  StarFormatter.swift
//  Project16
//
//  Created by Jinwoo Kim on 1/13/21.
//

import Cocoa

class StarFormatter: Formatter {
    override func string(for obj: Any?) -> String? {
        if let obj = obj {
            if let number = Int(String(describing: obj)) {
                return String(repeating: "⭐️", count: number)
            }
        }
        return ""
    }
}
