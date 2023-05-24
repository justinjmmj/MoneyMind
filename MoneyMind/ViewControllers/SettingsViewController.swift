//
//  SettingsViewController.swift
//  MoneyMind
//
//  Created by Justin Justiniano  on 6/5/21.
//

import UIKit

class SettingsViewController: UITableViewController {
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    let sectionNotification = 0
    let sectionAddCategory = 1
    let sectionSetBudget = 2
    let sectionClearData = 3
    
    let notificationCell = "notificationCell"
    let addCategoryCell = "addCategoryCell"
    let setBudgetCell = "setBudgetCell"
    let clearDataCell = "clearDataCell"
    
    var newCategory: String?
    
    private var models = [Expenses]()
    private var budgetData = [Budget]()
    private var selectedBudget: Budget?

    override func viewDidLoad() {
        super.viewDidLoad()
        getAllItems()
        selectedBudget = budgetData.first
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Settings"
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellNotification = tableView.dequeueReusableCell(withIdentifier: notificationCell, for: indexPath)
        let cellAddCategory = tableView.dequeueReusableCell(withIdentifier: addCategoryCell, for: indexPath)
        let cellSetBudget = tableView.dequeueReusableCell(withIdentifier: setBudgetCell, for: indexPath)
        let cellClearData = tableView.dequeueReusableCell(withIdentifier: clearDataCell, for: indexPath)
        
        if indexPath.row == sectionNotification
        {
            cellNotification.textLabel?.text = "Notification"
            return cellNotification
        }
        else if indexPath.row == sectionAddCategory
        {
            cellAddCategory.textLabel?.text = "Category List"
            return cellAddCategory
        }
        else if indexPath.row == sectionSetBudget
        {
            cellSetBudget.textLabel?.text = "Set Overall Budget"
            return cellSetBudget
        }
        else if indexPath.row == sectionClearData
        {
            cellClearData.textLabel?.text = "Clear Data"
            return cellClearData
        }

        return cellClearData;
    }

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return false
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == sectionNotification
        {
            performSegue(withIdentifier: "notificationSettingsSegue", sender: nil)
        }
        else if indexPath.row == sectionClearData
        {
            deleteDataMessage(title: "Confirm?", message: "Do you wish to proceed to delete Stored data?")
        }
        else if indexPath.row == sectionAddCategory
        {
        }
        else if indexPath.row == sectionSetBudget
        {
            addBudget(title: "Set Budget", message: "Enter Amount to Set as Budget")
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func getAllItems()
    {
        do
        {
            models = try context.fetch(Expenses.fetchRequest())
            budgetData = try context.fetch(Budget.fetchRequest())
        }
        catch
        {
            print("Getting Items Not working")
        }
    }
    
    func deleteAll()
    {
        for items in models
        {
            context.delete(items)
        }
        do{
            try context.save()
        }
        catch
        {
            
        }
    }
    
    func createCategory(category: String)
    {
        let newCategory = Category(context: context)
        newCategory.category = category
        let budgetCategory = Budget(context: context)
        budgetCategory.amount = 0
        newCategory.budget = budgetCategory

        do{
            try context.save()
        }
        catch
        {
            print("Saving Create did not Work")
        }
        
    }
    
    func settingBudget(amount: Float)
    {
        selectedBudget!.amount += amount
        do{
            try context.save()
            print("New Budget \(selectedBudget!.amount)")
        }
        catch
        {
            print("Saving New Budget Did not Work")
        }
    }
    
}

extension SettingsViewController //Alert Control Functions
{
    func addCategoryMessage(title: String, message: String)
    {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alertController.addTextField { (textField: UITextField) in
            textField.placeholder = "Enter Measurement"
        
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        
        alertController.addAction(UIAlertAction(title: "Confirm", style: .default, handler: { (UIAlertAction) in
            
            self.newCategory = alertController.textFields![0].text
            if self.newCategory == ""
            {
                self.errorMessage(title: "Error", message: "Please Enter New Category")
            }
            else
            {
                
                self.createCategory(category: self.newCategory!)
            }
        }))
        
        self.present(alertController, animated: true, completion:nil)
        }
    }
    
    func addBudget(title: String, message: String)
    {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alertController.addTextField { (textField: UITextField) in
            textField.placeholder = "Enter Amount"
        
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        
        alertController.addAction(UIAlertAction(title: "Confirm", style: .default, handler: { (UIAlertAction) in
            
            
            let inputBudget = alertController.textFields![0].text
            let setBudget = Float(inputBudget!)
            if setBudget == nil
            {
                self.errorMessage(title: "Error", message: "Please Enter Amount")
            }
            else
            {
                self.settingBudget(amount: setBudget!)
            }
        }))
        
        self.present(alertController, animated: true, completion:nil)
        }
    }
    
    func deleteDataMessage(title: String, message: String)
    {
        getAllItems()
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        
        alertController.addAction(UIAlertAction(title: "Confirm", style: .default, handler: { (UIAlertAction) in
            self.deleteAll()
        }))
        
        self.present(alertController, animated: true, completion:nil)
    }
    
    func errorMessage(title: String, message: String)
    {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
    
        self.present(alertController, animated: true, completion:nil)
        
    }
}
