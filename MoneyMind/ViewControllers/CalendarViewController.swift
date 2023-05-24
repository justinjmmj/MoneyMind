//
//  CalendarViewController.swift
//  MoneyMind
//
//  Created by Justin Justiniano  on 24/5/21.
//

import UIKit

class CalendarViewController: UIViewController
{
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    @IBOutlet weak var dateLbl: UILabel! 
    @IBOutlet weak var calenderColectionView: UICollectionView!
    @IBOutlet weak var expensesUITableView: UIView!
    @IBOutlet weak var expensesTableView: UITableView!
    
    
    var selectedDate = Date()
    var totalSquares = [String]()
    var dateSquares = [Date]()
    var expensesSquare = [String]()
    var dailyExpenseAmount: Float = 0
    
    var expenses = [Expenses]()
    var selectedExpenses = [Expenses]()
    var selectedExpense: Expenses?
    var tableSectionHeader = "Expenses"

    let calCell = "calCell"
    let expensesCell = "expensesCell"
    
    let showMonthExpenseIndex = 0
    let showDayExpenseIndex = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getAllItems()
        getDateExpenses(index: showMonthExpenseIndex)
        setCells()
        setMonth()
        expensesUITableView.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        getAllItems()
        getDateExpenses(index: showMonthExpenseIndex)
        setCells()
        setMonth()
        expensesUITableView.isHidden = true
        calenderColectionView.reloadData()
        expensesTableView.reloadData()
    }
    
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
    
    @IBAction func swipeNextMonth(_ sender: Any) {
        nextMonth()
    }
    @IBAction func swipePrevMonth(_ sender: Any) {
        prevMonth()
    }
    @IBAction func nextBtn(_ sender: Any) {
        nextMonth()
    }
    
    @IBAction func prevBtn(_ sender: Any) {
        prevMonth()
    }
    
    @IBAction func nextDayBtn(_ sender: Any) {
        selectedDate = CalendarMethods().nextDay(date: selectedDate)
        tableSectionHeader = "Expenses On \((CalendarMethods().dayString(date: selectedDate))) \(CalendarMethods().monthString(date: selectedDate)) \(CalendarMethods().yearString(date: selectedDate))"
        getDateExpenses(index: showDayExpenseIndex)
    }

    @IBAction func prevDayBtn(_ sender: Any) {
        selectedDate = CalendarMethods().prevDay(date: selectedDate)
        tableSectionHeader = "Expenses On \((CalendarMethods().dayString(date: selectedDate))) \(CalendarMethods().monthString(date: selectedDate)) \(CalendarMethods().yearString(date: selectedDate))"
        getDateExpenses(index: showDayExpenseIndex)
    }
    
    @IBAction func closeUIBtn(_ sender: Any) {
        expensesUITableView.isHidden = true
    }
    
    @IBAction func accessWalletBtn(_ sender: Any) {
        DeeplinkMethods().accessWallet()
    }
}
extension CalendarViewController
{
    func nextMonth()
    {
        selectedDate = CalendarMethods().nextMonth(date: selectedDate)
        setMonth()
    }
    func prevMonth()
    {
        selectedDate = CalendarMethods().prevMonth(date: selectedDate)
        setMonth()
    }
    func setCells()
    {
        let width = (calenderColectionView.frame.size.width - 2) / 7
        let height = (calenderColectionView.frame.size.height - 2) / 8

        let flowLayout = calenderColectionView.collectionViewLayout as! UICollectionViewFlowLayout
        flowLayout.itemSize = CGSize(width: width, height: height)
    }
    
