//
//  MediaListView.swift
//  XUI
//
//  Created by xueqooy on 2023/10/8.
//

import UIKit
import XKit
import Combine

public class MediaListView: UIView {
    
    public class Item: StateObservableObject {
        
        public struct TrailingButtonConfiguration {
            public let image: UIImage
            public let action: ((MediaListView, Int) -> Void)?
            
            public init(image: UIImage, action: ((MediaListView, Int) -> Void)?) {
                self.image = image
                self.action = action
            }
        }
        
        @State
        public var media: MediaConvertible
        
        @EquatableState
        public var isLoading: Bool
        
        public let trailingButtonConfiguration: TrailingButtonConfiguration

        public init(media: MediaConvertible, trailingButtonConfiguration: TrailingButtonConfiguration, isLoading: Bool = false) {
            self.media = media
            self.trailingButtonConfiguration = trailingButtonConfiguration
            self.isLoading = isLoading
        }
    }
    
    public var title: String? {
        didSet {
            titleLabel.text = title
            titleRow.isHidden = (title ?? "").isEmpty
        }
    }
    
    public var items = [Item]() {
        didSet {
            guard !isUpdating else {
                return
            }
            
            reload()
        }
    }
    
    public var tapAction: ((MediaListView, Int) -> Void)?
        
    private let titleLabel = UILabel(textColor: Colors.title, font: Fonts.body1Bold)
    private lazy var titleRow: FormRow = {
        let row = FormRow(titleLabel, alignment: .center)
        row.customSpacingAfter = .XUI.spacing7
        row.isHidden = true
        return row
    }()
    
    private let formView: FormView = {
        let formView = FormView()
        formView.contentInset = .directionalZero
        formView.itemSpacing = .XUI.spacing2
        return formView
    }()
        
    private var mediaRows = [FormRow]()
    
    private var cancellables = Set<AnyCancellable>()
        
    private var isUpdating: Bool = false
    
    public convenience init(title: String? = nil, items: [Item] = [], tapAction: ((MediaListView, Int) -> Void)? = nil) {
        self.init(frame: .zero)
        
        self.tapAction = tapAction

        defer {
            self.title = title
            self.items = items
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        initialize()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        initialize()
    }
    
    private func initialize() {
        addSubview(formView)
        formView.snp.makeConstraints { make in
            make.edges.equalTo(safeAreaLayoutGuide)
        }
    }
    
    public func reload() {
        cancellables.removeAll()
        
        mediaRows = items.map { createRow(for: $0) }
        
        formView.populate {
            titleRow
            mediaRows
        }
    }
    
    public func insertItem(_ item: Item, at index: Int) {
        isUpdating = true
        defer {
            isUpdating = false
        }
        
        items.insert(item, at: index)
        
        let row = createRow(for: item)
        
        mediaRows.insert(row, at: index)
        formView.insertItem(row, at: index)
    }
    
    public func removeItem(at index: Int) {
        isUpdating = true
        defer {
            isUpdating = false
        }
        
        items.remove(at: index)
        
        mediaRows
            .remove(at: index)
            .removeFromForm()
        
        formView.invalidateIntrinsicContentSize()
    }
    
    private func createRow(for item: Item) -> FormRow {
        let trailingButon = Button(designStyle: .borderless, image: item.trailingButtonConfiguration.image) { [weak self] _ in
            guard let self = self, let action = item.trailingButtonConfiguration.action, let currentIndex = self.items.firstIndex(where: { item === $0 }) else {
                return
            }
            
            action(self, currentIndex)
        }
        let mediaView = MediaView(media: item.media.asMedia()) { [weak self] _ in
            guard let self = self, let tapAction = tapAction, let currentIndex = self.items.firstIndex(where: { item === $0 }) else {
                return
            }
            
            tapAction(self, currentIndex)
        }
        mediaView.trailingView = trailingButon
        mediaView.isLoading = item.isLoading
        
        item.stateDidChange
            .sink { [weak mediaView, weak item] in
                guard let mediaView = mediaView, let item = item else { return }
                
                mediaView.media = item.media.asMedia()
                mediaView.isLoading = item.isLoading
            }
            .store(in: &cancellables)
        
        return FormRow(mediaView, alignment: .fill)
    }
}

