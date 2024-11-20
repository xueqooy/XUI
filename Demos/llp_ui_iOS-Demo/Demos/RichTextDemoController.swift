//
//  RichTextDemoController.swift
//  EDUI_Example
//
//  Created by xueqooy on 2023/8/18.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import LLPUI
import UIKit

class RichTextDemoController: DemoController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addTitle("Style Strategy - Supplement")
//        addLabel("""
//        \(supplement:
//        """
//        .supplement(
//            \(supplement:
//                """
//                .supplement(
//                \(supplement:
//                    """
//                            .supplement(
//                            ), .foreground(.font(Fonts.body3)
//                    """
//                , .font(Fonts.body3))
//                    ),  .foreground(Colors.red)
//                """
//            , .foreground(Colors.red))
//        ), .foreground(Colors.green), .font(Fonts.body1)
//        """
//        , .foreground(Colors.green), .font(Fonts.body1))
//        """)
        
        addLabel(
            RTSupplement(.foreground(Colors.green), .font(Fonts.body1)) {
                """
                .supplement(
                """
                
                RTLineBreak()
                
                RTSupplement(.foreground(Colors.red)) {
                    """
                        .supplement(
                    """
                    
                    RTLineBreak()
                        
                    RTSupplement(.font(Fonts.body3)) {
                        """
                                .supplement(
                                ), .foreground(.font(Fonts.body3)
                        """
                    }
                    
                    RTLineBreak()
                    
                    """
                        ),  .foreground(Colors.red)
                    """
                }
                
                RTLineBreak()
                
                """
                ), .foreground(Colors.green), .font(Fonts.body1)
                """
            }
        )
        
        addTitle("Style Strategy - Override")
