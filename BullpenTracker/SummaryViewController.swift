//
//  SummaryViewController.swift
//  BullpenTracker
//
//  Created by Sam Hollenbach on 8/28/17.
//  Copyright © 2017 Sam Hollenbach. All rights reserved.
//

import UIKit

class SummaryViewController: UIViewController {

    
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var emailStatusLabel: UILabel!
    public var currentBullpenID = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addButtons()
        imageView.contentMode = .scaleAspectFit
        navBar.frame = CGRect(x: 0, y: 0, width: (navBar.frame.size.width), height: (navBar.frame.size.height)+UIApplication.shared.statusBarFrame.height)
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        //tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        // Do any additional setup after loading the view.
        
        refreshImage()
        
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
        let url: NSURL = NSURL(string: "http://52.55.212.19/remove_bullpen.php")!
        let request:NSMutableURLRequest = NSMutableURLRequest(url:url as URL)
        request.httpMethod = "POST"
        let data = "bullpen_id=\(currentBullpenID)"
        request.httpBody = data.data(using: String.Encoding.utf8);
        let task = URLSession.shared.dataTask(with: request as URLRequest!, completionHandler: { data, response, error in
            guard let data = data, error == nil else {                                                 // check for fundamental networking error
                print("error=\(error)")
                //completion(false)
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(response)")
                //completion(false)
                return
            }
            
            let responseString = String(data: data, encoding: .utf8)!
            print("responseString = \(responseString)")
            //completion(true)
            return
            
        })
        task.resume()
        
        
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
        if let checkedUrl = URL(string: "http://52.55.212.19/plots/plot_\(currentBullpenID).png") {
            print(checkedUrl)
            
            downloadImage(url: checkedUrl)
        }
    }
    
    
    func getDataFromUrl(url: URL, completion: @escaping (_ data: Data?, _  response: URLResponse?, _ error: Error?) -> Void) {
        URLSession.shared.dataTask(with: url) {
            (data, response, error) in
            completion(data, response, error)
            }.resume()
    }
    
    func downloadImage(url: URL) {
        print("Download Started")
        getDataFromUrl(url: url) { (data, response, error)  in
            guard let data = data, error == nil else { return }
            //self.imageView.image = nil
            print(response?.suggestedFilename ?? url.lastPathComponent)
            print("Download Finished")
            DispatchQueue.main.async() { () -> Void in
                self.imageView.image = UIImage(data: data)
            }
        }
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
        //refreshImage()
    }
    
    
    
    
    @IBAction func doneButtonPressed(_ sender: AnyObject) {
        self.performSegue(withIdentifier: "unwindToBullpens", sender: self)
    }
    
    func addButtons(){
        
        let w = self.view.frame.size.width
        let h = self.view.frame.size.height
        
        
        let emailButton = UIButton(type: .custom)
        emailButton.frame = CGRect(x: w/2-125, y: h-150, width: 100, height: 100)
        emailButton.layer.cornerRadius = 0.5 * emailButton.bounds.size.width
        emailButton.clipsToBounds = true
        emailButton.setTitle("Email Stats", for: .normal)
        emailButton.backgroundColor = UIColor.blue
        emailButton.setTitleColor(UIColor.white, for: .normal)
        emailButton.addTarget(self, action: #selector(pressEmailBullpen), for: .touchUpInside)
        view.addSubview(emailButton)
        
        
        let addPitchesButton = UIButton(type: .custom)
        addPitchesButton.frame = CGRect(x: w/2+25, y: h-150, width: 100, height: 100)
        addPitchesButton.layer.cornerRadius = 0.5 * addPitchesButton.bounds.size.width
        addPitchesButton.clipsToBounds = true
        addPitchesButton.setTitle("Add Pitches", for: .normal)
        addPitchesButton.backgroundColor = UIColor.orange
        addPitchesButton.setTitleColor(UIColor.black, for: .normal)
        addPitchesButton.addTarget(self, action: #selector(addPitches), for: .touchUpInside)
        view.addSubview(addPitchesButton)


                
    }
    
    func pressEmailBullpen(){
        
        //1. Create the alert controller.
        let alert = UIAlertController(title: "Enter your email", message: "Your stats will be sent to this email", preferredStyle: .alert)
        
        //2. Add the text field. You can configure it however you need.
        alert.addTextField { (textField) in
            textField.placeholder = "Email Adress"
            textField.keyboardType = .emailAddress
        }
        
        // 3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "Send", style: .default, handler: { [weak alert] (_) in
            
            let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
            let emailAddress: String = (textField?.text)!
            self.emailBullpen(email: emailAddress){ success in
                DispatchQueue.main.async {
                    if success{
                        self.emailStatusLabel.text = "Email sent to \(emailAddress)"
                    }else{
                        self.emailStatusLabel.text = "Something went wrong, try again"
                    }
                    
                }
                
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

    
        
        // 4. Present the alert.
        self.present(alert, animated: true, completion: nil)
        
//        emailBullpen(){ success in
//            DispatchQueue.main.async {
//                if success{
//                    self.emailStatusLabel.text = "Email Sent!"
//                }else{
//                    self.emailStatusLabel.text = "Something went wrong, try again"
//                }
//                
//            }
//            
//        }
    }
    
    
    func emailBullpen(email: String,completion: @escaping (Bool) -> ()){
        
        //let email:String = (emailField.text?.trimmingCharacters(in: .whitespacesAndNewlines))!
        emailStatusLabel.text = "Sending email..."
        
        
        let url: NSURL = NSURL(string: "http://52.55.212.19/send_email.php")!
        let request:NSMutableURLRequest = NSMutableURLRequest(url:url as URL)
        request.httpMethod = "POST"
        let data = "bullpen_id=\(currentBullpenID)&email=\(email)"
        request.httpBody = data.data(using: String.Encoding.utf8);
        let task = URLSession.shared.dataTask(with: request as URLRequest!, completionHandler: { data, response, error in
            guard let data = data, error == nil else {                                                 // check for fundamental networking error
                print("error=\(error)")
                completion(false)
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(response)")
                completion(false)
                return
            }
            
            let responseString = String(data: data, encoding: .utf8)!
            print("responseString = \(responseString)")
            completion(true)
            return
            
        })
        task.resume()
        
        
    }
    
    
    func addPitches(){
        sendToAddPitchesVC(bullpen_id: currentBullpenID)
    }
    
    func sendToAddPitchesVC(bullpen_id: Int) {
        let storyboard = UIStoryboard(name: "AddPitches", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "AddPitches") as! AddPitches
        vc.bullpenID = bullpen_id
        vc.new = false
        present(vc, animated: true, completion: nil)
    }
    
    
}
