//
//  TransactionsViewController.swift
//  MoneyMind
//
//  Created by Justin Justiniano  on 27/5/21.
//

import UIKit

class TransactionsViewController: UIViewController {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    let segmentDailyExpense = 0
    let segmentCalendarExpense = 1
    let segmentCategoryExpense = 2
    
    @IBOutlet weak var dailyExpenseView: UIView!
    @IBOutlet weak var categoryExpenseView: UIView!
    @IBOutlet weak var calendarExpenseView: UIView!
    @IBOutlet weak var transactionsSegmentController: UISegmentedControl!
    
    var containerDailyExpense = DailyExpensesViewController()
    var containerCategoryExpense = DailyCategoryExpenseViewController()
    var containerCalendarExpense = CalendarViewController()
    
    private var models = [Expenses]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getAllItems()
        addChild(containerCategoryExpense)
        addChild(containerCalendarExpense)
        addChild(containerCategoryExpense)
        
        categoryExpenseView.isHidden = true
        calendarExpenseView.isHidden = true
        
        self.children[self.segmentDailyExpense].viewDidAppear(true)
        self.children[self.segmentCalendarExpense].viewDidDisappear(false)
        self.children[self.segmentCategoryExpense].viewDidDisappear(false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        dailyExpenseView.reloadInputViews()
        categoryExpenseView.reloadInputViews()
        calendarExpenseView.reloadInputViews()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addExpensesSegue"
        {
            let destination = segue.destination as! AddExpensesViewController
            destination.expensesDelegate = self
        }
    }
    
    @IBAction func transactionsSegmentControl(segment: UISegmentedControl) {
        dailyExpenseView.isHidden = true
        categoryExpenseView.isHidden = true
        calendarExpenseView.isHidden = true
        
        dailyExpenseView.reloadInputViews()
        categoryExpenseView.reloadInputViews()
        calendarExpenseView.reloadInputViews()
        
        if segment.selectedSegmentIndex == segmentDailyExpense
        {
            dailyExpenseView.isHidden = false
            self.children[self.segmentDailyExpense].viewDidAppear(true)
            self.children[self.segmentCalendarExpense].viewDidDisappear(true)
            self.children[self.segmentCategoryExpense].viewDidDisappear(true)
        }
        else if segment.selectedSegmentIndex == segmentCalendarExpense
        {
            calendarExpenseView.isHidden = false
            self.children[self.segmentCalendarExpense].viewDidAppear(true)
            self.children[self.segmentDailyExpense].viewDidDisappear(true)
            self.children[self.segmentCategoryExpense].viewDidDisappear(true)
        }
        else if segment.selectedSegmentIndex == segmentCategoryExpense
        {
            categoryExpenseView.isHidden = false
            self.children[self.segmentCategoryExpense].viewDidAppear(true)
            self.children[self.segmentCalendarExpense].viewDidDisappear(true)
            self.children[self.segmentDailyExpense].viewDidDisappear(true)
        }
    }
}

extension TransactionsViewController
{
    func getAllItems()
    {
        do{
            models = try context.fetch(Expenses.fetchRequest())
        }
        catch{
            print("Getting Expenses did not Work")
        }
    }
}

extension TransactionsViewController: ExpensesDelegate
{
    func getExpenses() -> Bool {
        getAllItems()
        return true
    }
}
