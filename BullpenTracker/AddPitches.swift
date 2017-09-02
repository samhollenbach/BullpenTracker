//
//  AddPitches.swift
//  BullpenTracker
//
//  Created by Sam Hollenbach on 8/27/17.
//  Copyright © 2017 Sam Hollenbach. All rights reserved.
//

import UIKit

class AddPitches: UIViewController {
    
    var totalPitches = 0
    var new: Bool = true
    var lastPitchID = -1
    
    @IBOutlet weak var navBar: UINavigationBar!
    var pitchButtons: [UIButton] = []
    var strikeButtons: [UIButton] = []
    let statusLabel: UILabel = UILabel()
    let pitchCountLabel: UILabel = UILabel()
    var bullpenID = -1
    var add_success = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navBar.frame = CGRect(x: 0, y: 0, width: (navBar.frame.size.width), height: (navBar.frame.size.height)+UIApplication.shared.statusBarFrame.height)
        addButtons()
        // Do any additional setup after loading the view.
    }
    
    func addButtons(){
        let w = self.view.frame.size.width
        let h = self.view.frame.size.height
        
        pitchCountLabel.frame = CGRect(x: 50, y: 70, width: w-50, height: 30)
        pitchCountLabel.text = "Pitches Recorded: " + String(totalPitches)
        pitchCountLabel.textAlignment = .left
        view.addSubview(pitchCountLabel)
        
        
        let pitches: [String] = ["FB", "CH", "CR", "SL", "X"]
        
        
        
        
        for (index, pitch) in pitches.enumerated(){
            
            let t = 25 + (w - 50) * (CGFloat(index)/CGFloat(pitches.count))
            let w1 = (w-50)/CGFloat(pitches.count) - 10
            
            let button = UIButton(type: .custom)
            button.frame = CGRect(x: t, y: 150, width: w1, height: w1)
            button.layer.cornerRadius = 0.5 * button.bounds.size.width
            button.clipsToBounds = true
            //button.setImage(UIImage(named:"thumbsUp.png"), for: .normal)
            button.setTitle(pitch, for: .normal)
            button.tag = index
            button.backgroundColor = UIColor.white
            button.setTitleColor(UIColor.black, for: .normal)
            button.addTarget(self, action: #selector(pitchesButtonPressed), for: .touchUpInside)
            pitchButtons.append(button)
            view.addSubview(button)

        }
        
        
        for (index, pitch) in ["Ball", "Strike"].enumerated(){
            
            let t = 75 + (w - 150) * (CGFloat(index)/2.0)
            let w1 = (w-150)/2.0 - 10
            
            let button = UIButton(type: .custom)
            button.frame = CGRect(x: t, y: 300, width: w1, height: w1)
            button.layer.cornerRadius = 0.5 * button.bounds.size.width
            button.clipsToBounds = true
            button.setTitle(pitch, for: .normal)
            button.tag = index
            button.backgroundColor = UIColor.white
            button.setTitleColor(UIColor.black, for: .normal)
            button.addTarget(self, action: #selector(strikeButtonPressed), for: .touchUpInside)
            strikeButtons.append(button)
            view.addSubview(button)
            
        }
        
        
        let enterButton = UIButton(type: .custom)
        enterButton.frame = CGRect(x: w/2-50, y: h-200, width: 100, height: 100)
        enterButton.layer.cornerRadius = 0.5 * enterButton.bounds.size.width
        enterButton.clipsToBounds = true
        enterButton.setTitle("Enter", for: .normal)
        enterButton.backgroundColor = UIColor.green
        enterButton.setTitleColor(UIColor.black, for: .normal)
        enterButton.addTarget(self, action: #selector(enterPitch), for: .touchUpInside)
        view.addSubview(enterButton)
        
        
        
        let undoButton = UIButton(type: .custom)
        undoButton.frame = CGRect(x: 50, y: h-175, width: 50, height: 50)
        undoButton.layer.cornerRadius = 0.5 * undoButton.bounds.size.width
        undoButton.clipsToBounds = true
        undoButton.setTitle("Undo", for: .normal)
        undoButton.backgroundColor = UIColor.red
        undoButton.setTitleColor(UIColor.white, for: .normal)
        undoButton.addTarget(self, action: #selector(pressUndoPitch), for: .touchUpInside)
        view.addSubview(undoButton)
        
        statusLabel.frame = CGRect(x: 0, y: h-60, width: w, height: 30)
        statusLabel.text = "Enter a pitch"
        statusLabel.textAlignment = .center
        view.addSubview(statusLabel)

        
    }
    
    func pressUndoPitch(){
        self.statusLabel.text = "Removing last pitch"
        if totalPitches == 0{
            self.statusLabel.text = "No pitches to remove"
            return
        }
        
        undoPitch(){ success in
            DispatchQueue.main.async {
                if success{
                    self.statusLabel.text = "Sucessfully removed last pitch"
                    self.totalPitches -= 1
                    self.pitchCountLabel.text = "Pitches Recorded: " + String(self.totalPitches)

                }else{
                    self.statusLabel.text = "Failed to remove previous pitch"
                }
            }
        }
    }
    
    
    func undoPitch(completion: @escaping (Bool) -> ()){
        let url: NSURL = NSURL(string: "http://52.55.212.19/remove_pitch.php")!
        let request:NSMutableURLRequest = NSMutableURLRequest(url:url as URL)
        request.httpMethod = "POST"
        //let name = nameField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let data = "id=\(lastPitchID)"
        request.httpBody = data.data(using: String.Encoding.utf8);
        let task = URLSession.shared.dataTask(with: request as URLRequest!, completionHandler: { data, response, error in
            guard let data = data, error == nil else {                                                 // check for fundamental networking error
                print("error=\(error)")
                //                DispatchQueue.main.async {
                //                    self.add_success = false
                //                }
                completion(false)
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(response)")
                completion(false)
                return
            }
            
            let responseString:String = String(data: data, encoding: .utf8)!
            print("responseString = \(responseString)")
            completion(true)
            return
            
        })
        task.resume()
    }
    
    
    
    
    func enterPitch(sender:UIButton){
        var pitch = ""
        for p in pitchButtons{
            if p.isSelected{
                pitch = p.title(for: .normal)!
                p.isSelected = false
                p.backgroundColor = UIColor.white
                print(pitch)
            }
        }
        var strike = ""
        for b in strikeButtons{
            if b.isSelected{
                strike = b.title(for: .normal)!
                b.isSelected = false
                b.backgroundColor = UIColor.white
                b.setTitleColor(UIColor.black, for: .normal)
                print(strike)
            }
        }
        
        if (pitch == "" || strike == ""){
            statusLabel.text = "Invalid entry, try again"
            return
        }
        
        self.statusLabel.text = "Sending..."
        
        addPitch(pitch: pitch, strike: strike){ success in
            DispatchQueue.main.async {
                if success{
                    self.totalPitches += 1
                    self.pitchCountLabel.text = "Pitches Recorded: " + String(self.totalPitches)
                    self.statusLabel.text = "Last pitch: " + pitch + ", " + strike
                }else{
                    self.statusLabel.text = "Trouble connecting to database, try again"
                }
            }

        }
    
        
    }
    
    
    func addPitch(pitch: String, strike: String, completion: @escaping (Bool) -> ()){
        var s = strike
        if s=="Strike"{
            s = "S"
        }else if s=="Ball"{
            s = "B"
        }
        
        let url: NSURL = NSURL(string: "http://52.55.212.19/add_pitch.php")!
        let request:NSMutableURLRequest = NSMutableURLRequest(url:url as URL)
        request.httpMethod = "POST"
        //let name = nameField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let data = "bullpen_id=\(bullpenID)&pitch_type=\(pitch)&ball_strike=\(s)"
        request.httpBody = data.data(using: String.Encoding.utf8);
        let task = URLSession.shared.dataTask(with: request as URLRequest!, completionHandler: { data, response, error in
            guard let data = data, error == nil else {                                                 // check for fundamental networking error
                print("error=\(error)")
//                DispatchQueue.main.async {
//                    self.add_success = false
//                }
                completion(false)
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(response)")
//                DispatchQueue.main.async {
//                    self.add_success = false
//                }
                completion(false)
                return
            }
            
            let responseString:String = String(data: data, encoding: .utf8)!
            print(responseString)
            completion(true)
            if responseString.hasPrefix("Pitch ID"){
                self.lastPitchID = Int(responseString.components(separatedBy: ":").last!)!
            }
            print("responseString = \(responseString)")
            
            return
            
        })
        task.resume()
    
        
    }
    
    
    func pitchesButtonPressed(sender:UIButton){
        for pitchB in pitchButtons{
            if pitchB.tag == sender.tag{
                pitchB.backgroundColor = UIColor.orange
                pitchB.isSelected = true
            }else{
                pitchB.backgroundColor = UIColor.white
                pitchB.isSelected = false

            }
        }
        
    }
    
    func strikeButtonPressed(sender:UIButton){
        for b in strikeButtons{
            if b.tag == sender.tag{
                b.backgroundColor = UIColor.blue
                b.setTitleColor(UIColor.white, for: .normal)

                b.isSelected = true
            }else{
                b.backgroundColor = UIColor.white
                b.setTitleColor(UIColor.black, for: .normal)
                b.isSelected = false
            }
        }
    }
    
    @IBAction func donePressed(_ sender: UIBarButtonItem) {
        sender.isEnabled = false
        if totalPitches > 0 {
            makeData(){ success in
                DispatchQueue.main.async {
                    print("Success: \(success)")
                    //idk y
                    sleep(1)
                    self.sendToSummaryVC(bullpen_id: self.bullpenID)

                }
            }
        }else{
            if new{
                performSegue(withIdentifier: "unwindToBullpens", sender: self)
            }else{
                performSegue(withIdentifier: "unwindToSummary", sender: self)
            }
            
        }
        
    }
    
    func makeData(completion: @escaping (Bool) -> ()){
        let url: NSURL = NSURL(string: "http://52.55.212.19/get_stats.php")!
        let request:NSMutableURLRequest = NSMutableURLRequest(url:url as URL)
        request.httpMethod = "POST"
        let data = "bullpen_id=\(bullpenID)"
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
    
    func sendToSummaryVC(bullpen_id: Int) {
        let storyboard = UIStoryboard(name: "SummaryView", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "SummaryVC") as! SummaryViewController
        vc.currentBullpenID = bullpen_id
        self.present(vc, animated: true, completion: nil)
        sleep(1)
        //vc.refreshImage()
    }
    
   
    
    
    func sendToBullpens() {
        let storyboard = UIStoryboard(name: "Bullpens", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "BullpensVC") as! BullpenViewController
        present(vc, animated: true, completion: nil)
        
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
