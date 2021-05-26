//
//  CategoryExpensesViewController.swift
//  MoneyMind
//
//  Created by Justin Justiniano  on 6/5/21.
//

import UIKit

class CategoryExpensesViewController: UITableViewController {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
   
    private var models = [Category]()
    
    var totalCategoryAmount = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        getAllItems()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tableView.reloadData()
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return models.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        let rows = models[section].expenses?.count
        return rows!+1
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return models[section].category
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let expensesCell = tableView.dequeueReusableCell(withIdentifier: "expensesCell", for: indexPath)

        // Configure the cell...
        let expenses = models[indexPath.section].expenses?.allObjects as? [Expenses]
        let expensesCount = models[indexPath.section].expenses?.count ?? 0

        if indexPath.row == 0
        {
            totalCategoryAmount = 0
        }
        
        if expensesCount == 0
        {
            expensesCell.textLabel?.text = "There are no Expenses in this Category"
            expensesCell.detailTextLabel?.isHidden = true
        }
        else if indexPath.row < expensesCount
        {
            totalCategoryAmount = totalCategoryAmount + Int(expenses![indexPath.row].amount)
            expensesCell.textLabel?.text = expenses![indexPath.row].expense!
            expensesCell.detailTextLabel?.text = "$\(expenses![indexPath.row].amount)"
        }
        else if indexPath.row == expensesCount
        {
            if expensesCount == 1
            {
                expensesCell.textLabel?.text = "\(expensesCount) Expense for Category: "
            }
            else
            {
                expensesCell.textLabel?.text = "\(expensesCount) Expenses for Category: "
            }
            expensesCell.detailTextLabel?.text = "$\(totalCategoryAmount)"
        }
        return expensesCell
    }

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    func getAllItems()
    {
        do{
            models = try context.fetch(Category.fetchRequest())
        }
        
        catch{
            print("Getting Category did not Work")
        }
    }

}
