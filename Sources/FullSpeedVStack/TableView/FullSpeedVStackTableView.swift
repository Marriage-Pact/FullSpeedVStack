
//
//  FullSpeedVStackTableView.swift
//  
//
//  Created by Ian Thomas on 8/14/23.
//

import SwiftUI

public struct FullSpeedVStackTableView<Section: SectionItemProtocol, CellItem: CellItemProtocol, CellView: View, SupplementaryView: View>: UIViewRepresentable {

    private class HostCell: UITableViewCell {
        
        override func prepareForReuse() {
            super.prepareForReuse()
            self.contentConfiguration = nil
        }
    }
    
    public class Coordinator: NSObject, UITableViewDelegate, UIScrollViewDelegate, UIGestureRecognizerDelegate {
        
        init(backgroundColor: UIColor,
             onScroll: @escaping ((UIScrollView) -> Void),
             scrollViewEndDragging: @escaping ((UIScrollView) -> Void),
             scrollViewBeginDragging: @escaping ((UIScrollView) -> Void),
             willDisplayCell: @escaping ((_ collectionView: UITableView, _ cell: UITableViewCell, _ indexPath: IndexPath) -> Void)
        ) {
            self.onScroll = onScroll
            self.backgroundColor = backgroundColor
            self.scrollViewEndDragging = scrollViewEndDragging
            self.scrollViewBeginDragging = scrollViewBeginDragging
            self.willDisplayCell = willDisplayCell
            super.init()
        }
        
        fileprivate var onScroll: ((UIScrollView) -> Void)
        fileprivate var scrollViewEndDragging: ((UIScrollView) -> Void)
        fileprivate var scrollViewBeginDragging: ((UIScrollView) -> Void)
        fileprivate var willDisplayCell: ((_ tableView: UITableView, _ cell: UITableViewCell, _ indexPath: IndexPath) -> Void)
        
        fileprivate typealias DataSource = UITableViewDiffableDataSource<Section, CellItem>
        
        fileprivate var dataSource: DataSource? = nil
        fileprivate var rowsHash: Int? = nil
        fileprivate let backgroundColor: UIColor
        
        public func scrollViewDidScroll(_ scrollView: UIScrollView) {
            onScroll(scrollView)
        }
        
        public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
            self.scrollViewEndDragging(scrollView)
        }
        
