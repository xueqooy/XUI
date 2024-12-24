//
//  SketchDemoController.swift
//  EDUI_Example
//
//  Created by 🌊 薛 on 2022/10/25.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import QuickLook
import XKit
import XUI

class SketchDemoController: DemoController {
    let sketchView = SketchView()

    var brushThickness: CGFloat = 3.0
    var brushColor: UIColor = .black

    var eraserThickness: CGFloat = 3.0

    var imageURL: URL!
    lazy var previewItem = PreviewItem(url: self.imageURL)

    var undoButton: Button?
    var redoButton: Button?
    var toolSegmentControl: SegmentControl?
    var thicknessStepper: UIStepper?

    var toolDotView: BackgroundView?

    var brushColorWell: UIView?

    private lazy var sketchViewItem = FormRow(sketchView, heightMode: .fixed(400), alignment: .fill)

    private var ob: Any?

    override func viewDidLoad() {
        super.viewDidLoad()

        let photoPickerBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "photo"), style: .plain, target: self, action: #selector(Self.showPhotoPicker))
        navigationItem.rightBarButtonItem = photoPickerBarButtonItem

        // Immediately pass the touches to the subview, otherwise drawing will have a delayed effect
        formView.scrollingContainer.delaysContentTouches = false

        if Device.current.isPad {
            formView.contentInset = .nondirectional(top: 20, left: 100, bottom: 20, right: 100)
        }

