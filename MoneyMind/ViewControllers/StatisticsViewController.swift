//
//  StatisticsViewController.swift
//  MoneyMind
//
//  Created by Justin Justiniano  on 18/5/21.
//

import UIKit
import Charts

class StatisticsViewController: UIViewController, ChartViewDelegate{
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let categoryCell = "categoryCell"
    let expenseCell = "expenseCell"
    
    @IBOutlet weak var statisticsTableView: UITableView!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var expensesLbl: UILabel!
    @IBOutlet weak var graphView: UIView!
    @IBOutlet weak var expensesView: UIView!
    @IBOutlet weak var expensesTableView: UITableView!
    
    var categories = [Category]()
    var categoriesWithExpense = [Category]()
    var selectedCategory: Category?
    var selectedCategoryExpenses = [Expenses]()
    var selectedExpense: Expenses?
    
    var categoriesExpenseAmount = [Float]()
    var selectedDate = Date()
    var totalExpensesAmount: Float = 0
    var categoryAmount: Float = 0
    var newLabel = ""
    
    var pieChart = PieChartView()
    var pieChartEntries = [ChartDataEntry]()
    
    let isAdded = 1
    let isNotAdded = 0
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        pieChart.frame = CGRect(x: 0, y: 0, width: graphView.frame.height, height: graphView.frame.height)
        pieChart.center = graphView.center
        pieChart.holeColor = graphView.backgroundColor
        pieChart.transparentCircleColor = graphView.backgroundColor
        pieChart.drawEntryLabelsEnabled = false
        pieChart.usePercentValuesEnabled = true
        
        view.addSubview(pieChart)
        view.addSubview(expensesView)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        expensesView.isHidden = true
        getAllItems()
        totalDateExpense()
        selectedCategory = categoriesWithExpense.first
        getPercentage()
        pieChart.delegate = self
    }
    override func viewDidAppear(_ animated: Bool) {
        expensesView.isHidden = true
        pieChart.centerText = ""
        totalDateExpense()
        getPercentage()
        expensesTableView.reloadData()
        statisticsTableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addExpensesSegue"
        {
            let destination = segue.destination as! AddExpensesViewController
            destination.expensesDelegate = self
        }
        if segue.identifier == "editExpensesSegue"
        {
            let destination = segue.destination as! AddExpensesViewController
            
            if let indexPath = expensesTableView.indexPathForSelectedRow
            {
                let expenseList = selectedCategory?.expenses?.allObjects as! [Expenses]
                destination.selectedExpense = expenseList[indexPath.row]
                destination.expensesDelegate = self
            }
        }
    }
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        pieChart.centerText = entry.accessibilityLabel!
        pieChart.centerTextRadiusPercent = 0.95
    }

    @IBAction func nextBtn(_ sender: Any) {
        selectedDate = CalendarMethods().nextMonth(date: selectedDate)
        
        newLabel =  "\(CalendarMethods().monthString(date: selectedDate)) \(CalendarMethods().yearString(date: selectedDate))"
        dateLbl.text = newLabel
        
        totalExpensesAmount = 0
        totalDateExpense()
        getPercentage()
        pieChart.centerText = nil
        expensesView.isHidden = true
        expensesTableView.reloadData()
        statisticsTableView.reloadData()
    }
    @IBAction func prevBtn(_ sender: Any) {
        selectedDate = CalendarMethods().prevMonth(date: selectedDate)
        newLabel =  "\(CalendarMethods().monthString(date: selectedDate)) \(CalendarMethods().yearString(date: selectedDate))"
        dateLbl.text = newLabel
       
        totalExpensesAmount = 0
        totalDateExpense()
        getPercentage()
        pieChart.centerText = nil
        expensesView.isHidden = true
        expensesTableView.reloadData()
        statisticsTableView.reloadData()
    }
    
    @IBAction func closeBtn(_ sender: Any) {
        expensesView.isHidden = true
    }
    
    @IBAction func accessWalletBtn(_ sender: Any) {
        DeeplinkMethods().accessWallet()
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
    
    func totalDateExpense()
    {
        categoriesWithExpense.removeAll()
        categoriesExpenseAmount.removeAll()
        pieChartEntries.removeAll()
        totalExpensesAmount = 0
        pieChart.data = nil
        
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "LLLL yyyy"
        let formatSelectedDate = dateFormat.string(from: selectedDate)
        dateLbl.text = formatSelectedDate
        
        let attributedString = NSMutableAttributedString.init(string: formatSelectedDate)
        // Add Underline Style Attribute.
        attributedString.addAttribute(NSAttributedString.Key.underlineStyle, value: 1, range:
            NSRange.init(location: 0, length: attributedString.length));
        dateLbl.attributedText = attributedString
        
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
                        totalExpensesAmount += expenses.amount
                        categoryAmount += expenses.amount
                        if categoryAdded == isNotAdded
                        {
                            categoriesWithExpense.append(category)
                            categoryAdded = isAdded
                        }
                    }
                }
                if categoryAmount != 0
                {
                    categoriesExpenseAmount.append(categoryAmount)
                }
            }
            categoryAmount = 0
            categoryAdded = isNotAdded
        }
        
        if totalExpensesAmount > 0
        {
            expensesLbl.text = "Total Expenses $\(totalExpensesAmount)"
        }
        else
        {
            expensesLbl.text = "No Expenses Have Been Made"
        }
    }
    
    func getCategoryExpenses()
    {
        selectedCategoryExpenses.removeAll()
        let expenses = selectedCategory?.expenses?.allObjects as? [Expenses]
        for expense in expenses!
        {
            let dateFormat = DateFormatter()
            dateFormat.dateFormat = "LLLL yyyy"
            let formatSelectedDate = dateFormat.string(from: selectedDate)
            let expenseDate = dateFormat.string(from: expense.date!)
            if expenseDate == formatSelectedDate
            {
                selectedCategoryExpenses.append(expense)
            }
        }
    }
    
    func getPercentage()
    {
        pieChartEntries.removeAll()
        
        for x in 0..<categoriesWithExpense.count
        {
            let entry = PieChartDataEntry()
            entry.value = Double(categoriesExpenseAmount[x])
            entry.label = categoriesWithExpense[x].category
            entry.accessibilityLabel = categoriesWithExpense[x].category
            pieChartEntries.append(entry)
        }
        
        let set = PieChartDataSet(entries: pieChartEntries)
        set.colors = ChartColorTemplates.pastel()
        set.label = ""
        let data = PieChartData(dataSet: set)
        pieChart.data = data
    }
    
}

