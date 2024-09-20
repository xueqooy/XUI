//
//  PersonaView.swift
//  LLPUI
//
//  Created by xueqooy on 2024/1/4.
//

import UIKit
import LLPUtils

open class PersonaView: UIView, Configurable {
    
    public struct Layout {
        public enum VerticalAlignment {
            case center, top
        }
        
        public let avatarSize: AvatarSize
        
        public let verticalAlignment: VerticalAlignment
        
        /// When view has both avatar and label content, this value is the padding between the avatar and the label.
        public let avatarPadding: CGFloat
        /// When view has both a title & subtitle, this value is the padding between those titles.
        public let titlePadding: CGFloat
         
        public init(
            avatarSize: AvatarSize = .size40,
            verticalAlignment: VerticalAlignment = .center,
            avatarPadding: CGFloat = .LLPUI.spacing4,
            titlePadding: CGFloat = .LLPUI.spacing1) {
            self.avatarSize = avatarSize
            self.verticalAlignment = verticalAlignment
            self.avatarPadding = avatarPadding
            self.titlePadding = titlePadding
        }
    }

    public struct Configuration: Equatable, Then {
        public var avatarURLConfiguration: AvatarURLConfiguration?
        
        // richTitle > attributedTitle > title
        public var title: String?
        public var titleStyle: TextStyleConfiguration?
        public var richTitle: RichText?
        public var numberOfTileLines = 1
        
        // richSubtitle > attributedSubtitle > subtitle
        public var subtitle: String?
        public var subtitleStyle: TextStyleConfiguration?
        public var richSubtitle: RichText?
        public var numberOfSubtileLines = 1
        
        public init(
            avatarURLConfiguration: AvatarURLConfiguration? = nil,
            title: String? = nil,
            titleStyle: TextStyleConfiguration? = .personaTitle,
            attributedTitle: NSAttributedString? = nil,
            richTitle: RichText? = nil,
            numberOfTileLines: Int = 1,
            subtitle: String? = nil,
            subtitleStyle: TextStyleConfiguration? = .personaSubtitle,
            attributedSubtitle: NSAttributedString? = nil,
            richSubtitle: RichText? = nil,
            numberOfSubtileLines: Int = 1) {
            self.avatarURLConfiguration = avatarURLConfiguration
            self.title = title
            self.titleStyle = titleStyle
            self.richTitle = richTitle
            self.subtitle = subtitle
            self.subtitleStyle = subtitleStyle
            self.richSubtitle = richSubtitle
        }
        
        public mutating func clearTitle() {
            title = nil
            richTitle = nil
        }
        
        public mutating func clearSubtitle() {
            subtitle = nil
            richSubtitle = nil
        }
    }
    
    public var avatarTapHandler: (() -> Void)? {
        didSet {
            avatarView.tapHandler = avatarTapHandler
        }
    }
    
    public var configuration: Configuration {
        didSet {
            guard oldValue != configuration else {
                return
            }
            
            applyConfiguration()
        }
    }
    
    private var shouldDisplayAvatar: Bool {
        configuration.avatarURLConfiguration != nil
    }
    
    private var shouldDisplayTitle: Bool {
        if let richTitle = configuration.richTitle {
            return richTitle.length > 0
        }
        if let title = configuration.title{
            return !title.isEmpty
        }
        return false
    }
    
    private var shouldDisplaySubtitle: Bool {
        if let richSubtitle = configuration.richSubtitle {
            return richSubtitle.length > 0
        }
        if let subtitle = configuration.subtitle {
            return !subtitle.isEmpty
        }
        return false
    }
    
    private let avatarView = AvatarView()
    
    private let titleLabel = UILabel()
    
    private let subtitleLabel = UILabel()
    
    private let layout: Layout
    
    public required init(layout: Layout = .init(), configuration: Configuration = .init()) {
        self.layout = layout
        self.configuration = configuration
        
        super.init(frame: .zero)
        
        initialize()
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initialize() {
        let hStackAlignment: UIStackView.Alignment
        switch layout.verticalAlignment {
        case .center:
            hStackAlignment = .center
        case .top:
            hStackAlignment = .top
        }
        
        avatarView.size = layout.avatarSize
        
        let contentStackView = HStackView(alignment: hStackAlignment, spacing: layout.avatarPadding) {
            avatarView
            
            VStackView(spacing: layout.titlePadding) {
                titleLabel
                subtitleLabel
            }
        }
        
        addSubview(contentStackView)
        contentStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        applyConfiguration()
    }
    
    private func applyConfiguration() {
        avatarView.isHidden = !shouldDisplayAvatar
        titleLabel.isHidden = !shouldDisplayTitle
        subtitleLabel.isHidden = !shouldDisplaySubtitle
        
        if let avatarURLConfiguration = configuration.avatarURLConfiguration {
            avatarView.urlConfiguration = avatarURLConfiguration
        }
        
        if let titleStyle = configuration.titleStyle {
            titleLabel.textStyleConfiguration = titleStyle
        } else {
            titleLabel.textStyleConfiguration = .init()
        }
        if let richTitle = configuration.richTitle {
            titleLabel.richText = richTitle
        } else if let title = configuration.title {
            titleLabel.text = title
        }
        titleLabel.numberOfLines = configuration.numberOfTileLines
        
        if let subtitleStyle = configuration.subtitleStyle {
            subtitleLabel.textStyleConfiguration = subtitleStyle
        } else {
            subtitleLabel.textStyleConfiguration = .init()
        }
        if let richSubtitle = configuration.richSubtitle {
            subtitleLabel.richText = richSubtitle
        } else if let subtitle = configuration.subtitle {
            subtitleLabel.text = subtitle
        }
        subtitleLabel.numberOfLines = configuration.numberOfSubtileLines
    }
    
}
