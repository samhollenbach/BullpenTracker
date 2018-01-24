//
//  AddPitches.swift
//  BullpenTracker
//
//  Created by Sam Hollenbach on 8/27/17.
//  Copyright © 2017 Sam Hollenbach. All rights reserved.
//

import UIKit

class AddPitches: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource{
    
    
    
    @IBOutlet weak var pitchPicker: UIPickerView!
    var totalPitches = 0
    var new: Bool = true
    var lastPitchID = -1
    
    @IBOutlet weak var navBar: UINavigationBar!
    var pitchButtons: [UIButton] = []
    var strikeButtons: [UIButton] = []
    let statusLabel: UILabel = UILabel()
    let pitchCountLabel: UILabel = UILabel()
    var bullpenID = -1
    var pitches: [[String]] = [[String]]()
    
    var add_success = false
    let velField = UITextField()
    let enterButton = UIButton(type: .custom)
    let undoButton = UIButton(type: .custom)
    let pitchTypeHighlight = UIColor.white
    let pitchTypeColor = UIColor(red:0.13, green:0.22, blue:0.46, alpha:1.0)
    let ballStrikeHighlight = UIColor.white
    let ballStrikeColor = UIColor(red:0.13, green:0.22, blue:0.46, alpha:1.0)
    let enterButtonsColorPressed = UIColor(red:0.00, green:0.16, blue:1.00, alpha:1.0)
    let enterButtonsColor = UIColor(red:0.23, green:0.32, blue:0.56, alpha:1.0)
    
    var selectedPitch: String = ""
    var selectedResult: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.pitchPicker.delegate = self
        self.pitchPicker.dataSource = self
        pitches = [["FB", "CH", "CR", "SL", "X"], ["None", "Swing and miss", "Strike taken", "Swinging strikout", "Looking strikeout"]]
        selectedPitch = pitches[0][0]
        selectedResult = pitches[1][0]
        
