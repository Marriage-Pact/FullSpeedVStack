# FullSpeedVStack

A high-performance SwiftUI package that provides native UICollectionView and UITableView wrappers for displaying large lists with smooth scrolling and advanced features.

## Why FullSpeedVStack?

SwiftUI's native `List` and `LazyVStack` can struggle with performance when displaying thousands of items or complex layouts. FullSpeedVStack leverages the battle-tested performance of UIKit's collection and table views while maintaining a SwiftUI-first API.

**Key Benefits:**
- 🚀 **High Performance**: Handles thousands of items smoothly
- 🔄 **Diffable Data Sources**: Efficient updates with automatic animations
- 🎯 **Advanced Layouts**: Full support for UICollectionViewCompositionalLayout
- 📱 **SwiftUI Integration**: Native SwiftUI view builders and bindings
- 🔍 **Built-in Search**: Integrated search functionality
- 📍 **Scroll Control**: Programmatic scrolling with animation support
- 🔀 **Flexible**: Both collection view and table view implementations

## Installation

### Swift Package Manager

Add FullSpeedVStack to your project through Xcode:

1. File → Add Package Dependencies
2. Enter the repository URL: `https://github.com/Marriage-Pact/FullSpeedVStack`
3. Select your desired version

## Quick Start

### 1. Define Your Data Models. A Chat/Messaging App Example:

Your section and cell models must conform to the required protocols:

```swift
import FullSpeedVStack

// Define your section types
enum ChatSection: SectionItemProtocol {
    case messages
    case typing
    
    var headerString: String {
        switch self {
        case .messages: return "Messages"
        case .typing: return "Typing"
        }
    }
}

// SectionItemProtocol requires Comparable, so we need to implement it
extension ChatSection: Comparable {
    static func < (lhs: ChatSection, rhs: ChatSection) -> Bool {
        switch (lhs, rhs) {
        case (.messages, .typing): return true
        case (.typing, .messages): return false
        case (.messages, .messages), (.typing, .typing): return false
        }
    }
}

// Define your cell models
struct Message: CellItemProtocol {
    let id = UUID()
    let text: String
    let author: String
    let timestamp: Date
    
    var contentToSearchWhenSearching: String {
        return "\(text) \(author)"
    }
    
    var description: String { text }
    
    // Required Hashable implementation
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    // Required Equatable implementation
    static func == (lhs: Message, rhs: Message) -> Bool {
        return lhs.id == rhs.id
    }
}
```

### 2. Create Your Collection View, (if you prefer a TableView, please see the `Table View Alternative` section below)

```swift
import SwiftUI
import FullSpeedVStack

struct ChatView: View {
    @State private var messages: [Message] = []
    @State private var scrollToItem: ScrollToItemAnimated?
    
    var body: some View {
        FullSpeedVStackCollectionView(
            rows: [
                FullSpeedVStackSectionWithCells(
                    section: ChatSection.messages,
                    items: messages,
                    displaySectionsWhenEmpty: false
                )
            ],
            collectionViewId: "chat-collection",
            backgroundColor: UIColor.systemBackground,
            needsToScrollToBottom: nil,
            needsToScrollToItem: $scrollToItem,
            sectionLayoutProvider: { sectionIndex, layoutEnvironment in
                // Define your layout
                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .estimated(60)
                )
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .estimated(60)
                )
                let group = NSCollectionLayoutGroup.horizontal(
                    layoutSize: groupSize,
                    repeatingSubitem: item,
                    count: 1
                )
                
                return NSCollectionLayoutSection(group: group)
            },
            cell: { indexPath, message in
                // Your SwiftUI cell view
                MessageCell(message: message)
            },
            supplementaryView: { kind, indexPath in
                // Optional headers/footers
                EmptyView()
            },
            onGestureShouldBegin: { _, _ in true },
            onScroll: { scrollView, collectionView in
                // Handle scroll events
            },
            scrollViewEndDragging: { _, _ in },
            scrollViewBeginDragging: { _, _ in },
            willDisplayCell: { _, _, _ in }
        )
    }
}

struct MessageCell: View {
    let message: Message
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(message.author)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(message.text)
                    .font(.body)
            }
            Spacer()
            Text(message.timestamp, style: .time)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}
```

