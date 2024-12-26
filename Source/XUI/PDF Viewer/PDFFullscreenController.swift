//
//  PDFFullscreenWindow.swift
//  XUI
//
//  Created by xueqooy on 2024/12/26.
//

import UIKit
import PDFKit
import Combine

class PDFFullscreenController {
    enum Event {
        case willEnter // Provide a opportunity to update display mode, mode button will be updated after this event
        case didEnter
        case willExit
        case didExit
        case fullscreenSizeDidChange
        case updateFullscreenDisplayMode(PDFDisplayMode)
    }
    
    var isFullscreen: Bool {
        guard let window else { return false }

        return !window.isHidden
    }
    
    private var pdfView: PDFView
    private var containerView: UIView
    private let eventHandler: (Event) -> Void
    private var window: PDFFullscreenWindow?
    private weak var sourceWindow: UIWindow?
    private var pageObservation: AnyCancellable?
    
    init(pdfView: PDFView, containerView: UIView, eventHandler: @escaping (Event) -> Void) {
        self.pdfView = pdfView
        self.containerView = containerView
        self.eventHandler = eventHandler
    }
    
    func enterFullscreen() {
        guard !isFullscreen else { return }
        
        let window = self.window ?? PDFFullscreenWindow()
        window.viewController.viewSizeChangedHandler = { [weak self] in
            self?.eventHandler(.fullscreenSizeDidChange)
        }
        window.viewController.controlBar.exitHandler = { [weak self] in
            self?.exitFullscreen()
        }
        window.viewController.controlBar.updateDisplayModeHandler = { [weak self] mode in
            self?.eventHandler(.updateFullscreenDisplayMode(mode))
        }
        self.window = window
        
        // Observe the page change
        window.viewController.controlBar.numberOfPages = pdfView.document?.pageCount ?? 0
        window.viewController.controlBar.currentPageIndex = pdfView.currentPage?.pageRef?.pageNumber ?? 0
        pageObservation = NotificationCenter.default.publisher(for: .PDFViewPageChanged, object: pdfView)
            .sink { [weak self] _  in
                guard let self else { return }
                window.viewController.controlBar.numberOfPages = self.pdfView.document?.pageCount ?? 0
                window.viewController.controlBar.currentPageIndex = self.pdfView.currentPageIndex
            }
        
        if !isFullscreen {
            guard let sourceWindow = containerView.window else { return }
            
            self.sourceWindow = sourceWindow
            
            let sourceRect = containerView.convert(containerView.bounds, to: sourceWindow)
            
            sourceWindow.addSubview(pdfView)
            pdfView.autoresizingMask = []
            pdfView.frame = sourceRect
            pdfView.layoutIfNeeded()
            
            if !window.isKeyWindow {
                window.isHidden = false
                window.makeKeyAndVisible()
            }
        }

        // Transition
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveOut) {
            self.pdfView.bounds = window.bounds
            self.pdfView.center = window.center
            self.pdfView.layoutIfNeeded()
            
            self.eventHandler(.willEnter)
            
            window.viewController.controlBar.displayMode = self.pdfView.displayMode

        } completion: { _ in
            self.pdfView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            window.viewController.view.addSubview(self.pdfView)
            self.pdfView.frame = window.bounds
            self.pdfView.layoutIfNeeded()

            self.eventHandler(.didEnter)
        }
    }
    
    func exitFullscreen() {
        guard isFullscreen else { return }
        
        pageObservation = nil
        
        guard let sourceWindow = containerView.window else {
            pdfView.removeFromSuperview()
            return
        }
        let sourceRect = containerView.convert(containerView.bounds, to: sourceWindow)
        let screenBounds = UIScreen.main.bounds
        let maxSize = max(screenBounds.width, screenBounds.height)
        let minSize = min(screenBounds.width, screenBounds.height)

        pdfView.autoresizingMask = []
        pdfView.bounds = .init(origin: .zero, size: .init(width: minSize, height: maxSize))
        pdfView.center = .init(x: minSize / 2, y: maxSize / 2)

        sourceWindow.addSubview(pdfView)
        sourceWindow.makeKeyAndVisible()
        pdfView.layoutIfNeeded()
        window?.isHidden = true
        
        // Transition
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveOut) {
            self.pdfView.transform = .identity
            self.pdfView.frame = sourceRect
            self.pdfView.layoutIfNeeded()
            
            self.eventHandler(.willExit)
            
            self.window?.viewController.controlBar.displayMode = self.pdfView.displayMode
            
        } completion: { _ in
            self.pdfView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            self.containerView.addSubview(self.pdfView)
            self.pdfView.frame = self.containerView.bounds
            self.pdfView.layoutIfNeeded()

            self.eventHandler(.didExit)
        }
    }
}