extension StatisticsViewController: UITableViewDelegate, UITableViewDataSource
{
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch tableView
        {
        case statisticsTableView:
            return "Expenses on \(newLabel)"
        case expensesTableView:
            return selectedCategory?.category
        default:
            return ""
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableView {
        case statisticsTableView:
            return categoriesWithExpense.count
        case expensesTableView:
            if selectedCategory != nil
            {
                return (selectedCategoryExpenses.count)
            }
            else
            {
                return 0
            }
        default:
            return 0
        }
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch tableView {
        case statisticsTableView:
            let cell = tableView.dequeueReusableCell(withIdentifier: categoryCell)!
            let category = categoriesWithExpense[indexPath.row]
            let amount = categoriesExpenseAmount[indexPath.row]
            
            cell.textLabel?.text = category.category
            cell.detailTextLabel?.text = "$\(amount)"
            return cell
        case expensesTableView:
            let cell = tableView.dequeueReusableCell(withIdentifier: expenseCell)!
            
            cell.textLabel?.text = selectedCategoryExpenses[indexPath.row].expense
            cell.detailTextLabel?.text = "$\(selectedCategoryExpenses[indexPath.row].amount)"
            return cell
        default:
            return tableView.dequeueReusableCell(withIdentifier: categoryCell)!
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch tableView {
        case statisticsTableView:
            selectedCategory = categoriesWithExpense[indexPath.row]
            getCategoryExpenses()
            expensesTableView.reloadData()
            expensesView.isHidden = false
            statisticsTableView.deselectRow(at: indexPath, animated: false)
        default:
            return
        }
    }
}

extension StatisticsViewController: ExpensesDelegate
{
    func getExpenses() -> Bool {
        getAllItems()
        return true
    }
}

