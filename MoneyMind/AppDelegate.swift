//
//  AppDelegate.swift
//  MoneyMind
//
//  Created by Justin Justiniano  on 3/5/21.
//

import UIKit
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        preloadData()
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    private func preloadData()
    {
        let preloadedDataKey = "didPreload"
        let userDefaults = UserDefaults.standard
        if userDefaults.bool(forKey: preloadedDataKey) == false
        {
            guard  let urlPath = Bundle.main.url(forResource: "PreloadCategory", withExtension: "plist")
            else{return}
            
            let backgroundContext = persistentContainer.newBackgroundContext()
            backgroundContext.perform {
                
                do
                {
                    let notificationSettingObject = NotificationSettings(context: backgroundContext)
                    notificationSettingObject.enable = 0;
                    notificationSettingObject.daily = 0;
                    notificationSettingObject.weekly = 0;
                    notificationSettingObject.monthly = 0;
                    notificationSettingObject.reoccurring = 0;
                    
                    let budgetItem = Budget(context: backgroundContext)
                    budgetItem.amount = 0;
                    
                    try backgroundContext.save()
                }
                catch
                {
                    print ("Error Saving Notif Settings")
                }
                
                if let arrayContents = NSArray(contentsOf: urlPath) as? [String]
                {
                    do{
                        for category in arrayContents
                        {
                            let categoryObject = Category(context: backgroundContext)
                            categoryObject.category = category
                            let budgetCategory = Budget(context: backgroundContext)
                            budgetCategory.amount = 0
                            categoryObject.budget = budgetCategory
                        }
                        try backgroundContext.save()
                        userDefaults.set(true, forKey: preloadedDataKey)
                    }
                    catch{
                        print("Error Saving Category Objects")
                    }
                }
            }
        }
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "MoneyMind")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

