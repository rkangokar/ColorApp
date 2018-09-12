//
//  LoginVC.swift
//  ColorApp
//
//  Created by Vineeth Menon on 6/28/18.
//  Copyright © 2018 Reshma. All rights reserved.
//

import Foundation
import UIKit
import LocalAuthentication
import CoreData

// Struct are used to define the JSON response stucture to fetch the Quote
struct Quotes : Codable {
    let quote : String
    let length : String
    let author : String
    let tags : [String]
    let category : String
    let date : String
    let permalink : String
    let title : String
    let background : String
    let id : String
}
struct Success : Codable {
    let total : Int
}
struct Contents: Codable {
    let quotes : [Quotes]
    let copyright: String
}

struct QoutesApi : Codable {
    let success: Success
    let contents: Contents
}

// Class registered with Login View Controller.
class LoginVC: UIViewController {
    
    // variables
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var quoteLabel: UILabel!
    var quoteMessage : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.callQuotesApi()
        NotificationCenter.default.addObserver(self, selector: #selector(LoginVC.viewDidLoad), name: Notification.Name("Quote"), object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        quoteLabel.text = self.quoteMessage
        NotificationCenter.default.removeObserver(self)
    }
    
    /** User defined func to fetch the saved records from Core Data using the passed argument and retrive password.
     Arguments : Username : String
     return String
     **/

    func fetchSavedRecords(username: String) -> String {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Users")
        request.predicate = NSPredicate(format: "username = %@", username)
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request)
            if result.count == 0 {
                let alertController = UIAlertController(title: nil, message: "Username doesn't exist, Please register and then login", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                present(alertController, animated: true, completion: nil)
            } else {
                for data in result as! [NSManagedObject] {
                    let password = data.value(forKey: "password") as! String
                    print(data.value(forKey: "password") as! String)
                    return password
                }
            }
        } catch {
            print("Failed")
        }
        return ""
    }
    
    // Present next ViewController when login button is tapped.
    func checkLoginButton(){
        let nextViewController = storyboard?.instantiateViewController(withIdentifier: "MainNavigationController") as! MainNavigationController
        present(nextViewController, animated: true, completion: nil)
    }
    
    /**
     Validates the login for its existance in Core Data and password.
     Arugment type : AnyObject
     **/
    @IBAction func ClickedLogin(_ sender: AnyObject) {
        guard let usernameCount = username.text?.count else {
            return
        }
        
        guard let passwordCount = password.text?.count else {
            return
        }
        
        if(usernameCount > 0 && passwordCount > 0){
            guard let userNme = username.text else {
                return
            }
            
            let savedPasswrd = self.fetchSavedRecords(username: userNme)
            if savedPasswrd == password.text {
                checkLoginButton()
            } else {
                showAlert(message: "Incorrect Password", true)
            }
        } else {
            showAlert(message: "Enter UserName and Password", true)
        }
    }
    
    /**
     Func associated with button 'Register' in login screen,  to present Register ViewController
     Argument type : Any
    **/
    @IBAction func clickedRegister(_ sender: Any) {
        let nextViewController = storyboard?.instantiateViewController(withIdentifier: "RegisterVC") as! RegisterVC
        present(nextViewController, animated: true, completion: nil)
    }
    
    /**
    Validate Touch ID for login
     **/
    @IBAction func touchAuthentication(_ sender: Any) {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Authenticate with Touch ID"
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason, reply: {[weak self] (succes, error) in
                if succes {
                    self?.checkLoginButton()
                } else {
                    self?.showAlert(message: "Touch ID Authentication Failed", true)
                }
            })
        }  else {
            showAlert(message: "Touch ID not available", true)
        }
    }
    
    func getMessage(text: String){
        self.quoteMessage = "Quote for the Day : \(text)"
        NotificationCenter.default.post(name: Notification.Name("Quote"), object: nil)
    }
    
    /**
     Function to request API and retrieve response
    **/
    func callQuotesApi(){
        let qoutes = "https://quotes.rest/qod?category=inspire"
        let session = URLSession.shared
        let requestUrl = URL(string: qoutes)
        let task = session.dataTask(with: requestUrl!) { (data, response, error) in
            if let error = error {
                print("Error : \(error)")
            } else {
                if let unwrappedData = data {
                    self.read(data: unwrappedData)
                }
            }
        }
        task.resume()
    }
    
    /**
     API response is decoded and parsing the JSON to extract quote
     **/
    func read(data: Data){
        var message = ""
        let decoder = JSONDecoder()
        do {
            let readData = try decoder.decode(QoutesApi.self, from: data)
            message = readData.contents.quotes[0].quote
            self.getMessage(text: message)
        } catch (let error) {
            print(error)
        }
    }
    
    /**
     function showAlert is to display Alert pop-up with passed message in argument.
     Argument : message : String
     **/
    func showAlert(message : String, _ animated : Bool){
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: animated, completion: nil)
    }
}
