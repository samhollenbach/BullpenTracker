//
//  AddPitcherViewController.swift
//  BullpenTracker
//
//  Created by Sam Hollenbach on 6/19/17.
//  Copyright © 2017 Sam Hollenbach. All rights reserved.
//

import UIKit

class AddPitcherViewController: UIViewController {

    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var firstNameField: UITextField!
    
    @IBOutlet weak var lastNameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 11.0, *) {
            //self.additionalSafeAreaInsets.top = 20
        }
        
        navBar.sizeToFit()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(AddPitcherViewController.dismissKeyboard))
        
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        //tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)

    }
    
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func dismissVC(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func submitNewPitcher(_ sender: UIButton) {
        
        let firstName = firstNameField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let lastName = lastNameField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let email = emailField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let throw_arm = "R"
        
        
        let data = "firstname=\(firstName)&lastname=\(lastName)&email=\(email)&throws=\(throw_arm)"
        
        ServerConnector.runScript(scriptName: "AddPitcher.php", data: data)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "PitchersVC") as UIViewController
        present(vc, animated: true, completion: nil)
        
    }
    

}
