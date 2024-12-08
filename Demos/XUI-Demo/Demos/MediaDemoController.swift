//
//  MediaDemoController.swift
//  EDUI_Example
//
//  Created by xueqooy on 2023/9/14.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
import XUI
import XKit

class MediaDemoController: DemoController {
    static let medias: [Media] = {
        let linkMedias = Media.LinkType.allCases
            .map { linkType in
                Media.link(title: linkType.description, content: linkType.description.lowercased(), type: linkType)
            }
        
        let documentMedias = (Media.DocumentType.allCases + [Media.DocumentType.unknown(ext: nil)])
            .map { documentType in
                Media.document(name: documentType.description, type: documentType)
            }
        
        let videoMedias = [
            Media.video(name: "Video")
        ]
        
        let audioMedias = [
            Media.audio(name: "Audio")
        ]
        
        let pictureMedias = [
            Media.picture(name: "Picture", image: UIImage(named: "brand")!)
        ]
        
        let networkPictureMedias = [
            Media.networkPicture(name: "Network Picture", url: .randomImageURL(), placeholder: nil)
        ]
        
        let unknownMedias = [
            Media.unknown(name: "Unknown")
        ]
        
        return linkMedias + documentMedias + videoMedias + audioMedias + pictureMedias + networkPictureMedias + unknownMedias
    }()
    
    static var randomMedia: Media {
        medias[Int.random(in: (0..<medias.count))]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        formView.itemSpacing = .XUI.spacing2
        
        Self.medias.enumerated().forEach { (index, media) in
            let view = MediaView(media: media) { [weak self] mediaView in
                print("Tap Action -> \(mediaView.media!)")

                guard let self = self else { return }
                
                self.showInfo(for: mediaView.media!, in: self.view, from: mediaView)
            }
            
            let button = Button(designStyle: .borderless, image: UIImage(systemName: "wand.and.stars.inverse")!) { [weak view] _ in
                view?.media = Self.randomMedia
            }
            
            view.trailingView = button
            
            view.isLoading = true
            Queue.main.execute(.delay(TimeInterval(index + 1))) { [weak view] in
                view?.isLoading = false
            }
            
            addRow(view, alignment: .fill)
        }
        
        addSpacer(.XUI.spacing3)
        
        let drawerButton = Button(designStyle: .primary, title: "Show In Drawer") { [weak self] button in
            self?.showInDrawer(from: button)
        }
        addRow(drawerButton)
    }
    
    private func showInDrawer(from view: UIView) {
        let drawer = DrawerController(sourceView: view, sourceRect: view.bounds, configuration: .init(resizingBehavior: .dismissOrExpand))
        
        if DrawerController.recommendedPresentationStyle(for: self, presentationDirection: .up) == .popover {
            drawer.preferredContentSize = .init(width: self.view.bounds.width / 2, height: 0)
        }
        
        let items = Self.medias.map { media in
            MediaListView.Item(media: media, trailingButtonConfiguration: .init(image: Icons.xmark, action: { [weak drawer] view, index in
                view.removeItem(at: index)
                
                if view.items.isEmpty {
                    drawer?.dismiss(animated: true)
                }
            }))
        }
        
        let listView = MediaListView(title: Strings.attachment, items: items) { [weak self] view, index in
            print(index)
            
            let media = view.items[index].media.asMedia()
            self?.showMessage("\(media)")
        }
        
        drawer.contentView = listView
        
        present(drawer, animated: true)
    }
    
    private func showInfo(for media: Media, in view: UIView, from sourceView: UIView) {
        var configuration = Popover.Configuration()
        configuration.dismissMode = .tapOnSuperview
        configuration.preferredDirection = .down
        
        let popover = Popover(configuration: configuration)
        
        let label = UILabel(text: "\(media)", textColor: Colors.title, font: Fonts.body1Bold, numberOfLines: 0)
        popover.show(label, in: view, from: sourceView)
    }
}
