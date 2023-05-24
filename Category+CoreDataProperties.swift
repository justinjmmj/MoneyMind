//
//  Category+CoreDataProperties.swift
//  MoneyMind
//
//  Created by Justin Justiniano  on 7/6/21.
//
//

import Foundation
import CoreData


extension Category {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Category> {
        return NSFetchRequest<Category>(entityName: "Category")
    }

    @NSManaged public var category: String?
    @NSManaged public var budget: Budget?
    @NSManaged public var expenses: NSSet?

}

// MARK: Generated accessors for expenses
extension Category {

    @objc(addExpensesObject:)
    @NSManaged public func addToExpenses(_ value: Expenses)

    @objc(removeExpensesObject:)
    @NSManaged public func removeFromExpenses(_ value: Expenses)

    @objc(addExpenses:)
    @NSManaged public func addToExpenses(_ values: NSSet)

    @objc(removeExpenses:)
    @NSManaged public func removeFromExpenses(_ values: NSSet)

}

extension Category : Identifiable {

}
