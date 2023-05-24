//
//  CalendarTester.swift
//  MoneyMindTests
//
//  Created by Justin Justiniano  on 27/5/21.
//

@testable import MoneyMind
import XCTest

class CalendarTester: XCTestCase {

    var calendar: CalendarMethods!
    
    override func setUp() {
        super.setUp()
        calendar = CalendarMethods()
    }
    
    override func tearDown() {
        calendar = nil
        super.tearDown()
    }
    
    func nextMonthTest() throws{
        XCTAssertNoThrow(calendar.nextMonth(date: Date()))
    }
    
    func nextDayTest() throws
    {
        XCTAssertNoThrow(calendar.nextDay(date: Date()))
    }
}
