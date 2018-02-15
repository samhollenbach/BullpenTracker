//
//  TeamSelectViewController.swift
//  BullpenTracker
//
//  Created by Sam Hollenbach on 2/14/18.
//  Copyright © 2018 Sam Hollenbach. All rights reserved.
//

import Foundation
import UIKit

class TeamSelectViewController: UITableViewController{
    
    @IBOutlet weak var navBar: CINavigationBar!
    
    var TeamData: [[String:Any]] = []
    
    struct defaultsKeys {
        static let savedTeamIDs = "savedTeams"
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navBar.sizeToFit()
        // TODO: Setvartle of VC to pitcher name
        //self.parent?.title = currentPitcherName
        //self.tableView.rowHeight = 110.0
        fillTeamData()
    }
    
    func fillTeamData(){
        TeamData = []
        let defaults = UserDefaults.standard
        let teamsArray = defaults.array(forKey: defaultsKeys.savedTeamIDs) as? [[String:Any]] ?? [[String:Any]]()
        for team in teamsArray{
            TeamData.append(team)
        }
        DispatchQueue.main.async{
            self.tableView.reloadData()
        }
        
        
    }
    
    func addTeamToList(teamData : [String: Any]){
        let tid = teamData["id"] as? String
        if tid == nil{
            showCodeErrorPopup(error:"Internal error (found null team ID)")
            print("Team ID null")
            return
        }
        
        for t_dat in TeamData{
            if t_dat["id"] as? String == tid{
                showCodeErrorPopup(error:"That team is already in your list")
                print("Team \(tid!) is already in list")
                return
            }
        }
        TeamData.append(teamData)
        
        DispatchQueue.main.async{
            self.tableView.reloadData()
        }
        
        let defaults = UserDefaults.standard
        defaults.set(TeamData, forKey: defaultsKeys.savedTeamIDs)
    }
    
    func processTeamCode(code: String){
        let data = "access_code=\(code)"
        
        ServerConnector.runScript(scriptName: "GetTeam.php", data: data){ response in
            if response == nil{
                print("Could not find team")
                return
            }
            let teams = ServerConnector.extractJSON(response!.data(using: .utf8)!)
            //self.TeamData = []
            if teams.count > 1{
                self.showCodeErrorPopup(error:"Internal error (more than one team with access code)")
                print("Found more than one team with same access code!")
                return
            }
            if teams.count == 0{
                self.showCodeErrorPopup(error:"No team found with this code")
                return
            }
            
            print(teams)
            for i in 0 ..< teams.count {
                if let team = teams[i] as? NSDictionary {
                    if let teamID = team["id"] as? String, let teamName = team["team_name"] as? String, let teamInfo = team["team_info"] as? String{
                        let single_team_data = ["id": teamID, "name": teamName, "info": teamInfo]
                        self.addTeamToList(teamData: single_team_data)
                    }
                }
            }
        }
    }
    
    func showCodeErrorPopup(error: String = ""){
        var errorMessage = "Could not find a team with entered access code"
        if error != ""{
            errorMessage = error
        }
        
         let codeErrorPop = UIAlertController(title: "Team Access Error", message: errorMessage, preferredStyle: .alert)
        let okayAction = UIAlertAction(title: "Okay", style: .default, handler: {
            (action : UIAlertAction!) -> Void in
            
        })
        codeErrorPop.addAction(okayAction)
        self.present(codeErrorPop, animated: true, completion: nil)
    }
    
    @IBAction func addTeam(_ sender: Any) {
        let addTeamPopup = UIAlertController(title: "Join Team", message: "Enter the access code for a team to add it to your saved list", preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Enter", style: .default, handler: {
            alert -> Void in
            
            let codeField = addTeamPopup.textFields![0] as UITextField
            //let secondTextField = addTeamPopup.textFields![1] as UITextField
            
            print("teamCode \(codeField.text!)")
            if codeField.text != ""{
                self.processTeamCode(code: codeField.text!)
            }else{
                self.showCodeErrorPopup()
            }
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (action : UIAlertAction!) -> Void in
            
        })
        
        addTeamPopup.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Enter Team Code"
        }
        addTeamPopup.addAction(cancelAction)
        addTeamPopup.addAction(saveAction)
        
        
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
        
        if !TeamData.isEmpty {
            let tdata = TeamData[indexPath.row]
            cell?.textLabel?.text = tdata["name"] as? String
            cell?.detailTextLabel?.text = tdata["info"] as? String
            
        }else{
            cell?.textLabel?.text = "You have no saved teams"
            cell?.detailTextLabel?.text = "Click the + to add a team"
        }
        
        return cell!
    }
    
    func sendToPitchersVC(teamID : Int){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "PitchersVC") as! PitcherViewController
        vc.team = teamID
        present(vc, animated: true, completion: nil)
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let tData = TeamData[indexPath.row]
        if TeamData.count == 0{
            print("Not a valid team")
            return
        }
        
        tableView.deselectRow(at: indexPath, animated: false)
        sendToPitchersVC(teamID: Int(tData["id"] as! String)!)
        
    }
    
}
