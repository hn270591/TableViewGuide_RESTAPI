import UIKit

enum UserInterfaceStyleType: String {
    case system = "System Default"
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
    
    static let defaultsCategory = "Home" 
    private static let categoryKey = "category"
    private static let userInterfaceStyle = "UserInterfaceStyle"
    
    // MARK: - Category
    
    func getCategory() -> String {
        return string(forKey: UserDefaults.categoryKey) ?? UserDefaults.defaultsCategory
    }
    
    func setCategory(value: String) {
        set(value, forKey: UserDefaults.categoryKey)
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
    
    func getIsCheckmark() -> [Bool] {
        let style = UserDefaults.standard.value(forKey: UserDefaults.userInterfaceStyle) as? String ?? ""
        switch style {
        case UserInterfaceStyleType.system.rawValue:
            return [true, false, false]
        case UserInterfaceStyleType.dark.rawValue:
            return [false, true, false]
        case UserInterfaceStyleType.light.rawValue:
            return [false, false, true]
        default: return [true, false, false]
        }
    }
}

// MARK: - Change Style of User Interface Style

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

