//
//  Strings.swift
//  LLPUI
//
//  Created by xueqooy on 2023/8/5.
//

import Foundation

public struct Strings {
    public static let next = "Next".localized
    public static let skip = "Skip".localized
    public static let done = "Done".localized
    public static let filter = "Filter".localized
    public static let sortBy = "Sort by".localized
    public static let post = "Post".localized
    public static let attachment = "Attachment".localized
    public static let attachmentQuantityLimitReminder = "Maximum number of attachments allowed has been reached".localized
    public static let share = "Share".localized
    public static let loading = "Loading...".localized
    public static let clear = "Clear".localized
    public static let apply = "Apply".localized
    public static let search = "Search".localized
    public static let cancel = "Cancel".localized
    public static let searchWithNoResults = "No results were found".localized
    public static let success = "Success".localized
    public static let note = "Note".localized
    public static let warning = "Warning".localized
    public static let error = "Error".localized

    public struct PasswordStrength {
        public static let weak = "PasswordStrength.Weak".localized
        public static let moderate = "PasswordStrength.Moderate".localized
        public static let strong = "PasswordStrength.Strong".localized
    }
    
    public static func step(_ current: Int, of total: Int) -> String {
        let current = max(current, 0)
        let total = max(total, 0)
        return String(format: "Step %1$d of %2$d".localized, current, total)
    }
    
    public static func attachments(_ count: Int) -> String {
        let count = max(count, 0)
        return String(format: "%d attachments".localized, count)
    }
    
    public static func like(_ count: Int) -> String {
        let count = max(count, 0)
        switch count {
        case 0:
            return "Like".localized
        case 1:
            return "1 " + "Like".localized
        default:
            return String(format: "%d Likes".localized, count)
        }
    }
    
    public static func comment(_ count: Int) -> String {
        let count = max(count, 0)
        switch count {
        case 0:
            return "Comment".localized
        case 1:
            return "1 " + "Comment".localized
        default:
            return String(format: "%d Comments".localized, count)
        }
    }
    
    public static func reply(_ count: Int) -> String {
        let count = max(count, 0)
        switch count {
        case 0:
            return "Reply".localized
        case 1:
            return "1 " + "Reply".localized
        default:
            return String(format: "%d Replies".localized, count)
        }
    }
    
    public static func charactersLimit(_ current: Int, of total: Int) -> String {
        String(format: "%1$d/%2$d charecters limit".localized, current, total)
    }
    
    public static func viewAll(_ additionalCount: Int) -> String {
        let count = max(additionalCount, 0)
        return String(format: "View all (%d+)".localized, count)
    }
}

extension String {
    var localized: String {
        return NSLocalizedString(self, bundle: LLPUIFramework.resourceBundle, comment: "")
    }
}
