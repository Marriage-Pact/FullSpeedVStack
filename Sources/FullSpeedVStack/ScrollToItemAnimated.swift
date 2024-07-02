//
//  ScrollToItemAnimated.swift
//
//
//  Created by Ian Thomas on 5/10/24.
//

import Foundation

public struct ScrollToItemAnimated {
    
    public init(indexPath: IndexPath, animated: Bool) {
        self.indexPath = indexPath
        self.animated = animated
    }
    
    public let indexPath: IndexPath
    public let animated: Bool
}
