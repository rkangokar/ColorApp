//
//  RegisterVC.swift
//  ColorApp
//
//  Created by Vineeth Menon on 6/28/18.
//  Copyright © 2018 Reshma. All rights reserved.
//

import Foundation
import UIKit
import CoreData

// Class RegisterVC is linked to Register ViewController.
class RegisterVC : UIViewController {
 
    // variables
    @IBOutlet weak var emailId: UITextField!
    @IBOutlet weak var password: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    /**
     Registered new users details are saved in Core Data
     Arguments -> UserName : String, password : String
    **/
    func insertNewRecord(userName: String, password: String) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Users", in: context)
        let newUser = NSManagedObject(entity: entity!, insertInto: context)
        newUser.setValue(userName, forKey: "username")
        newUser.setValue(password, forKey: "password")
        do {
            try context.save()
        } catch {
            print("Failed saving")
        }
    }
    
    /**
     Validate the user entered Email Id is valid email id format.
     Argument -> mailId : String
     return Bool
     **/
    func isValidId(mailId : String) -> Bool{
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: mailId)
    }
    
    /**
     Validate the user entered Email Id is a new record.
     Argument -> username : String
     return Bool
     **/
    func doesExist(username: String) -> Bool {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Users")
        request.predicate = NSPredicate(format: "username = %@", username)
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request)
            if result.count == 0 {
                return true
            } else {
                return false
            }
        } catch {
            print("Failed")
        }
        return false
    }
    
    /**
     Validate the user entered details before registration.
     Argument type -> Any
     **/
    @IBAction func register(_ sender: Any) {
        if let id = emailId.text {
            
            guard let emailLength = emailId.text?.count else {
                return
            }
        
            guard let passwordLength = password.text?.count else {
                return
            }
        
            if(emailLength > 0 && passwordLength > 0){
                if (passwordLength > 5 && passwordLength < 13) {
                    let isValidId = self.isValidId(mailId: id)
                    let isValid = self.doesExist(username: id)
                    
                    guard let password = password.text else {
                        return
                    }
                
                    if isValidId {
                        if isValid {
                            self.insertNewRecord(userName: id, password: password)
                            self.dismiss(animated: true, completion: nil)
                        } else {
                            showAlert(message: "Email Id already exists")
                        }
                    } else {
                        showAlert(message: "Incorrect Email ID")
                    }
                } else {
                    showAlert(message: "Password length should be 6 - 12")
                }
            }
            else {
                showAlert(message: "Please provide EmailId and Password")
            }
        }
    }
    
    /**
     Action after back button in ViewController is tapped
     Argument type -> Any
     **/
    @IBAction func clickedBack(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    /**
     function showAlert is to display Alert pop-up with passed message in argument.
     Argument : message : String
     **/
    func showAlert(message : String){
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

extension UITextFieldDelegate {
    
}
