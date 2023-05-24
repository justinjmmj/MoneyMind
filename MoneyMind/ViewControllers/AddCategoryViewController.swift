//
//  AddCategoryViewController.swift
//  MoneyMind
//
//  Created by Justin Justiniano  on 7/6/21.
//

import UIKit

class AddCategoryViewController: UITableViewController {
   
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var categories = [Category]()
    var selectedCateogry: Category?
    var newCategory: String?
    var newCategoryAmount: Float?
    
    let categoryCell = "categoryCell"

    override func viewDidLoad() {
        super.viewDidLoad()
        getAllItems()
        tableView.reloadData()
    }

    override func viewDidAppear(_ animated: Bool) {
        getAllItems()
        tableView.reloadData()
    }
    
    @IBAction func addCategory(_ sender: Any) {
        addCategoryMessage(title: "New Category", message: "Please Enter Category")
    }
    
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Categories"
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return categories.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: categoryCell, for: indexPath)

        cell.textLabel?.text = categories[indexPath.row].category
        cell.detailTextLabel?.text = "Budget: $\(String(describing: categories[indexPath.row].budget!.amount))"

        return cell
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            selectedCateogry = categories[indexPath.row]
            if selectedCateogry?.category != "Others"
            {
                self.deleteItem(category: selectedCateogry!)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedCateogry = categories[indexPath.row]
        addCategoryMessage(title: "Edit Category", message: "")
    }
    
}

extension AddCategoryViewController
{
    func getAllItems()
    {
        do{
            categories = try context.fetch(Category.fetchRequest())
        }
        
        catch{
            print("Getting Category did not Work")
        }
    }
    
    func deleteItem(category: Category)
    {
        let expenses = category.expenses?.allObjects as! [Expenses]
        let othersCategory = categories.first(where: {$0.category == "Others"})
        for expense in expenses
        {
            expense.category = othersCategory
        }
        context.delete(category)
        do{
            try context.save()
            getAllItems()
            tableView.reloadData()
        }
        catch
        {
            
        }
        tableView.reloadData()
    }
    
    func createCategory(category: String, budget: Float)
    {
        if selectedCateogry == nil
        {
            let newCategory = Category(context: context)
            newCategory.category = category
            let budgetCategory = Budget(context: context)
            budgetCategory.amount = budget
            newCategory.budget = budgetCategory
        }
        else
        {
            selectedCateogry?.category = category
            selectedCateogry?.budget?.amount = budget
        }
        do{
            try context.save()
        }
        catch
        {
            print("Saving Create did not Work")
        }
    }
    
    func addCategoryMessage(title: String, message: String)
    {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alertController.addTextField { (textField: UITextField) in
            if self.selectedCateogry != nil
            {
                textField.text = self.selectedCateogry!.category
            }
            else
            {
                textField.placeholder = "Enter Category"
            }
        }
        alertController.addTextField{(textField: UITextField) in
            if self.selectedCateogry != nil
            {
                let budget = self.selectedCateogry!.budget
                textField.text = budget?.amount.description
            }
            else
            {
                textField.placeholder = "Enter Budget for Category"
            }
        }
        
        
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        
        alertController.addAction(UIAlertAction(title: "Confirm", style: .default, handler: { (UIAlertAction) in
            
            self.newCategory = alertController.textFields![0].text
            let newAmount = alertController.textFields![1].text
           
            if self.newCategory == ""
            {
                self.errorMessage(title: "Error", message: "Please Enter New Category")
            }
            else
            {
                if newAmount == ""
                {
                    self.newCategoryAmount = 0
                }
                else
                {
                    self.newCategoryAmount = Float((newAmount)!)
                }
                self.createCategory(category: self.newCategory!, budget: self.newCategoryAmount!)
                self.getAllItems()
                self.tableView.reloadData()
            }
        }))
        
        self.newCategoryAmount = 0
        self.newCategory = ""
        self.present(alertController, animated: true, completion:nil)
        
    }
    
    func errorMessage(title: String, message: String)
    {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
    
        self.present(alertController, animated: true, completion:nil)
        
    }
}

