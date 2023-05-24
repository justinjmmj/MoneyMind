//
//  File.swift
//  MoneyMind
//
//  Created by Justin Justiniano  on 24/5/21.
//

import Foundation
import UIKit

class CalendarMethods
{
    let calendar = Calendar.current
    
    func nextMonth(date: Date) -> Date
    {
        return calendar.date(byAdding: .month,value: 1, to: date)!
    }
    func nextDay(date: Date) -> Date
    {
        return calendar.date(byAdding: .day, value: 1, to: date)!
    }
    func prevDay(date: Date) -> Date
    {
        return calendar.date(byAdding: .day, value: -1, to: date)!
    }
    func prevMonth(date: Date) -> Date
    {
        return calendar.date(byAdding: .month,value: -1, to: date)!
    }
    func dayString(date: Date) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd"
        return dateFormatter.string(from: date)
    }
    func monthString(date: Date) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "LLLL"
        return dateFormatter.string(from: date)
    }
    func yearString(date: Date) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"
        return dateFormatter.string(from: date)
    }
    
    func daysInMonth(date: Date) -> Int
    {
        let range = calendar.range(of: .day, in: .month, for: date)!
        return range.count
    }
    func dayOfMonth(date: Date) -> Int
    {
        let component = calendar.dateComponents([.day], from: date)
        return component.day!
    }
    func weekDay(date: Date) -> Int
    {
        let component = calendar.dateComponents([.weekday], from: date)
        return component.weekday! - 1
    }
    func firstOfMonth(date: Date) -> Date
    {
        let component = calendar.dateComponents([.year, .month], from: date)
        return calendar.date(from: component)!
    }
}
