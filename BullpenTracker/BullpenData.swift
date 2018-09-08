//
//  BullpenSession.swift
//  BullpenTracker
//
//  Created by Sam Hollenbach on 9/7/18.
//  Copyright © 2018 Sam Hollenbach. All rights reserved.
//

import Foundation

class Bullpen {
    
    var pitcherToken : String?
    var pitchList : [Pitch]?
    
}

class AtBat {
    var bullpenID : Int? //Maybe token
    var pitcherToken : String?
}

class Pitch {
    var pitchType : String?
    var ballStrike : String?
    var vel : Float?
    var pitchLocation : PitchLocation?
    var atBat : AtBat?
    
}

class PitchLocation {
    var x : Float?
    var y : Float?
    var catcherView : Bool = true
}
