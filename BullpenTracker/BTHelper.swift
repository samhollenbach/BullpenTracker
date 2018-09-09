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
        static let storedLoginPitcherID = "storedLogin"
        static let storedLoginPitcherEmail = "storedEmail"
        static let storedPitcher = "storedPitcher"
    }
    
    
    static var offlineMode = false
    
    static var LoggedInPitcherEmail : String = ""
    static var LoggedInPitcher : Int = -1
    static var CurrentTeam : Int = -1
    static var CurrentPitcherID : Int = -1
    static var CurrentBullpen : Int = -1
    
    static var LoggedPitcher : Pitcher?
    
    static let PitchResults = ["N/A":"None", "SM":"Swing and miss", "ST": "Strike taken", "SS": "Swinging strikeout", "LS": "Looking strikeout"]
    
    static let PitchTypeColors = ["F": UIColor.black, "S": UIColor.orange, "B": UIColor.blue, "X": UIColor.green, "2": UIColor.purple, "C": UIColor.magenta]
    
    static var TeamColorPrimary : UIColor = UIColor(red:0.23, green:0.32, blue:0.56, alpha:1.0)
    static var TeamColorSecondary : UIColor  = UIColor.white
    
    
    static func setTeamColors(primary : UIColor, secondary : UIColor){
        self.TeamColorPrimary = primary
        self.TeamColorSecondary = secondary
    }
    
    static func StoreLogin(pitcherID: Int, pitcherEmail: String){
        let defaults = UserDefaults.standard
        defaults.setValue(pitcherID, forKey: defaultsKeys.storedLoginPitcherID)
        defaults.setValue(pitcherEmail, forKey: defaultsKeys.storedLoginPitcherEmail)
        self.LoggedInPitcher = pitcherID
        self.LoggedInPitcherEmail = pitcherEmail
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
    static func ResetPitcher(){
        self.CurrentPitcherID = -1
    }
    static func ResetBullpen(){
        self.CurrentBullpen = -1
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

