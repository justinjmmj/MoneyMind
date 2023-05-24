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
    @IBOutlet weak var notesTxt: UITextField!
    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var addImageBtn: UIButton!
    
    weak var expensesDelegate: ExpensesDelegate?
    var selectedExpense: Expenses?
    var selectedCategory: Category?
    var selectedBudget: Budget?
    var imagePath = ""
    
    private var categoryPickerData = [Category]()
    private var budgetData = [Budget]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getData()
        categoryTxt.dataSource = self
        categoryTxt.delegate = self
        dateTxt.date = Date()
        selectedCategory = categoryPickerData[0]
        selectedBudget = budgetData.first
        
        if selectedExpense != nil
        {
            self.title = "Edit Expenses"
            expensesTxt.text = selectedExpense?.expense
            amountTxt.text = String(describing: (selectedExpense?.amount)!)
            dateTxt.date = (selectedExpense?.date)!
            let selectedCategoryIndex = categoryPickerData.firstIndex(of: (selectedExpense?.category)!)!
            categoryTxt.selectRow(selectedCategoryIndex, inComponent: 0, animated: true)
            selectedCategory = categoryPickerData[selectedCategoryIndex]
            notesTxt.text = selectedExpense?.notes
            
            if selectedExpense?.image != ""
            {
                imageView.image = loadImageData(fileName: (selectedExpense?.image)!)
            }
            
            addBtn.setTitle("Edit", for: .normal)
        }
    }
    
    @IBAction func addImage(_ sender: Any) {
        displayPhotosOptions()
    }
    
    
    @IBAction func addExpenses(_ sender: UIButton) {
        guard let expensesName = expensesTxt.text, expensesName.isEmpty == false else
        {
            displayMessage(title: "Error", message: "Please Enter Expenses")
            return
        }
        guard let amountText = amountTxt.text, let amount = Float(amountText) else
        {
            displayMessage(title: "Error", message: "Please Enter Amount")
            return
        }
        
        if let expensesDelegate = expensesDelegate
        {
            if selectedExpense == nil
            {
                self.createExpense(expense: expensesName, amount: amount, date: dateTxt.date, category: selectedCategory!, notes: notesTxt.text!)
            }
            else
            {
                selectedBudget!.amount += selectedExpense!.amount
                selectedExpense!.category!.budget!.amount += selectedExpense!.amount
                self.updateItem(expenses: selectedExpense!, expenseType: expensesName, amount: amount, date: dateTxt.date, category: selectedCategory!, notes: notesTxt.text!)
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
}

extension AddExpensesViewController //Data Functions
{
    func createExpense(expense: String, amount: Float, date: Date, category: Category, notes: String)
    {
        var fileName = ""
        let image = imageView.image
        if image != nil
        {
            let timeStamp = UInt(Date().timeIntervalSince1970)
            fileName = "\(timeStamp).jpg"
            let pathsList = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            let documentDirectory = pathsList[0]
            let imageFile = documentDirectory.appendingPathComponent(fileName)
            
            guard let data = image?.jpegData(compressionQuality: 0.8) else
            {
                print("Unable to Compress")
                return
            }
            do
            {
                try data.write(to: imageFile)
            }
            catch
            {
                print("Error Made")
            }
        }
        
        let newExpense = Expenses(context: context)
        newExpense.expense = expense
        newExpense.amount = amount
        newExpense.date = date
        newExpense.category = category
        newExpense.notes = notes
        newExpense.budget = selectedBudget
        newExpense.image = fileName
        if selectedBudget!.amount > 0
        {
            selectedBudget!.amount -= newExpense.amount
        }
        else
        {
            selectedBudget!.amount = 0
        }
        
        if newExpense.category!.budget!.amount > 0
        {
            newExpense.category!.budget!.amount -= newExpense.amount
        }
        else
        {
            newExpense.category!.budget!.amount = 0
        }
        
        do{
            try context.save()
        }
        catch
        {
            print("Saving Create did not Work")
        }
        
    }
    
    func updateItem(expenses: Expenses, expenseType: String, amount: Float, date: Date, category: Category, notes: String)
    {
        let image = imageView.image
        var fileName = expenses.image
        
        if image != nil
        {
            if fileName == ""
            {
                let timeStamp = UInt(Date().timeIntervalSince1970)
                fileName = "\(timeStamp).jpg"
            }
            let pathsList = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            let documentDirectory = pathsList[0]
            let imageFile = documentDirectory.appendingPathComponent(fileName!)
            
            guard let data = image?.jpegData(compressionQuality: 0.8) else
            {
                print("Unable to Compress")
                return
            }
            do
            {
                try data.write(to: imageFile)
                
            }
            catch
            {
                print("Error Made")
            }
        }
        
        expenses.expense = expenseType
        expenses.amount = amount
        expenses.date = date
        expenses.category = category
        expenses.notes = notes
        expenses.image = fileName
        
        if selectedBudget!.amount > 0
        {
            selectedBudget!.amount -= expenses.amount
        }
        else
        {
            selectedBudget!.amount = 0
        }

        if expenses.category!.budget!.amount > 0
        {
            expenses.category!.budget!.amount -= expenses.amount
        }
        else
        {
            expenses.category!.budget!.amount = 0
        }
        
        do
        {
            try context.save()
        }
        catch{
            print("Error Updating")
        }
    }
    
    func deleteItem(expenses: Expenses)
    {
        context.delete(expenses)
        do{
            try context.save()
        }
        catch
        {
            print("Error Deleting")
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
    
    func displayPhotosOptions()
    {
        let controller = UIImagePickerController()
        controller.allowsEditing = true
        controller.delegate = self
        
        let alertController = UIAlertController(title: "", message: "Select Option", preferredStyle: .actionSheet)
        
        let cameraAction = UIAlertAction(title: "Camera", style: .default)
        {
            action in controller.sourceType = .camera
            self.present(controller, animated: true, completion: nil)
        }
        
        let libraryAction = UIAlertAction(title: "Photo Library", style: .default)
        {
            action in controller.sourceType = .photoLibrary
            self.present(controller, animated: true, completion: nil)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        if UIImagePickerController.isSourceTypeAvailable(.camera)
        {
            alertController.addAction(cameraAction)
        }
        
        alertController.addAction(libraryAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
        
    }

}


extension AddExpensesViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[.editedImage] as? UIImage
        {
            imageView.image = pickedImage
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func loadImageData(fileName: String) -> UIImage?
    {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        
        let imageURL = documentsDirectory.appendingPathComponent(fileName)
        let image = UIImage(contentsOfFile: imageURL.path)
        return image
    }
}
