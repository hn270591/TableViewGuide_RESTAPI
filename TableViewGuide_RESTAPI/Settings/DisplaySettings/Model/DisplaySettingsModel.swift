import Foundation

struct Titles {
    static let automatic = "Automatic"
    static let dark = "Dark"
    static let light = "Light"
    static let textSize = "Text Size"
}

struct Description {
    static let automatic = "User your device setting to determine appearance. The app will change modes when your device setting is changed"
    static let dark = "Ignore your device setting and always render is dark mode"
    static let light = "Ignore your device setting and always render is light mode"
}

final class TextSize {
    static let header = "Text Size"
    var headline: String!
    init(headline: String!) {
        self.headline = headline
    }
    
    class func getTextSizeArray() -> [TextSize] {
        var textSizeArray: [TextSize] = []
        let textSize = TextSize(headline: Titles.textSize)
        textSizeArray = [textSize]
        return textSizeArray
    }
}

final class DisplaySettings {
    static let header = "APPEARANCE"
    var headline: String!
    var description: String!
    
    init(headline: String!, description: String!) {
        self.headline = headline
        self.description = description
    }
    
    class func getDisplaySettingsArray() -> [DisplaySettings] {
        var displaySettingsArray: [DisplaySettings] = []
        let automatic = DisplaySettings(headline: Titles.automatic, description: Description.automatic)
        let dark = DisplaySettings(headline: Titles.dark, description: Description.dark)
        let light = DisplaySettings(headline: Titles.light, description: Description.light)
        displaySettingsArray = [automatic, dark, light]
        return displaySettingsArray
    }
}
