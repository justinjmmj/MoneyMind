//
//  Savings+CoreDataProperties.swift
//  MoneyMind
//
//  Created by Justin Justiniano  on 7/6/21.
//
//

import Foundation
import CoreData


extension Savings {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Savings> {
        return NSFetchRequest<Savings>(entityName: "Savings")
    }

    @NSManaged public var amount: Float
    @NSManaged public var date: Date?
    @NSManaged public var savings: String?
    @NSManaged public var budget: Budget?

}

extension Savings : Identifiable {

}
