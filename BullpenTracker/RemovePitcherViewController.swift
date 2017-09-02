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
        navBar.frame = CGRect(x: 0, y: 0, width: (navBar.frame.size.width), height: (navBar.frame.size.height)+UIApplication.shared.statusBarFrame.height)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(RemovePitcherViewController.dismissKeyboard))
        
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        //tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    

    @IBAction func RemovePitcher(_ sender: UIButton) {
        let pitcher_name = textField.text!
        
        
        let url: NSURL = NSURL(string: "http://52.55.212.19/remove_pitcher.php")!
        let request:NSMutableURLRequest = NSMutableURLRequest(url:url as URL)
        request.httpMethod = "POST"
        let data = "name="+pitcher_name
        request.httpBody = data.data(using: String.Encoding.utf8);
        let task = URLSession.shared.dataTask(with: request as URLRequest!, completionHandler: { data, response, error in
            guard let data = data, error == nil else {                                                 // check for fundamental networking error
                print("error=\(error)")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(response)")
            }
            
            let responseString = String(data: data, encoding: .utf8)
            print("responseString = \(responseString)")
            
        })
        task.resume()
        sleep(1)
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