## Advanced Features

### Custom Layouts

Create complex layouts using UICollectionViewCompositionalLayout:

```swift
sectionLayoutProvider: { sectionIndex, layoutEnvironment in
    switch sectionIndex { }
}
```

### Headers and Footers

Add section headers and footers:

```swift
sectionLayoutProvider: { sectionIndex, layoutEnvironment in
    ...
    section.boundarySupplementaryItems = [header]
    
    return section
},
supplementaryView: { kind, indexPath in
    if kind == UICollectionView.elementKindSectionHeader {
        SectionHeaderView(title: "Section \(indexPath.section)")
    } else {
        EmptyView()
    }
}
```

### Programmatic Scrolling

Scroll to specific items programmatically:

```swift
struct ContentView: View {
    @State private var scrollToItem: ScrollToItemAnimated?
    
    var body: some View {
        VStack {
            Button("Scroll to Item 50") {
                scrollToItem = ScrollToItemAnimated(
                    indexPath: IndexPath(item: 50, section: 0),
                    animated: true
                )
            }
            
            FullSpeedVStackCollectionView(
                // ... other parameters
                needsToScrollToItem: $scrollToItem,
                // ... rest of configuration
            )
        }
    }
}
```

### Delegate Methods

FullSpeedVStack exposes several delegate methods that allow you to respond to scroll events and control gesture behavior:

#### onGestureShouldBegin

Control whether pan gestures should begin. Useful for implementing custom gesture handling or preventing scrolling in certain conditions:

```swift
onGestureShouldBegin: { gestureRecognizer, scrollView in }
```

#### onScroll

Respond to scroll events in real-time. Perfect for implementing parallax effects, or tracking scroll position:

```swift
onScroll: { scrollView, collectionView in }
```

#### scrollViewBeginDragging

Called when the user starts dragging the scroll view:

```swift
scrollViewBeginDragging: { scrollView, collectionView in }
```

#### scrollViewEndDragging

Called when the user stops dragging the scroll view:

```swift
scrollViewEndDragging: { scrollView, collectionView in }
```

#### willDisplayCell

Called just before a cell is displayed. Useful for triggering data loading, analytics, or animations:

```swift
willDisplayCell: { collectionView, cell, indexPath in }
```

### Inverted Views (Chat-style)

When creating a chat/message view it's helpfule to invert the view, so that the most recent messages are easier to access.
To do so set `invertView: true`

```swift
FullSpeedVStackCollectionView(
    rows: chatSections,
    collectionViewId: "chat",
    backgroundColor: UIColor.systemBackground,
    invertView: true, // This inverts the entire view
    // ... rest of configuration
)
```

### Table View Alternative

For simpler list layouts, use the UITableView version:

```swift
enum SimpleSection: SectionItemProtocol {
    case main
    
    var headerString: String {
        return "Items"
    }
}

// MARK: - Cell Model
struct SimpleItem: CellItemProtocol {
    let id = UUID()
    let title: String
    
    var description: String { title }
    var contentToSearchWhenSearching: String { title }
    
    static func == (lhs: SimpleItem, rhs: SimpleItem) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct TableViewExample: View {
    private let items = (1...20).map { SimpleItem(title: "Item \($0)") }
    
    private var sections: [FullSpeedVStackSectionWithCells<SimpleSection, SimpleItem>] {
        [FullSpeedVStackSectionWithCells(
            section: .main,
            items: items,
            displaySectionsWhenEmpty: false
        )]
    }
    
    var body: some View {
        FullSpeedVStackTableView(
            rows: sections,
            backgroundColor: UIColor.systemBackground,
            needsToScrollToBottom: nil,
            cell: { indexPath, item in
                Text(item.title)
                    .padding()
            },
            supplementaryView: { kind, indexPath in
                Text("Header")
                    .font(.headline)
                    .padding()
            },
            onGestureShouldBegin: { _, _ in true },
            onScroll: { _ in },
            scrollViewEndDragging: { _ in },
            scrollViewBeginDragging: { _ in },
            willDisplayCell: { _, _, _ in }
        )
    }
}

```

