//
//  AddTeamPlayerViewController.swift
//  BullpenTracker
//
//  Created by Sam Hollenbach on 2/19/18.
//  Copyright © 2018 Sam Hollenbach. All rights reserved.
//

import Foundation
import UIKit

class AddTeamPlayerViewController : UIViewController{
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var numberField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func sendPressed(_ sender: Any) {
        let email = emailField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if !email.contains("@") || !email.contains(".") {
            BTHelper.showErrorPopup(source: self, errorTitle: "Error", error: "Not a valid email address")
            return
        }
        let data = "pitcher_email=\(email)&team_id=\(BTHelper.CurrentTeam)&number=\(numberField.text!)"
        
        ServerConnector.runScript(scriptName: "AddTeamPlayer.php", data: data){ response in
            print(response!)
        }
        dismissVC(self)
        
    }
    
    @IBAction func dismissVC(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
