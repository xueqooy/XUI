//
//  ViewAllEntitiesCell.swift
//  LLPUI
//
//  Created by xueqooy on 2024/5/31.
//

import UIKit
import IGListKit

class ViewAllEntitiesCell: UICollectionViewCell, ListCellSizeProviding, ListBindable {
    
    override var isHighlighted: Bool {
        didSet {
            contentView.alpha = isHighlighted ? .LLPUI.highlightAlpha : 1
        }
    }
    
    private let textLabel = UILabel()
    
    var cellSizeOptions: ListCellSizeOptions {
        [.compress, .cache, .configureCell]
    }
    
    private var height: CGFloat = 14
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(textLabel)
        textLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bindViewModel(_ viewModel: Any) {
        let viewModel = viewModel as! ViewAllEntitiesViewModel
        
        height = viewModel.height
        
        textLabel.richText = RTText( Strings.viewAll(viewModel.additionalCount), .foreground(Colors.teal), .font(Fonts.button3), .underline(.single))
    }
    
    var cellSize: CGSize {
        .init(width: .LLPUI.automaticDimension, height: height)
    }
}
