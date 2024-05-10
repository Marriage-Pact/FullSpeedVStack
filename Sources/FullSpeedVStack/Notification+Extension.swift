//
//  File.swift
//
//
//  Created by Ian Thomas on 5/9/24.
//

import Foundation
/*
public struct FullSpeedVStackScrollToIndexPathNotification {
    
    /// Since this notification is on all the collection views, we want to send the scroll to action to a specific one.
    public init(collectionViewIdentifier: String, indexPath: IndexPath) {
        self.collectionViewId = collectionViewIdentifier
        self.indexPath = indexPath
    }
    
    let collectionViewId: String
    let indexPath: IndexPath
}
*/
public struct FullSpeedVStackSetScrollToIndexPathNilNotification {
    
    /// Since this notification is on all the collection views, we want to send the scroll to action to a specific one.
    public init(collectionViewIdentifier: String) {
        self.collectionViewId = collectionViewIdentifier
    }
    
    public let collectionViewId: String
}


extension Notification.Name {
    public static let FullSpeedVStackSetScrollToIndexPathNil = Notification.Name("FullSpeedVStackSetScrollToIndexPathNil")

//    public static let FullSpeedVStackScrollToIndexPath = Notification.Name("FullSpeedVStackScrollToIndexPath")
}
