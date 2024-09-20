//
//  FormSpacer.swift
//  LLPUI
//
//  Created by xueqooy on 2023/3/4.
//

import UIKit
import LLPUtils

public class FormSpacer: FormItem {
   
    public struct Constants {
        public static let defaultSpacing: CGFloat = 0
        public static let defaultHuggingPriority: UILayoutPriority = .dragThatCannotResizeScene
        public static let defaultcompressionResistancePriority: UILayoutPriority = .dragThatCannotResizeScene
    }
    
    @EquatableState
    public var spacing: CGFloat {
        didSet {
            (loadedView as? FormSpacerView)?.spacing = spacing
        }
    }
    
    @EquatableState
    public var huggingPriority: UILayoutPriority {
        didSet {
            (loadedView as? FormSpacerView)?.huggingPriority = huggingPriority
        }
    }
    
    @EquatableState
    public var compressionResistancePriority: UILayoutPriority {
        didSet {
            (loadedView as? FormSpacerView)?.compressionResistancePriority = compressionResistancePriority
        }
    }
        
    public init(_ spacing: CGFloat = Constants.defaultSpacing, huggingPriority: UILayoutPriority = Constants.defaultHuggingPriority, compressionResistancePriority: UILayoutPriority = Constants.defaultcompressionResistancePriority) {
        self.spacing = spacing
        self.huggingPriority = huggingPriority
        self.compressionResistancePriority = compressionResistancePriority
        
        super.init()
    }

    public static func flexible() -> FormSpacer {
        FormSpacer(.greatestFiniteMagnitude, compressionResistancePriority: .fittingSizeLevel)
    }
    
    override func createView() -> UIView {
        FormSpacerView(spacing, huggingPriority: huggingPriority, compressionResistancePriority: compressionResistancePriority)
    }
}

class FormSpacerView: VSpacerView {
}
