//
//  NotificationSettingsViewController.swift
//  MoneyMind
//
//  Created by Justin Justiniano  on 19/5/21.
//

import UIKit
import NotificationCenter

class NotificationSettingsViewController: UITableViewController {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    let notificationSettingCell = "notificationSettingCell"
    let notificationSettingData = ["Enable Notification", "Daily Expenses", "Weekly Expenses", "Monthly Expenses", "Reoccurring Expenses Made"]
    
    let enableTag = 0
    let dailyTag = 1
    let weeklyTag = 2
    let monthlyTag = 3
    let reoccurringTag = 4
    
    let enableIdentifier = "enableID"
    let dailyIdentifier = "dailyID"
    let weeklyIdentifier = "weeklyID"
    let monthlyIdentifier = "monthlyID"
    let reoccurringIdentifier = "reoccurringID"
    
    let isON: Int16 = 1
    let isOff: Int16 = 0
    
    var expenses = [Expenses]()
    var notificationSettingsData = [NotificationSettings]()
    var notificationSettings: NotificationSettings?
    var settingsInt = [Int16]()
    
    let reminderWeekDay = 1
    let reminderDay = 1
    let reminderHour = 22
    let reminderMinute = 30
    var dailyNotifTiming = DateComponents()
    var weeklyNotifTiming = DateComponents()
    var monthlyNotifTiming = DateComponents()
    
    var dailyExpenses = 0
    var weeklyExpenses = 0
    var monthlyExpenses = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getNotifSettings()
        
        dailyNotifTiming.hour = reminderHour
        dailyNotifTiming.minute = reminderMinute
        
        weeklyNotifTiming.weekday = reminderWeekDay
        weeklyNotifTiming.hour = reminderHour
        weeklyNotifTiming.minute = reminderMinute
        
