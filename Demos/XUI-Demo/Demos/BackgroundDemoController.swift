//
//  BackgroundDemoController.swift
//  EDUI_Example
//
//  Created by xueqooy on 2023/3/7.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
import XUI

class BackgroundDemoController: DemoController {
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = Colors.background1

        addTitle("Overlay")
        addRow(BackgroundView(configuration: .overlay()), height: 80, alignment: .fill)

        addTitle("Dimming")
        addRow(BackgroundView(configuration: .dimmingBlack()), height: 80, alignment: .fill)

        addTitle("Border")
        var borderConfig = BackgroundConfiguration()
        borderConfig.cornerStyle = .capsule
        borderConfig.stroke.width = 2
        borderConfig.stroke.color = Colors.teal
        borderConfig.fillColor = .white
        addRow(BackgroundView(configuration: borderConfig), height: 80, alignment: .fill)

        addTitle("Blur")

        let imageView = UIImageView()
//        imageView.sd_setImage(with: .randomImageURL(width: 400, height: 200))
        imageView.contentMode = .center
        imageView.clipsToBounds = true

        var blurConfig = BackgroundConfiguration()
        blurConfig.cornerStyle = .capsule
        blurConfig.visualEffect = UIBlurEffect(style: .regular)

        let blurBackgroundView = BackgroundView(configuration: blurConfig)

        imageView.addSubview(blurBackgroundView)
        blurBackgroundView.snp.makeConstraints { make in
            make.height.equalTo(80)
            make.centerY.leading.trailing.equalToSuperview()
        }
        addRow(imageView, height: 120, alignment: .fill)
    }
}
