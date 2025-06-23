//
//  FullSpeedVStackSectionWithCells.swift
//  
//
//  Created by Ian Thomas on 8/14/23.
//

import Foundation

// https://defagos.github.io/swiftui_collection_part3/
// https://github.com/defagos/SwiftUICollection

public protocol SectionItemProtocol: Hashable, Comparable, CaseIterable {
    var headerString: String { get }
}

/// When it's an enum with an associated value, make sure that value that is in `hash(into)` is that associated value.
/*
 func hash(into hasher: inout Hasher) {
 switch self {
 case .topLineNumbers(let viewModel):
 hasher.combine(viewModel)
 */
/// Also completely fill-out the switch statement for the `static func ==`
/*
 static func == (lhs: UserProfileCellViewModel, rhs: UserProfileCellViewModel) -> Bool {
 switch (lhs, rhs) {
 case (.topLineNumbers(let lhsViewModel), .topLineNumbers(let rhsViewModel)):
 return lhsViewModel == rhsViewModel
 */
public protocol CellItemProtocol: Identifiable, Hashable, CustomStringConvertible {
    
    var contentToSearchWhenSearching: String { get }
}

extension String {
    fileprivate func containsIgnoringCase(find: String) -> Bool {
        return self.range(of: find, options: .caseInsensitive) != nil
    }
}

public struct FullSpeedVStackSectionWithCells<Section: SectionItemProtocol, CellItem: CellItemProtocol>: Hashable {
    
    public let section: Section
    public let items: [CellItem]
    
    public let displaySectionsWhenEmpty: Bool
    
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
    }
}
