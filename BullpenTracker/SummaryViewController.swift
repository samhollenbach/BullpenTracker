//
//  SummaryViewController.swift
//  BullpenTracker
//
//  Created by Sam Hollenbach on 8/28/17.
//  Copyright © 2017 Sam Hollenbach. All rights reserved.
//

import UIKit

class SummaryViewController: UIViewController {

    var bullpenData: [Any] = []
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var emailStatusLabel: UILabel!
    var graph: UIImage? = nil
    
    struct defaultsKeys {
        static let lastEmail = "lastEmail"
        static let keyTwo = "secondStringKey"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 11.0, *) {
            self.additionalSafeAreaInsets.top = 20
        }
        navBar.frame = CGRect(x: 0, y: 20, width: (navBar.frame.size.width), height: (navBar.frame.size.height))
        addButtons()
        
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        //tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        
        
        refreshImage()
        
    }
    
    func addButtons(){
        let w = self.view.frame.size.width
        let h = self.view.frame.size.height

        let emailButton = UIButton(type: .custom)
        emailButton.frame = CGRect(x: w/2-125, y: h-150, width: 100, height: 100)
        emailButton.layer.cornerRadius = 0.5 * emailButton.bounds.size.width
        emailButton.clipsToBounds = true
        emailButton.setTitle("Email Stats", for: .normal)
        emailButton.layer.borderWidth = 1
        emailButton.layer.borderColor = UIColor.black.cgColor
        emailButton.backgroundColor = UIColor.white
        emailButton.setTitleColor(UIColor.black, for: .normal)
        emailButton.addTarget(self, action: #selector(pressEmailBullpen), for: .touchUpInside)
        view.addSubview(emailButton)
        
        let addPitchesButton = UIButton(type: .custom)
        addPitchesButton.frame = CGRect(x: w/2+25, y: h-150, width: 100, height: 100)
        addPitchesButton.layer.cornerRadius = 0.5 * addPitchesButton.bounds.size.width
        addPitchesButton.clipsToBounds = true
        addPitchesButton.layer.borderWidth = 1
        addPitchesButton.layer.borderColor = UIColor.black.cgColor
        addPitchesButton.setTitle("Add Pitches", for: .normal)
        addPitchesButton.backgroundColor = UIColor.white
        addPitchesButton.setTitleColor(UIColor.black, for: .normal)
        addPitchesButton.addTarget(self, action: #selector(addPitches), for: .touchUpInside)
        view.addSubview(addPitchesButton)
        
        
        
    }
    
    
    
    @IBAction func trashPressed(_ sender: AnyObject) {
        
        let alert = UIAlertController(title: "Are you sure you want to delete this bullpen?", message: "This cannot be undone", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Delete", style: UIAlertActionStyle.destructive, handler: { action in
            self.deleteBullpen()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil ))
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func deleteBullpen(){
        let data = "bullpen_id=\(bullpenData[0])"
        ServerConnector.runScript(scriptName: "RemoveBullpen.php", data: data)
        DispatchQueue.main.async {
            self.doneButtonPressed(self)
        }
    }
    
    @IBAction func unwindToSummary(segue: UIStoryboardSegue) {
        DispatchQueue.main.async() { () -> Void in
            self.refreshImage()
        }
    }
    
    func refreshImage(){
        if let checkedUrl = URL(string: "http://52.55.212.19/plots/plot_\(bullpenData[0]).png") {
            print(checkedUrl)
            downloadImage(url: checkedUrl)
            setImage()
        }
    }
    
    func downloadImage(url: URL) {
        print("Download Started")
        getDataFromUrl(url: url) { (data, response, error)  in
            guard let data = data, error == nil else { return }
            //self.imageView.image = nil
            //print(response?.suggestedFilename ?? url.lastPathComponent)
            print("Download Finished")
            DispatchQueue.main.async() { () -> Void in
                self.graph = UIImage(data: data)
            }
        }
    }
    
    func setImage(){
        self.imageView.image = nil
        self.imageView.layer.masksToBounds = true
        self.imageView.contentMode = .scaleAspectFit
        self.imageView.image = graph
    }
  
    
    func getDataFromUrl(url: URL, completion: @escaping (_ data: Data?, _  response: URLResponse?, _ error: Error?) -> Void) {
        URLSession.shared.reset{
            let urlTask = URLSession.shared.dataTask(with: url) {
                (data, response, error) in
                completion(data, response, error)
            }
            urlTask.resume()
        }
    }
    
    
    
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
  
    
    @IBAction func doneButtonPressed(_ sender: AnyObject) {
        self.performSegue(withIdentifier: "unwindToBullpens", sender: self)
        
    }
    
    
    @objc func pressEmailBullpen(){
        
        //1. Create the alert controller.
        let alert = UIAlertController(title: "Enter your email", message: "Your stats will be sent to this email", preferredStyle: .alert)
        
        //2. Add the text field. You can configure it however you need.
        alert.addTextField { (textField) in
            textField.placeholder = "Email Adress"
            textField.keyboardType = .emailAddress
            let defaults = UserDefaults.standard
            if let emailPlaceholder: String = defaults.string(forKey: defaultsKeys.lastEmail) {
                textField.text = emailPlaceholder
            }
        }
        
        // 3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "Send", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0]
            // Force unwrapping because we know it exists.
            let emailAddress: String = (textField?.text)!
            self.emailBullpen(email: emailAddress){ success in
                DispatchQueue.main.async {
                    if success{
                        self.emailStatusLabel.text = "Email sent to \(emailAddress)"
                        let defaults = UserDefaults.standard
                        defaults.set(emailAddress, forKey: defaultsKeys.lastEmail)
                    }else{
                        self.emailStatusLabel.text = "Something went wrong, try again"
                    }
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        // 4. Present the alert.
        self.present(alert, animated: true, completion: nil)
        
    }
    
    
    func emailBullpen(email: String,completion: @escaping (Bool) -> ()){
        emailStatusLabel.text = "Sending email..."
        let data = "bullpen_id=\(bullpenData[0])&email=\(email)"
        ServerConnector.runScript(scriptName: "send_email.php", data: data){ response in
            completion(response != nil)
        }
    }
    
    
    @objc func addPitches(){
        sendToAddPitchesVC(bullpenData: bullpenData, comp: false)
    }
    
    func sendToAddPitchesVC(bullpenData: [Any], comp: Bool) {
        let storyboard = UIStoryboard(name: "AddPitches", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "AddPitches") as! AddPitches
        vc.bullpenData = bullpenData
        vc.new = false
        present(vc, animated: true, completion: nil)
    }
    
    
}
