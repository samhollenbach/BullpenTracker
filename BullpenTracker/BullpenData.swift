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
    
    var id : Int? // LOSE THIS SOON!
    var pitcherToken : String?
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
    
    //constructor make pls
}

struct Bullpen {
    
    var pitcher : Pitcher?
    var id : Int?
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
