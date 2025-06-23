//
//  Notification+Extension.swift
//
//
//  Created by Ian Thomas on 5/9/24.
//

import Foundation

public struct FullSpeedVStackSetScrollToIndexPathNilNotification {
    
    /// Since this notification observer is on all the collection views, we want to send the scroll to action to a specific one.
    public init(collectionViewIdentifier: String) {
        self.collectionViewId = collectionViewIdentifier
    }
    
    public let collectionViewId: String
}

extension Notification.Name {
    public static let FullSpeedVStackSetScrollToIndexPathNil = Notification.Name("FullSpeedVStackSetScrollToIndexPathNil")
    public static let FullSpeedVStackAwakeScroll = Notification.Name("FullSpeedVStackAwakeScroll")
}
