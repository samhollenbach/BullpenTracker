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
    }
    
    
    static var offlineMode = false
    
    static var LoggedInPitcher : Int = -1
    static var CurrentTeam : Int = -1
    static var CurrentPitcher : Int = -1
    static var CurrentBullpen : Int = -1
    
    static let PitchResults = ["N/A":"None", "SM":"Swing and miss", "ST": "Strike taken", "SS": "Swinging strikeout", "LS": "Looking strikeout"]
    
    static let PitchTypeColors = ["F": UIColor.black, "S": UIColor.orange, "B": UIColor.blue, "X": UIColor.green, "2": UIColor.purple, "C": UIColor.magenta]
    
    static var TeamColorPrimary : UIColor = UIColor(red:0.23, green:0.32, blue:0.56, alpha:1.0)
    static var TeamColorSecondary : UIColor  = UIColor.white
    
    
    static func setTeamColors(primary : UIColor, secondary : UIColor){
        self.TeamColorPrimary = primary
        self.TeamColorSecondary = secondary
    }
    
    static func StoreLogin(pitcherID: Int){
        let defaults = UserDefaults.standard
        defaults.setValue(pitcherID, forKey: defaultsKeys.storedLoginPitcherID)
        self.LoggedInPitcher = pitcherID
    }
    
    static func LogOut(){
        self.LoggedInPitcher = -1
        let defaults = UserDefaults.standard
        defaults.setValue(-1, forKey: defaultsKeys.storedLoginPitcherID)
    }
    
    static func ResetTeam(){
        self.CurrentTeam = -1
    }
    static func ResetPitcher(){
        self.CurrentPitcher = -1
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

