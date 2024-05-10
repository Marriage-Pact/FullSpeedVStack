//
//  File.swift
//
//
//  Created by Ian Thomas on 5/9/24.
//

import Foundation

public struct FullSpeedVStackScrollToIndexPathNotification {
    
    /// Since this notification is on all the collection views, we want to send the scroll to action to a specifc one.
    public init(collectionViewIdentifier: String, indexPath: IndexPath) {
        self.collectionViewId = collectionViewIdentifier
        self.indexPath = indexPath
    }
    
    let collectionViewId: String
    let indexPath: IndexPath
}

extension Notification.Name {
    public static let FullSpeedVStackScrollToIndexPath = Notification.Name("FullSpeedVStackScrollToIndexPath")
}
