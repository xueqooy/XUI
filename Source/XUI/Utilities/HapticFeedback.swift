//
//  HapticFeedback.swift
//  XUI
//
//  Created by 🌊 薛 on 2022/9/22.
//

import AudioToolbox
import Foundation
import UIKit

private enum ImpactHapticFeedbackStyle {
    case light
    case medium
    case heavy
}

private final class HapticFeedbackImpl {
    private lazy var impactGenerator: [ImpactHapticFeedbackStyle: UIImpactFeedbackGenerator] = [.light: UIImpactFeedbackGenerator(style: .light),
                                                                                                .medium: UIImpactFeedbackGenerator(style: .medium),
                                                                                                .heavy: UIImpactFeedbackGenerator(style: .heavy)]

    private lazy var selectionGenerator: UISelectionFeedbackGenerator? = {
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        return generator
    }()

    private lazy var notificationGenerator: UINotificationFeedbackGenerator? = {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        var string = generator.debugDescription
        string.removeLast()
        let number = string.suffix(1)
        if number == "1" {
            return generator
        } else {
            return nil
        }
    }()

    func prepareTap() {
        if let selectionGenerator = selectionGenerator {
            selectionGenerator.prepare()
        }
    }

    func tap() {
        if let selectionGenerator = selectionGenerator {
            selectionGenerator.selectionChanged()
        }
    }

    func prepareImpact(_ style: ImpactHapticFeedbackStyle) {
        if let impactGenerator = impactGenerator[style] {
            impactGenerator.prepare()
        }
    }

    func impact(_ style: ImpactHapticFeedbackStyle) {
        if let impactGenerator = impactGenerator[style] {
            impactGenerator.impactOccurred()
        }
    }

    func prepareSuccess() {
        if let notificationGenerator = notificationGenerator {
            notificationGenerator.prepare()
        }
    }

    func success() {
        if let notificationGenerator = notificationGenerator {
            notificationGenerator.notificationOccurred(.success)
        } else {
            AudioServicesPlaySystemSound(1520)
        }
    }

    func prepareWarning() {
        if let notificationGenerator = notificationGenerator {
            notificationGenerator.prepare()
        }
    }

    func warning() {
        if let notificationGenerator = notificationGenerator {
            notificationGenerator.notificationOccurred(.warning)
        } else {
            AudioServicesPlaySystemSound(1520)
        }
    }

    func prepareError() {
        if let notificationGenerator = notificationGenerator {
            notificationGenerator.prepare()
        }
    }

    func error() {
        if let notificationGenerator = notificationGenerator {
            notificationGenerator.notificationOccurred(.error)
        } else {
            AudioServicesPlaySystemSound(1521)
        }
    }

    @objc dynamic func f() {}
}

public enum HapticFeedbackType {
    case light
    case medium
    case heavy
    case tap
    case success
    case warning
    case error
}

public final class HapticFeedback {
    public let type: HapticFeedbackType

    private var impl: AnyObject?

    public init(type: HapticFeedbackType = .light) {
        self.type = type
    }

    deinit {
        let impl = self.impl
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) {
            if let impl = impl as? HapticFeedbackImpl {
                impl.f()
            }
        }
    }

    public func prepare() {
        let type = self.type
        withImpl { impl in
            switch type {
            case .light:
                impl.prepareImpact(.light)
            case .medium:
                impl.prepareImpact(.medium)
            case .heavy:
                impl.prepareImpact(.heavy)
            case .tap:
                impl.prepareTap()
            case .success:
                impl.prepareSuccess()
            case .warning:
                impl.prepareWarning()
            case .error:
                impl.prepareError()
            }
        }
    }

    public func trigger() {
        let type = self.type
        withImpl { impl in
            switch type {
            case .light:
                impl.impact(.light)
            case .medium:
                impl.impact(.medium)
            case .heavy:
                impl.impact(.heavy)
            case .tap:
                impl.tap()
            case .success:
                impl.success()
            case .warning:
                impl.warning()
            case .error:
                impl.error()
            }
        }
    }

    private func withImpl(_ f: (HapticFeedbackImpl) -> Void) {
        if impl == nil {
            impl = HapticFeedbackImpl()
        }
        f(impl as! HapticFeedbackImpl)
    }
}