        public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
            self.scrollViewBeginDragging(scrollView)
        }
        
        public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
            self.willDisplayCell(tableView, cell, indexPath)
        }
    }
    
    let rows: [FullSpeedVStackSectionWithCells<Section, CellItem>]
    let cell: (IndexPath, CellItem) -> CellView
    let supplementaryView: (String, IndexPath) -> SupplementaryView
    
    var onGestureShouldBegin: ((_ gestureRecognizer: UIPanGestureRecognizer, _ scrollView: UIScrollView) -> Bool)?
    var onScroll: ((UIScrollView) -> Void)
    var scrollViewEndDragging: ((UIScrollView) -> Void)
    var scrollViewBeginDragging: ((UIScrollView) -> Void)
    
    let backgroundColor: UIColor
    let invertView: Bool
    var needsToScrollToBottom: Binding<Bool>? = nil
    var willDisplayCell: ((_ collectionView: UITableView, _ cell: UITableViewCell, _ indexPath: IndexPath) -> Void)
    
    public init(rows: [FullSpeedVStackSectionWithCells<Section, CellItem>],
         backgroundColor: UIColor,
         invertView: Bool = false,
         needsToScrollToBottom: Binding<Bool>?,
         @ViewBuilder cell: @escaping (IndexPath, CellItem) -> CellView,
         @ViewBuilder supplementaryView: @escaping (String, IndexPath) -> SupplementaryView,
         onGestureShouldBegin: @escaping (_ gestureRecognizer: UIPanGestureRecognizer, _ scrollView: UIScrollView) -> Bool,
         onScroll: @escaping ((UIScrollView) -> Void),
         scrollViewEndDragging: @escaping ((UIScrollView) -> Void),
         scrollViewBeginDragging: @escaping ((UIScrollView) -> Void),
         willDisplayCell: @escaping ((_ collectionView: UITableView, _ cell: UITableViewCell, _ indexPath: IndexPath) -> Void)
    ) {
        
        self.rows = rows
        self.cell = cell
        self.supplementaryView = supplementaryView
        self.onGestureShouldBegin = onGestureShouldBegin
        self.onScroll = onScroll
        self.backgroundColor = backgroundColor
        self.scrollViewEndDragging = scrollViewEndDragging
        self.needsToScrollToBottom = needsToScrollToBottom
        self.scrollViewBeginDragging = scrollViewBeginDragging
        self.invertView = invertView
        self.willDisplayCell = willDisplayCell
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
    
    private func reloadData(in tableView: UITableView, context: Context, animated: Bool = false) {
        let coordinator = context.coordinator
        
        guard let dataSource = coordinator.dataSource else { return }
        
        let rowsHash = rows.hashValue
        if coordinator.rowsHash != rowsHash {
            
            dataSource.apply(snapshot(), animatingDifferences: animated)
            
            coordinator.rowsHash = rowsHash
        }
    }
    
    public func makeCoordinator() -> Coordinator {
        return Coordinator(backgroundColor: self.backgroundColor,
                           onScroll: self.onScroll,
                           scrollViewEndDragging: self.scrollViewEndDragging,
                           scrollViewBeginDragging: self.scrollViewBeginDragging,
                           willDisplayCell: self.willDisplayCell)
    }
    
    public func makeUIView(context: Context) -> UITableView {
        let cellIdentifier = "hostCell"
        
        let tableView = CustomUITableView(frame: .zero, invertView: self.invertView)
                
        tableView.delegate = context.coordinator
        tableView.register(HostCell.self, forCellReuseIdentifier: cellIdentifier)
        
        tableView.onGestureShouldBegin = onGestureShouldBegin
        
        tableView.backgroundView?.backgroundColor = self.backgroundColor
        tableView.backgroundColor = self.backgroundColor
        
        let dataSource = Coordinator.DataSource(tableView: tableView) { tableView, indexPath, cellModel in
            let hostCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? HostCell
            
            hostCell?.contentConfiguration = UIHostingConfiguration {
                cell(indexPath, cellModel)
            }
            /// `UIHostingConfiguration` has extra layout margins that need to be removed.
            .margins(.all, 0)
            
            hostCell?.selectionStyle = .none
                    
            if invertView {
                hostCell?.contentView.transform = CGAffineTransform(scaleX: 1, y: -1)
            }
            
            return hostCell
        }
        
        /// This fixes a bug where cells totally animated in and out when the delivery state was being updated.
        dataSource.defaultRowAnimation = .fade

        context.coordinator.dataSource = dataSource
        
        reloadData(in: tableView, context: context)
        return tableView
    }
    
    public func updateUIView(_ uiView: UITableView, context: Context) {
        reloadData(in: uiView, context: context, animated: true)
    }
}

/// We subclass `UITableView` so we can override `gestureRecognizerShouldBegin`
final fileprivate class CustomUITableView: UITableView {
    
    init(frame: CGRect, invertView: Bool) {
        
        super.init(frame: frame, style: UITableView.Style.plain)
        
        self.rowHeight = UITableView.automaticDimension
        self.separatorStyle = UITableViewCell.SeparatorStyle.none

        self.layoutMargins = UIEdgeInsets.zero
        self.separatorInset = UIEdgeInsets.zero
                
        if invertView {
            self.transform = CGAffineTransform(scaleX: 1, y: -1)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var onGestureShouldBegin: ((_ gestureRecognizer: UIPanGestureRecognizer, _ scrollView: UIScrollView) -> Bool)?
    
    public override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let panGesture = gestureRecognizer as? UIPanGestureRecognizer else { return super.gestureRecognizerShouldBegin(gestureRecognizer)}
        
        return onGestureShouldBegin?(panGesture, self) ?? super.gestureRecognizerShouldBegin(gestureRecognizer)
    }
}
