//
//  addExpenseTester.swift
//  MoneyMindTests
//
//  Created by Justin Justiniano  on 27/5/21.
//

@testable import MoneyMind
import XCTest

class addExpenseTester: XCTestCase {

    var addExpense: AddExpensesViewController!
    
    override func setUp() {
        super.setUp()
        addExpense = AddExpensesViewController()
    }
    
    override func tearDown() {
        addExpense = nil
        super.tearDown()
    }
    
//    func getItemsTest() throws
//    {
//        let category = Category.init()
//        XCTAssertTrue(try addExpense.createExpense(expense: "Hello", amount: "30", date: Date, category: category))
//    }

}
