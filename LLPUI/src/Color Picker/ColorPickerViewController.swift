//
//  ColorPickerViewController.swift
//  LLPUI
//
//  Created by xueqooy on 2024/2/20.
//

import UIKit

class ColorPickerViewController: UIViewController {

    private static let cellReuseIdentifier = "ColorPickerCell"
        
    private static let formRowSpacing: CGFloat = .LLPUI.spacing7
    
    private static var maximumColumns = 5
    
    private static let itemSize = CGSize(width: 57, height: 57)
    
    private static let minimumLineSpacing: CGFloat = .LLPUI.spacing4
   
    
    let colors: [UIColor]
    
    var selectedColor: UIColor? {
        didSet {
            if shouldShowConfirmationButton {
                self.confirmationButton.isEnabled = selectedColor != nil
            }
        }
    }
    
    var shouldShowPickerTitle: Bool {
        !(pickerTitle ?? "").isEmpty
    }
    
    var shouldShowConfirmationButton: Bool {
        !(confirmationButtonTitle ?? "").isEmpty
    }
    
    private let pickerTitle: String?
     
    private let confirmationButtonTitle: String?
    
    private let selectionHandler: (ColorPickerViewController) -> Void
    
    private lazy var titleLabel = UILabel(text: pickerTitle, textColor: Colors.title, font: Fonts.body1Bold)
    
    private lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.backgroundColor = .clear
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(ColorPickerCell.self, forCellWithReuseIdentifier: Self.cellReuseIdentifier)
        
        return collectionView
    }()
    
    private lazy var confirmationButton = Button(designStyle: .primary, title: confirmationButtonTitle) { [weak self] _ in
        guard let self, self.selectedColor != nil else { return }
        
        self.selectionHandler(self)
    }
    
    init(colors: [UIColor], selectedColor: UIColor?, pickerTitle: String?, confirmationButtonTitle: String?, selectionHandler: @escaping (ColorPickerViewController) -> Void) {
        self.colors = colors
        self.selectedColor = selectedColor
        self.pickerTitle = pickerTitle
        self.confirmationButtonTitle = confirmationButtonTitle
        self.selectionHandler = selectionHandler
        
        super.init(nibName: nil, bundle: nil)
        
        view.addForm(scrollingBehavior: .disabled) { formView in
            formView.contentInset = .directionalZero
            formView.itemSpacing = Self.formRowSpacing
        } populate: {
            if shouldShowPickerTitle {
                FormRow(titleLabel, alignment: .center)
            }
            
            FormRow(collectionView, alignment: .center)
            
            if shouldShowConfirmationButton {
                FormRow(confirmationButton, alignment: .center)
            }
        }
        
        var actualSelectedColor = selectedColor
        if let selectedColor {
            if let item = colors.firstIndex(of: selectedColor) {
                collectionView.selectItem(at: IndexPath(item: item, section: 0), animated: false, scrollPosition: .centeredVertically)

            } else {
                actualSelectedColor = nil
            }
        }
        
        defer {
            self.selectedColor = actualSelectedColor
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var preferredContentSize: CGSize {
        get {
            let colorColumns = CGFloat(Self.maximumColumns)
            let colorRows = ceil(CGFloat(colors.count) / CGFloat(Self.maximumColumns))
            
            var formRows: CGFloat = 0
            
            let width: CGFloat = colorColumns * Self.itemSize.width + (colorColumns - 1) * Self.minimumLineSpacing
            var height: CGFloat = 0
            
            // Append title height
            if shouldShowPickerTitle {
                formRows += 1
                
                let titleHeight = titleLabel.sizeThatFits(.zero).height
                height += titleHeight
            }
            
            // Append colors height
            if !colors.isEmpty {
                formRows  += 1
                
                let colorsHeight = colorRows * Self.itemSize.height + (colorRows - 1) * Self.minimumLineSpacing
                height += colorsHeight
            }
        
            
            // Append button height
            if shouldShowConfirmationButton {
                formRows += 1
                
                let buttonHeight = confirmationButton.sizeThatFits(.max).height
                height += buttonHeight
            }
            
            // Append spacing between form rows
            height += (formRows - 1) * Self.formRowSpacing
                   
            return CGSize(width: width, height: height)
        }
        set {
            super.preferredContentSize = newValue
        }
    }

}


extension ColorPickerViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        colors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Self.cellReuseIdentifier, for: indexPath) as! ColorPickerCell
        
        cell.color = colors[indexPath.item]
        
        return cell
    }
    
}

extension ColorPickerViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        Self.itemSize
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        Self.minimumLineSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedColor = colors[indexPath.item]
        
        guard !shouldShowConfirmationButton else {
            return
        }
        
        selectionHandler(self)
    }
    
}
