
//
//  FullSpeedVStackCollectionView.swift
//  
//
//  Created by Ian Thomas on 7/26/23.
//

import SwiftUI

fileprivate struct Identifiers {
    fileprivate static let SupplementaryViewIdentifierHeader = "hostSupplementaryViewHeader"
    fileprivate static let SupplementaryViewIdentifierFooter = "hostSupplementaryViewFooter"
}

public struct FullSpeedVStackCollectionView<Section: SectionItemProtocol, CellItem: CellItemProtocol, CellView: View, SupplementaryView: View>: UIViewRepresentable {

    private class HostCell: UICollectionViewCell {
        
        override func prepareForReuse() {
            super.prepareForReuse()
            self.contentConfiguration = nil
        }
    }
    
    private class HostSupplementaryView: UICollectionReusableView {
        
        private var hostController: UIHostingController<SupplementaryView>?
        
        override func prepareForReuse() {
            super.prepareForReuse()
            if let hostView = hostController?.view {
                hostView.removeFromSuperview()
            }
            hostController = nil
        }
        
        var hostedSupplementaryView: SupplementaryView? {
            willSet {
                guard let view = newValue else { return }
                hostController = UIHostingController(rootView: view, ignoreSafeArea: true)
                
                /// - Note: This is set to .clear so that when tapping on cells the border headers, the tap selection rectangle shows.
                hostController?.view.backgroundColor = UIColor.clear
                if let hostView = hostController?.view {
                    hostView.frame = self.bounds
                    hostView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                    addSubview(hostView)
                }
            }
        }
    }
    
    public class Coordinator: NSObject, UICollectionViewDelegate, UIScrollViewDelegate, UIGestureRecognizerDelegate {
        
        init(backgroundColor: UIColor,
             onScroll: @escaping ScrollViewAndOptionalCollectionView,
             scrollViewEndDragging: @escaping ScrollViewAndOptionalCollectionView,
             scrollViewBeginDragging: @escaping ScrollViewAndOptionalCollectionView,
             willDisplayCell: @escaping ((_ collectionView: UICollectionView, _ cell: UICollectionViewCell, _ indexPath: IndexPath) -> Void)
        ) {
            self.onScroll = onScroll
            self.backgroundColor = backgroundColor
            self.scrollViewEndDragging = scrollViewEndDragging
            self.scrollViewBeginDragging = scrollViewBeginDragging
            self.willDisplayCell = willDisplayCell
            super.init()
        }
        
        weak var collectionViewReference: UICollectionView?

        fileprivate var onScroll: ScrollViewAndOptionalCollectionView
        fileprivate var scrollViewEndDragging: ScrollViewAndOptionalCollectionView
        fileprivate var scrollViewBeginDragging: ScrollViewAndOptionalCollectionView
        fileprivate var willDisplayCell: ((_ collectionView: UICollectionView, _ cell: UICollectionViewCell, _ indexPath: IndexPath) -> Void)
        
        fileprivate typealias DataSource = UICollectionViewDiffableDataSource<Section, CellItem>
        
        fileprivate var dataSource: DataSource? = nil
        fileprivate var sectionLayoutProvider: ((Int, NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection)?
        fileprivate var rowsHash: Int? = nil
        fileprivate let backgroundColor: UIColor
        
        public func scrollViewDidScroll(_ scrollView: UIScrollView) {
            onScroll(scrollView, self.collectionViewReference)
        }
        
        public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
            self.scrollViewEndDragging(scrollView, self.collectionViewReference)
        }
        
        public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
            self.scrollViewBeginDragging(scrollView, self.collectionViewReference)
        }
        
