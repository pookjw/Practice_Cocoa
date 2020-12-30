//
//  Array+moveItem.swift
//  Project7
//
//  Created by Jinwoo Kim on 12/30/20.
//

import Foundation

extension Array {
    mutating func moveItem(from: Int, to: Int) {
        let item = self[from]
        self.remove(at: from)
        
        if to <= from {
            self.insert(item, at: to)
        } else {
            self.insert(item, at: to - 1)
        }
    }
}
