//
//  BTHelper.swift
//  BullpenTracker
//
//  Created by Sam Hollenbach on 2/15/18.
//  Copyright © 2018 Sam Hollenbach. All rights reserved.
//

import Foundation
import UIKit

class BTHelper{
    
    struct defaultsKeys {
        static let savedTeamIDs = "savedTeams"
        static let storedPitcher = "storedPitcher"
    }
    
    
    static var offlineMode = false
    
    static var CurrentTeam : Int = -1
    
    static var LoggedPitcher : Pitcher?
    
    static let PitchResults = ["N/A":"None", "SM":"Swing and miss", "ST": "Strike taken", "SS": "Swinging strikeout", "LS": "Looking strikeout"]
    
    static let PitchTypeColors = ["F": UIColor.black, "S": UIColor.orange, "B": UIColor.blue, "X": UIColor.green, "2": UIColor.purple, "C": UIColor.magenta]
    
    static var TeamColorPrimary : UIColor = UIColor(red:0.23, green:0.32, blue:0.56, alpha:1.0)
    static var TeamColorSecondary : UIColor  = UIColor.white
    
    
    static func setTeamColors(primary : UIColor, secondary : UIColor){
        self.TeamColorPrimary = primary
        self.TeamColorSecondary = secondary
    }
    
    static func login(loginData: String, sender: UIViewController){
        ServerConnector.serverRequest(URI: "Login.php", parameters: loginData, finished: {
            data, response, error in
            
            if response == nil{
                DispatchQueue.main.async {
                    BTHelper.showErrorPopup(source: sender, errorTitle: "Server Error", error: "Error connecting to server")
                }
                return
            }
            
            let loggedPitcherDict = ServerConnector.extractJSONtoDict(data!)
            
            
            if loggedPitcherDict.isEmpty{
                DispatchQueue.main.async {
                    BTHelper.showErrorPopup(source: sender, errorTitle: "Login Error", error: "Invalid email or password")
                }
                return
            }
            let pid = Int((loggedPitcherDict["id"] as! NSString).floatValue)
            
            let pnum = Int((loggedPitcherDict["number"] as! NSString).floatValue)
            
            let loggedPitcher = Pitcher(id: pid, pitcherToken: "poop", email:loggedPitcherDict["email"] as? String, firstname: loggedPitcherDict["firstname"] as? String, lastname: loggedPitcherDict["lastname"] as? String ,number: pnum, throwSide: loggedPitcherDict["throws"] as? String)
            
            BTHelper.LogPitcher(pitcher: loggedPitcher)
            DispatchQueue.main.async {
                let storyboard = UIStoryboard(name: "Bullpens", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "BullpensVC") as! BullpenViewController
                vc.individualMode = true
                sender.present(vc, animated: true, completion: nil)
            }
            
        })
    }
    
    
    static func LogPitcher(pitcher: Pitcher){
        
        if let encoded = try? JSONEncoder().encode(pitcher) {
            UserDefaults.standard.set(encoded, forKey: defaultsKeys.storedPitcher)
        }
    }
    
    static func getLoggedInPitcher() -> Pitcher?{
        if let encodedPitcher = UserDefaults.standard.data(forKey: defaultsKeys.storedPitcher),
            let pitcher = try? JSONDecoder().decode(Pitcher.self, from: encodedPitcher) {
            return pitcher
        }
        return nil
    }
    
    static func LogOut(){
        let defaults = UserDefaults.standard
        defaults.set(nil, forKey: defaultsKeys.storedPitcher)
    }
    
    static func ResetTeam(){
        self.CurrentTeam = -1
    }
    
    
    static func showErrorPopup(source: UIViewController, errorTitle: String, error: String = ""){
        DispatchQueue.main.async {
            var errorMessage = "Error"
            if error != ""{
                errorMessage = error
            }
            
            let codeErrorPop = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle: .alert)
            let okayAction = UIAlertAction(title: "Okay", style: .default, handler: {
                (action : UIAlertAction!) -> Void in
                
            })
            codeErrorPop.addAction(okayAction)
            source.present(codeErrorPop, animated: true, completion: nil)
        }
    }
    
    
}

