import UIKit

extension Date {
    func publishDate(date: String) -> String {
        // Format according to ISO 8601
        let iSO8601DateFormatter = ISO8601DateFormatter()
        guard let publishedDate = iSO8601DateFormatter.date(from: date) else { return "" }
        let formatter = RelativeDateTimeFormatter()
        formatter.dateTimeStyle = .numeric
        
        // Format according to yyyy/dd/MM
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/dd/MM"
        let dateString = dateFormatter.string(from: publishedDate)
        
        //
        var pubDateString = String(formatter.localizedString(for: Date(), relativeTo: publishedDate))
        var isCheck: Bool = false
        let abc = ["day", "moth", "year"]
        for a in abc {
            if pubDateString.contains(a) {
               isCheck = true
                break
            }
        }
        
        // Delete 'in' and add 'ago' for pubDateString
        let index = pubDateString.firstIndex(of: " ") ?? pubDateString.endIndex
        let pubDate = String(pubDateString[index...] + " ago")
        return isCheck ? dateString : pubDate
    }
}