        sketchView.layer.borderColor = Colors.teal.cgColor
        sketchView.layer.borderWidth = 1
        sketchView.backgroundImage = UIImage(named: "brand")
        sketchView.didFinishDrawing = { [weak self] _ in
            self?.updateUndoRedoButton()
        }
        sketchView.didUndo = { [weak self] _ in
            self?.updateUndoRedoButton()
        }
        sketchView.didRedo = { [weak self] _ in
            self?.updateUndoRedoButton()
        }

        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, [.userDomainMask], true).first!
        imageURL = URL(fileURLWithPath: path.appending("/sketch_image.png"))

        let undoButton = createButton(image: UIImage(systemName: "arrow.uturn.backward"), style: .borderless) { [weak self] _ in
            try? self?.sketchView.undo()
        }
        undoButton.isEnabled = false

        let redoButton = createButton(image: UIImage(systemName: "arrow.uturn.forward"), style: .borderless) { [weak self] _ in
            try? self?.sketchView.redo()
        }
        redoButton.isEnabled = false

        let exportButton = createButton(image: UIImage(systemName: "square.and.arrow.up"), style: .borderless) { [weak self] _ in
            guard let self = self else {
                return
            }

            let image = self.sketchView.export()

            let path = self.imageURL.path
            FileManager.default.createFile(atPath: path, contents: image.pngData())

            let viewController = QLPreviewController()
            viewController.dataSource = self
            self.present(viewController, animated: true)
        }

        let clearButton = createButton(image: UIImage(systemName: "clear"), style: .borderless) { [weak self] _ in
            self?.sketchView.clear()

            self?.updateUndoRedoButton()
        }

        addRow([undoButton, redoButton, exportButton, clearButton], itemSpacing: 10, distribution: .fillEqually)
        addItem(sketchViewItem)

        let toolSegmentControl = SegmentControl(style: .tab, fillEqually: true, items: ["Brush", "Eraser"])
        toolSegmentControl.selectedSegmentIndex = 0
        toolSegmentControl.addTarget(self, action: #selector(Self.toolDidChange(_:)), for: .valueChanged)

        addTitle("Tool")
        addRow(toolSegmentControl)

        let thicknessStepper = UIStepper()
        thicknessStepper.minimumValue = 1
        thicknessStepper.maximumValue = 15
        thicknessStepper.value = brushThickness
        thicknessStepper.addTarget(self, action: #selector(Self.thicknessDidChange(_:)), for: .valueChanged)

        if #available(iOS 14.0, *) {
            let colorWell = UIColorWell()
            colorWell.selectedColor = brushColor
            colorWell.addTarget(self, action: #selector(Self.brushColorDidChange(_:)), for: .valueChanged)
            addRow([colorWell, thicknessStepper], itemSpacing: 15, alignment: .center, distribution: .fill)

            self.brushColorWell = colorWell
        } else {
            addRow(thicknessStepper)
        }

        let toolDotView = BackgroundView()
        toolDotView.configuration.cornerStyle = .capsule
        toolDotView.configuration.fillColor = brushColor
        toolDotView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        toolDotView.widthAnchor.constraint(equalToConstant: 1).isActive = true
        toolDotView.transform = CGAffineTransform(scaleX: brushThickness, y: brushThickness)

        addSpacer(10)
        addRow(toolDotView)

        self.undoButton = undoButton
        self.redoButton = redoButton
        self.toolSegmentControl = toolSegmentControl
        self.thicknessStepper = thicknessStepper
        self.toolDotView = toolDotView

        ob = NotificationCenter.default.addObserver(forName: UIDevice.orientationDidChangeNotification, object: nil, queue: .main) { [weak self] _ in
            guard let self = self else {
                return
            }
            Queue.main.execute(.delay(0.1)) { [weak self] in
                self?.updateForm()
            }
        }
    }

    private var didUpdateForm: Bool = false
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if didUpdateForm {
            return
        }
        didUpdateForm = true

        updateForm()
    }

    @objc func showPhotoPicker() {
        let picker = UIImagePickerController()
        picker.delegate = self
        present(picker, animated: true)
    }

    @objc func toolDidChange(_ sender: SegmentControl) {
        if sender.selectedSegmentIndex == 0 {
            brushColorWell?.isHidden = false
            thicknessStepper?.value = brushThickness
        } else {
            brushColorWell?.isHidden = true
            thicknessStepper?.value = eraserThickness
        }

        updateTool()
        updateDot()
    }

    @objc func thicknessDidChange(_ sender: UIStepper) {
        if toolSegmentControl!.selectedSegmentIndex == 0 {
            brushThickness = sender.value
        } else {
            eraserThickness = sender.value
        }

        updateTool()
        updateDot()
    }

    @available(iOS 14.0, *)
    @objc func brushColorDidChange(_ sender: UIColorWell) {
        brushColor = sender.selectedColor ?? .black

        updateTool()
        updateDot()
    }

    func updateUndoRedoButton() {
        undoButton?.isEnabled = sketchView.canUndo
        redoButton?.isEnabled = sketchView.canRedo
    }

    func updateTool() {
        sketchView.tool = toolSegmentControl!.selectedSegmentIndex == 0 ? .brush(color: brushColor, thickness: brushThickness) : .eraser(thickness: eraserThickness)
    }

    func updateDot() {
        if toolSegmentControl!.selectedSegmentIndex == 0 {
            toolDotView?.transform = CGAffineTransform(scaleX: brushThickness, y: brushThickness)
            toolDotView?.configuration.fillColor = brushColor
        } else {
            toolDotView?.transform = CGAffineTransform(scaleX: eraserThickness, y: eraserThickness)
            toolDotView?.configuration.fillColor = .lightGray
        }
    }

    func updateForm() {
        if Device.current.orientation == .landscape {
            sketchViewItem.heightMode = .fixed(view.bounds.height - formView.contentInset.vertical - view.safeAreaInsets.vertical)
            formView.scrollingContainer.makeSubviewVisible(sketchView)
            formView.scrollingContainer.isScrollEnabled = false
        } else {
            sketchViewItem.heightMode = .fixed(view.bounds.width - formView.contentInset.horizontal)
            formView.scrollingContainer.isScrollEnabled = true
        }
    }
}

extension SketchDemoController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        defer {
            picker.dismiss(animated: true)
        }

        guard let image = info[.originalImage] as? UIImage else {
            return
        }
        sketchView.backgroundImage = image

        updateUndoRedoButton()
    }
}

extension SketchDemoController: QLPreviewControllerDataSource {
    func numberOfPreviewItems(in _: QLPreviewController) -> Int {
        return 1
    }

    func previewController(_: QLPreviewController, previewItemAt _: Int) -> QLPreviewItem {
        return previewItem
    }
}

class PreviewItem: NSObject, QLPreviewItem {
    let previewItemURL: URL?

    init(url: URL) {
        previewItemURL = url
    }
}
