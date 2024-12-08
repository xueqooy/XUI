//
//  DateSelectProvider.swift
//  XUI
//
//  Created by xueqooy on 2023/4/26.
//

import UIKit
import Combine
import XKit

public class DateTextSelector: TextSelector {
            
    public override var contentView: UIView? {
        let datePicker = UIDatePicker()
        datePicker.locale = locale
        datePicker.datePickerMode = datePickerMode
        datePicker.minimumDate = minimumDate
        datePicker.maximumDate = maximumDate
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }
        if let date = date {
            datePicker.date = date
        }
        
        datePickSubscription = datePicker.datePublisher
            .map { (date) -> Date? in date }
            .sink { [weak self] in
                self?.date = $0
            }
        
        currentDatePicker = datePicker
        
        return datePicker
    }
    
    public override var popoverConfiguration: Popover.Configuration {
        var configuration = Popover.Configuration()
        configuration.preferredDirection = .down
        configuration.dismissMode = .tapOnOutsidePopoverAndAnchor
        configuration.animationTransition = .push
        configuration.arrowSize = .zero
        return configuration
    }
    
    public override var drawerConfiguration: DrawerController.Configuration {
        .init(presentationDirection: .up, resizingBehavior: .dismiss)
    }
    
    @EquatableState
    public var date: Date? {
        didSet {
            if let date {
                selectedText = self.dateFormatter.string(from: date)
            } else {
                selectedText = nil
            }
            
            if let picker = currentDatePicker {
                picker.date = date ?? Date()
            }
        }
    }
    
    private let dateFormat: String
    private let datePickerMode: UIDatePicker.Mode
    private let locale: Locale
    private let minimumDate: Date?
    private let maximumDate: Date?
    
    private lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = locale
        dateFormatter.dateFormat = dateFormat
        return dateFormatter
    }()
    
    private weak var currentDatePicker: UIDatePicker?
    
    private var datePickSubscription: AnyCancellable?
            
    public init(datePickerMode: UIDatePicker.Mode = .date, dateFormat: String = "MM/dd/yyyy", locale: Locale = .init(identifier: "en_US"), minimumDate: Date? = nil, maximumDate: Date? = nil, presentationStyle: PresentationStyle = .popover, presentingViewController: UIViewController? = nil) {
        self.datePickerMode = datePickerMode
        self.dateFormat = dateFormat
        self.locale = locale
        self.minimumDate = minimumDate
        self.maximumDate = maximumDate
        
        super.init(presentationStyle: presentationStyle)
        
        self.presentingViewController = presentingViewController
    }
}
