import UIKit

extension UIFont {

    // font for headline
    static func fontOfHeadline() -> UIFont {
        let fontSize = UserDefaults.getCurrentFontSize()
        return UIFont.boldSystemFont(ofSize: CGFloat(fontSize.size))
    }
    
    // Font for subTitle/date
    static func fontOfSubtitle() -> UIFont {
        let fontSize = UserDefaults.getCurrentFontSize()
        return UIFont.systemFont(ofSize: CGFloat(0.8 * fontSize.size), weight: .regular)
    }
}
