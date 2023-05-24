//
//  ExpensesTest.swift
//  MoneyMindTests
//
//  Created by Justin Justiniano  on 27/5/21.
//

@testable import MoneyMind
import XCTest

class ExpensesTest: XCTestCase {

    var expense: ExpensesViewController!
    
    override func setUp() {
        super.setUp()
        expense = ExpensesViewController()
    }
    
    override func tearDown() {
        expense = nil
        super.tearDown()
    }
//    
//    func getItemsTest() throws
//    {
//        XCTAssertNoThrow(expense.getAllItems())
//    }
}