        public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
            self.willDisplayCell(collectionView, cell, indexPath)
        }
    }
    
    let rows: [FullSpeedVStackSectionWithCells<Section, CellItem>]
    let sectionLayoutProvider: (Int, NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection
    let cell: (IndexPath, CellItem) -> CellView
    let supplementaryView: (String, IndexPath) -> SupplementaryView
    
    public typealias ScrollViewAndOptionalCollectionView = ((UIScrollView, UICollectionView?) -> Void)
    
    var onGestureShouldBegin: ((_ gestureRecognizer: UIPanGestureRecognizer, _ scrollView: UIScrollView) -> Bool)?
    var onScroll: ScrollViewAndOptionalCollectionView
    var scrollViewEndDragging: ScrollViewAndOptionalCollectionView
    var scrollViewBeginDragging: ScrollViewAndOptionalCollectionView
    
    let backgroundColor: UIColor
    let invertView: Bool
    let collectionViewId: String

    var needsToScrollToBottom: Binding<Bool>? = nil
    var needsToScrollToItem: Binding<ScrollToItemAnimated?>? = nil

    var willDisplayCell: ((_ collectionView: UICollectionView, _ cell: UICollectionViewCell, _ indexPath: IndexPath) -> Void)
    
    public init(rows: [FullSpeedVStackSectionWithCells<Section, CellItem>],
                collectionViewId: String,
                backgroundColor: UIColor,
                invertView: Bool = false,
                needsToScrollToBottom: Binding<Bool>?,
                needsToScrollToItem: Binding<ScrollToItemAnimated?>, /// This binding needs to be a concrete type for it to work
                sectionLayoutProvider: @escaping (Int, NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection,
                @ViewBuilder cell: @escaping (IndexPath, CellItem) -> CellView,
                @ViewBuilder supplementaryView: @escaping (String, IndexPath) -> SupplementaryView,
                onGestureShouldBegin: @escaping (_ gestureRecognizer: UIPanGestureRecognizer, _ scrollView: UIScrollView) -> Bool,
                onScroll: @escaping ScrollViewAndOptionalCollectionView,
                scrollViewEndDragging: @escaping ScrollViewAndOptionalCollectionView,
                scrollViewBeginDragging: @escaping ScrollViewAndOptionalCollectionView,
                willDisplayCell: @escaping ((_ collectionView: UICollectionView, _ cell: UICollectionViewCell, _ indexPath: IndexPath) -> Void)
    ) {
        
        self.rows = rows
        self.collectionViewId = collectionViewId
        self.sectionLayoutProvider = sectionLayoutProvider
        self.cell = cell
        self.supplementaryView = supplementaryView
        self.onGestureShouldBegin = onGestureShouldBegin
        self.onScroll = onScroll
        self.backgroundColor = backgroundColor
        self.scrollViewEndDragging = scrollViewEndDragging
        self.needsToScrollToBottom = needsToScrollToBottom
        self.needsToScrollToItem = needsToScrollToItem
        self.scrollViewBeginDragging = scrollViewBeginDragging
        self.invertView = invertView
        self.willDisplayCell = willDisplayCell
    }
    
    private func layout(context: Context) -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { sectionIndex, layoutEnvironment in
            return context.coordinator.sectionLayoutProvider!(sectionIndex, layoutEnvironment)
        }
    }
    
    public func snapshot() -> NSDiffableDataSourceSnapshot<Section, CellItem> {
        var snapshot = NSDiffableDataSourceSnapshot<Section, CellItem>()
        
        for row in rows {
            /// This needs to match up with the displayed content, otherwise the headers are put on the wrong sections.
            if row.shouldBeDisplayed {
                snapshot.appendSections([row.section])
                snapshot.appendItems(row.items, toSection: row.section)
            }
        }
        return snapshot
    }
    
    private func reloadData(in collectionView: UICollectionView, context: Context, animated: Bool = false) {
        let coordinator = context.coordinator
        coordinator.sectionLayoutProvider = self.sectionLayoutProvider
        
        guard let dataSource = coordinator.dataSource else { return }
        
        let rowsHash = rows.hashValue
        if coordinator.rowsHash != rowsHash {
            
            dataSource.apply(snapshot(), animatingDifferences: animated)
            
            coordinator.rowsHash = rowsHash
        }
        
        handleIfNeedToScrollToItem(collectionView: collectionView)
    }
    
    private func handleIfNeedToScrollToItem(collectionView: UICollectionView) {
        guard let scrollItem = self.needsToScrollToItem?.wrappedValue else { return }
        guard collectionView.isValid(indexPath: scrollItem.indexPath) else {
            return
        }
        collectionViewScrollToIndexPath(collectionView: collectionView, scrollItem: scrollItem)
    }
  
    private func collectionViewScrollToIndexPath(collectionView: UICollectionView, scrollItem: ScrollToItemAnimated) {
        
        DispatchQueue.main.async {
            collectionView.scrollToItem(at: scrollItem.indexPath, at: .centeredVertically, animated: scrollItem.animated)
            NotificationCenter.default.post(name: .FullSpeedVStackSetScrollToIndexPathNil, object: FullSpeedVStackSetScrollToIndexPathNilNotification(collectionViewIdentifier: self.collectionViewId))
        }
    }
    
    public func makeCoordinator() -> Coordinator {
        return Coordinator(backgroundColor: self.backgroundColor,
                           onScroll: self.onScroll,
                           scrollViewEndDragging: self.scrollViewEndDragging,
                           scrollViewBeginDragging: self.scrollViewBeginDragging,
                           willDisplayCell: self.willDisplayCell)
    }
    
    public func makeUIView(context: Context) -> UICollectionView {
        let cellIdentifier = "hostCell"
        
        let collectionView = CustomUICollectionView(frame: .zero,
                                                    collectionViewLayout: layout(context: context), 
                                                    invertView: self.invertView,
                                                    collectionViewId: self.collectionViewId)
        
        context.coordinator.collectionViewReference = collectionView
        
        collectionView.delegate = context.coordinator
        collectionView.register(HostCell.self, forCellWithReuseIdentifier: cellIdentifier)
        
        collectionView.onGestureShouldBegin = onGestureShouldBegin
        
        collectionView.backgroundView?.backgroundColor = self.backgroundColor
        collectionView.backgroundColor = self.backgroundColor
        
        let dataSource = Coordinator.DataSource(collectionView: collectionView) { collectionView, indexPath, cellModel in
            let hostCell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? HostCell
            hostCell?.insetsLayoutMarginsFromSafeArea = false
            hostCell?.contentConfiguration = UIHostingConfiguration {
                cell(indexPath, cellModel)
            } 
            /// `UIHostingConfiguration` has extra layout margins that need to be removed.
            .margins(.all, 0)
            
            /// - Note: If the cells are not sizing properly, try adding sizeToFit()
            
            if invertView {
                hostCell?.contentView.transform = CGAffineTransform(scaleX: 1, y: -1)
            }
            return hostCell
        }
        context.coordinator.dataSource = dataSource
        
        /// - Note: There was a memory leak that the debugger said was linked to the supplementary view, so I moved the registration outside the following closure to resile the issue
        collectionView.register(HostSupplementaryView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: Identifiers.SupplementaryViewIdentifierHeader)

        collectionView.register(HostSupplementaryView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
                                withReuseIdentifier: Identifiers.SupplementaryViewIdentifierFooter)
        
        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            
            switch kind {
            case UICollectionView.elementKindSectionHeader:
                guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: Identifiers.SupplementaryViewIdentifierHeader, for: indexPath) as? HostSupplementaryView else { return nil }
                headerView.hostedSupplementaryView = supplementaryView(kind, indexPath)
                return headerView
            case UICollectionView.elementKindSectionFooter:
                guard let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: Identifiers.SupplementaryViewIdentifierFooter, for: indexPath) as? HostSupplementaryView else { return nil }
                footerView.hostedSupplementaryView = supplementaryView(kind, indexPath)
                return footerView
            default:
                return nil
            }
    
        }
        
        reloadData(in: collectionView, context: context)
        return collectionView
    }
    
    public func updateUIView(_ uiView: UICollectionView, context: Context) {
        reloadData(in: uiView, context: context, animated: true)
    }
}

