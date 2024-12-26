//
//  HUD.swift
//  CombineCocoa
//
//  Created by xueqooy on 2024/3/13.
//

import UIKit
import PDFKit
import Combine

public class PDFViewer: UIView {
    public var url: URL? {
        didSet {
            guard oldValue != url else { return }
            
            if let url {
                pdfView.document = PDFDocument(url: url)
            } else {
                pdfView.document = nil
            }
        }
    }
    
    private let pdfView = _PDFView()
    private let pdfContainerView = UIView().then {
        $0.backgroundColor = Colors.bodyText1
    }
    private let controlBar = PDFControlBar()
    
    private var fullscreenController: PDFFullscreenController!
    private var fullscreenDisplayMode: PDFDisplayMode = .twoUpContinuous
    private var lastBoundingSize: CGSize = .zero

    public init(url: URL? = nil) {
        super.init(frame: .zero)
        
        initialize()
        
        defer {
            self.url = url
        }
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initialize() {
        addSubview(controlBar) { make in
            make.left.bottom.right.equalToSuperview()
        }
        
        addSubview(pdfContainerView) { make in
            make.top.leading.right.equalToSuperview()
            make.bottom.equalTo(controlBar.snp.top)
        }
        
        pdfContainerView.addSubview(pdfView)
        pdfView.frame = pdfContainerView.bounds
        pdfView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        pdfView.scaleChangedHandler = { [weak self] in
            self?.scaleChanged()
        }
        
        pdfView.pageChangedHandler = { [weak self] in
            self?.pageChanged()
        }
        
        controlBar.goPageHandler = { [weak self] index in
            guard let self, let page = self.pdfView.document?.page(at: index) else { return }
            self.pdfView.go(to: page)
        }
        
        controlBar.updateScaleFactorHandler = { [weak self] factor in
            guard let self else { return }
            
            self.pdfView.scaleFactor = factor
            self.scaleChanged()
        }
        
        controlBar.fullscreenHandler = { [weak self] in
            guard let self else { return }
            
            self.fullscreenController.enterFullscreen()
        }
    
        fullscreenController = PDFFullscreenController(pdfView: pdfView, containerView: pdfContainerView) { [weak self] event in
            self?.handleFullscreenEvent(event)
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        if lastBoundingSize != bounds.size {
            lastBoundingSize = bounds.size
            
            pdfView.updateScaleFactor(setsCurrentToMin: true)
        }
    }

    private func pageChanged() {
        guard let document = pdfView.document else { return }
        
        controlBar.numberOfPages = document.pageCount
        controlBar.currentPageIndex = pdfView.currentPageIndex
    }
    
    private func scaleChanged() {
        controlBar.minScaleFactor = pdfView.minScaleFactor
        controlBar.maxScaleFactor = pdfView.maxScaleFactor
        controlBar.currentScaleFactor = pdfView.scaleFactor
    }
    
    private func handleFullscreenEvent(_ event: PDFFullscreenController.Event) {
        switch event {
        case .willEnter:
            pdfView.displayMode = fullscreenDisplayMode
            
        case .didEnter:
            break
            
        case .willExit:
            pdfView.displayMode = .twoUp
            
        case .didExit:
            break
            
        case .fullscreenSizeDidChange:
            pdfView.updateScaleFactor(setsCurrentToMin: true)
            
        case .updateFullscreenDisplayMode(let mode):
            self.fullscreenDisplayMode = mode
            if fullscreenController.isFullscreen {
                UIView.animate(withDuration: 0.25, delay: 0, options: .curveOut) {
                    self.pdfView.displayMode = mode
                }
            }
        }
    }
}
