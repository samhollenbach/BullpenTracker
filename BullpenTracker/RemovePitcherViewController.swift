//
//  RemovePitcherViewController.swift
//  BullpenTracker
//
//  Created by Sam Hollenbach on 6/19/17.
//  Copyright © 2017 Sam Hollenbach. All rights reserved.
//

import UIKit

class RemovePitcherViewController: UIViewController {

    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var textField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navBar.frame = CGRect(x: 0, y: 20, width: (navBar.frame.size.width), height: (navBar.frame.size.height))
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(RemovePitcherViewController.dismissKeyboard))
        
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        //tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    

    @IBAction func RemovePitcher(_ sender: UIButton) {
        let pitcher_name = textField.text!
        
        
        let data = "name=\(pitcher_name)"
        ServerConnector.runScript(scriptName: "RemovePitcher.php", data: data)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "PitchersVC") as UIViewController
        present(vc, animated: true, completion: nil)
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
