//
//  FullSpeedVStackSectionWithCells.swift
//  Checkmate
//
//  Created by Ian Thomas on 8/14/23.
//

import Foundation

// https://defagos.github.io/swiftui_collection_part3/
// https://github.com/defagos/SwiftUICollection

public struct FullSpeedVStackSectionWithCells<Section: Hashable, CellItem: Hashable>: Hashable {
    let section: Section
    let items: [CellItem]
    
    public init(section: Section, items: [CellItem]) {
        self.section = section
        self.items = items
    }
    
    var shouldBeDisplayed: Bool {
        //self.content.isEmpty == false
        return true
    }
}
