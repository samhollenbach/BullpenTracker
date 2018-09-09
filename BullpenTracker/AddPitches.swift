//
//  AddPitches.swift
//  BullpenTracker
//
//  Created by Sam Hollenbach on 8/27/17.
//  Copyright © 2017 Sam Hollenbach. All rights reserved.
//

import UIKit
import Foundation

class AddPitches: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource{
    
    var CurrentBullpen : Bullpen?
    var CurrentPitcher : Pitcher?
    var CurrentAtBat : AtBat?

    var competitivePen = false
    
    
    @IBOutlet weak var hardContactButton: UIButton!
    
    @IBOutlet weak var pitchPicker: UIPickerView!
    var totalPitches = 0
    var new: Bool = true
    var lastPitchID = -1
    
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var velField: UITextField!
    @IBOutlet weak var pitchResultLabel: UILabel!
    
    @IBOutlet weak var pitchTypeLabel: UILabel!
    var pitchButtons: [UIButton] = []
    var strikeButtons: [UIButton] = []
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var pitchCountLabel: UILabel!
    
    @IBOutlet weak var executedLabel: UILabel!
    
    @IBOutlet weak var abLabel: UILabel!
    @IBOutlet weak var StrikeZone: UIImageView!
    var ballImage: UIImageView!
    var strikeZoneImage: UIImageView!
    
    
    @IBOutlet weak var strikeButton: UIButton!
    @IBOutlet weak var ballButton: UIButton!
    
    var permanentBalls: [UIImageView] = []
    
    var bullpenID = -1
    var abID = 0
    var pitches: [[String]] = [[String]]()
    
    var add_success = false
    var newABButton = UIButton(type: .custom)
    var enterButton = UIButton(type: .custom)
    var undoButton = UIButton(type: .custom)
    let backgroundColor = UIColor.white
    let pitchTypeHighlight = UIColor.white
    let pitchTypeColor = UIColor(red:0.13, green:0.22, blue:0.46, alpha:1.0)
    let ballStrikeHighlight = UIColor.white
    let ballStrikeColor = UIColor(red:0.13, green:0.22, blue:0.46, alpha:1.0)
    let enterButtonsColorPressed = UIColor(red:0.00, green:0.16, blue:1.00, alpha:1.0)
    let enterButtonsColor = UIColor(red:0.23, green:0.32, blue:0.56, alpha:1.0)
    
    var selectedPitch: String = ""
    var selectedResult: String = ""
    
    var controllingBall = false
    var BallLocation : CGPoint? = nil
    let ballSize : CGFloat = 15
    
    var permBalls : [UIImageView] = []
    var StrikeViewWidth : CGFloat = 0.0
    var StrikeViewHeight : CGFloat = 0.0
    let strikeZoneRatio : CGFloat = 1.5
    private var showPitchHistory = true
    private var hardContact = false
    
    private var currentABPitches = 0
    
    private var remakeZone = true
    
    private var OfflinePitchData : [[String: Any?]] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if CurrentBullpen == nil{
            BTHelper.showErrorPopup(source: self, errorTitle: "Could not find bullpen (Internal Error)")
            self.performSegue(withIdentifier: "unwindToBullpens", sender: self)
        }
        
        self.pitchPicker.delegate = self
        self.pitchPicker.dataSource = self
        
        
        
        navBar.sizeToFit()
        
        if BTHelper.offlineMode{
            competitivePen = true
            bullpenID = -5
        }else{
            competitivePen = CurrentBullpen!.compPen!
            //competitivePen = bullpenData[1] as! Bool
            bullpenID = CurrentBullpen!.id!
            //bullpenID = bullpenData[0] as! Int
        }
        
        
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(AddPitcherViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        initializePitchChoices()
        
        
    }
    
    override func viewDidLayoutSubviews() {
        if remakeZone{
            let f = pitchPicker.frame
            var h = f.height
            if h < 200{
                h = 200
            }
            
            pitchPicker.frame = CGRect(x: f.origin.x, y: f.origin.y, width: f.width, height: h)
            
            
//            let sf = StrikeZone.frame
//            if sf.height > 200{
//
//                StrikeZone.frame = CGRect(x: sf.origin.x, y: sf.origin.y, width: f.width, height: 200)
//            }
            
            //Move position of strike zone area if comp pen
            if !self.competitivePen{
                var f = self.StrikeZone.frame
                f.origin.x = (self.view.frame.width-self.StrikeViewWidth)/2
                self.StrikeZone.frame = f
            }
            
            addButtons()
            
            makeStrikeZone()
            remakeZone = false
            
            
        }
    }
    
