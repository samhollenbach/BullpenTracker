//
//  BullpenSession.swift
//  BullpenTracker
//
//  Created by Sam Hollenbach on 9/7/18.
//  Copyright © 2018 Sam Hollenbach. All rights reserved.
//

import Foundation

class Pitcher{
    
    var pitcherToken : String?
    var name : String?
    var number : Int?
    var throwSide : String?
    
    //constructor make pls
}

class Bullpen {
    
    var pitcher : Pitcher?
    var id : Int?
    var penType : String?
    var compPen : Bool? = false
    var pitchList : [Pitch]?
    
    func Bullpen(pitcher : Pitcher?, id : Int?, penType : String?, pitchList : [Pitch]?){
        self.pitcher = pitcher
        self.id = id
        self.penType = penType
        if penType == "COMP" || penType == "GAME"{
            self.compPen = true
        }
        self.pitchList = pitchList
    }
    
}

class AtBat {
    var bullpenID : Int? //Maybe token
    var pitcherToken : String?
    var batterSide : String?
}

class Pitch {
    var pitchType : String?
    var ballStrike : String?
    var vel : Float?
    var pitchLocation : PitchLocation?
    var atBat : AtBat?
    var uploadedToServer : Bool = false
    
}

class PitchLocation {
    var x : Float?
    var y : Float?
    var catcherView : Bool = true
}
