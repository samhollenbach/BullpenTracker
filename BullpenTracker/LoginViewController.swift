//
//  LoginViewController.swift
//  BullpenTracker
//
//  Created by Sam Hollenbach on 2/22/18.
//  Copyright © 2018 Sam Hollenbach. All rights reserved.
//

import Foundation
import UIKit

class LoginViewController : UIViewController{
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passField: UITextField!
    @IBOutlet weak var offlineButton: UIButton!
    
    var newLoginPID = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        offlineButton.titleLabel?.numberOfLines = 2
        offlineButton.titleLabel?.adjustsFontSizeToFitWidth = true
        offlineButton.titleLabel?.textAlignment = .center
        offlineButton.layer.cornerRadius = offlineButton.bounds.width / 4
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.dismissKeyboard))
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        //tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
    }
    
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    
    @IBAction func cancelPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func loginPressed(_ sender: Any) {
        let email = emailField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let pass = passField.text!
        if pass == ""{
            BTHelper.showErrorPopup(source: self, errorTitle: "Password Error", error: "Please enter a password")
            return
        }
        let data = "email=\(email)&password=\(pass)"
        BTHelper.login(loginData: data, sender: self)
    }
    

    @IBAction func offlineMode(_ sender: Any) {
        
        BTHelper.offlineMode = true
        
        let storyboard = UIStoryboard(name: "AddPitches", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "AddPitches") as! AddPitches
        self.present(vc, animated: true, completion: nil)
        
        
    }
    
}
