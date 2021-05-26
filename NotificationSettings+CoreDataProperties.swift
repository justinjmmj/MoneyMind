//
//  NotificationSettings+CoreDataProperties.swift
//  MoneyMind
//
//  Created by Justin Justiniano  on 20/5/21.
//
//

import Foundation
import CoreData


extension NotificationSettings {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<NotificationSettings> {
        return NSFetchRequest<NotificationSettings>(entityName: "NotificationSettings")
    }

    @NSManaged public var enable: Int16
    @NSManaged public var daily: Int16
    @NSManaged public var weekly: Int16
    @NSManaged public var monthly: Int16
    @NSManaged public var reoccurring: Int16

}

extension NotificationSettings : Identifiable {

}
