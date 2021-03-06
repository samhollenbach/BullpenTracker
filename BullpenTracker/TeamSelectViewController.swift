//
//  TeamSelectViewController.swift
//  BullpenTracker
//
//  Created by Sam Hollenbach on 2/14/18.
//  Copyright © 2018 Sam Hollenbach. All rights reserved.
//

import Foundation
//import Braintree
//import BraintreeDropIn
import UIKit

class TeamSelectViewController: UITableViewController{
    
    @IBOutlet weak var navBar: CINavigationBar!
    
    //NOTICE: CURRENTLY USING SANDBOX TOKENIZATION KEY, BEFORE WE ROLL OUT NEED TO FILL OUT APPLICATION AND OBTAIN REGULAR TOKENIZATION KEY, THIS WILL WORK FOR ANY TESTING HOWEVER..
    let tokenizationKey = "sandbox_bdft4v5x_qnq4b22h37g3t8sq"
    
    var TeamData: [Team] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navBar.sizeToFit()
        // TODO: Setvartle of VC to pitcher name
        //self.parent?.title = currentPitcherName
        //self.tableView.rowHeight = 110.0
        load_teams()
    }
    
    func load_teams(){
        
        ServerConnector.serverRequest(path: "/pitcher/teams", query_string: "", httpMethod: "GET", finished: { data, response, error in
            if response == nil || error != nil{
                self.showErrorPopup(errorTitle: "Team Access Error", error:"Error connecting to server")
                print("Could not find teams")
                return
            }
            
            let teams = ServerConnector.extractJSONtoList(data!)
            print(teams)
            for t in teams{
            
                let team = Team(dict: t)
                if team != nil{
                    self.TeamData.append(team!)
                }
                
            }
            
            DispatchQueue.main.async{
                self.tableView.reloadData()
            }
            
        })
    }
    
    
    func addTeamToList(team : Team){
//        let tid = team.teamID as? String
//        if tid == nil{
//            showErrorPopup(errorTitle: "Team Access Error", error:"Internal error (found null team ID)")
//            print("Team ID null")
//            return
//        }
//
//        for t_dat in TeamData{
//            if t_dat["id"] as? String == tid{
//                showErrorPopup(errorTitle: "Team Access Error", error:"That team is already in your list")
//                print("Team \(tid!) is already in list")
//                return
//            }
//        }
        TeamData.append(team)
        
        DispatchQueue.main.async{
            self.tableView.reloadData()
        }
        
        let defaults = UserDefaults.standard
        defaults.set(TeamData, forKey: BTHelper.defaultsKeys.savedTeamIDs)
    }
    
    func processTeamCode(name: String, code: String, teamNumber: Int){
        let qs = "team_name=\(name)&team_access_code=\(code)&team_number=\(teamNumber)"
        
        ServerConnector.serverRequest(path: "/team/join", query_string: qs, finished: { data, response, error in
            if response == nil || error != nil{
                self.showErrorPopup(errorTitle: "Team Access Error", error:"Error connecting to server")
                print("Could not find team")
                return
            }
            
            let teams = ServerConnector.extractJSONtoList(data!)
            //self.TeamData = []
            if teams.count > 1{
                self.showErrorPopup(errorTitle: "Team Access Error", error:"Internal error (more than one team with access code)")
                print("Found more than one team with same access code!")
                return
            }
            if teams.count == 0{
                self.showErrorPopup(errorTitle: "Team Access Error", error:"No team found with this code")
                return
            }

            self.load_teams()
            
        })
    }
    
    func showErrorPopup(errorTitle: String, error: String = ""){
        var errorMessage = "Could not find a team with entered access code"
        if error != ""{
            errorMessage = error
        }
        
         let codeErrorPop = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle: .alert)
        let okayAction = UIAlertAction(title: "Okay", style: .default, handler: {
            (action : UIAlertAction!) -> Void in
            
        })
        codeErrorPop.addAction(okayAction)
        self.present(codeErrorPop, animated: true, completion: nil)
    }
    
    func createNewTeam(teamName: String, teamInfo: String, teamAccess: String){
        let data = "team_name=\(teamName)&team_info=\(teamInfo)&team_access_code=\(teamAccess)"
        ServerConnector.serverRequest(path: "/team/create", query_string: data, finished: { data, response, error in
            if error != nil{
                self.showErrorPopup(errorTitle: "Error Creating Team", error: "Could not connect to server")
            }
            
            let finishCreationPopup = UIAlertController(title: "Finish Team Creation", message: "Enter your player number to add yourself to this team. If you do not want to add yourself right now you can join the team manually later.", preferredStyle: .alert)
            
            let saveAction = UIAlertAction(title: "Finish", style: .default, handler: {
                alert -> Void in
                
                let myNumberField = finishCreationPopup.textFields![0] as UITextField
                myNumberField.keyboardType = .numberPad
                
                
                if let num = Int(myNumberField.text!){
                    self.processTeamCode(name: teamName, code: teamAccess, teamNumber: num )
                }else{
                    self.showErrorPopup(errorTitle: "Team Create Error", error: "Invalid player number")
                }
            })

            finishCreationPopup.addTextField { (teamAccessField : UITextField!) -> Void in
                teamAccessField.placeholder = "Access Code"
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: {
                (action : UIAlertAction!) -> Void in
            })
            
            finishCreationPopup.addAction(saveAction)
            finishCreationPopup.addAction(cancelAction)
            
            self.present(finishCreationPopup, animated: true, completion: nil)
           
        })
    }
    
    func tapCreateTeam(){
        let createTeamPopup = UIAlertController(title: "Create Team", message: "Enter the name of your team and team info below (in the future this will be a premium feature)", preferredStyle: .alert)
        
        
        let saveAction = UIAlertAction(title: "Create", style: .default, handler: {
            alert -> Void in
            
            let teamNameField = createTeamPopup.textFields![0] as UITextField
            let teamInfoField = createTeamPopup.textFields![1] as UITextField
            let teamAccessField = createTeamPopup.textFields![2] as UITextField
            
            
            print("teamName  \(teamNameField.text!)")
            if teamNameField.text != "" && teamAccessField.text != ""{
                self.createNewTeam(teamName: teamNameField.text!, teamInfo: teamInfoField.text!, teamAccess: teamAccessField.text!)
                //self.pay()
                
            }else{
                self.showErrorPopup(errorTitle: "Team Create Error", error: "Please enter a valid team name")
            }
        })
        
       
        createTeamPopup.addTextField { (teamNameField : UITextField!) -> Void in
            teamNameField.placeholder = "Team Name"
        }
        createTeamPopup.addTextField { (teamInfoField : UITextField!) -> Void in
            teamInfoField.placeholder = "Team Info"
        }
        createTeamPopup.addTextField { (teamAccessField : UITextField!) -> Void in
            teamAccessField.placeholder = "Access Code"
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: {
            (action : UIAlertAction!) -> Void in
            
        })
        
        createTeamPopup.addAction(saveAction)
        createTeamPopup.addAction(cancelAction)
        
        self.present(createTeamPopup, animated: true, completion: nil)
    }
    
    @IBAction func addTeam(_ sender: Any) {
        let addTeamPopup = UIAlertController(title: "Join Team", message: "Enter the access code for a team to add it to your saved list", preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Enter", style: .default, handler: {
            alert -> Void in
            
            let nameField = addTeamPopup.textFields![0] as UITextField
            let codeField = addTeamPopup.textFields![1] as UITextField
            let myNumberField = addTeamPopup.textFields![2] as UITextField
            
            
            if codeField.text != "" && nameField.text != "", let num = Int(myNumberField.text!) {
                self.processTeamCode(name: nameField.text!, code: codeField.text!, teamNumber: num)
            }else{
                self.showErrorPopup(errorTitle: "Team Access Error")
            }
        })
        
        let createTeam = UIAlertAction(title: "Create New", style: .default, handler: {
            (action : UIAlertAction!) -> Void in
            self.tapCreateTeam()
            
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: {
            (action : UIAlertAction!) -> Void in
        })
        
        addTeamPopup.addTextField { (nameField : UITextField!) -> Void in
            nameField.placeholder = "Enter Team Name"
        }
        addTeamPopup.addTextField { (codeField : UITextField!) -> Void in
            codeField.placeholder = "Enter Team Code"
        }
        addTeamPopup.addTextField { (codeField : UITextField!) -> Void in
            codeField.placeholder = "My number on this team"
        }
        
        addTeamPopup.addAction(saveAction)
        addTeamPopup.addAction(createTeam)
        addTeamPopup.addAction(cancelAction)
        
        
        self.present(addTeamPopup, animated: true, completion: nil)
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return TeamData.isEmpty ? 1 : TeamData.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //just leave this because it works
        let cellIdentifier = "Cell"
        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: cellIdentifier)
        }
        cell?.textLabel?.font = UIFont(name: "Helvetica Neue", size: 24)
        cell?.textLabel?.textColor = UIColor(red:0.06, green:0.11, blue:0.26, alpha:1.0)
        cell?.textLabel?.adjustsFontSizeToFitWidth = true
        
        print(TeamData)
        print("LAEFNOEIGIJOWEG")
        if !TeamData.isEmpty {
            let tdata = TeamData[indexPath.row]
            cell?.textLabel?.text = tdata.team_name
            cell?.detailTextLabel?.text = tdata.team_info
            
        }else{
            cell?.textLabel?.text = "You have no saved teams"
            cell?.detailTextLabel?.text = "Click the + to add a team"
        }
        
        return cell!
    }
    
    
    @IBAction func dismissVC(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    func sendToPitchersVC(team : Team){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "PitchersVC") as! PitcherViewController
        BTHelper.CurrentTeam = team
        present(vc, animated: true, completion: nil)
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if TeamData.count == 0{
            print("Not a valid team")
            return
        }
        let team = TeamData[indexPath.row]
        tableView.deselectRow(at: indexPath, animated: false)
        
        //TODO: Replace with t_token_priv
        sendToPitchersVC(team: team)
        
    }
    //MARK: -  I AM PUTTING THE CODE FOR BRAINTREE STUFF BELOW. THERE IS ALSO A VARIABLE DECLARED AT THE TOP
    
