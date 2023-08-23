import Foundation
import UIKit

enum UserDefaultsKeys {
    static let displaySetting = "displaySetting"
}

extension UserDefaults {
    static func getCurrentDisplaySetting() -> DisplaySetting {
        guard let rawValue = UserDefaults.standard.value(forKey: UserDefaultsKeys.displaySetting) as? Int else { return .automatic }
        return DisplaySetting(rawValue: rawValue) ?? .automatic
    }
    
    static func setCurrentDisplaySetting(_ displaySetting: DisplaySetting) {
        UserDefaults.standard.set(displaySetting.rawValue, forKey: UserDefaultsKeys.displaySetting)
    }
}

enum DisplaySetting: Int, CaseIterable {
    case automatic, dark, light
    
    var name: String {
        switch self {
        case .automatic: return "Automatic"
        case .dark: return "Dark"
        case .light: return "Light"
        }
    }
    
    var description: String {
        switch self {
        case .automatic:
            return "User your device setting to determine appearance. The app will change modes when your device setting is changed."
        case .dark:
            return "Ignore your device setting and always render is dark mode."
        case .light:
            return "Ignore your device setting and always render is light mode."
        }
    }
    
    var userInterface: UIUserInterfaceStyle {
        switch self {
        case .automatic: return .unspecified
        case .dark: return .dark
        case .light: return .light
        }
    }
}

enum TextSetting: CaseIterable {
    case textSize
    
    var name: String {
        switch self {
        case .textSize: return "Text Size"
        }
    }
}