    func setMonth()
    {
        totalSquares.removeAll()
        dateSquares.removeAll()
        expensesSquare.removeAll()
        selectedExpenses.removeAll()
        getDateExpenses(index: showMonthExpenseIndex)
        
        
        var dayOfMonth = CalendarMethods().firstOfMonth(date: selectedDate)
        let daysInMonth = CalendarMethods().daysInMonth(date: selectedDate)
        let startingCell = CalendarMethods().weekDay(date: dayOfMonth)
        let newLabel =  "\(CalendarMethods().monthString(date: selectedDate)) \(CalendarMethods().yearString(date: selectedDate))"
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "dd LLLL yyyy"
        
        var count: Int = 1
        
        while (count <= 42)
        {
            if (count <= startingCell || count - startingCell > daysInMonth)
            {
                totalSquares.append("")
                expensesSquare.append("")
            }
            else
            {
                totalSquares.append(String(count - startingCell))
                dateSquares.append(dayOfMonth)
                let formatDayofMonth = dateFormat.string(from: dayOfMonth)
                for expenses in expenses
                {
                    let formatExpenseDate = dateFormat.string(from: expenses.date!)
                    if formatExpenseDate == formatDayofMonth
                    {
                        dailyExpenseAmount += expenses.amount
                    }
                }
                if dailyExpenseAmount > 0
                {
                    expensesSquare.append("$\(String(dailyExpenseAmount))")
                }
                else
                {
                    expensesSquare.append("")
                }
                dailyExpenseAmount = 0
                dayOfMonth = CalendarMethods().nextDay(date: dayOfMonth)
            }
            dailyExpenseAmount = 0
            count += 1
        }
        
        let attributedString = NSMutableAttributedString.init(string: newLabel)
        // Add Underline Style Attribute.
        attributedString.addAttribute(NSAttributedString.Key.underlineStyle, value: 1, range:
            NSRange.init(location: 0, length: attributedString.length));
        
        dateLbl.text = newLabel
        dateLbl.attributedText = attributedString
        tableSectionHeader = "Expenses Made On \(newLabel)"
        
        calenderColectionView.reloadData()
    }
    
    func getAllItems()
    {
        do{
            expenses = try context.fetch(Expenses.fetchRequest())
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
            setCells()
            setMonth()
            getDateExpenses(index: showDayExpenseIndex)
        }
        catch
        {
            
        }
    }
    
    func getDateExpenses(index: Int)
    {
        selectedExpenses.removeAll()
        let dateFormat = DateFormatter()
        
        if index == showMonthExpenseIndex
        {
            dateFormat.dateFormat = "LLLL yyyy"
        }
        else if index == showDayExpenseIndex
        {
            dateFormat.dateFormat = "dd LLLL yyyy"
        }
        
        let formatToday = dateFormat.string(from: selectedDate)
        
        for expenses in expenses
        {
            let formattedDate = dateFormat.string(from: expenses.date!)
            if formattedDate == formatToday
            {
                selectedExpenses.append(expenses)
            }
        }
        tableSectionHeader = "Expenses On \((CalendarMethods().dayString(date: selectedDate))) \(CalendarMethods().monthString(date: selectedDate)) \(CalendarMethods().yearString(date: selectedDate))"
        expensesTableView.reloadData()
    }
}

extension CalendarViewController: ExpensesDelegate
{
    func getExpenses() -> Bool {
        getAllItems()
        return true
    }
}

extension CalendarViewController: UICollectionViewDelegate, UICollectionViewDataSource
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return totalSquares.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = calenderColectionView.dequeueReusableCell(withReuseIdentifier: calCell, for: indexPath) as! CalendarCollectionViewCell
        cell.dayLbl.text =  totalSquares[indexPath.item]
        cell.expensesLbl.text = expensesSquare[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if totalSquares[indexPath.item] != ""
        {
            let dateIndex = Int(totalSquares[indexPath.item])! - 1
            selectedDate = (dateSquares[dateIndex])
            
            tableSectionHeader = "Expenses On \((CalendarMethods().dayString(date: selectedDate))) \(CalendarMethods().monthString(date: selectedDate)) \(CalendarMethods().yearString(date: selectedDate))"
            
            selectedExpenses.removeAll()
            getDateExpenses(index: showDayExpenseIndex)
            expensesUITableView.isHidden = false
        }
        expensesTableView.reloadData()
        collectionView.reloadData()
    }
    
}

extension CalendarViewController: UITableViewDelegate, UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if selectedExpenses.count == 0
        {
            return 1
        }
        else
        {
            return selectedExpenses.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: expensesCell)!
        if selectedExpenses.count != 0
        {
            let model = selectedExpenses[indexPath.row]
            cell.textLabel?.text = model.expense
            cell.detailTextLabel?.text = "$\(String(model.amount))"
            tableView.allowsSelection = true
        }
        else
        {
            cell.textLabel?.text = "No Expenses Made"
            cell.detailTextLabel?.text = ""
            tableView.allowsSelection = false
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return tableSectionHeader
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedExpense = selectedExpenses[indexPath.row]
        expensesUITableView.isHidden = true
        performSegue(withIdentifier: "editExpenseSegue", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete
        {
            // Delete the row from the data source
            selectedExpense = selectedExpenses[indexPath.row]
            selectedExpense?.budget?.amount += selectedExpense!.amount
            selectedExpense!.category?.budget?.amount += selectedExpense!.amount
            self.deleteItem(expenses: selectedExpense!)
        }
    }
}
