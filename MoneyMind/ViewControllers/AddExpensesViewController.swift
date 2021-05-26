//
//  AddExpensesViewController.swift
//  MoneyMind
//
//  Created by Justin Justiniano  on 3/5/21.
//

import UIKit

class AddExpensesViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    @IBOutlet weak var expensesTxt: UITextField!
    @IBOutlet weak var amountTxt: UITextField!
    @IBOutlet weak var dateTxt: UIDatePicker!
    @IBOutlet weak var categoryTxt: UIPickerView!
    
    
    weak var expensesDelegate: ExpensesDelegate?
    var selectedExpense: Expenses?
    var selectedCategory: Category?
    var selectedBudget: Budget?
    
    private var categoryPickerData = [Category]()
    private var budgetData = [Budget]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getData()
        categoryTxt.dataSource = self
        categoryTxt.delegate = self
        selectedBudget = budgetData.first
        if selectedExpense != nil
        {
            self.title = "Edit Expenses"
            expensesTxt.text = selectedExpense?.expense
            amountTxt.text = String(describing: (selectedExpense?.amount)!)
            dateTxt.date = (selectedExpense?.date)!
            let selectedCategoryIndex = categoryPickerData.firstIndex(of: (selectedExpense?.category)!)!
            categoryTxt.selectRow(selectedCategoryIndex, inComponent: 0, animated: true)
        }
    }
    

    @IBAction func addExpenses(_ sender: UIButton) {
        guard let expensesName = expensesTxt.text, expensesName.isEmpty == false else
        {
            displayMessage(title: "Error", message: "Please Enter Expenses")
            return
        }
        guard let amountText = amountTxt.text, let amount = Int32(amountText) else
        {
            displayMessage(title: "Error", message: "Please Enter Amount")
            return
        }
        
        if let expensesDelegate = expensesDelegate
        {
            if selectedExpense == nil
            {
                self.createExpense(expense: expensesName, amount: amount, date: dateTxt.date, category: selectedCategory! )
            }
            else
            {
                selectedBudget!.amount += selectedExpense!.amount
                self.updateItem(expenses: selectedExpense!, expenseType: expensesName, amount: amount, date: dateTxt.date, category: selectedCategory!)
            }
            if expensesDelegate.getExpenses()
            {
                navigationController?.popViewController(animated: false)
                return
            }
            
        }
    }
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categoryPickerData.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return categoryPickerData[row].category
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int){
        selectedCategory = categoryPickerData[row]
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    
}

extension AddExpensesViewController //Data Functions
{
    func createExpense(expense: String, amount: Int32, date: Date, category: Category)
    {
        let newExpense = Expenses(context: context)
        newExpense.expense = expense
        newExpense.amount = amount
        newExpense.date = date
        newExpense.category = category
        newExpense.budget = selectedBudget
        selectedBudget!.amount -= newExpense.amount
        
        do{
            try context.save()
        }
        catch
        {
            print("Saving Create did not Work")
        }
        
    }
    
    func updateItem(expenses: Expenses, expenseType: String, amount: Int32, date: Date, category: Category)
    {
        expenses.expense = expenseType
        expenses.amount = amount
        expenses.date = date
        expenses.category = category
        selectedBudget!.amount -= expenses.amount
        
        do
        {
            try context.save()
        }
        catch{
            print("Saving Update did not Work")
        }
    }
    
    func getData()
    {
        do{
            categoryPickerData = try context.fetch(Category.fetchRequest())
            budgetData = try context.fetch(Budget.fetchRequest())
        }
        catch{
            print("Getting Category did not Work")
        }
    }
}

extension AddExpensesViewController //Alert Functions
{
    func displayMessage(title: String, message: String)
    {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
    
        self.present(alertController, animated: true, completion:nil)
    }

}
