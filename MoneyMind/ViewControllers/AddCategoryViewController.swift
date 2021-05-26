//
//  AddCategoryViewController.swift
//  MoneyMind
//
//  Created by Justin Justiniano  on 6/5/21.
//

import UIKit

class AddCategoryViewController: UIViewController {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    @IBOutlet weak var categoryTxt: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func addCategory(_ sender: Any) {
        guard let categoryText = categoryTxt.text, categoryText.isEmpty == false else
        {
            displayMessage(title: "Error", message: "Please Enter Category")
            return
        }
        createCategory(category: categoryText)
        navigationController?.popViewController(animated: true)
    }
        
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    func createCategory(category: String)
    {
        let newCategory = Category(context: context)
        newCategory.category = category
        
        do{
            try context.save()
        }
        catch
        {
            print("Saving Create did not Work")
        }
        
    }
    
    
    
    func displayMessage(title: String, message: String)
    {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
    
        self.present(alertController, animated: true, completion:nil)
        
    }
}
