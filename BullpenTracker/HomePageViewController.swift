//
//  HomePageViewController.swift
//  BullpenTracker
//
//  Created by Sam Hollenbach on 2/14/18.
//  Copyright © 2018 Sam Hollenbach. All rights reserved.
//

import Foundation
import UIKit

class HomePageViewController: UIViewController{
    
    
    @IBOutlet weak var myTeamsButton: UIButton!
    @IBOutlet weak var indivStatsButton: UIButton!
    @IBOutlet weak var loginStatusLabel: UILabel!
    @IBOutlet weak var logoutButton: UIButton!
    
    var loggedEmail = UserDefaults.standard.string(forKey: BTHelper.defaultsKeys.storedLoginPitcherEmail)
    
    override func viewDidLoad() {
        
        myTeamsButton.titleLabel?.adjustsFontSizeToFitWidth = true
        myTeamsButton.titleLabel?.textAlignment = .center
        myTeamsButton.layer.cornerRadius = myTeamsButton.frame.width/5
        
        indivStatsButton.titleLabel?.adjustsFontSizeToFitWidth = true
        indivStatsButton.titleLabel?.textAlignment = .center
        //indivStatsButton.titleLabel?.numberOfLines = 2
        indivStatsButton.layer.cornerRadius = indivStatsButton.frame.width/5
        
        
        updateLoggedStatus()
        
    }
    
    func updateLoggedStatus(){
        loggedEmail = UserDefaults.standard.string(forKey: BTHelper.defaultsKeys.storedLoginPitcherEmail)
        if loggedEmail == "" || loggedEmail == nil{
            loginStatusLabel.text = "Not Logged In"
            logoutButton.isHidden = true
        }else{
            loginStatusLabel.text = "Logged in as \(loggedEmail!)"
            logoutButton.isHidden = false
        }
    }
    
    @IBAction func unwindToHomePage(segue:UIStoryboardSegue) {
        updateLoggedStatus()
    }
    
    
    @IBAction func clickMyTeams(_ sender: Any) {
        sendToMyTeams()
    }
    
    
    
    @IBAction func logoutPressed(_ sender: Any) {
        //TODO: change to choose to log out message
        
        if loggedEmail == ""{
            let storyboard = UIStoryboard(name: "TeamSelect", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "loginVC") as! LoginViewController
            present(vc, animated: true, completion: nil)
        }else{
            BTHelper.LogOut()
            loginStatusLabel.text = "Not Logged In"
            logoutButton.isHidden = true
        }
        
        
    }
    
    
    func sendToMyTeams() {
        let storyboard = UIStoryboard(name: "TeamSelect", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "myTeams") as! TeamSelectViewController
        present(vc, animated: true, completion: nil)
        
    }
    
    @IBAction func clickIndividualStats(_ sender: Any) {

        let loggedPitcher = BTHelper.getLoggedInPitcher()
        
        print(loggedPitcher)
       
        if loggedPitcher == nil{
            let storyboard = UIStoryboard(name: "TeamSelect", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "loginVC") as! LoginViewController
            present(vc, animated: true, completion: nil)
        }else{
            //BTHelper.CurrentPitcherID = pid
            let storyboard = UIStoryboard(name: "Bullpens", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "BullpensVC") as! BullpenViewController
            vc.individualMode = true
            present(vc, animated: true, completion: nil)
        }
        
        
    }
    
}
