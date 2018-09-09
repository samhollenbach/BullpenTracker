//
//  CreateAccountVC.swift
//  BullpenTracker
//
//  Created by Sam Hollenbach on 2/21/18.
//  Copyright © 2018 Sam Hollenbach. All rights reserved.
//

import Foundation
import UIKit

class CreateAcountViewController : UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource{
    
    
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    
    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var lastNameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passField1: UITextField!
    @IBOutlet weak var passField2: UITextField!
    
    @IBOutlet weak var armPicker: UIPickerView!
    
    let armChoices = ["R", "L"]
    var armSelected: String = "R"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(CreateAcountViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        self.cancelButton.layer.cornerRadius = 10
        self.registerButton.layer.cornerRadius = 10
        
        initializePicker()
    }
    
    func initializePicker(){
        self.armPicker.delegate = self
        self.armPicker.dataSource = self
        self.armPicker.layer.cornerRadius = 5
        armSelected = armChoices[0]
        
    }
    
    @IBAction func cancelPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    @IBAction func registerPressed(_ sender: Any) {
        let firstName = firstNameField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let lastName = lastNameField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let email = emailField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        
        let pass1 = passField1.text!
        let pass2 = passField2.text!
        if pass1 != pass2{
            BTHelper.showErrorPopup(source: self, errorTitle: "Password Error", error: "Passwords do not match")
            return
        }
        if pass1.rangeOfCharacter(from: CharacterSet.illegalCharacters) != nil {
            BTHelper.showErrorPopup(source: self, errorTitle: "Password Error", error: "Illegal character(s) found in password")
            return
        }
        
        
        let data = "firstname=\(firstName)&lastname=\(lastName)&email=\(email)&throws=\(armSelected)&password=\(pass1)"
        
        ServerConnector.runScript(scriptName: "CreateAccount.php", data: data, verbose: true){
            response in
            if response != nil && response == "1"{
                let loginData = "email=\(email)&password=\(pass1)"
                self.login(data: loginData, email: email)
            }else{
                BTHelper.showErrorPopup(source: self, errorTitle: "Registration Error", error: "Could not create account")
                
            }
            
        }
        
        
    }
    
    func login(data: String, email: String = ""){
        ServerConnector.runScript(scriptName: "Login.php", data: data, verbose: true){
            response in
            if response == nil{
                //BTHelper.showErrorPopup(source: self, errorTitle: "Server Error", error: "Error connecting to server")
                return
            }
            if response! == "-1"{
                //BTHelper.showErrorPopup(source: self, errorTitle: "Login Error", error: "Invalid email or password")
                return
            }
            
            if let pid = Int(response!){
                BTHelper.CurrentPitcherID = pid
                BTHelper.StoreLogin(pitcherID: pid, pitcherEmail: email)
                DispatchQueue.main.async {
                    let storyboard = UIStoryboard(name: "Bullpens", bundle: nil)
                    let vc = storyboard.instantiateViewController(withIdentifier: "BullpensVC") as! BullpenViewController
                    self.present(vc, animated: true, completion: nil)
                }
                
            }else{
                //BTHelper.showErrorPopup(source: self, errorTitle: "Login Error", error: "Invalid pitcher ID (internal error)")
            }
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return armChoices.count
    }
    
    // The data to return for the row and component (column) that's being passed in
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return armChoices[row]
    }
    
    // Catpure the picker view selection
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        dismissKeyboard()
        armSelected = armChoices[row]
    }
}
