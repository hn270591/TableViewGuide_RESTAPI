import UIKit

extension DateFormatter {
    private static var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.doesRelativeDateFormatting = true
        return formatter
    }()
    
    private static var timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.doesRelativeDateFormatting = true
        return formatter
    }()
    
    private static var iso8601Full: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = .current
        return formatter
    }()
    
    private static var YYYYMMdd: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY/MM/dd"
        return dateFormatter
    }()
    
    // MARK: -  Top Stories and Search
    
    static func publishedDateFormatterForArticles(dateString: String) -> String {
        let currentDate = Date()
        let publishedDate = DateFormatter.iso8601Full.date(from: dateString) ?? Date()
        
        if publishedDate <= currentDate.addingTimeInterval(-24*60*60) { // 1 day passed
            return String(DateFormatter.YYYYMMdd.string(from: publishedDate))
        } else {
            return String(publishedDate.timeAgoDisplay())
        }
    }
    
    // MARK: - History
    
    static func dateFormatterForSectionHeader(date: Date) -> String {
        return DateFormatter.dateFormatter.string(from: date)
    }
    
    static func dateFormatterForRowPublishTime(date: Date) -> String {
        return DateFormatter.timeFormatter.string(from: date)
    }
}

extension Date {
    func timeAgoDisplay() -> String {
        let date = Date()
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: self, relativeTo: date)
    }
}

