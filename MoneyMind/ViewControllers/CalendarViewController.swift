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
    @IBOutlet weak var expensesTableView: UITableView!
    
    var selectedDate = Date()
    var totalSquares = [String]()
    var dateSquares = [Date]()
    var expensesSquare = [String]()
    var dailyExpenseAmount = 0
    
    var expenses = [Expenses]()
    var selectedExpenses = [Expenses]()
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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        calenderColectionView.reloadData()
        expensesTableView.reloadData()
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
                //If statement doing the addition of DailyExpenses
                expensesSquare.append(String(dailyExpenseAmount))
                dailyExpenseAmount = 0
                
                dayOfMonth = CalendarMethods().nextDay(date: dayOfMonth)
            }
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
        expensesTableView.reloadData()
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
    
    func getDateExpenses(index: Int)
    {
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
        
        
        if totalSquares[indexPath.item] != ""
        {
            let dateIndex = Int(totalSquares[indexPath.item])! - 1
            let specificDate = dateSquares[dateIndex]
            
            let dateFormat = DateFormatter()
            dateFormat.dateFormat = "dd LLLL yyyy"
            
            let specificDateFormat = dateFormat.string(from: specificDate)
            let selectedDateFormat = dateFormat.string(from: selectedDate)
            
            var expenseAmount = 0
            
            for expenses in expenses
            {
                if specificDateFormat == selectedDateFormat
                {
                    expenseAmount += Int(expenses.amount)
                }
            }
            cell.expensesLbl.text = "$\(expenseAmount)"
        }
        else
        {
            cell.expensesLbl.text = ""
        }
        dailyExpenseAmount = 0
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if totalSquares[indexPath.item] != ""
        {
            let dateIndex = Int(totalSquares[indexPath.item])! - 1
            selectedDate = (dateSquares[dateIndex])
            
            tableSectionHeader = "Expenses Made On \((CalendarMethods().dayString(date: selectedDate))) \(CalendarMethods().monthString(date: selectedDate)) \(CalendarMethods().yearString(date: selectedDate))"
            
            selectedExpenses.removeAll()
            getDateExpenses(index: showDayExpenseIndex)
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
        }
        else
        {
            cell.textLabel?.text = "No Expenses Made"
            cell.detailTextLabel?.text = ""
        }
        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return tableSectionHeader
    }


}
