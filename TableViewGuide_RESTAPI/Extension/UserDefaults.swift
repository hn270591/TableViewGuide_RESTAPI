import UIKit

enum UserInterfaceStyleType: String {
    case system = "Automatic"
    case dark = "Dark"
    case light = "Light"
   
   static func setIndex(index:Int)-> UserInterfaceStyleType{
        switch index {
        case 0: return .system
            
        case 1: return .dark
            
        case 2: return .light
            
        default: return .system
        }
    }
}

extension UserDefaults {
    
    private static let categoryKey = "category"
    static let defaultsCategory = "Home" 
    
    static let fontSizeKey = "FontSize"
    private static let fontSizeDefault: CGFloat = 17
    
    private static let userInterfaceStyle = "UserInterfaceStyle"
    
    // MARK: - Category
    
    func getCategory() -> String {
        return string(forKey: UserDefaults.categoryKey) ?? UserDefaults.defaultsCategory
    }
    
    func setCategory(value: String) {
        set(value, forKey: UserDefaults.categoryKey)
    }
    
    // MARK: - Font Style

    func getFontSize() -> CGFloat {
        var size = CGFloat(float(forKey: UserDefaults.fontSizeKey))
        if !size.isNormal {
            size = UserDefaults.fontSizeDefault
        }
        return size
    }
    
    func setFontSize(size: Float) {
        set(size, forKey: UserDefaults.fontSizeKey)
    }
    
    // MARK: - User prefered interface style
    
    func setUserInterfaceStyle(value: String){
        set(value, forKey: UserDefaults.userInterfaceStyle)
    }
    
    // Retrieve User prefered interface style
    func getUserInterfaceStyle() -> UserInterfaceStyleType{
        let style = UserDefaults.standard.value(forKey: UserDefaults.userInterfaceStyle) as? String ?? ""
        switch style {
        case UserInterfaceStyleType.system.rawValue:
            return .system
        case UserInterfaceStyleType.dark.rawValue:
            return .dark
        case UserInterfaceStyleType.light.rawValue:
            return .light
        default: return .system
        }
    }
}

// MARK: - Change User Interface Style

final class UserInterfaceStyle {
    static func changeStyle(style:UserInterfaceStyleType, animate:Bool = true){
        var tempStyle: UIUserInterfaceStyle = .unspecified
        switch style {
        case .system:
            tempStyle = .unspecified
        case .light:
            tempStyle = .light
        case .dark:
            tempStyle = .dark
        }
        
        //Save in UserDefaults
        UserDefaults.standard.setUserInterfaceStyle(value: style.rawValue)
        
        //Change with animation
        let duration = animate ? 0.35 : 0.0
        UIView.animate(withDuration: duration) {
            UIApplication.shared.windows.first?.overrideUserInterfaceStyle  = tempStyle
        }
    }
}

// MARK: - Change Font Style

final class FontStyle {
    class func setFontSizeAndSliderTitle(index: Float) -> (Float, String) {
        var currentSize: Float = 17
        var currentText = "Default"
        switch index {
        case 0:
            currentSize = 0.8 * currentSize
            currentText = "0.8 times"
        case 1:
            return (currentSize, currentText)
        case 2:
            currentSize = 1.2 * currentSize
            currentText = "1.2 times"
        case 3:
            currentSize = 1.5 * currentSize
            currentText = "1.5 times"
        default:
            return (currentSize, currentText)
        }
        return (currentSize, currentText)
    }
    
    class func setSliderIndex() -> Int {
        let currentSize: Float = 17
        let size = UserDefaults.standard.float(forKey: UserDefaults.fontSizeKey)
        switch size {
        case 0.8 * currentSize:
            return 0
        case currentSize:
            return 1
        case 1.2 * currentSize:
            return 2
        case 1.5 * currentSize:
            return 3
        default:
            return 1
        }
    }
}


