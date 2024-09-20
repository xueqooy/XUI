//
//  CoachmarkController.swift
//  LLPUI
//
//  Created by xueqooy on 2023/8/3.
//

import UIKit
import Combine

public protocol CoachmarkControllerDataSource: AnyObject {
    func coachmarkController(_ controller: CoachmarkController, requestCoachmarkAt index: Int, completionHandler: @escaping (Coachmark?) -> Void)
}


public class CoachmarkController {
    
    private struct State: Equatable {
        let id: UUID
        let index: Int
        
        init(id: UUID = .init(), index: Int = 0) {
            self.id = id
            self.index = index
        }
        
        func next() -> State {
            .init(id: id, index: index + 1)
        }
    }
    
    public weak var dataSource: CoachmarkControllerDataSource?

    var window: CoachmarkWindow?
    
    var viewController: CoachmarkViewController?
    
    private var state: State?
    
    private var animationId: UUID?
    
    private lazy var windowLayoutPropertyObserver = ViewLayoutPropertyObserver()
    
    private var windowLayoutPropertyChangeSubscription: AnyCancellable?
    
    public init() {
    }
    
    @MainActor public func start() {
        state = State()
        
        window = createWindow()
        viewController = createViewController()
        
        window!.rootViewController = viewController!
        next()
    }
    
    @MainActor public func stop() {
        let previousWindow = window
        let previousViewController = viewController
        
        viewController = nil
        window = nil
        state = nil
        
        guard let previousWindow = previousWindow, let previousViewController = previousViewController else {
            return
        }
        
        previousViewController.coachmark = nil
        previousViewController.animateOut {
            previousWindow.rootViewController = nil
            previousWindow.isHidden = true
        }
    }
    
    @MainActor public func next() {
        guard let state = state else {
            stop()
            return
        }
                
        self.state = state.next()
                
        requestCoachmark(for: state)
    }
    
    @MainActor private func requestCoachmark(for state: State) {
        guard let dataSource = dataSource else {
            return
        }
        
        var isCompleted: Bool = false
        
        dataSource.coachmarkController(self, requestCoachmarkAt: state.index) { [weak self] coachmark in
            isCompleted = true
            
            guard let self = self,
                  let viewController = self.viewController,
                  let currentState = self.state else {
                return
            }
            
            guard state.next() == currentState  else {
                return
            }
            
            guard let coachmark = coachmark else {
                self.stop()
                return
            }
            
            self.animationIn()
            viewController.coachmark = coachmark
        }
        
        if !isCompleted {
            animationOut()
        }
    }
    
    // MARK: - Creation
    
    private func createViewController() -> CoachmarkViewController {
        .init()
    }
    
    @MainActor private func createWindow() -> CoachmarkWindow {
        guard let windowScene = UIApplication.shared.activeScene else {
            let bounds = UIApplication.shared.keyWindows.first?.bounds ?? UIScreen.main.bounds
            return CoachmarkWindow(frame: bounds)
        }
        
        let keywindow = windowScene.windows.first { $0.isKeyWindow }
        let window = CoachmarkWindow(windowScene: windowScene)
        window.frame = keywindow?.bounds ?? UIScreen.main.bounds
        
        // Requesting coachmark again when the window frame changes（e.g. device rotation changed）
        windowLayoutPropertyObserver.addToView(window)
        windowLayoutPropertyChangeSubscription = windowLayoutPropertyObserver.propertyDidChangePublisher
            .dropFirst()
            .sink { [weak self] _ in
                guard let self, let state = self.state else {
                    return
                }
                self.state = State(index: max(0, state.index - 1))
                self.next()
            }
        
        return window
    }
    
    // MARK: - Animation
    
    @MainActor private func animationIn() {
        animationId = UUID()
        
        viewController?.animateIn(forced: window?.isHidden ?? false)
        window?.isHidden = false
    }
    
    @MainActor private func animationOut() {
        let id = UUID()
        animationId = id
        
        viewController?.coachmark = nil
        viewController?.animateOut { [weak self] in
            guard let self = self, id == animationId else {
                return
            }
            
            window?.isHidden = true
        }
    }
}


