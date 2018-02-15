//
//  PitchPopoverViewController.swift
//  BullpenTracker
//
//  Created by Sam Hollenbach on 2/3/18.
//  Copyright © 2018 Sam Hollenbach. All rights reserved.
//

import Foundation
import UIKit

class PitchPopoverViewController: UIViewController {

    var pitchType = ""
    var ballStrike = ""
    var vel = ""
    var pitchResult = ""
    var hardContact = ""
    
    @IBOutlet weak var ptLabel: UILabel!
    @IBOutlet weak var bsLabel: UILabel!
    @IBOutlet weak var vLabel: UILabel!
    @IBOutlet weak var hcLabel: UILabel!
    @IBOutlet weak var prLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ptLabel.text = "Pitch Type: \(pitchType)"
        bsLabel.text = "Ball/Strike: \(ballStrike)"
        vLabel.text = "Velocity: \(vel)"
        hcLabel.text = "Hard Contact: \(hardContact)"
        prLabel.text = "Pitch Result: \(pitchResult)"
    }

}
