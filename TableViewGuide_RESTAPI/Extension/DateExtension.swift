import UIKit

extension Date {
    func publishDate(date: String) -> String {
        // ISO 8601 format
        let iSO8601DateFormatter = ISO8601DateFormatter()
        guard let monthOfAllDate = iSO8601DateFormatter.date(from: date) else { return "" }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/dd/MM"
        let date = dateFormatter.string(from: monthOfAllDate)
        
        // Create timeInterval before
        let secondsAgo = Int(Date().timeIntervalSince(monthOfAllDate))
        
        var value: Int
        var unti: String
        
        let minute = 60
        let hour = 60 * minute
        let day = 24 * hour
        
        switch secondsAgo {
        case 0..<minute:
            value = secondsAgo
            unti = "seconds ago"
            return "\(value) \(unti)"
        case minute..<hour:
            value = secondsAgo / minute
            unti = "minutes ago"
            return "\(value) \(unti)"
        case hour..<day:
            value = secondsAgo / hour
            unti = "hours ago"
            return "\(value) \(unti)"
        default:
            unti = date
            return "\(unti)"
        }
    }
}

