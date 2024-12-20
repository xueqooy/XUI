//
//  BarChartLegendGroupView.swift
//  XUI
//
//  Created by xueqooy on 2024/5/10.
//

import UIKit
import XKit

class BarChartLegendGroupView: UIView {
    private static let insets: UIEdgeInsets = .init(uniformValue: .XUI.spacing2)
    private static let minimumInteritemSpacing: CGFloat = .XUI.spacing3

    var legends = [BarChartLegend]() {
        didSet {
            guard oldValue != legends else { return }

            collectionView.reloadData()

            updateContentSize()
        }
    }

    var preferredLayoutWidth: CGFloat = 0 {
        didSet {
            guard oldValue != preferredLayoutWidth else { return }

            updateContentSize()
        }
    }

    private let collectionView: UICollectionView

    override init(frame: CGRect) {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumInteritemSpacing = Self.minimumInteritemSpacing
        flowLayout.minimumLineSpacing = .XUI.spacing1
        collectionView = UICollectionView(frame: .init(origin: .zero, size: CGSize(width: 200, height: 30)), collectionViewLayout: flowLayout)

        super.init(frame: frame)

        collectionView.backgroundColor = .clear
        collectionView.register(LegendCell.self, forCellWithReuseIdentifier: "LegendCell")
        collectionView.delegate = self
        collectionView.dataSource = self

        addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        layer.cornerRadius = 4
        layer.borderWidth = 1
        layer.borderColor = Colors.line2.cgColor
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func updateContentSize() {
        var collectionViewWidth = preferredLayoutWidth

        // Minimize the size as much as possible while keeping the width within preferredLayoutWidth

        var maxWidth: CGFloat = legends.reduce(0.0) {
            $0 + LegendCell.calculateSize(for: $1.label, maxWidth: preferredLayoutWidth).width
        }
        let reservedWidth: CGFloat = 5
        maxWidth += Self.insets.horizontal + CGFloat(max(legends.count - 1, 0)) * Self.minimumInteritemSpacing + reservedWidth

        if maxWidth < preferredLayoutWidth {
            collectionViewWidth = maxWidth
        }

        collectionView.bounds.size.width = collectionViewWidth
        collectionView.collectionViewLayout.invalidateLayout()
        invalidateIntrinsicContentSize()
    }

    override var intrinsicContentSize: CGSize {
        collectionView.collectionViewLayout.collectionViewContentSize
    }
}

extension BarChartLegendGroupView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        legends.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LegendCell", for: indexPath) as! LegendCell

        cell.update(withLegend: legends[indexPath.item])

        return cell
    }

    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        LegendCell.calculateSize(for: legends[indexPath.item].label, maxWidth: max(0, bounds.width - Self.insets.horizontal))
    }

    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, insetForSectionAt _: Int) -> UIEdgeInsets {
        Self.insets
    }
}

private class LegendCell: UICollectionViewCell {
    private static let imageSize: CGSize = .square(12)
    private static let imageToLabelSpacing: CGFloat = .XUI.spacing1
    private static let labelFont = Fonts.caption

    private let colorImageView = UIImageView(image: Icons.roundSquare, contentMode: .scaleAspectFill)

    private let textLabel = UILabel(textColor: Colors.bodyText1, font: LegendCell.labelFont)

    override init(frame: CGRect) {
        super.init(frame: frame)

        let stackView = HStackView(alignment: .center, spacing: Self.imageToLabelSpacing) {
            colorImageView
                .settingSizeConstraint(Self.imageSize)

            textLabel
        }

        contentView.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(withLegend legend: BarChartLegend) {
        colorImageView.tintColor = legend.color
        textLabel.text = legend.label
    }

    static func calculateSize(for text: String, maxWidth: CGFloat) -> CGSize {
        let reservedWidth: CGFloat = 1
        let width = Self.imageSize.width + Self.imageToLabelSpacing + text.preferredSize(for: Self.labelFont, width: maxWidth).width + reservedWidth
        return .init(width: width, height: Self.imageSize.height)
    }
}
