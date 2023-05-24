//
//  CategoryExpenseViewController.swift
//  MoneyMind
//
//  Created by Justin Justiniano  on 27/5/21.
//

import UIKit

class DailyCategoryExpenseViewController: UIViewController {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    private var models = [Category]()
    var categoryWithExpense = [Category]()
    var categoryWithExpenseToday = [String: [Expenses]]()
    var categoryDictKey = [Category]()
    var selectedExpense: Expenses?
    
    var totalCategoryAmount: Float = 0

    @IBOutlet weak var noExpenseLbl: UILabel!
    @IBOutlet weak var categoryExpenseTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getAllItems()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getAllItems()
        categoryExpenseTable.reloadData()
    }
    
    @IBAction func accessWalletBtn(_ sender: Any) {
        DeeplinkMethods().accessWallet()
    }
    
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editDailyCategoryExpenseSegue"
        {
            let destination = segue.destination as! AddExpensesViewController
            
            if let selectedIndexPath = categoryExpenseTable.indexPathForSelectedRow
            {
                let key = categoryDictKey[selectedIndexPath.section].category
                let expensesList = categoryWithExpenseToday[key!]
                let expense = expensesList![selectedIndexPath.row]
                selectedExpense = expense
                
                destination.selectedExpense = selectedExpense
                destination.expensesDelegate = self
            }
        }
        
    }
    

}
extension DailyCategoryExpenseViewController
{
    func getAllItems()
    {
        models.removeAll()
        do{
            models = try context.fetch(Category.fetchRequest())
            getCategoryWithExpenseDate()
            DispatchQueue.main.async {
                self.categoryExpenseTable.reloadData()
            }
        }
        
        catch{
            print("Getting Category did not Work")
        }
    }
    
    func deleteItem(expenses: Expenses)
    {
        context.delete(expenses)
        do{
            try context.save()
            getAllItems()
        }
        catch
        {
            
        }
    }
    
    func getCategoryWithExpenseDate()
    {
        noExpenseLbl.isHidden = true
        
        categoryWithExpense.removeAll()
        categoryWithExpenseToday.removeAll()
        categoryDictKey.removeAll()
        
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "dd LLLL yyyy"
        let formattedDate = dateFormat.string(from: Date())
        
        for category in models
        {
            let expensesList = category.expenses?.allObjects as? [Expenses]
            for expense in expensesList!
            {
                let keyExist = categoryWithExpenseToday[category.category!] != nil
                let expenseDate = dateFormat.string(from: expense.date!)
                
                if expenseDate == formattedDate
                {
                    if keyExist == false
                    {
                        let newExpenseArray = [expense]
                        categoryWithExpenseToday.updateValue(newExpenseArray, forKey: category.category!)
                        categoryDictKey.append(category)
                    }
                    else
                    {
                        categoryWithExpenseToday[category.category!]!.append(expense)
                    }
                }
            }
        }
        if categoryWithExpenseToday.count == 0
        {
            noExpenseLbl.isHidden = false
            noExpenseLbl.text = "There are no Expenses recorded"
        }
    }
}

extension DailyCategoryExpenseViewController: UITableViewDelegate, UITableViewDataSource
{
     func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return categoryWithExpenseToday.count
    }

     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        let rows = categoryWithExpenseToday[categoryDictKey[section].category!]!.count
        return rows+1
    }
    
     func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let category = categoryDictKey[section]
        return category.category
    }


     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let expensesCell = tableView.dequeueReusableCell(withIdentifier: "expensesCell", for: indexPath)

        // Configure the cell...
        let key = categoryDictKey[indexPath.section].category
        let expensesList = categoryWithExpenseToday[key!]
        let expensesCount = expensesList!.count
        
        if expensesCount == 0
        {
            expensesCell.textLabel?.text = "There are no Transactions in this Category"
        }
        else if indexPath.row < expensesCount
        {
            if indexPath.row == 0
            {
                totalCategoryAmount = 0
            }
            totalCategoryAmount = totalCategoryAmount + expensesList![indexPath.row].amount
            expensesCell.textLabel?.text = expensesList![indexPath.row].expense!
            expensesCell.detailTextLabel?.text = "$\(expensesList![indexPath.row].amount)"
        }
        else if indexPath.row == expensesCount
        {
            expensesCell.textLabel?.text = "Total: $\(totalCategoryAmount)"
            expensesCell.detailTextLabel?.text = "Budget $\(categoryDictKey[indexPath.section].budget!.amount)"
        }
        return expensesCell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "editDailyCategoryExpenseSegue", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        let key = categoryDictKey[indexPath.section].category
        let expensesList = categoryWithExpenseToday[key!]
        let expensesCount = expensesList!.count
        if expensesCount == indexPath.row
        {
            return nil
        }
        else
        {
            print("\(indexPath.section) and \(indexPath.row)")
            print()
            
            return indexPath
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        let key = categoryDictKey[indexPath.section].category
        let expensesList = categoryWithExpenseToday[key!]
        let expensesCount = expensesList!.count
        selectedExpense = expensesList![indexPath.row]
        
        if editingStyle == .delete && indexPath.row != expensesCount{
            // Delete the row from the data source
            selectedExpense?.budget?.amount += selectedExpense!.amount
            selectedExpense!.category?.budget?.amount += selectedExpense!.amount
            self.deleteItem(expenses: selectedExpense!)
            tableView.reloadData()
        }
    }
    
     func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let key = categoryDictKey[indexPath.section].category
        let expensesList = categoryWithExpenseToday[key!]
        let expensesCount = expensesList!.count
        if expensesCount == indexPath.row
        {
            return false
        }
        else
        {
            return false
        }
    }
}

extension DailyCategoryExpenseViewController: ExpensesDelegate
{
    func getExpenses() -> Bool {
        getAllItems()
        return true
    }
}