        navBar.frame = CGRect(x: 0, y: 20, width: (navBar.frame.size.width), height: (navBar.frame.size.height)+UIApplication.shared.statusBarFrame.height)
        addButtons()
        // Do any additional setup after loading the view.
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(AddPitcherViewController.dismissKeyboard))
        
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        //tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    

    
    func addButtons(){
        let w = self.view.frame.size.width
        let h = self.view.frame.size.height
        
        pitchCountLabel.frame = CGRect(x: 50, y: 70, width: w-100, height: 30)
        pitchCountLabel.text = "Pitches Recorded: " + String(totalPitches)
        pitchCountLabel.textAlignment = .center
        view.addSubview(pitchCountLabel)
        
        
        
        
        
        
        // pitch buttons
//        for (index, pitch) in pitches.enumerated(){
//
//            let t = 25 + (w - 50) * (CGFloat(index)/CGFloat(pitches.count))
//            let w1 = (w-50)/CGFloat(pitches.count) - 10
//
//            let button = UIButton(type: .custom)
//            button.frame = CGRect(x: t, y: 150, width: w1, height: w1)
//            button.layer.cornerRadius = 0.5 * button.bounds.size.width
//            button.clipsToBounds = true
//            //button.setImage(UIImage(named:"thumbsUp.png"), for: .normal)
//            button.setTitle(pitch, for: .normal)
//            button.tag = index
//            button.backgroundColor = pitchTypeHighlight
//            button.layer.borderWidth = 1
//            button.layer.borderColor = pitchTypeColor.cgColor
//            button.setTitleColor(pitchTypeColor, for: .normal)
//            button.addTarget(self, action: #selector(pitchesButtonPressed), for: .touchUpInside)
//            pitchButtons.append(button)
//            view.addSubview(button)
//
//        }
        
        
        
        for (index, pitch) in ["N", "Y"].enumerated(){
            
            let size: CGFloat = 75
            let t = w - (size + 10) * (CGFloat(index+1))
            
            let button = UIButton(type: .custom)
            button.frame = CGRect(x: t, y: 275, width: size, height: size)
            button.layer.cornerRadius = 0.5 * button.bounds.size.width
            button.clipsToBounds = true
            button.setTitle(pitch, for: .normal)
            button.tag = index
            button.backgroundColor = ballStrikeHighlight
            button.layer.borderWidth = 1
            button.layer.borderColor = ballStrikeColor.cgColor
            button.setTitleColor(ballStrikeColor, for: .normal)
            button.addTarget(self, action: #selector(strikeButtonPressed), for: .touchUpInside)
            strikeButtons.append(button)
            view.addSubview(button)
            
        }
        
        
        
        velField.frame = CGRect(x: w/2-40, y: h-250, width: 80, height: 30)
        velField.keyboardType = .numberPad
        velField.placeholder = "velo"
        velField.backgroundColor = UIColor.white
        velField.layer.borderWidth = 1
        velField.layer.borderColor = enterButtonsColor.cgColor
        velField.textAlignment = .center
        velField.layer.cornerRadius = 7
        view.addSubview(velField)
        
        let mphLabel = UILabel()
        mphLabel.frame = CGRect(x: w/2+50, y: h-250, width: 50, height: 30)
        mphLabel.text = "mph"
        view.addSubview(mphLabel)
        
        
        
        enterButton.frame = CGRect(x: w/2-50, y: h-180, width: 100, height: 100)
        enterButton.layer.cornerRadius = 0.5 * enterButton.bounds.size.width
        enterButton.clipsToBounds = true
        enterButton.setTitle("Enter", for: .normal)
        enterButton.backgroundColor = enterButtonsColor
        enterButton.setTitleColor(UIColor.white, for: .normal)
        enterButton.addTarget(self, action: #selector(enterPitch), for: .touchUpInside)
        view.addSubview(enterButton)
        
        
        
        
        undoButton.frame = CGRect(x: 50, y: h-155, width: 50, height: 50)
        undoButton.layer.cornerRadius = 0.5 * undoButton.bounds.size.width
        undoButton.clipsToBounds = true
        undoButton.setTitle("Undo", for: .normal)
        undoButton.backgroundColor = enterButtonsColor
        undoButton.setTitleColor(UIColor.white, for: .normal)
        undoButton.addTarget(self, action: #selector(pressUndoPitch), for: .touchUpInside)
        view.addSubview(undoButton)
        
        statusLabel.frame = CGRect(x: 0, y: h-60, width: w, height: 30)
        statusLabel.text = "Enter a pitch"
        statusLabel.textAlignment = .center
        view.addSubview(statusLabel)

        
    }
    
    @objc func pressUndoPitch(){
        undoButton.backgroundColor = enterButtonsColorPressed
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
        undoButton.backgroundColor = enterButtonsColor
    }
    
    
    func undoPitch(completion: @escaping (Bool) -> ()){
        let data = "id=\(lastPitchID)&bullpen_id=\(bullpenID)"
        ServerConnector.runScript(scriptName: "RemovePitch.php", data: data){ response in
            completion(response != nil)
        }
    }
    
    
    
    @objc func enterPitch(sender:UIButton){
        enterButton.backgroundColor = enterButtonsColorPressed
        var pitch = ""
//        for p in pitchButtons{
//            if p.isSelected{
//                pitch = p.title(for: .normal)!
//                p.isSelected = false
//                p.backgroundColor = pitchTypeHighlight
//                p.setTitleColor(pitchTypeColor, for: .normal)
//                print(pitch)
//            }
//        }
        pitch = selectedPitch
        var strike = ""
        for b in strikeButtons{
            if b.isSelected{
                strike = b.title(for: .normal)!
                b.isSelected = false
                b.backgroundColor = ballStrikeHighlight
                b.setTitleColor(ballStrikeColor, for: .normal)
                print(strike)
            }
        }
        
        if (pitch == "" || strike == ""){
            statusLabel.text = "Invalid entry, try again"
            enterButton.backgroundColor = enterButtonsColor
            return
        }
        
        self.statusLabel.text = "Sending..."
        
        let vel = velField.text
        
        
        addPitch(pitch: pitch, strike: strike, vel: vel!){ success in
            DispatchQueue.main.async {
                if success{
                    self.totalPitches += 1
                    self.pitchCountLabel.text = "Pitches Recorded: " + String(self.totalPitches)
                    self.statusLabel.text = "Last pitch: " + pitch + ", " + strike
                }else{
                    self.statusLabel.text = "Trouble connecting to database, try again"
                }
                self.enterButton.backgroundColor = self.enterButtonsColor
            }
            
            
        }
        velField.text = ""
        

        
    }
    
    
    func addPitch(pitch: String, strike: String, vel: String, completion: @escaping (Bool) -> ()){
        var s = strike
        if s=="Strike"{
            s = "S"
        }else if s=="Ball"{
            s = "B"
        }
        let data = "bullpen_id=\(bullpenID)&pitch_type=\(pitch)&ball_strike=\(s)&vel=\(vel)"
        
        ServerConnector.runScript(scriptName: "AddPitch.php", data: data){ response in
            completion(response != nil)
            let pitch_list = ServerConnector.extractJSON((response?.data(using: .utf8))!)
            let pitch = pitch_list[0] as? NSDictionary
            let last_pitch = pitch!["last_id"] as! String
            self.lastPitchID = Int(last_pitch)!
        }
    }
    
    
    @objc func pitchesButtonPressed(sender:UIButton){
        for pitchB in pitchButtons{
            if pitchB.tag == sender.tag{
                pitchB.backgroundColor = pitchTypeColor
                pitchB.setTitleColor(pitchTypeHighlight, for: .normal)
                pitchB.isSelected = true
            }else{
                pitchB.backgroundColor = pitchTypeHighlight
                pitchB.setTitleColor(pitchTypeColor, for: .normal)
                pitchB.isSelected = false
            }
        }
        dismissKeyboard()
    }
    
    @objc func strikeButtonPressed(sender:UIButton){
        for b in strikeButtons{
            if b.tag == sender.tag{
                b.backgroundColor = ballStrikeColor
                b.setTitleColor(ballStrikeHighlight, for: .normal)
                b.isSelected = true
            }else{
                b.backgroundColor = ballStrikeHighlight
                b.setTitleColor(ballStrikeColor, for: .normal)
                b.isSelected = false
            }
        }
        dismissKeyboard()
    }
    
    @IBAction func donePressed(_ sender: UIBarButtonItem) {
        dismissKeyboard()
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
        let data = "bullpen_id=\(bullpenID)"
        ServerConnector.runScript(scriptName: "get_stats.php", data: data){ response in
            completion(response != nil)
        }


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
    
    // The number of columns of data
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return pitches.count
    }
    
    // The number of rows of data
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pitches[component].count
    }
    
    // The data to return for the row and component (column) that's being passed in
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pitches[component][row]
    }
    
    // Catpure the picker view selection
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0{
             selectedPitch = pitches[component][row]
        }else{
            selectedResult = pitches[1][row]
        }
       
        
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