    func initializePitchChoices(){
        pitches = [["F", "S", "B", "X", "2", "C"], ["None", "Swing and miss", "Strike taken", "Swinging strikout", "Looking strikeout"]]
        selectedPitch = pitches[0][0]
        selectedResult = pitches[1][0]
        if BTHelper.offlineMode{
            totalPitches = OfflinePitchData.count
        }else{
            totalPitches = CurrentBullpen!.pitchList != nil ? CurrentBullpen!.pitchList!.count : 0
            //totalPitches = bullpenData[5] as! Int
        }
        
    }
    
    // Initialize buttons
    func addButtons(){
        // Main canvas width and height
        let w = self.view.frame.size.width
        let h = self.view.frame.size.height
        
        // Frame size for Nav Bar (weird iOS 11)
        navBar.frame = CGRect(x: 0, y: 20, width: w, height: (navBar.frame.size.height)+UIApplication.shared.statusBarFrame.height)
        
        
        // Set top bar labels
        statusLabel.text = "Enter a pitch"
        statusLabel.textAlignment = .left
        statusLabel.font = UIFont.boldSystemFont(ofSize: 18.0)
        view.addSubview(statusLabel)
            
        pitchCountLabel.text = "Total: " + String(totalPitches)
        pitchCountLabel.textAlignment = .right
        pitchCountLabel.font = UIFont.boldSystemFont(ofSize: 18.0)
        view.addSubview(pitchCountLabel)
        
    
        var bsButtons: [String]
        
        // If comp pen initialize At Bat and Hard contact buttons
        if competitivePen{
            bsButtons = ["Y", "N"]
            pitchResultLabel.isHidden = false
            
            
            let nbwidth : CGFloat = 75
            newABButton.frame = CGRect(x: 10 , y: h-nbwidth-10, width: nbwidth, height: nbwidth)
            newABButton = makeStandardButton(button: newABButton, title: "Start New At Bat")
            newABButton.backgroundColor = backgroundColor
            newABButton.layer.borderColor = enterButtonsColor.cgColor
            newABButton.layer.borderWidth = 1
            newABButton.titleLabel?.adjustsFontSizeToFitWidth = true
            newABButton.setTitleColor(UIColor.lightGray, for: .normal)
            newABButton.addTarget(self, action: #selector(newAB), for: .touchUpInside)
            view.addSubview(newABButton)
            
            hardContactButton = makeStandardButton(button: hardContactButton, title: "Hard Contact?")
            hardContactButton.layer.borderColor = ballStrikeColor.cgColor
            hardContactButton.backgroundColor = ballStrikeHighlight
            hardContactButton.setTitleColor(ballStrikeColor, for: .normal)
            hardContactButton.addTarget(self, action: #selector(hardContactPressed), for: .touchUpInside)
            view.addSubview(hardContactButton)
            
        }else{
            bsButtons = ["Strike", "Ball"]
            executedLabel.isHidden = true
            pitchResultLabel.isHidden = true
            hardContactButton.isHidden = true
            abLabel.isHidden = true
            //var frame : CGRect = pitchTypeLabel.frame
            //frame.origin.x = (w-frame.width)/2
            //pitchTypeLabel.frame = frame;
        }
        
        
        strikeButton.tag = 1
        strikeButton.layer.cornerRadius = 0.5 * strikeButton.bounds.size.width
        strikeButton.clipsToBounds = true
        strikeButton.setTitle(bsButtons[0], for: .normal)
        strikeButton.titleLabel?.adjustsFontSizeToFitWidth = true;
        strikeButton.titleLabel?.textAlignment = .center;
        strikeButton.titleLabel?.numberOfLines = 0;
        strikeButton.titleLabel?.minimumScaleFactor = 0.5;
        strikeButton.layer.borderWidth = 1
        strikeButton.layer.borderColor = ballStrikeColor.cgColor
        strikeButton.backgroundColor = ballStrikeHighlight
        strikeButton.setTitleColor(ballStrikeColor, for: .normal)
        strikeButton.addTarget(self, action: #selector(strikeButtonPressed), for: .touchUpInside)
        strikeButtons.append(strikeButton)
        view.addSubview(strikeButton)
        
        ballButton.tag = 0
        ballButton.layer.cornerRadius = 0.5 * ballButton.bounds.size.width
        ballButton.clipsToBounds = true
        ballButton.setTitle(bsButtons[1], for: .normal)
        ballButton.titleLabel?.adjustsFontSizeToFitWidth = true;
        ballButton.titleLabel?.textAlignment = .center;
        ballButton.titleLabel?.numberOfLines = 0;
        ballButton.titleLabel?.minimumScaleFactor = 0.5;
        ballButton.layer.borderWidth = 1
        ballButton.layer.borderColor = ballStrikeColor.cgColor
        ballButton.backgroundColor = ballStrikeHighlight
        ballButton.setTitleColor(ballStrikeColor, for: .normal)
        ballButton.addTarget(self, action: #selector(strikeButtonPressed), for: .touchUpInside)
        strikeButtons.append(ballButton)
        view.addSubview(ballButton)
        
        // Velocity Input Field
        velField.keyboardType = .numberPad
        velField.placeholder = "velo"
        velField.backgroundColor = backgroundColor
        velField.layer.borderWidth = 1
        velField.layer.borderColor = enterButtonsColor.cgColor
        velField.textAlignment = .center
        velField.layer.cornerRadius = 7
        view.addSubview(velField)
        
        // Enter Button
        let ebwidth : CGFloat = 75
        enterButton.frame = CGRect(x: w-ebwidth-10 , y: h-ebwidth-10, width: ebwidth, height: ebwidth)
        enterButton = makeStandardButton(button: enterButton, title: "Enter")
        enterButton.backgroundColor = enterButtonsColor
        enterButton.setTitleColor(backgroundColor, for: .normal)
        enterButton.addTarget(self, action: #selector(enterPitch), for: .touchUpInside)
        view.addSubview(enterButton)
        
        // Undo Button
        let ubwidth : CGFloat = 35
        undoButton.frame = CGRect(x: (w-ubwidth)/2, y: h-ubwidth-10, width: ubwidth, height: ubwidth)
        undoButton = makeStandardButton(button: undoButton, title: "undo")
        undoButton.backgroundColor = enterButtonsColor
        let undoImage: UIImage? = UIImage(named: "Undo")?.withRenderingMode(.alwaysTemplate)
        undoButton.setImage(undoImage, for: .normal)
        undoButton.imageView?.tintColor = backgroundColor
        undoButton.addTarget(self, action: #selector(pressUndoPitch), for: .touchUpInside)
        view.addSubview(undoButton)
        
    }
    
    func makeStrikeZone(){
        DispatchQueue.main.async{
            // Main Strike Zone layer setup
            self.StrikeZone.isUserInteractionEnabled = true
            self.StrikeViewWidth = self.StrikeZone.frame.width
            self.StrikeViewHeight = self.StrikeZone.frame.height
            self.StrikeZone.layer.borderColor = self.enterButtonsColor.cgColor
            self.StrikeZone.layer.borderWidth = 2
            self.StrikeZone.layer.cornerRadius = 8
            self.StrikeZone.backgroundColor = UIColor(red: 0.7765, green: 0.7765, blue: 0.7765, alpha: 1.0)
            
            
            
            // Set up real Strike Zone bounds
            let zoneWidth = self.StrikeViewWidth/(2.2)
            let zoneHeight = zoneWidth*self.strikeZoneRatio
            self.strikeZoneImage = UIImageView()
            self.strikeZoneImage.frame = CGRect(x: self.StrikeZone.frame.origin.x + (self.StrikeViewWidth-zoneWidth)/2, y: self.StrikeZone.frame.origin.y + (self.StrikeViewHeight-zoneHeight)/2, width: zoneWidth, height: zoneHeight)
            self.strikeZoneImage.layer.borderWidth = 2
            self.strikeZoneImage.layer.borderColor = UIColor.black.cgColor
            self.strikeZoneImage.backgroundColor = UIColor.white
            self.view.addSubview(self.strikeZoneImage)
            
            // Initialize ball image
            self.ballImage = UIImageView()
            self.ballImage.frame = CGRect(x: self.StrikeZone.frame.origin.x + self.StrikeViewWidth/2, y: self.StrikeZone.frame.origin.y + self.StrikeViewHeight/2, width: self.ballSize, height: self.ballSize)
            self.ballImage.image = UIImage.circle(hollow: false, diameter: self.ballSize, color: UIColor.black)
            self.view.addSubview(self.ballImage)
            self.ballImage.isHidden = true;
        }
        
        
    }
    
    func makeStandardButton(button: UIButton, title: String) -> UIButton{
        button.layer.cornerRadius = 0.5 * button.bounds.size.width
        button.clipsToBounds = true
        button.setTitle(title, for: .normal)
        button.titleLabel?.adjustsFontSizeToFitWidth = true;
        button.titleLabel?.textAlignment = .center;
        button.titleLabel?.numberOfLines = 0;
        button.titleLabel?.minimumScaleFactor = 0.5;
        button.layer.borderWidth = 1
        return button
    }
    
    @objc func newAB(sender:UIButton){
        if currentABPitches == 0{
            return
        }
        let abPopup = UIAlertController(title: "Batter Details", message: "Is the batter left or right handed", preferredStyle: .actionSheet)
        
        
        let lefty = UIAlertAction(title: "Left", style: .default, handler: {
            alert -> Void in
            self.sendNewAB(side: "L")
        })
        let righty = UIAlertAction(title: "Right", style: .default, handler: {
            alert -> Void in
            self.sendNewAB(side: "R")
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: {
            (action : UIAlertAction!) -> Void in
            
        })
        
        abPopup.addAction(lefty)
        abPopup.addAction(righty)
        abPopup.addAction(cancelAction)
        
        self.present(abPopup, animated: true, completion: nil)
        
        
        
    }
    
    func sendNewAB(side: String){
        
        let data = "b_id=\(bullpenID)&batter_side=\(side)"
        ServerConnector.runScript(scriptName: "AddAtBat.php", data: data){ response in
            if response == "null"{
                self.abID = 0
            }else{
                self.abID = Int(response!)!
            }
            self.currentABPitches = 0
            self.updateABLabel()
            DispatchQueue.main.async{
                self.newABButton.backgroundColor = self.backgroundColor
                self.newABButton.setTitleColor(UIColor.lightGray, for: .normal)
                for pb in self.permBalls{
                    pb.image = UIImage.circle(hollow: false, diameter: self.ballSize, color: UIColor.lightGray)
                }
            }
        }
    }
    
    func updateABLabel(){
        DispatchQueue.main.async {
            if self.currentABPitches == 1{
                self.abLabel.text = "Current At Bat: \(self.currentABPitches) pitch"
            }else{
                self.abLabel.text = "Current At Bat: \(self.currentABPitches) pitches"
            }
        }
        
        
    }
    
    @objc func enterPitch(sender:UIButton){
        DispatchQueue.main.async {
            self.enterButton.backgroundColor = self.enterButtonsColorPressed
        }
        
        let pitch = selectedPitch
        var strike = ""
        for b in strikeButtons{
            if b.isSelected{
                strike = b.title(for: .normal)!
                b.isSelected = false
                b.backgroundColor = ballStrikeHighlight
                b.setTitleColor(ballStrikeColor, for: .normal)
            }
        }
        
        if (pitch == "" || strike == ""){
            statusLabel.text = "Invalid entry, try again"
            enterButton.backgroundColor = enterButtonsColor
            return
        }
        
        self.statusLabel.text = "Sending..."
        let vel = velField.text
        var resultCode:String
        switch selectedResult{
        case "None":
            resultCode = "N/A"
            break
        case "Swing and miss":
            resultCode = "SM"
            break
        case "Strike taken":
            resultCode = "ST"
            break
        case "Swinging strikeout":
            resultCode = "SS"
            break
        case "Looking strikeout":
            resultCode = "LS"
            break
        default:
            resultCode = "N/A"
        }
        if BallLocation != nil{
            createPermanentBall(location: BallLocation!)
        }
        
        var s = strike
        if s=="Strike"{
            s = "S"
        }else if s=="Ball"{
            s = "B"
        }else if s=="Y"{
            s = "X"
        }
        
        if BTHelper.offlineMode{
            
            var offlinePitch = ["pitch_type": pitch, "ball_strike": strike, "vel": vel!, "result":resultCode, "hard_contact": hardContact] as [String : Any]
            if BallLocation != nil && !ballImage.isHidden{
                let loc : CGPoint = getTranslatedLocation(viewLocation: BallLocation!)
                offlinePitch["pitchX"] =  loc.x
                offlinePitch["pitchY"] =  loc.y
            }
            OfflinePitchData.append(offlinePitch)
            self.totalPitches += 1
            self.pitchCountLabel.text = "Total: \(self.totalPitches)"
            self.statusLabel.text = "Last pitch: \(pitch), \(strike)"
            if self.competitivePen{
                self.statusLabel.text?.append(", \(resultCode)")
                self.pitchPicker.selectRow(0, inComponent: 1, animated:false)
            }
            self.enterButton.backgroundColor = self.enterButtonsColor
        }else{
            addPitch(pitch: pitch, strike: strike, vel: vel!, result: resultCode, hard_contact: hardContact){ success in
                DispatchQueue.main.async {
                    if success{
                        self.totalPitches += 1
                        self.pitchCountLabel.text = "Total: \(self.totalPitches)"
                        self.statusLabel.text = "Last pitch: \(pitch), \(strike)"
                        if self.competitivePen{
                            self.statusLabel.text?.append(", \(resultCode)")
                            self.pitchPicker.selectRow(0, inComponent: 1, animated:false)
                        }
                    }else{
                        self.statusLabel.text = "Trouble connecting to database, try again"
                    }
                    self.enterButton.backgroundColor = self.enterButtonsColor
                }
            }
        }
        
        
        velField.text = ""
        if hardContact{
            toggleHardContact()
        }
        currentABPitches += 1
        updateABLabel()
        newABButton.backgroundColor = enterButtonsColor
        newABButton.setTitleColor(backgroundColor, for: .normal)
    }
    
    
    func addPitch(pitch: String, strike: String, vel: String, result: String, hard_contact: Bool, completion: @escaping (Bool) -> ()){
        
        var data = "bullpen_id=\(bullpenID)&pitch_type=\(pitch)&ball_strike=\(strike)&vel=\(vel)&result=\(result)"
        
        var hc : Int? = nil
        if competitivePen{
            hc = hard_contact ? 1 : 0
            data.append("&hard_contact=\(String(describing: hc))")
        }
        var pitchLocation : PitchLocation? = nil
        if BallLocation != nil && !ballImage.isHidden{
            let loc : CGPoint = getTranslatedLocation(viewLocation: BallLocation!)
            data.append("&pitchX=\(loc.x)&pitchY=\(loc.y)")
            pitchLocation = PitchLocation(x: loc.x, y: loc.y, catcherView: true)
        }
        
        var newPitch = Pitch(pitchType: pitch, ballStrike: strike, vel: Float(vel), pitchLocation: pitchLocation, pitchResult: result, hardContact: hc, atBat: CurrentAtBat, uploadedToServer: false)
        
        
        
        ServerConnector.runScript(scriptName: "AddPitch.php", data: data){ response in
            completion(response != nil)
            if response == nil{
                print("Error running Add Pitch script")
                return
            }
            newPitch.uploadedToServer = true
            let pitch = ServerConnector.extractJSONtoDict((response?.data(using: .utf8))!)
            //let pitch = pitch_list[0] as? NSDictionary
            let last_pitch = pitch["last_id"] as! String
            self.lastPitchID = Int(last_pitch)!
            self.BallLocation = nil
            DispatchQueue.main.async {
                self.ballImage.isHidden = true;
            }
        }
        
        CurrentBullpen?.pitchList?.append(newPitch)
        
        
    }
    
    
    @objc func pressUndoPitch(){
        undoButton.backgroundColor = enterButtonsColorPressed
        self.statusLabel.text = "Removing last pitch"
        if totalPitches == 0{
            self.statusLabel.text = "No pitches to remove"
            undoButton.backgroundColor = enterButtonsColor
            return
        }
        
        undoPitch(){ success in
            DispatchQueue.main.async {
                if success{
                    self.statusLabel.text = "Sucessfully removed last pitch"
                    self.totalPitches -= 1
                    self.pitchCountLabel.text = "Total: " + String(self.totalPitches)
                    self.currentABPitches -= 1
                    self.updateABLabel()
                    
                    self.permBalls[self.permBalls.count-1].removeFromSuperview()
                    self.permBalls.removeLast()
                    
                }else{
                    self.statusLabel.text = "Failed to remove previous pitch"
                }
            }
        }
        undoButton.backgroundColor = enterButtonsColor
    }
    
    
    func undoPitch(completion: @escaping (Bool) -> ()){
        let _ = CurrentBullpen?.pitchList?.popLast()
        if BTHelper.offlineMode{
            let _ = OfflinePitchData.popLast()
            completion(true)
        }else{
            let data = "id=\(lastPitchID)&bullpen_id=\(bullpenID)"
            ServerConnector.runScript(scriptName: "RemovePitch.php", data: data){ response in
                completion(response != nil)
            }
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
            self.sendToSummaryVC(CurrentBullpen: self.CurrentBullpen!, CurrentPitcher: self.CurrentPitcher!)
        }else{
            if new{
                self.performSegue(withIdentifier: "unwindToBullpens", sender: self)
            }else{
                self.performSegue(withIdentifier: "unwindToSummary", sender: self)
            }
            
        }
        
    }
    
    func makeData(completion: @escaping (Bool) -> ()){
        let data = "bullpen_id=\(CurrentBullpen!.id!)"
        ServerConnector.runScript(scriptName: "get_stats.php", data: data){ response in
            completion(response != nil)
        }
    }
    
    // The number of columns of data
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        if competitivePen{
            return pitches.count
        }else{
            return 1
        }
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
        dismissKeyboard()
        if component == 0{
            selectedPitch = pitches[component][row]
            var color = UIColor.black
            if let c = BTHelper.PitchTypeColors[selectedPitch]{
                color = c
            }
            ballImage.image = UIImage.circle(hollow: false, diameter: ballSize, color: color)
            
        }else{
            selectedResult = pitches[1][row]
        }
        
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches , with:event)
        if let touch = touches.first {
            let loc = touch.location(in: StrikeZone)
            if loc.x < 0 || loc.x > StrikeViewWidth || loc.y < 0 || loc.y > StrikeViewHeight {
                controllingBall = false
                return
            }else{
                controllingBall = true
            }
            BallLocation = loc
            showBall(location: BallLocation)
        }
        
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !controllingBall{
            return
        }
        super.touchesMoved(touches, with: event)
        if let touch = touches.first{
            let loc = touch.location(in: StrikeZone)

            var lockX = false
            if loc.x < 0 {
                BallLocation!.x = 0
                lockX = true
            }else if loc.x > StrikeViewWidth{
                BallLocation!.x = StrikeViewWidth
                lockX = true
            }
            var lockY = false
            if loc.y < 0 {
                BallLocation!.y = 0
                lockY = true
            }else if loc.y > StrikeViewHeight{
                BallLocation!.y = StrikeViewHeight
                lockY = true
            }
            if lockX && lockY{
                return
            }
            if BallLocation != nil{
                if !lockX {
                    BallLocation!.x = loc.x
                }
                if !lockY {
                    BallLocation!.y = loc.y
                }
            }
            
            showBall(location: BallLocation)
        }
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        if let touch = touches.first{
//            //let loc = touch.location(in: StrikeZone)
//            controllingBall = false
//            //BallLocation = loc
//            //showBall(location: BallLocation)
//        }
    }
    
    func showBall(location: CGPoint?){
    
        if !controllingBall || location == nil{
            return
        }
        ballImage.isHidden = false;
        var frame = ballImage.frame
        frame.origin.x = StrikeZone.frame.minX + location!.x - frame.width/2
        frame.origin.y = StrikeZone.frame.minY + location!.y - frame.height/2
        ballImage.frame = frame
    }
    
    func createPermanentBall(location: CGPoint){
        
        let permBallImage = UIImageView()
        permBallImage.frame = CGRect(x: StrikeZone.frame.origin.x + location.x - ballSize/2, y: StrikeZone.frame.origin.y + location.y - ballSize/2, width: ballSize, height: ballSize)
        permBallImage.image = UIImage.circle(hollow: false, diameter: ballSize, color: UIColor.gray)
        permBalls.append(permBallImage)
        view.addSubview(permBallImage)
    }
    
    @objc func hardContactPressed(_ sender: UIButton){
        dismissKeyboard()
        toggleHardContact()
    }
    func toggleHardContact(){
        hardContact = !hardContact
        if hardContact{
            hardContactButton.backgroundColor = ballStrikeColor
            hardContactButton.setTitleColor(ballStrikeHighlight, for: .normal)
        }else{
            hardContactButton.backgroundColor = ballStrikeHighlight
            hardContactButton.setTitleColor(ballStrikeColor, for: .normal)
        }
    }
    // Points will be relative to the center of the strike zone at (0, 0). Strike zone top should be at -strikeZoneRatio, left side at -1.0
    func getTranslatedLocation(viewLocation : CGPoint) -> CGPoint{
        let tx = (viewLocation.x - StrikeZone.frame.width/2) / (strikeZoneImage.frame.width/2)
        // Still relative to zone width
        let ty = (viewLocation.y - StrikeZone.frame.height/2) / (strikeZoneImage.frame.width/2)
        return CGPoint(x:tx,y:ty)
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func sendToSummaryVC(CurrentBullpen: Bullpen, CurrentPitcher: Pitcher) {
        let storyboard = UIStoryboard(name: "SummaryView", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "SummaryVC") as! SummaryViewController
        
        if BTHelper.offlineMode{
            vc.OfflinePitchData = self.OfflinePitchData
        }else{
            vc.CurrentBullpen = CurrentBullpen
            vc.CurrentPitcher = CurrentPitcher
        }
        self.present(vc, animated: true, completion: nil)
    }
    
    func sendToBullpens() {
        let storyboard = UIStoryboard(name: "Bullpens", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "BullpensVC") as! BullpenViewController
        vc.CurrentPitcher = CurrentPitcher
        present(vc, animated: true, completion: nil)
        
    }
    
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension UIImage {
    class func circle(hollow: Bool, diameter: CGFloat, color: UIColor, withX: Bool = false) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: diameter, height: diameter), false, 0)
        let ctx = UIGraphicsGetCurrentContext()!
        ctx.saveGState()
        let rect = CGRect(x: 0, y: 0, width: diameter, height: diameter)
        ctx.setFillColor(color.cgColor)
        ctx.setStrokeColor(color.cgColor)
        if hollow{
            ctx.setLineWidth(2.0)
            ctx.strokeEllipse(in: rect)
        }else{
            ctx.fillEllipse(in: rect)
            
        }
        if withX{
            let l = diameter/2.0 * CGFloat(cos(Double.pi/4.0))
            ctx.setStrokeColor(UIColor.red.cgColor)
            let p1 = CGPoint(x:  l + diameter/2.0, y: l + diameter/2.0)
            let p2 = CGPoint(x:  -l + diameter/2.0, y: l + diameter/2.0)
            let p3 = CGPoint(x:  l + diameter/2.0, y: -l + diameter/2.0)
            let p4 = CGPoint(x:  -l + diameter/2.0, y: -l + diameter/2.0)
            
            let points = [p1, p4, p2, p3]
            ctx.setLineWidth(2.0)
            ctx.strokeLineSegments(between: points)
        }
        
        
        
        
        ctx.restoreGState()
        let img = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return img
    }
    
    class func triangle(hollow: Bool, diameter: CGFloat, color: UIColor, flipped: Bool) -> UIImage{
        UIGraphicsBeginImageContextWithOptions(CGSize(width: diameter, height: diameter), false, 0)
        let ctx = UIGraphicsGetCurrentContext()!
        ctx.saveGState()
        ctx.setFillColor(color.cgColor)
        ctx.setStrokeColor(color.cgColor)
        
        
        var p1 = CGPoint(x: 0.0, y: sqrt(3.0)/2 * diameter)
        var p2 = CGPoint(x: diameter/2, y: 0.0)
        var p3 = CGPoint(x: diameter, y: sqrt(3.0)/2 * diameter)
        
        if flipped{
            p1 = CGPoint(x: 0.0, y: 0.0)
            p2 = CGPoint(x: diameter/2, y: sqrt(3.0)/2 * diameter)
            p3 = CGPoint(x: diameter, y: 0)
        }
        let points = [p1, p2, p2, p3, p3, p1]
        
        if hollow{
            ctx.setLineWidth(2.0)
            ctx.strokeLineSegments(between: points)
        }else{
            ctx.beginPath()
            ctx.addLines(between: points)
            ctx.fillPath()
            ctx.closePath()
        }
        ctx.restoreGState()
        let img = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return img
    }
    
}