//    func sendRequestPaymentToServer(nonce: String, amount: String) {
//        let paymentURL = URL(string: "http://localhost/braintree/pay.php")!
//        var request = URLRequest(url: paymentURL)
//        request.httpBody = "payment_method_nonce=\(nonce)&amount=\(amount)".data(using: String.Encoding.utf8)
//        request.httpMethod = "POST"
//
//        URLSession.shared.dataTask(with: request) { [weak self] (data, response, error) -> Void in
//            guard let data = data else {
//                print(error!.localizedDescription)
//                return
//            }
//
//            guard let result = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any], let success = result?["success"] as? Bool, success == true else {
//                print("Transaction failed. Please try again.")
//                return
//            }
//
//            print("Successfully charged. Thanks So Much :)")
//            }.resume()
//    }
//
//    func pay() {
//        let request =  BTDropInRequest()
//        let dropIn = BTDropInController(authorization: tokenizationKey, request: request)
//        { [unowned self] (controller, result, error) in
//
//            if let error = error {
//                print(error.localizedDescription)
//
//            } else if (result?.isCancelled == true) {
//                print("Transaction Cancelled")
//
//            } else if let nonce = result?.paymentMethod?.nonce, let amount = Optional(10) { // **need to fix these lines to do what we want - self.amountTextField.text {
//                self.sendRequestPaymentToServer(nonce: nonce, amount: String(amount))
//            }
//            controller.dismiss(animated: true, completion: nil)
//        }
//        self.present(dropIn!, animated: true, completion: nil)
//    }
    
}
