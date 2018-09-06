//
//  ChangePasswordViewController.swift
//  BullpenTracker
//
//  Created by Sam Hollenbach on 2/24/18.
//  Copyright © 2018 Sam Hollenbach. All rights reserved.
//

import Foundation
import UIKit

class ChangePasswordViewController: UIViewController{
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var oldPassField: UITextField!
    @IBOutlet weak var newPassField1: UITextField!
    @IBOutlet weak var newPassField2: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func cancelPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func submitPressed(_ sender: Any) {
        let email = emailField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let oldPass = oldPassField.text!
        let newPass1 = newPassField1.text!
        let newPass2 = newPassField2.text!
        
        if newPass1 != newPass2{
            BTHelper.showErrorPopup(source: self, errorTitle: "Password Error", error: "Passwords do not match")
            return
        }
        let data = "email=\(email)&password_old=\(oldPass)&password_new=\(newPass1)"
        ServerConnector.runScript(scriptName: "ChangePassword.php", data: data){
            response in
            if response == nil{
                DispatchQueue.main.async {
                    BTHelper.showErrorPopup(source: self, errorTitle: "Server Error", error: "Could not connect to server (internal error)")
                }
                return
            }
            if response! == "-1"{
                DispatchQueue.main.async {
                    BTHelper.showErrorPopup(source: self, errorTitle: "Error", error: "Could not find account with provided credentials")
                }
                return
            }
            if response! == "1"{
                self.dismiss(animated: true, completion: {
                    sleep(1)
                    // Probably doesnt work because "self" no longer exists
                    DispatchQueue.main.async {
                        BTHelper.showErrorPopup(source: self, errorTitle: "Password Change Successful", error: "Your password has been successfully changed")
                        
                    }
                })
                
                
            }else{
                DispatchQueue.main.async {
                    BTHelper.showErrorPopup(source: self, errorTitle: "Server Error", error: "Could not connect to server (internal error)")
                }
            }
            
        }
        
    }
    
    
    
}
