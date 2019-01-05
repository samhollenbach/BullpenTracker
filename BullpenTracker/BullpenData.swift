//
//  BullpenSession.swift
//  BullpenTracker
//
//  Created by Sam Hollenbach on 9/7/18.
//  Copyright © 2018 Sam Hollenbach. All rights reserved.
//

import Foundation
import UIKit

struct Pitcher : Codable{
    
    var p_token : String?
    var email : String?
    var firstname : String?
    var lastname : String?
    var number : Int?
    var throwSide : String?
    
    func fullName() -> String?{
        if firstname != nil && lastname != nil{
            return "\(firstname!) \(lastname!)"
        }else{
            return nil
        }
    }
    
    init?(dict: [String : Any]) {
        self.p_token = dict["p_token"] as? String
        self.email = dict["email"] as? String
        self.firstname = dict["firstname"] as? String
        self.lastname = dict["lastname"] as? String
//        self.number = Int(dict["number"]!)
        self.throwSide = dict["throwSide"] as? String
    }
    
    //constructor make pls
}

struct Bullpen {
    
    var pitcher : Pitcher?
    var b_token : String?
    var penType : String?
    var compPen : Bool? = false
    var pitchList : [Pitch]?
    var date : String? = ""
    var penTypeDisplay : String? = ""
    var tableViewDisplay : String? = ""
    
//    func Bullpen(pitcher : Pitcher?, id : Int?, penType : String?, pitchList : [Pitch]?){
//        self.pitcher = pitcher
//        self.id = id
//        self.penType = penType
//        if penType == "COMP" || penType == "GAME"{
//            self.compPen = true
//        }
//        self.pitchList = pitchList
//    }
    
}

struct AtBat {
    var bullpenID : Int? //Maybe token
    var pitcherToken : String?
    var batterSide : String?
    var batterNumber : String? // maybe int?
    
}

struct Pitch {
    var pitchType : String?
    var ballStrike : String?
    var vel : Float?
    var pitchLocation : PitchLocation?
    var pitchResult : String?
    var hardContact : Int? // maybe change from int?
    var atBat : AtBat?
    var uploadedToServer : Bool = false
    
}

struct PitchLocation {
    var x : CGFloat?
    var y : CGFloat?
    var catcherView : Bool = true
}

struct Team {
    var t_id : Int?
    var team_name : String?
    var team_info : String?
    var team_access_code : String?
    var tp_token_priv : String?
    var tp_token_pub : String?
    
    init?(dict: [String : Any]) {
        
        guard let team_name = dict["team_name"] as? String else {
            return nil
        }
        
        self.t_id = dict["t_id"] as? Int
        self.team_name = team_name
        self.team_info = dict["team_info"] as? String
//        self.team_access_code = dict["team_access_code"]
        self.tp_token_priv = dict["tp_token_private"] as? String
        self.tp_token_pub = dict["tp_token_public"] as? String
    }
}