## Protocol Requirements

### SectionItemProtocol

Your section enum must conform to `SectionItemProtocol`:

```swift
enum MySection: SectionItemProtocol {
    case first
    case second
    
    var headerString: String {
        switch self {
        case .first: return "First Section"
        case .second: return "Second Section" 
        }
    }
}

// Required Comparable implementation
extension MySection: Comparable {
    static func < (lhs: MySection, rhs: MySection) -> Bool {
        switch (lhs, rhs) {
        case (.first, .second): return true
        case (.second, .first): return false
        case (.first, .first), (.second, .second): return false
        }
    }
}
```

**Important Implementation Notes:**
- For enums with associated values, include the associated value in `hash(into:)`
- Implement complete switch statements in `static func ==`

```swift
enum ComplexSection: SectionItemProtocol {
    case category(CategoryViewModel)
    case items(ItemsViewModel)
    
    var headerString: String {
        switch self {
        case .category: return "Categories"
        case .items: return "Items"
        }
    }
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case .category(let viewModel):
            hasher.combine(viewModel)
        case .items(let viewModel):
            hasher.combine(viewModel)
        }
    }
    
    static func == (lhs: ComplexSection, rhs: ComplexSection) -> Bool {
        switch (lhs, rhs) {
        case (.category(let lhsViewModel), .category(let rhsViewModel)):
            return lhsViewModel == rhsViewModel
        case (.items(let lhsViewModel), .items(let rhsViewModel)):
            return lhsViewModel == rhsViewModel
        default:
            return false
        }
    }
}

// Required Comparable implementation
extension ComplexSection: Comparable {
    static func < (lhs: ComplexSection, rhs: ComplexSection) -> Bool {
        switch (lhs, rhs) {
        case (.category, .items): return true
        case (.items, .category): return false
        case (.category, .category), (.items, .items): return false
        }
    }
}
```

### CellItemProtocol

Your cell models must conform to `CellItemProtocol`:

```swift
struct MyItem: CellItemProtocol {
    let id = UUID()
    let title: String
    let subtitle: String
    
    var contentToSearchWhenSearching: String {
        return "\(title) \(subtitle)"
    }
    
    var description: String { title }
    
    // Required Hashable implementation
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    // Required Equatable implementation
    static func == (lhs: MyItem, rhs: MyItem) -> Bool {
        return lhs.id == rhs.id
    }
}
```

## Performance Tips

1. **Implement Proper Hashing**: Ensure your models have efficient `hash(into:)` implementations
2. **Minimize Cell Complexity**: Keep cell views lightweight
3. **Batch Updates**: Group data changes together for better animation performance

## Common Patterns

### Empty States

```swift
FullSpeedVStackSectionWithCells(
    section: .content,
    items: items,
    displaySectionsWhenEmpty: items.isEmpty // Show section even when empty
)
```

## Troubleshooting

### Common Issues

**Cells not updating**: Ensure your models properly implement `Hashable` and `Equatable`

**Layout issues**: Verify your `sectionLayoutProvider` returns valid layout configurations

**Memory leaks**: Check that you're not creating retain cycles in your closures

**Scroll position**: Use the `needsToScrollToItem` binding for programmatic scrolling

### Debug Tips

- Use the `willDisplayCell` callback to monitor cell lifecycle

## Requirements

- iOS 16.0+
- Swift 5.9+
- Xcode 15.0+
