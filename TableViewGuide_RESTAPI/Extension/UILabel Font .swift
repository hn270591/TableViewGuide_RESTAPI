import UIKit

extension UIFont {
    // font for headline
    static func fontOfHeadline() -> UIFont {
        return UIFont.boldSystemFont(ofSize: 17)
    }
    
    // Font for subTitle/date
    static func fontOfSubtitle() -> UIFont {
        return UIFont.systemFont(ofSize: 14)
    }
}
