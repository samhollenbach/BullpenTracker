//
//  HomePageViewController.swift
//  BullpenTracker
//
//  Created by Sam Hollenbach on 2/14/18.
//  Copyright © 2018 Sam Hollenbach. All rights reserved.
//

import Foundation
import UIKit

class HomePageViewController: UIViewController{
    
    
    @IBOutlet weak var myTeamsButton: UIButton!
    @IBOutlet weak var indivStatsButton: UIButton!
    
    override func viewDidLoad() {
        
        myTeamsButton.titleLabel?.adjustsFontSizeToFitWidth = true
        myTeamsButton.titleLabel?.textAlignment = .center
        myTeamsButton.layer.cornerRadius = myTeamsButton.frame.width/5
        
        indivStatsButton.titleLabel?.adjustsFontSizeToFitWidth = true
        indivStatsButton.titleLabel?.textAlignment = .center
        //indivStatsButton.titleLabel?.numberOfLines = 2
        indivStatsButton.layer.cornerRadius = indivStatsButton.frame.width/5
        
        
        
    }
    
    @IBAction func unwindToHomePage(segue:UIStoryboardSegue) { }
    
    
    @IBAction func clickMyTeams(_ sender: Any) {
        sendToMyTeams()
    }
    
    func sendToMyTeams() {
        let storyboard = UIStoryboard(name: "TeamSelect", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "myTeams") as! TeamSelectViewController
        present(vc, animated: true, completion: nil)
        
    }
    
    @IBAction func clickIndividualStats(_ sender: Any) {
        let defaults = UserDefaults.standard
        var pid = defaults.integer(forKey: BTHelper.defaultsKeys.storedLoginPitcherID)
        pid = -1
        //TODO: TAKE THIS SHIT OUT ^
        if pid == -1 || pid == 0{
            let storyboard = UIStoryboard(name: "TeamSelect", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "loginVC") as! LoginViewController
            present(vc, animated: true, completion: nil)
        }else{
            BTHelper.CurrentPitcher = pid
            let storyboard = UIStoryboard(name: "Bullpens", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "BullpensVC") as! BullpenViewController
            present(vc, animated: true, completion: nil)
        }
        
        
    }
    
}
