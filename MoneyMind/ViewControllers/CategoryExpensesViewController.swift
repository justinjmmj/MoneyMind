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
    var categoryWithExpense = [Category]()
    var searchCategory = [Category]()
    var selectedExpense: Expenses?
    
    var totalCategoryAmount: Float = 0
    
    @IBOutlet weak var noExpenseLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getAllItems()
        searchCategory = categoryWithExpense
        
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
        getCategoryWithExpense()
        searchCategory = categoryWithExpense
        
        self.tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addExpensesSegue"
        {
            let destination = segue.destination as! AddExpensesViewController
            destination.expensesDelegate = self
        }
        
        if segue.identifier == "editCategoryExpenseSegue"
        {
            let destination = segue.destination as! AddExpensesViewController
            
            if let selectedIndexPath = tableView.indexPathForSelectedRow
            {
                let expensesList = categoryWithExpense[selectedIndexPath.section].expenses?.allObjects as? [Expenses]
                let expense = expensesList![selectedIndexPath.row]
                selectedExpense = expense
            
                destination.selectedExpense = selectedExpense
                destination.expensesDelegate = self
            }
        }
    }
    @IBAction func accessWalletBtn(_ sender: Any) {
        DeeplinkMethods().accessWallet()
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return searchCategory.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        let rows = searchCategory[section].expenses?.count
        return rows!+1
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return searchCategory[section].category
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let expensesCell = tableView.dequeueReusableCell(withIdentifier: "expensesCell", for: indexPath)

        // Configure the cell...
        let expenses = searchCategory[indexPath.section].expenses?.allObjects as? [Expenses]
        let expensesCount = searchCategory[indexPath.section].expenses!.count
        
        if expensesCount == 0
        {
            expensesCell.textLabel?.text = "There are no Transactions in this Category"
            expensesCell.detailTextLabel?.isHidden = true
        }
        else if indexPath.row < expensesCount
        {
            if indexPath.row == 0
            {
                totalCategoryAmount = 0
            }
            totalCategoryAmount = totalCategoryAmount + expenses![indexPath.row].amount
            expensesCell.textLabel?.text = expenses![indexPath.row].expense!
            expensesCell.detailTextLabel?.text = "$\(expenses![indexPath.row].amount)"
        }
        else if indexPath.row == expensesCount
        {
            expensesCell.textLabel?.text = "Total: $\(totalCategoryAmount)"
            expensesCell.detailTextLabel?.text = "Budget: $\(searchCategory[indexPath.section].budget!.amount)"
        }
        return expensesCell
    }

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        let expensesList = searchCategory[indexPath.section].expenses?.allObjects as? [Expenses]
        if indexPath.row == expensesList?.count
        {
            return false
        }
        else
        {
            return true
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        let expensesList = searchCategory[indexPath.section].expenses?.allObjects as? [Expenses]
        
        if editingStyle == .delete && indexPath.row != expensesList?.count
        {
            // Delete the row from the data source
            selectedExpense = expensesList![indexPath.row]
            selectedExpense?.budget?.amount += selectedExpense!.amount
            selectedExpense!.category?.budget?.amount += selectedExpense!.amount
            self.deleteItem(expenses: selectedExpense!)
        }
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        let expensesList = searchCategory[indexPath.section].expenses?.allObjects as? [Expenses]
        if indexPath.row == expensesList?.count
        {
            return nil
        }
        else
        {
            return indexPath
        }
    }
}

extension CategoryExpensesViewController: UISearchResultsUpdating
{
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text?.lowercased()
        else{return}
        if searchText.count > 0
        {
            searchCategory = categoryWithExpense.filter({(category: Category) -> Bool in
                return (category.category!.lowercased().contains(searchText))
            })
        }
        else
        {
            searchCategory = categoryWithExpense
        }
        tableView.reloadData()
    }
}

extension CategoryExpensesViewController
{
    
    func getAllItems()
    {
        do{
            models = try context.fetch(Category.fetchRequest())
            getCategoryWithExpense()
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
            tableView.reloadData()
        }
        catch
        {
            
        }
        tableView.reloadData()
    }
    
    func getCategoryWithExpense()
    {
        noExpenseLbl.isHidden = true
        categoryWithExpense.removeAll()
        for category in models
        {
            if category.expenses!.count != 0
            {
                categoryWithExpense.append(category)
            }
        }
        if categoryWithExpense.count == 0
        {
            noExpenseLbl.isHidden = false
            noExpenseLbl.text = "There are no Expenses recorded"
        }
    }
}

extension CategoryExpensesViewController: ExpensesDelegate
{
    func getExpenses() -> Bool {
        getAllItems()
        return true
    }
}