/// We subclass `UICollectionView` to override `gestureRecognizerShouldBegin`
final fileprivate class CustomUICollectionView: UICollectionView {
    
    init(frame: CGRect,
         collectionViewLayout: UICollectionViewLayout,
         invertView: Bool,
         collectionViewId: String) {
        
        self.collectionViewId = collectionViewId
        
        super.init(frame: frame, collectionViewLayout: collectionViewLayout)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        if invertView {
            self.transform = CGAffineTransform(scaleX: 1, y: -1)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(awakeScroll), name: .FullSpeedVStackAwakeScroll, object: nil)
    }
    
    private let collectionViewId: String
    
    @objc private func keyboardWillChangeFrame(_ notification: Notification) {
//        guard
//            let userInfo = notification.userInfo,
//            let endPos = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
//        else { return }
//        
//        let keyboardHeightDynamic = endPos.height
        /*
        self.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeightDynamic, right: 0)
        self.scrollIndicatorInsets = self.contentInset
         */
    }
    
    private var hasAwoken = false
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// The missing taps issue: where the tapping on a cell has no effect until the user scrolls.
    ///
    /// if you add `override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView?` to the `HostSupplementaryView` and other reasonable places it does not appear to work.
    ///
    /// If is happens again, other things to try:
    /// - Moving the drawer view via drag. The problem only happens when the drawer is set the top position programatically.
    /// - look at the comment with `didSelectItemAt`
    /// - adding to the SwiftUI View  `.allowsHitTesting(true)`
    
    @objc func awakeScroll() {
        
        guard hasAwoken == false else { return }
        hasAwoken = true
        DispatchQueue.main.async { [weak self] in
            // TODONow: test on device with short lists that don't fill the screen fully.
            /// This is not great.
            self?.scrollRectToVisible(CGRect(origin: CGPoint(x: 0, y: 2000), size: CGSize(width: 1, height: 1)), animated: false)
            self?.scrollRectToVisible(CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 1, height: 1)), animated: false)
        }
    }
    
    var onGestureShouldBegin: ((_ gestureRecognizer: UIPanGestureRecognizer, _ scrollView: UIScrollView) -> Bool)?
    
    public override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let panGesture = gestureRecognizer as? UIPanGestureRecognizer else { return super.gestureRecognizerShouldBegin(gestureRecognizer)}
        
        return onGestureShouldBegin?(panGesture, self) ?? super.gestureRecognizerShouldBegin(gestureRecognizer)
    }
}