//        addLabel("""
//        \(override:
//        """
//        .override(
//            \(supplement:
//                """
//                .supplement(
//                \(supplement:
//                    """
//                            .supplement(
//                            ), .foreground(Colors.green), .font(Fonts.body3)
//                    """
//                , .foreground(Colors.green), .font(Fonts.body3))
//                    ),   .foreground(Colors.red), .font(Fonts.body2)
//                """
//            , .foreground(Colors.red), .font(Fonts.body2))
//        ), .font(Fonts.body1)
//        """
//        , .font(Fonts.body1))
//
//        """)
        
        addLabel(
            RTOverride(.font(Fonts.body1)) {
                """
                .override(
                """
                
                RTLineBreak()
                
                RTSupplement(.foreground(Colors.red), .font(Fonts.body2)) {
                    """
                        .supplement(
                    """
                    
                    RTLineBreak()
                    
                    RTSupplement(.foreground(Colors.green), .font(Fonts.body3)) {
                        """
                                .supplement(
                                ), .foreground(Colors.green), .font(Fonts.body3)
                        """
                    }
                    
                    RTLineBreak()
                    
                    """
                        ),   .foreground(Colors.red), .font(Fonts.body2)
                    """
                }
                
                
                RTLineBreak()
                
                """
                ), .font(Fonts.body1)
                """
            }
        )
        
        
        addTitle("Operator")
            
        let numberStyle: [RichText.Style] = [.font(Fonts.h6), .foreground(Colors.teal)]
        let signStyle: [RichText.Style] = [.font(Fonts.h6), .foreground(Colors.green)]
        let operatorRichText: RichText =
        "\("1", numberStyle)" as RichText +
        " " as RichText +
        "\("+", signStyle)" as RichText +
        " " as RichText +
        "\("2", numberStyle)" as RichText +
        " " as RichText +
        "\("=", signStyle)" as RichText +
        " " as RichText +
        "\("3", numberStyle)" as RichText
        
        addLabel(operatorRichText, alignment: .center)
        
        
        addTitle("Action")
        
        func tapped(_ target: RichText.Style.Action.Target) {
            switch target.content {
            case .string(let attributedString):
                print(attributedString.string)
            case .attachment(let attachment):
                print(attachment)
            }
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd hh:mm:ss"
        addLabel("""
        \(.image(Icons.calendar.withTintColor(Colors.orange), .automatic(.center)), .action(tapped)) \(dateFormatter.string(from: Date()), .foreground(Colors.teal), .font(Fonts.body1Bold), .action([.underline(.single), .foreground(Colors.teal)], tapped))
        """, alignment: .center)
    
        
        addTitle("Checking")
        let checkingLabel = UILabel(numberOfLines: 0)
        checkingLabel.addCheckings([.phoneNumber, .date, .link]) { result in
            switch result {
            case .phoneNumber(let number):
                print(number)
            case .date(let date):
                print(date)
            case .link(let url):
                print(url)
            default:
                fatalError()
                break
            }
        }
        var text: RichText = "86-13412345678 \n\n https://github.com/EdmodoWorld/EDUI-iOS \n\n \(dateFormatter.string(from: Date()))"
        text.addStyles(.foreground(Colors.green), checkings: [.phoneNumber])
        text.addStyles(.foreground(Colors.red), checkings: [.date])
        text.addStyles(.foreground(Colors.mediumTeal), checkings: [.link])
        checkingLabel.richText = text
        addRow(checkingLabel)
        
        
        addTitle("Image Attachment")
        let alertIcon = Icons.checkCircle.withTintColor(Colors.teal)
        addLabel((
        """
        
         \(.image(alertIcon, .automatic(.center), sizingFont: Fonts.body2)) .automatic(.center)
        
         \(.image(alertIcon, .automatic(.offset(CGPoint(x: 0, y: -5))), sizingFont: Fonts.body2)) .automatic(.offset(CGPoint(x: 0, y: -5)))
        
         \(.image(alertIcon, .specified(CGSize(width: 15, height: 15), .center), sizingFont: Fonts.body2)) .specified(CGSize(width: 15, height: 15), .center)
        
         \(.image(alertIcon, .specified(CGSize(width: 15, height: 15), .offset(CGPoint(x: 0, y: -5))), sizingFont: Fonts.body2)) .specified(CGSize(width: 10, height: 10), .offset(CGPoint(x: 0, y: -5)))
        """ as RichText)
            .addingStyles(.font(Fonts.body2), .foreground(Colors.title), .background(.lightGray))
        )
        
        addTitle("View Attachment")
        let field1 = InputField(placeholder: "Field 1")
        let field2 = InputField(placeholder: "Field 2")

        let textView = UITextView()
        textView.isEditable = false
        textView.isSelectable = false
        
//        weak var weakView = view
        weak var weakTextView = textView
        
        func updateViewAttachmentSize() {
//            weakView?.intrinsicSize = CGSize(width: .random(in: 20...100), height: .random(in: 20...100))
            field1.translatesAutoresizingMaskIntoConstraints = false
            field2.translatesAutoresizingMaskIntoConstraints = false
            field1.settingWidthConstraint(.random(in: 100...300))
            field2.settingWidthConstraint(.random(in: 100...300))
            weakTextView?.layoutViewAttachmentsIfNeeded()
        }
        
       
//        textView.richText = """
//        \(supplement:
//            """
//            View attachment is only support \("UITextView", .font(Fonts.font(ofSize: 14, weight: .bold)), .foreground(Colors.green))
//            View Attachment -> ( \(.view(view, .automatic(.center))) )
//            
//            The size of the view attachment is determined by its bounds size if size mode is not \("specified", .font(Fonts.font(ofSize: 14, weight: .bold)), .foreground(Colors.red))
//            
//            Call \("layoutViewAttachmentsIfNeeded", .action(updateViewAttachmentSize), .font(Fonts.font(ofSize: 14, weight: .bold)), .foreground(Colors.mediumTeal)) to update its layout
//            """
//        , .font(Fonts.font(ofSize: 14, weight: .regular)), .foreground(Colors.bodyText1))
//        """
        
        
        textView.richText = RTSupplement(.font(Fonts.font(ofSize: 14, weight: .regular)), .foreground(Colors.bodyText1)) {
            "View attachment is only support \("UITextView", .font(Fonts.font(ofSize: 14, weight: .bold)), .foreground(Colors.green))" as RichText
            
            RTLineBreak()
            
            "View Attachment -> ( \(.view(field1, .automatic(.center))) )" as RichText
            
            RTLineBreak(2)
            
            "The size of the view attachment \(.view(field2, .automatic(.center))) is determined by its bounds size if size mode is not \("specified", .font(Fonts.font(ofSize: 14, weight: .bold)), .foreground(Colors.red))" as RichText
            
            RTLineBreak(2)
            
            "Call \("layoutViewAttachmentsIfNeeded", .action(updateViewAttachmentSize), .font(Fonts.font(ofSize: 14, weight: .bold)), .foreground(Colors.mediumTeal)) to update its layout" as RichText
        }
        
        addRow(textView, height: 300, alignment: .fill)
    }
    
    private func addLabel(_ richText: RichText, alignment: RowAlignment = .fill) {
        let label = UILabel(numberOfLines: 0)
        label.richText = richText
        addRow(label, alignment: alignment)
    }
}

