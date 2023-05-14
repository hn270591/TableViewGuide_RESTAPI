import UIKit

extension UIFont {

    // font for headline
    static func fontOfHeadline() -> UIFont {
        let size = UserDefaults.standard.getFontSize()
        return UIFont.boldSystemFont(ofSize: size)
    }
    
    // Font for subTitle/date
    static func fontOfSubtitle() -> UIFont {
        let size = UserDefaults.standard.getFontSize()
        return UIFont.systemFont(ofSize: size * 0.8, weight: .regular)
    }
}
