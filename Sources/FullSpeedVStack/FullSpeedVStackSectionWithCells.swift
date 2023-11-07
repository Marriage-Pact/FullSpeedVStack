//
//  FullSpeedVStackSectionWithCells.swift
//  Checkmate
//
//  Created by Ian Thomas on 8/14/23.
//

import Foundation

// https://defagos.github.io/swiftui_collection_part3/
// https://github.com/defagos/SwiftUICollection

public protocol SectionItemProtocol: Hashable, Comparable, CaseIterable {
    var headerString: String { get }
}

public protocol CellItemProtocol: Identifiable, Hashable, CustomStringConvertible {
    
    var contentToSearchWhenSearching: String { get }
}

extension String {
    fileprivate func containsIgnoringCase(find: String) -> Bool {
        return self.range(of: find, options: .caseInsensitive) != nil
    }
}

public struct FullSpeedVStackSectionWithCells<Section: SectionItemProtocol, CellItem: CellItemProtocol>: Hashable {
    
    let section: Section
    let items: [CellItem]
    
    let displaySectionsWhenEmpty: Bool
    
    public init(section: Section, items: [CellItem], displaySectionsWhenEmpty: Bool) {
        self.section = section
        self.items = items
        self.displaySectionsWhenEmpty = displaySectionsWhenEmpty
    }
    
    public var shouldBeDisplayed: Bool {
        switch displaySectionsWhenEmpty {
        case true:
            return true
        case false:
            return self.items.isEmpty == false
        }
    }
    
    public func searchItemsCopy(searchText: String) -> FullSpeedVStackSectionWithCells {
        
        let itemsContainingSearch: [CellItem] = self.items.compactMap { cellModel in
            if cellModel.contentToSearchWhenSearching.containsIgnoringCase(find: searchText) {
                return cellModel
            } else {
                return nil
            }
        }
        
        return FullSpeedVStackSectionWithCells(section: self.section,
                                               items: itemsContainingSearch,
                                               displaySectionsWhenEmpty: self.displaySectionsWhenEmpty)
        
//        Section(section: self.section,
//                       content: itemsContainingSearch,
//                       displaySectionsWhenEmpty: self.displaySectionsWhenEmpty)
    }
    
//    private func searchItems(searchText: String) -> [CellItem] {
//        return []
//        return self.content.compactMap { matchModel in
//            if matchModel.displayName.containsIgnoringCase(find: searchText) {
//                return matchModel
//            } else {
//                return nil
//            }
//        }
//    }
}
