//
//  StatisticsViewController.swift
//  MoneyMind
//
//  Created by Justin Justiniano  on 18/5/21.
//

import UIKit

class StatisticsViewController: UIViewController{
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let categoryCell = "categoryCell"
    
    @IBOutlet weak var statisticsTableView: UITableView!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var expensesLbl: UILabel!
    
    var categories = [Category]()
    var categoriesWithExpense = [Category]()
    var selectedDate = Date()
    var expensesAmount = 0
    var newLabel = ""
    
    let isAdded = 1
    let isNotAdded = 0
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getAllItems()
        totalDateExpense()
        
    }
    override func viewDidAppear(_ animated: Bool) {
        statisticsTableView.reloadData()
    }

    @IBAction func nextBtn(_ sender: Any) {
        selectedDate = CalendarMethods().nextMonth(date: selectedDate)
        
        newLabel =  "\(CalendarMethods().monthString(date: selectedDate)) \(CalendarMethods().yearString(date: selectedDate))"
        dateLbl.text = newLabel
        
        expensesAmount = 0
        totalDateExpense()
        statisticsTableView.reloadData()
    }
    @IBAction func prevBtn(_ sender: Any) {
        selectedDate = CalendarMethods().prevMonth(date: selectedDate)
        newLabel =  "\(CalendarMethods().monthString(date: selectedDate)) \(CalendarMethods().yearString(date: selectedDate))"
        dateLbl.text = newLabel
       
        expensesAmount = 0
        totalDateExpense()
        statisticsTableView.reloadData()
    }
}

extension StatisticsViewController
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
    func categoryExpenses() //Gets Categories with Expenses
    {
        categoriesWithExpense.removeAll()
        for categories in categories
        {
            let expensesCount = categories.expenses?.count
            if expensesCount != 0
            {
                categoriesWithExpense.append(categories)
            }
        }
        print(categoriesWithExpense.count)
    }
    
    func totalDateExpense()
    {
        categoriesWithExpense.removeAll()
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "LLLL yyyy"
        let formatSelectedDate = dateFormat.string(from: selectedDate)
        
        for category in categories
        {
            let expensesCount = category.expenses?.count
            let expenses = category.expenses?.allObjects as? [Expenses]
            var categoryAdded = isNotAdded
            if expensesCount != 0
            {
                for expenses in expenses!
                {
                    let expenseDate = dateFormat.string(from: expenses.date!)
                    if(expenseDate == formatSelectedDate)
                    {
                        expensesAmount += Int(expenses.amount)
                        if categoryAdded == isNotAdded
                        {
                            categoriesWithExpense.append(category)
                            categoryAdded = isAdded
                        }
                    }
                }
            }
            categoryAdded = isNotAdded
        }
        
        print(categoriesWithExpense.count)
        if expensesAmount > 0
        {
            expensesLbl.text = "Total Expenses $\(expensesAmount)"
        }
        else
        {
            expensesLbl.text = "No Expenses Have Been Made"
        }
        print (expensesAmount)
    }
}

extension StatisticsViewController: UITableViewDelegate, UITableViewDataSource
{
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Expenses on \(newLabel)"
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoriesWithExpense.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: categoryCell)!
        let category = categoriesWithExpense[indexPath.row]
        let expensesCount = category.expenses?.count
        let expenses = category.expenses?.allObjects as? [Expenses]
        
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "LLLL yyyy"
        let formatSelectedDate = dateFormat.string(from: selectedDate)
        
        var totalCategoryAmount = 0
        
        cell.textLabel?.text = category.category
        if expensesCount != 0
        {
            for expenses in expenses!
            {
                let expenseDate = dateFormat.string(from: expenses.date!)
                if(expenseDate == formatSelectedDate)
                {
                    totalCategoryAmount += Int(expenses.amount)
                }
            }
        }
        
        //categoryPercentage =
        cell.detailTextLabel?.text = "$\(totalCategoryAmount)"
        return cell
    }
}


