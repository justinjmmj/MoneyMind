//
//  ExpensesViewController.swift
//  MoneyMind
//
//  Created by Justin Justiniano  on 3/5/21.
//

import UIKit

class ExpensesViewController: UITableViewController{
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    let sectionExpense = 0
    let sectionInfo = 1
    
    let expensesCell = "expensesCell"
    let infoCell = "infoCell"
    
    var totalExpenses: Int32 = 0
    
    private var models = [Expenses]()
    var selectedExpense: Expenses?
    
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
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        switch section{
        case sectionExpense:
            return models.count
        case sectionInfo:
            return 1
        default:
            return 0
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellExpenses = tableView.dequeueReusableCell(withIdentifier: expensesCell, for: indexPath)
        let cellInfo = tableView.dequeueReusableCell(withIdentifier: infoCell)
        
        if indexPath.section == sectionExpense
        {
            let model = models[indexPath.row]
            cellExpenses.textLabel?.text = model.expense
            cellExpenses.detailTextLabel?.text = "$\(String(model.amount))"
        }
        
        else if indexPath.section == sectionInfo
        {
            if models.isEmpty == true
            {
                cellInfo?.textLabel?.text = "There are no Expenses recorded"
                return cellInfo!
            }
            else if models.isEmpty == false
            {
                cellInfo?.textLabel?.text = "Total Expenses $\(totalExpenses), Budget Left $\(String(describing: models.first!.budget!.amount))"
                return cellInfo!
            }
        }
        return cellExpenses
    }
    

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        if indexPath.section == sectionExpense{
            return true
        }
        return false
    }
    

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete && indexPath.section == sectionExpense{
            // Delete the row from the data source
            self.deleteItem(expenses: models[indexPath.row])
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedExpense = models[indexPath.row]
        performSegue(withIdentifier: "editExpensesSegue", sender: nil)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addExpensesSegue"
        {
            let destination = segue.destination as! AddExpensesViewController
            destination.expensesDelegate = self
        }
        if segue.identifier == "editExpensesSegue"
        {
            let destination = segue.destination as! AddExpensesViewController
            destination.selectedExpense = selectedExpense
            destination.expensesDelegate = self
        }
    }

}

extension ExpensesViewController
{
    func getAllItems()
    {
        totalExpenses = 0
        do{
            models = try context.fetch(Expenses.fetchRequest())
            for expenses in models
            {
                totalExpenses += expenses.amount
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        
        catch{
            print("Getting Expenses did not Work")
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
}

extension ExpensesViewController: ExpensesDelegate
{
    func getExpenses() -> Bool {
        getAllItems()
        return true
    }
}
