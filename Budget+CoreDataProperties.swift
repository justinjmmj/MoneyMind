//
//  Budget+CoreDataProperties.swift
//  MoneyMind
//
//  Created by Justin Justiniano  on 20/5/21.
//
//

import Foundation
import CoreData


extension Budget {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Budget> {
        return NSFetchRequest<Budget>(entityName: "Budget")
    }

    @NSManaged public var amount: Int32
    @NSManaged public var expenses: NSSet?
    @NSManaged public var savings: NSSet?

}

// MARK: Generated accessors for expenses
extension Budget {

    @objc(addExpensesObject:)
    @NSManaged public func addToExpenses(_ value: Expenses)

    @objc(removeExpensesObject:)
    @NSManaged public func removeFromExpenses(_ value: Expenses)

    @objc(addExpenses:)
    @NSManaged public func addToExpenses(_ values: NSSet)

    @objc(removeExpenses:)
    @NSManaged public func removeFromExpenses(_ values: NSSet)

}

// MARK: Generated accessors for savings
extension Budget {

    @objc(addSavingsObject:)
    @NSManaged public func addToSavings(_ value: Savings)

    @objc(removeSavingsObject:)
    @NSManaged public func removeFromSavings(_ value: Savings)

    @objc(addSavings:)
    @NSManaged public func addToSavings(_ values: NSSet)

    @objc(removeSavings:)
    @NSManaged public func removeFromSavings(_ values: NSSet)

}

extension Budget : Identifiable {

}
