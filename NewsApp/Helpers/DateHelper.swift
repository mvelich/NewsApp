//
//  HelperFunctions.swift
//  NewsApp
//
//  Created by Maksim Velich on 30.03.21.
//

import Foundation

struct DateHelper {
    
    static func convertStringToDate(with stringDate: String?) -> Date? {
        guard let stringDate = stringDate else { return nil }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ssZZZ"
        let date = dateFormatter.date(from: stringDate)
        return date
    }
    
    static func convertDateToString(with date: Date?) -> String? {
        guard let date = date else { return nil }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let resultStringDate = dateFormatter.string(from: date)
        return resultStringDate
    }
    
    static func dateCounter(counter: Int) -> String {
        // Build date for request based on scrollCounter value
        let rightDate = Calendar.current.date(byAdding: .day, value: -counter, to: Date())
        let resultDate = DateHelper.convertDateToString(with: rightDate)!
        return resultDate
    }
}