        monthlyNotifTiming.day = reminderDay
        monthlyNotifTiming.hour = reminderHour
        monthlyNotifTiming.minute = reminderMinute
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notificationSettingData.count
    }
    

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellNotificationSetting = tableView.dequeueReusableCell(withIdentifier: notificationSettingCell, for: indexPath)
        
        cellNotificationSetting.textLabel?.text = notificationSettingData[indexPath.row]

        // Adding switch in each Cell
        let notificationSwitch = UISwitch(frame: .zero)
        if settingsInt[indexPath.row] == isOff
        {
            notificationSwitch.setOn(false, animated: true)
        }
        else
        {
            notificationSwitch.setOn(true, animated: true)
        }
        notificationSwitch.tag = indexPath.row
        notificationSwitch.addTarget(self, action: #selector(self.switchChanged(_:)), for: .valueChanged)
        cellNotificationSetting.accessoryView = notificationSwitch
        return cellNotificationSetting
    }

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return false
    }
    
    @objc func switchChanged(_ sender: UISwitch!)
    {
        if sender.isOn == true
        {
            settingsInt[sender.tag] = isON
            if settingsInt[enableTag] == isOff
            {
                settingsInt[sender.tag] = isOff
                sender.setOn(false, animated: true)
            }
            else
            {
                enableNotification(tag: sender.tag)
            }
        }
        else
        {
            settingsInt[sender.tag] = isOff
            offNotification(tag: sender.tag)
            if sender.tag == enableTag
            {
                offAllNotification(notifSettings: notificationSettings!)
            }
        }

        updateSettings(notifSettings: notificationSettings!, enable: settingsInt[0], daily: settingsInt[1], weekly: settingsInt[2], monthly: settingsInt[3], reoccurring: settingsInt[4])
    }
    
    func getNotifSettings()
    {
        do{
            expenses = try context.fetch(Expenses.fetchRequest())
            notificationSettingsData = try context.fetch(NotificationSettings.fetchRequest())
            notificationSettings = notificationSettingsData.first
            settingsInt = [notificationSettings!.enable, notificationSettings!.daily, notificationSettings!.weekly, notificationSettings!.monthly, notificationSettings!.reoccurring]
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        
        catch{
            print("Getting Data did not Work")
        }
    }
    
    
    func updateSettings(notifSettings: NotificationSettings, enable: Int16, daily: Int16, weekly: Int16, monthly: Int16, reoccurring: Int16)
    {
        notifSettings.enable = enable
        notifSettings.daily = daily
        notifSettings.weekly = weekly
        notifSettings.monthly = monthly
        notifSettings.reoccurring = reoccurring
        do
        {
            try context.save()
        }
        catch{
            print("Saving Update did not Work")
        }
    }
    
    func enableNotification(tag: Int)
    {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound], completionHandler: { success, error in
            if success
            {
                if tag == self.enableTag
                {
                    self.setNotification(title: "Welcome to MoneyMind", body: "MoneyMind is here to help you track your finances", tag: tag)
                }
                else if tag == self.dailyTag
                {
                    self.setNotification(title: "Daily Expenses", body: "Expenses for the day is $$$", tag: tag)
                }
                else if tag == self.weeklyTag
                {
                    self.setNotification(title: "Weekly Expenses", body: "Expenses for the day is $$$", tag: tag)
                }
                else if tag == self.monthlyTag
                {
                    self.setNotification(title: "Monthly Expenses", body: "Expenses for the day is $$$", tag: tag)
                }
                else if tag == self.reoccurringTag
                {
                    self.setNotification(title: "Reoccurring Expenses", body: "Expenses for the day is $$$", tag: tag)
                }
                print("Success")
            }
            else if error != nil
            {
                print("Error Occurred")
            }
        })
        print("Enabled")
    }
    
    func setNotification(title: String, body: String, tag: Int)
    {
        //Notif Content
        let content = UNMutableNotificationContent()
        content.title = title
        content.sound = .default
        
        //Notif Trigger
        var trigger = UNCalendarNotificationTrigger(dateMatching: dailyNotifTiming, repeats: true)
        var identifier = ""
        
        
        //After enabling
//        if tag == enableTag
//        {
//            trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
//            identifier = enableIdentifier
//        }
        
        //Daily Time Interval
        if tag == dailyTag
        {
            content.body = body + String(dailyExpenses)
            trigger = UNCalendarNotificationTrigger(dateMatching: dailyNotifTiming, repeats: true)
            identifier = dailyIdentifier
        }
        
        //Weekly Time Interval
        else if tag == weeklyTag
        {
            content.body = body + String(weeklyExpenses)
            trigger = UNCalendarNotificationTrigger(dateMatching: weeklyNotifTiming, repeats: true)
            identifier = weeklyIdentifier
        }
        
        //Monthly Time Interval
        else if tag == monthlyTag
        {
            content.body = body + String(monthlyExpenses)
            trigger = UNCalendarNotificationTrigger(dateMatching: monthlyNotifTiming, repeats: true)
            identifier = monthlyIdentifier
        }
        
//        else if tag == reoccurringTag
//        {
//            trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
//            identifier = reoccurringIdentifier
//        }
        
        //Notif Create
        let newNotification = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        //Notif Add
        UNUserNotificationCenter.current().add(newNotification){(error) in
            if let error = error {
                print("Error: " + error.localizedDescription)
            }
            else
            {
                NSLog("Notification Scheduled \(tag)")
            }
        }
        
    }
    
    func offNotification(tag: Int)
    {
        var notificationIDs = [String]()
        var notificationID = ""
        if tag == dailyTag {notificationID = dailyIdentifier}
        else if tag == weeklyTag{notificationID = weeklyIdentifier}
        else if tag == monthlyTag{notificationID = monthlyIdentifier}
        else if tag == reoccurringTag{notificationID = reoccurringIdentifier}
        notificationIDs.append(notificationID)
        
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: notificationIDs)
        NSLog("Notification with ID:\(notificationID), has been turned off")
    }
    
    func offAllNotification(notifSettings: NotificationSettings)
    {
        notifSettings.enable = isOff
        notifSettings.daily = isOff
        notifSettings.weekly = isOff
        notifSettings.monthly = isOff
        notifSettings.reoccurring = isOff
        settingsInt = [isOff,isOff,isOff,isOff,isOff]
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        NSLog("Notification has been turned off")

        do
        {
            try context.save()
        }
        catch{
            print("Turning Off Settings did not Work")
        }
        tableView.reloadData()
    }
    
}
