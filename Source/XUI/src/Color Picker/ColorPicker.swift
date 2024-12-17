//
//  ColorPicker.swift
//  XUI
//
//  Created by xueqooy on 2024/2/20.
//

import UIKit
import XKit

public class ColorPicker {
    
    public static let defaultColors: [UIColor] = [
        "e33c37",
        "e66838",
        "3583e5",
        "28a992",
        "e53683",
        "39c9e6",
        "7f42c9",
        "4cb855",
        "717991",
        "fecb00"]
        .map { UIColor(hexString: $0)! }
    
    public let colors: [UIColor]
    
    private let selectedColor: UIColor?
    
    private let title: String?
     
    private let confirmationButtonTitle: String?
    
    private let selectionHandler: (UIColor) -> Void
    
    public init(colors: [UIColor] = defaultColors, selectedColor: UIColor? = nil, title: String? = nil, confirmationButtonTitle: String? = nil, selectionHandler: @escaping (UIColor) -> Void) {
        self.colors = colors
        self.selectedColor = selectedColor
        self.title = title
        self.confirmationButtonTitle = confirmationButtonTitle
        self.selectionHandler = selectionHandler
    }
 
    @MainActor public func show(in viewController: UIViewController, sourceView: UIView? = nil, sourceRect: CGRect? = nil) {
        
        let presentationStyle: DrawerController.PresentationStyle = sourceView == nil && sourceRect == nil ? .slideover : .automatic
        let sourceRect = sourceRect ?? sourceView?.bounds ?? CGRect(origin: viewController.view.center, size: .zero)
        let sourceView = sourceView ?? viewController.view!
        let configuration: DrawerController.Configuration = .init(presentationStyle: presentationStyle, presentationDirection: .up, resizingBehavior: .dismiss)
        
        let drawer = DrawerController(sourceView: sourceView, sourceRect: sourceRect, configuration: configuration)
        drawer.contentController = createContentController(for: drawer)
       
        viewController.present(drawer, animated: true)
    }
    
    private func createContentController(for presentedController: UIViewController) -> UIViewController {
        let selectionHandler = selectionHandler
        
        let view = ColorPickerViewController(colors: colors, selectedColor: selectedColor, pickerTitle: title, confirmationButtonTitle: confirmationButtonTitle) { [weak presentedController] viewController in
            
            let selectedColor = viewController.selectedColor!
            
            if let presentedController = presentedController {
                func hideAndCallback() {
                    presentedController.dismiss(animated: true) {
                        selectionHandler(selectedColor)
                    }
                }
                
                if !viewController.shouldShowConfirmationButton {
                    // Delay to hide
                    Queue.main.execute(.delay(0.15), work: hideAndCallback)
                } else {
                    hideAndCallback()
                }
                
            } else {
               selectionHandler(selectedColor)
            }
        }
        
        return view
    }
    
}
