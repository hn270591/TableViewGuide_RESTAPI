import UIKit

extension Date {
    
    // Format according to ISO 8601
    static var iSO8601DateFormatter: ISO8601DateFormatter = {
        let iSO8601DateFormatter = ISO8601DateFormatter()
        return iSO8601DateFormatter
    }()
    
    // Relative DateTime Formatter
    static var relativeDateTimeFormatter: RelativeDateTimeFormatter = {
        let relativeDate = RelativeDateTimeFormatter()
        relativeDate.dateTimeStyle = .numeric
        return relativeDate
    }()
    
    // Format according to yyyy/dd/MM
    static var dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.locale = .current
        df.dateFormat = "yyyy/dd/MM"
        return df
    }()
    
    // Current Date
    static var currentDate: Date = {
        let currentDate = Date()
        return currentDate
    }()
    
    func publishDate(dateString: String) -> String {
        guard let publishedDate = Date.iSO8601DateFormatter.date(from: dateString) else { return "" }
        let pubDate = Date.dateFormatter.string(from: publishedDate)
        let relativePubDate = String(Date.relativeDateTimeFormatter.localizedString(for: Date.currentDate, relativeTo: publishedDate))
        
        var isCheck: Bool = false
        let abc = ["day", "week", "month", "year"]
        for a in abc {
            if relativePubDate.contains(a) {
               isCheck = true
                break
            }
        }
        
        // Delete 'in' and add 'ago' for pubDateString
        let index = relativePubDate.firstIndex(of: " ") ?? relativePubDate.endIndex
        let relativeDate = String(relativePubDate[index...] + " ago")
        return isCheck ? pubDate : relativeDate
    }
}
