import UIKit

enum FontSizeKeys {
    static let fontSize = "fontSize"
}

extension UserDefaults {
    static func getCurrentFontSize() -> FontSize {
        guard let rawValue = UserDefaults.standard.value(forKey: FontSizeKeys.fontSize) as? Int else { return .defaults }
        return FontSize(rawValue: rawValue) ?? .defaults
    }
    
    static func setCurrentFontSize(_ fontSize: FontSize) {
        UserDefaults.standard.set(fontSize.rawValue, forKey: FontSizeKeys.fontSize)
    }
}

enum FontSize: Int {
    case small, defaults, large, largest
    
    var name: String {
        switch self {
        case .small: return "Small"
        case .defaults: return "Default"
        case .large: return "Large"
        case .largest: return "Largest"
        }
    }
    
    var size: CGFloat {
        let currentSize: CGFloat = 17
        switch self {
        case .small: return 0.8 * currentSize
        case .defaults: return currentSize
        case .large: return 1.2 * currentSize
        case .largest: return 1.5 * currentSize
        }
    }
    
    var index: UInt {
        switch self {
        case .small: return 0
        case .defaults: return 1
        case .large: return 2
        case .largest: return 3
        }
    }
    
    static func size(index: Int) -> FontSize {
        switch index {
        case FontSize.small.rawValue:
            return .small
        case FontSize.defaults.rawValue:
            return .defaults
        case FontSize.large.rawValue:
            return .large
        case FontSize.largest.rawValue:
            return .largest
        default:
            return .defaults
        }
    }
}

