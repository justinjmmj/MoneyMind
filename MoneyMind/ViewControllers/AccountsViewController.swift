//
//  ExpensesViewController.swift
//  MoneyMind
//
//  Created by Justin Justiniano  on 3/5/21.
//

import UIKit

class AccountsViewController: UITableViewController{
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    let expensesCell = "expensesCell"
    let infoCell = "infoCell"
    
    private var models = [Expenses]()
    
    var expensesByDateDict = [String: [Expenses]]()
    var sortedDictionaryKeys = [String]()
    var totalExpenses: Float = 0
    
    var searchExpense = [Expenses]()
    var searchExpenseDict = [String: [Expenses]]()
    var searchKey = [String]()
    
    var selectedExpense: Expenses?
    
    @IBOutlet weak var infoLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getAllItems()
        fillDictionary(keyArray: &sortedDictionaryKeys, expensesDictionary: &expensesByDateDict, ExpensesArray: &models)
        
        searchExpenseDict = expensesByDateDict
        searchKey = sortedDictionaryKeys
        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search All"
        navigationItem.searchController = searchController
        
        definesPresentationContext = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getAllItems()
        fillDictionary(keyArray: &sortedDictionaryKeys, expensesDictionary: &expensesByDateDict, ExpensesArray: &models)
        searchExpenseDict = expensesByDateDict
        searchKey = sortedDictionaryKeys
        self.tableView.reloadData()
    }

    @IBAction func accessWalletBtn(_ sender: Any) {
        DeeplinkMethods().accessWallet()
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return searchExpenseDict.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return searchExpenseDict[searchKey[section]]!.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return searchKey[section]
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cellExpenses = tableView.dequeueReusableCell(withIdentifier: expensesCell, for: indexPath)
        
        let key = searchKey[indexPath.section]
        let expenseList = searchExpenseDict[key]
        let expense = expenseList![indexPath.row]
        cellExpenses.textLabel?.text = expense.expense
        cellExpenses.detailTextLabel?.text = "$\(String(expense.amount))"
        
        return cellExpenses
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
        
    }
    
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete
        {
            // Delete the row from the data source
            let key = searchKey[indexPath.section]
            let expenseList = expensesByDateDict[key]
            let expense = expenseList![indexPath.row]
            expense.budget?.amount += expense.amount
            expense.category?.budget?.amount += expense.amount
            self.deleteItem(expenses: expense)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let key = searchKey[indexPath.section]
        let expenseList = expensesByDateDict[key]
        selectedExpense = expenseList![indexPath.row]
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

extension AccountsViewController: UISearchResultsUpdating
{
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text?.lowercased()
        else{return}
        if searchText.count > 0
        {
            searchExpense = models.filter({(expenses: Expenses) -> Bool in
                return(expenses.expense!.lowercased().contains(searchText))
            })
            fillDictionary(keyArray: &searchKey, expensesDictionary: &searchExpenseDict, ExpensesArray: &searchExpense)
        }
        else
        {
            searchExpenseDict = expensesByDateDict
            searchKey = sortedDictionaryKeys
        }
        tableView.reloadData()
    }
}

extension AccountsViewController
{
    func getAllItems()
    {
        totalExpenses = 0
        do{
            models = try context.fetch(Expenses.fetchRequest())
            models.sort(by: {
                $0.date! > $1.date!
            })
            for expenses in models
            {
                totalExpenses += expenses.amount
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            
            if models.count != 0
            {
                infoLbl.text = "Total Expenses $\(totalExpenses), Budget Left $\(String(describing: models.first!.budget!.amount))"
            }
            else
            {
                infoLbl.text = "There are no Expenses recorded"
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
            fillDictionary(keyArray: &sortedDictionaryKeys, expensesDictionary: &expensesByDateDict, ExpensesArray: &models)
            fillDictionary(keyArray: &searchKey, expensesDictionary: &searchExpenseDict, ExpensesArray: &models)
        }
        catch
        {
            
        }
    }
    
    func fillDictionary(keyArray: inout [String], expensesDictionary: inout [String: [Expenses]], ExpensesArray: inout [Expenses])
    {
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "dd LLLL yyyy"
        keyArray.removeAll()
        expensesDictionary.removeAll()
        
        for expenses in ExpensesArray
        {
            let expenseDate = dateFormat.string(from: expenses.date!)
            let keyExist = expensesDictionary[expenseDate] != nil
            
            if keyExist == false
            {
                let newExpenseArray = [expenses]
                expensesDictionary.updateValue(newExpenseArray, forKey: expenseDate)
                keyArray.append(expenseDate)
            }
            else
            {
                expensesDictionary[expenseDate]!.append(expenses)
            }
        }
    }
}

extension AccountsViewController: ExpensesDelegate
{
    func getExpenses() -> Bool {
        getAllItems()
        return true
    }
}
