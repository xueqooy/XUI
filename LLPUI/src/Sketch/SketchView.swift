//
//  SketchView.swift
//  LLPUI
//
//  Created by 🌊 薛 on 2022/10/25.
//

import UIKit
import LLPUtils

public class SketchView: UIView {
    
    public enum Tool {
        case brush(color: UIColor = .black, thickness: CGFloat = 3)
        case eraser(thickness: CGFloat = 6)
        
        func thicknessInPoint(for width: CGFloat) -> CGFloat {
            let referenceWidth = 400.0
            let scale = width / referenceWidth
            
            switch self {
            case .brush(_, let thickness):
                return scale * thickness
            case .eraser(let thickness):
                return scale * thickness
            }
        }
    }
    
    public var tool: Tool {
        get {
            contentView.drawingView.tool
        }
        set {
            contentView.drawingView.tool = newValue
        }
    }
    
    public var backgroundImage: UIImage? {
        get {
            contentView.backgroundImage
        }
        set {
            contentView.backgroundImage = newValue
            undoRedoManager.clear()
        }
    }
    
    public var canUndo: Bool {
        undoRedoManager.canUndo
    }
    
    public var canRedo: Bool {
        undoRedoManager.canRedo
    }
    
    public var didUndo: ((SketchView) -> Void)?
    public var didRedo: ((SketchView) -> Void)?
    public var willBeginDrawing: ((SketchView) -> Void)?
    public var didFinishDrawing: ((SketchView) -> Void)?
    
    private let scrollView = SketchScrollView()
    private let contentView = SketchContentView()
    
    private var undoRedoManager = UndoRedoManager<Void>()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        initialize()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)

        initialize()
    }
    
    private func initialize() {
        scrollView.contentView = contentView

        addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
                
        contentView.drawingView.willBeginDrawing = { [weak self] in
            guard let self = self else { return }
            
            self.willBeginDrawing?(self)
        }
        
        contentView.drawingView.didFinishDrawing = { [weak self] undo, redo in
            guard let self = self else { return }
            
            self.undoRedoManager.add(undo: undo, redo: redo)
            self.didFinishDrawing?(self)
        }
    }
    
    public func undo() throws {
        try undoRedoManager.undo()
        didUndo?(self)
    }
    
    public func redo() throws {
        try undoRedoManager.redo()
        didRedo?(self)
    }
    
    public func clear() {
        contentView.drawingView.clear()
        undoRedoManager.clear()
    }
    
    public func export() -> UIImage {
        contentView.export()
    }
}

