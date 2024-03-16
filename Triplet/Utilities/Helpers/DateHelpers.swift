//
//  DateHelpers.swift
//  Triplet
//
//  Created by Derek Ma on 3/15/24.
//

import Foundation

func getDateString(date: Date?, includeTime: Bool = false) -> String {
    guard let date else {
        return ""
    }
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = includeTime ? "MM/dd, h:mm a" : "MM/dd"
    return dateFormatter.string(from: date)
}

func getDayOfWeek(_ date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "EEEE"
    return dateFormatter.string(from: date)
}

func datesInRange(from startDate: Date, to endDate: Date) -> [Date] {
    var dates: [Date] = []
    var currentDate = startDate
    
    let calendar = Calendar.current
    
    while currentDate <= endDate {
        dates.append(currentDate)
        
        guard let day = calendar.date(byAdding: .day, value: 1, to: currentDate) else {
            return [Date()]
        }
        
        currentDate = day
    }

    return dates
}
