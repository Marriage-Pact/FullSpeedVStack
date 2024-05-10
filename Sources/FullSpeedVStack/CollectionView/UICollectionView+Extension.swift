//
//  UICollectionView+Extension.swift
//
//
//  Created by Ian Thomas on 5/10/24.
//

import UIKit

extension UICollectionView {
    
    func isValid(indexPath: IndexPath) -> Bool {
        guard indexPath.section < numberOfSections,
              indexPath.row < numberOfItems(inSection: indexPath.section)
        else { return false }
        return true
    }
    
}
