//
//  Expenses+CoreDataProperties.swift
//  MoneyMind
//
//  Created by Justin Justiniano  on 7/6/21.
//
//

import Foundation
import CoreData


extension Expenses {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Expenses> {
        return NSFetchRequest<Expenses>(entityName: "Expenses")
    }

    @NSManaged public var amount: Float
    @NSManaged public var date: Date?
    @NSManaged public var expense: String?
    @NSManaged public var notes: String?
    @NSManaged public var image: String?
    @NSManaged public var budget: Budget?
    @NSManaged public var category: Category?

}

extension Expenses : Identifiable {

}
