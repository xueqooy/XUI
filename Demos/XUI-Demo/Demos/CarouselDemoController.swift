//
//  CarouselDemoController.swift
//  EDUI_Example
//
//  Created by xueqooy on 2023/8/22.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
import XUI
import SnapKit
import XKit

class CarouselDemoController: DemoController {
    override func viewDidLoad() {
        super.viewDidLoad()
                
        let flexibleCarouselView = CarouselView<BindingBackgroundView>()
        if Device.current.isPad {
            flexibleCarouselView.contentSize = .init(width: 350, height: .XUI.automaticDimension)
        } else {
            flexibleCarouselView.contentSize = .square(.XUI.automaticDimension) // Default
        }
        flexibleCarouselView.contentInitializer = {
            BindingBackgroundView(frame: .zero)
        }
        let heightAnchor = flexibleCarouselView.heightAnchor.constraint(equalToConstant: 108)
        heightAnchor.isActive = true
        let flexibleCarouselViewModels: [BackgoundViewMdodel] =
        (0...6).map { index -> (BackgoundViewMdodel) in
            BackgoundViewMdodel(index: index, config: .overlay().with {
                $0.fillColor = .randomColor()
                $0.stroke.color = .randomColor()
                $0.stroke.width = 2
            })
        }
        flexibleCarouselView.viewModels = flexibleCarouselViewModels
        
        let updateHeightButton = Button(designStyle: .primary, title: "Update Height") { [weak self] _ in
            guard let self else { return }
            UIView.animate(withDuration: 0.3) {
                heightAnchor.constant = CGFloat.random(in: 80...200)
                self.formView.layoutIfNeeded()
            }
        }
        
        
        let fixedSizeCarouselView = CarouselView<BindingBackgroundView>()
        fixedSizeCarouselView.layoutMargins = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        fixedSizeCarouselView.backgroundColor = Colors.teal
        fixedSizeCarouselView.pageControlColor = .white
        fixedSizeCarouselView.contentSize = CGSize(width: 278, height: 250)
        flexibleCarouselView.contentInitializer = {
            BindingBackgroundView(frame: .zero)
        }
        fixedSizeCarouselView.heightAnchor.constraint(equalToConstant: 300).isActive = true
        let fixedSizeCarouselViewModels: [BackgoundViewMdodel] =
        (0...6).map { index -> BackgoundViewMdodel in
            BackgoundViewMdodel(index: index, config: .overlay().with {
                $0.fillColor = .randomColor()
                $0.stroke.color = .randomColor()
                $0.stroke.width = 2
            })
        }
        fixedSizeCarouselView.viewModels = fixedSizeCarouselViewModels
        
        addTitle("Flexible Size")
        addRow(flexibleCarouselView, alignment: .fill)
        addRow(updateHeightButton)

        addSpacer(30)
        
        addTitle("Fixed Size")
        addRow(fixedSizeCarouselView, alignment: .fill)

    }
    
    func createLabel(for index: Int) -> UILabel {
        UILabel(text: "\(index)", textColor: .black, font: Fonts.h6, textAlignment: .center)
    }
}


private struct BackgoundViewMdodel {
    let index: Int
    let config: BackgroundConfiguration
}

private class BindingBackgroundView: BackgroundView, Bindable {
    let label: UILabel = UILabel(textColor: .black, font: Fonts.h6, textAlignment: .center)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(label)
        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bindViewModel(_ viewModel: BackgoundViewMdodel) {
        configuration = viewModel.config
        label.text = "\(viewModel.index)"
    }
}
