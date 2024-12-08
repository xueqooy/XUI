//
//  CoachmarkViewController.swift
//  XUI
//
//  Created by xueqooy on 2023/8/3.
//

import UIKit

class CoachmarkViewController: UIViewController {

    private struct Constants {
        static let pathAnimtionDuration = 0.25
        static let animationInOutDuration = 0.15
    }
    
    var coachmark: Coachmark? {
        didSet {
            popover.hide()
            
            guard let coachmark = coachmark else {
                let previousMaskPath = maskLayer.path
                let maskPath = UIBezierPath().cgPath
                maskLayer.path = maskPath
                maskLayer.animate(from: previousMaskPath, to: maskPath, keyPath: "path", duration: Constants.pathAnimtionDuration)
                return
            }
            
            transition(to: coachmark)
        }
    }
        
    private lazy var popover: Popover = {
        var configuration = Popover.Configuration()
        configuration.preferredDirection = .up
        configuration.background.cornerStyle = .fixed(.XUI.cornerRadius)
        configuration.contentInsets = .init(uniformValue: .XUI.spacing5)
        
        let popover = Popover()
        popover.configuration = configuration
        
        return popover
    }()
    
    private lazy var backgroundView = BackgroundView(configuration: .dimmingBlack())
    
    private lazy var dummyView = UIView()
    
    private lazy var maskLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillRule = .evenOdd
        return layer
    }()
        
    deinit {
        let popover = popover
        Task { @MainActor in
            popover.hide()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
               
        initialize()
    }
    
    private func initialize() {
        maskLayer.path = UIBezierPath().cgPath
        backgroundView.layer.mask = maskLayer

        view.addSubview(backgroundView)
        backgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        view.addSubview(dummyView)
    }
    
    func animateIn(forced: Bool) {
        guard backgroundView.layer.opacity != 1 || forced else {
            return
        }
        
        backgroundView.layer.opacity = 1
        backgroundView.layer.animateAlpha(from: 0, to: 1, duration: Constants.animationInOutDuration)
    }
    
    func animateOut(_ completion: @escaping () -> Void) {
        guard backgroundView.layer.opacity != 0 else {
            completion()
            return
        }
        
        backgroundView.layer.opacity = 0
        backgroundView.layer.animateAlpha(from: 1, to: 0, duration: Constants.animationInOutDuration, completion: { _ in completion() })
    }
    
    func transition(to coachmark: Coachmark) {
        dummyView.frame = coachmark.rect

        let maskPath = coachmark.maskPath(for: view.bounds)
        
        if let previousMaskPath = maskLayer.path {
            maskLayer.path = maskPath
            maskLayer.animate(from: previousMaskPath, to: maskPath, keyPath: "path", duration: Constants.pathAnimtionDuration) { [weak self] _ in
                guard let self = self, self.coachmark === coachmark else {
                    return
                }
                
                self.popover.show(coachmark.contentView, from: dummyView, animated: true)
            }
        } else {
            maskLayer.path = maskPath
            popover.show(coachmark.contentView, from: dummyView, animated: true)
        }
    }
}
