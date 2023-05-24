//
//  OverallExpensesViewController.swift
//  MoneyMind
//
//  Created by Justin Justiniano  on 27/5/21.
//

import UIKit

class DailyExpensesViewController: UIViewController {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    let sectionExpense = 0
    let sectionInfo = 1
    
    let expensesCell = "expensesCell"
    let infoCell = "infoCell"
    
    var totalExpenses: Float = 0
    
    private var models = [Expenses]()
    var selectedExpenses = [Expenses]()
    var selectedExpense: Expenses?
    
    @IBOutlet weak var expensesTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        getAllItems()
        getDateExpense()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getAllItems()
        getDateExpense()
        expensesTableView.reloadData()
    }
    
    @IBAction func accessWalletBtn(_ sender: Any) {
        DeeplinkMethods().accessWallet()
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "editExpenseSegue"
        {
            let destination = segue.destination as! AddExpensesViewController
            destination.selectedExpense = selectedExpense
            destination.expensesDelegate = self
        }
    }
    

}

extension DailyExpensesViewController
{
    func getAllItems()
    {
        totalExpenses = 0
        do{
            models = try context.fetch(Expenses.fetchRequest())
            DispatchQueue.main.async {
                self.expensesTableView.reloadData()
            }
        }
        
        catch{
            print("Getting Expenses did not Work")
        }
    }
    
    func getDateExpense()
    {
        selectedExpenses.removeAll()
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "dd LLLL yyyy"
        let formattedDate = dateFormat.string(from: Date())
        for expense in models
        {
            let formattedExpenseDate = dateFormat.string(from: expense.date!)
            if formattedExpenseDate == formattedDate
            {
                totalExpenses += expense.amount
                selectedExpenses.append(expense)
            }
        }
    }
    
    func deleteItem(expenses: Expenses)
    {
        context.delete(expenses)
        do{
            try context.save()
            getAllItems()
            getDateExpense()
        }
        catch
        {
            
        }
    }
}

extension DailyExpensesViewController: ExpensesDelegate
{
    func getExpenses() -> Bool {
        getAllItems()
        return true
    }
}

extension DailyExpensesViewController: UITableViewDelegate, UITableViewDataSource
{
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section{
        case sectionExpense:
            let dateFormat = DateFormatter()
            dateFormat.dateFormat = "dd LLLL yyyy"
            let formattedDate = dateFormat.string(from: Date())
            return formattedDate
        default:
            return nil
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        switch section{
        case sectionExpense:
            return selectedExpenses.count
        case sectionInfo:
            return 1
        default:
            return 0
        }
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellExpenses = tableView.dequeueReusableCell(withIdentifier: expensesCell, for: indexPath)
        let cellInfo = tableView.dequeueReusableCell(withIdentifier: infoCell)
        
        if indexPath.section == sectionExpense
        {
            let model = selectedExpenses[indexPath.row]
            cellExpenses.textLabel?.text = model.expense
            cellExpenses.detailTextLabel?.text = "$\(String(model.amount))"
        }
        
        else if indexPath.section == sectionInfo
        {
            if selectedExpenses.isEmpty == true
            {
                cellInfo?.textLabel?.text = "There are no Expenses recorded Today"
                return cellInfo!
            }
            else if selectedExpenses.isEmpty == false
            {
                cellInfo?.textLabel?.text = "Total Expenses $\(totalExpenses), Budget Left $\(String(describing: models.first!.budget!.amount))"
                return cellInfo!
            }
        }
        return cellExpenses
    }
    

    
    // Override to support conditional editing of the table view.
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        if indexPath.section == sectionExpense{
            return false
        }
        return false
    }
    

    
    // Override to support editing the table view.
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete && indexPath.section == sectionExpense{
            // Delete the row from the data source
            selectedExpenses[indexPath.row].budget?.amount += selectedExpenses[indexPath.row].amount
            selectedExpenses[indexPath.row].category?.budget?.amount += selectedExpenses[indexPath.row].amount
            self.deleteItem(expenses: selectedExpenses[indexPath.row])
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedExpense = selectedExpenses[indexPath.row]
        performSegue(withIdentifier: "editExpenseSegue", sender: nil)
    }
}
