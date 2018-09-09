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
        login(data: data, email: email)
    }
    
    func login(data: String, email: String = ""){
        ServerConnector.serverRequest(URI: "Login.php", parameters: data, finished: {
            data, response, error in
            
            if response == nil{
                DispatchQueue.main.async {
                    BTHelper.showErrorPopup(source: self, errorTitle: "Server Error", error: "Error connecting to server")
                }
                return
            }
            
            let loggedPitcherDict = ServerConnector.extractJSONtoDict(data!)

            
            if loggedPitcherDict.isEmpty{
                DispatchQueue.main.async {
                    BTHelper.showErrorPopup(source: self, errorTitle: "Login Error", error: "Invalid email or password")
                }
                return
            }
            let pid = Int((loggedPitcherDict["id"] as! NSString).floatValue)
            
            let pnum = Int((loggedPitcherDict["number"] as! NSString).floatValue)
            
            let loggedPitcher = Pitcher(id: pid, pitcherToken: "poop", firstname: loggedPitcherDict["firstname"] as? String, lastname: loggedPitcherDict["lastname"] as? String ,number: pnum, throwSide: loggedPitcherDict["throws"] as? String)
            
            BTHelper.LogPitcher(pitcher: loggedPitcher)
            DispatchQueue.main.async {
                let storyboard = UIStoryboard(name: "Bullpens", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "BullpensVC") as! BullpenViewController
                vc.individualMode = true
                self.present(vc, animated: true, completion: nil)
            }
            
        })
    }

    @IBAction func offlineMode(_ sender: Any) {
        
        BTHelper.offlineMode = true
        
        let storyboard = UIStoryboard(name: "AddPitches", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "AddPitches") as! AddPitches
        self.present(vc, animated: true, completion: nil)
        
        
    }
    
}
