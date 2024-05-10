
import SwiftUI

fileprivate class TestViewModel: ObservableObject {
    
    typealias SectionWithCellsItem = FullSpeedVStackSectionWithCells<SectionType, CellViewModel>
    
    @Published public private(set) var sectionsDisplayed: [SectionWithCellsItem] = []
    
    @Published var scrollToItem: ScrollToItemAnimated? = nil
    
    init() {
        let cells: [CellViewModel] = [
            CellViewModel(),
            CellViewModel(),
            CellViewModel(),
            CellViewModel(),
            CellViewModel(),
            CellViewModel(),  
            CellViewModel(),
            CellViewModel(),
            CellViewModel(),  
            CellViewModel(),
            CellViewModel(),
            CellViewModel(),
            CellViewModel(),
            CellViewModel(),
            CellViewModel(),
            CellViewModel(),
            CellViewModel(),
            CellViewModel(),
            CellViewModel(),
            CellViewModel(),
            CellViewModel(),
            CellViewModel(),
            CellViewModel(),
            CellViewModel(),
        ]
        //= Array.init(repeating: CellViewModel(), count: 20)
        sectionsDisplayed = [
            SectionWithCellsItem(section: SectionType.main, items: cells, displaySectionsWhenEmpty: true)
        ]
        
        NotificationCenter.default.addObserver(self, selector: #selector(setScrollToItemFalse), name: .FullSpeedVStackSetScrollToIndexPathNil, object: nil)
    }
    
    @objc private func setScrollToItemFalse(_ notification: Notification) {
        print("setScrollToItemFalse")
//        guard let object = notification.object as? FullSpeedVStackSetScrollToIndexPathNilNotification, object.collectionViewId == self.collectionViewId else {
//            print("wrong id")
//            return
//        }
        DispatchQueue.main.async { [weak self] in
//            print("scrollToItem = nil")
            self?.scrollToItem = nil
        }
    }

}

struct TestCollectionView: View {

    @ObservedObject fileprivate var viewModel = TestViewModel()
    
    var body: some View {
        VStack {
            HStack {
                Button {
                    viewModel.scrollToItem = ScrollToItemAnimated(indexPath: IndexPath(item: 20, section: 0), animated: true)
                } label: {
                    Text("scroll animated")
                }
                Button {
                    viewModel.scrollToItem = ScrollToItemAnimated(indexPath: IndexPath(item: 20, section: 0), animated: false)
                } label: {
                    Text("scroll NOTAnimated")
                }
            }

            collectionView
        }
    }
    
    @ViewBuilder
    private var collectionView: some View {
        
        FullSpeedVStackCollectionView(rows: viewModel.sectionsDisplayed,
                                      collectionViewId: "testIdForOnlyThisTab",
                                      backgroundColor: UIColor.red,
                                      needsToScrollToBottom: nil,
                                      needsToScrollToItem: $viewModel.scrollToItem,
                                      sectionLayoutProvider: { sectionIndex, layoutEnvironment in
            
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                  heightDimension: .fractionalHeight(1))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                   heightDimension: .absolute(50))
            
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, repeatingSubitem: item, count: 1)
            
            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = 0
            
            let header = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                   heightDimension: .absolute(0)),
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .topLeading
            )
            section.boundarySupplementaryItems = [header]
            return section
            
        },
        cell: { indexPath, cellModel in
            Text("indexPath row: \(indexPath.row)")
                .foregroundStyle(.black)
            
        }, supplementaryView: { kind, indexPath in
            
        }, onGestureShouldBegin: { _, _ in
            return true
        }, onScroll: {
            scrollView in
        }, scrollViewEndDragging: { _ in },
        scrollViewBeginDragging: { _ in },
        willDisplayCell: { _, _, _ in })
    }
}

#Preview {
    TestCollectionView()
}

fileprivate enum SectionType: SectionItemProtocol {
    case main
    var headerString: String {
        switch self {
        case .main:
            return ""
        }
    }
}

fileprivate final class CellViewModel: CellItemProtocol, ObservableObject, Identifiable, Hashable {
    
    var description: String { id }
    
    static func == (lhs: CellViewModel, rhs: CellViewModel) -> Bool {
        lhs.id == rhs.id
    }
    
    init() {
        id = UUID().uuidString
    }
    let id: String
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    var contentToSearchWhenSearching: String {
        return ""
    }
}
