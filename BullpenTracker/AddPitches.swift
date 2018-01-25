//
//  AddPitches.swift
//  BullpenTracker
//
//  Created by Sam Hollenbach on 8/27/17.
//  Copyright © 2017 Sam Hollenbach. All rights reserved.
//

import UIKit

class AddPitches: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource{
    
    var bullpenData = [Any]()
    var competitivePen = false
    
    
    @IBOutlet weak var hardContactButton: UIButton!
    
    @IBOutlet weak var atBatPicker: UIPickerView!
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
    
    @IBOutlet weak var StrikeZone: UIImageView!
    var ballImage: UIImageView!
    var strikeZoneImage: UIImageView!
    
    var bullpenID = -1
    var pitches: [[String]] = [[String]]()
    
    var add_success = false
    var newABButton = UIButton(type: .custom)
    var enterButton = UIButton(type: .custom)
    var undoButton = UIButton(type: .custom)
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
    let ballSize : CGFloat = 8
    
    var StrikeViewWidth : CGFloat = 0.0
    var StrikeViewHeight : CGFloat = 0.0
    let strikeZoneRatio : CGFloat = 1.5
    var showPitchHistory = true
    var hardContact = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.pitchPicker.delegate = self
        self.pitchPicker.dataSource = self

        competitivePen = bullpenData[1] as! Bool
        bullpenID = bullpenData[0] as! Int
        
        
        pitches = [["FB", "CH", "CR", "SL", "X"], ["None", "Swing and miss", "Strike taken", "Swinging strikout", "Looking strikeout"]]
        selectedPitch = pitches[0][0]
        selectedResult = pitches[1][0]
        totalPitches = bullpenData[5] as! Int
        
        navBar.frame = CGRect(x: 0, y: 20, width: (navBar.frame.size.width), height: (navBar.frame.size.height)+UIApplication.shared.statusBarFrame.height)
        addButtons()
        // Do any additional setup after loading the view.
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(AddPitcherViewController.dismissKeyboard))
        
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        //tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        
        makeStrikeZone()
    }
    
    func makeStrikeZone(){
        
        
        StrikeZone.isUserInteractionEnabled = true
        StrikeViewWidth = StrikeZone.frame.width
        StrikeViewHeight = StrikeZone.frame.height
        
        if !competitivePen{
            var f = StrikeZone.frame
            f.origin.x = (self.view.frame.width-StrikeViewWidth)/2
            StrikeZone.frame = f
        }
        
        let zoneWidth = StrikeViewWidth/(2.2)
        let zoneHeight = zoneWidth*strikeZoneRatio
        
        strikeZoneImage = UIImageView()
        strikeZoneImage.frame = CGRect(x: StrikeZone.frame.origin.x + (StrikeViewWidth-zoneWidth)/2, y: StrikeZone.frame.origin.y + (StrikeViewHeight-zoneHeight)/2, width: zoneWidth, height: zoneHeight)
        strikeZoneImage.layer.borderWidth = 2
        strikeZoneImage.layer.borderColor = UIColor.black.cgColor
        view.addSubview(strikeZoneImage)
        
        ballImage = UIImageView()
        ballImage.frame = CGRect(x: StrikeZone.frame.origin.x + StrikeViewWidth/2, y: StrikeZone.frame.origin.y + StrikeViewHeight/2, width: ballSize, height: ballSize)
        ballImage.image = UIImage.circle(diameter: ballSize, color: UIColor.red)
        view.addSubview(ballImage)
    }
    
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    

    
    func addButtons(){
        let w = self.view.frame.size.width
        let h = self.view.frame.size.height
        
        statusLabel.text = "Enter a pitch"
        statusLabel.textAlignment = .left
        statusLabel.font = UIFont.boldSystemFont(ofSize: 18.0)
        view.addSubview(statusLabel)
        
        pitchCountLabel.text = "Total: " + String(totalPitches)
        pitchCountLabel.textAlignment = .right
        pitchCountLabel.font = UIFont.boldSystemFont(ofSize: 18.0)
        view.addSubview(pitchCountLabel)
        
    
        var bsButtons: [String]
        
        if competitivePen{
            bsButtons = ["N", "Y"]
            pitchResultLabel.isHidden = false
            
            
            let nbwidth : CGFloat = 75
            newABButton.frame = CGRect(x: 10 , y: h-nbwidth-10, width: nbwidth, height: nbwidth)
            newABButton = makeStandardButton(button: newABButton, title: "Finish At Bat")
            newABButton.backgroundColor = enterButtonsColor
            newABButton.setTitleColor(UIColor.white, for: .normal)
            //newABButton.addTarget(self, action: #selector(enterPitch), for: .touchUpInside)
            view.addSubview(newABButton)
            
            hardContactButton = makeStandardButton(button: hardContactButton, title: "Hard Contact?")
            hardContactButton.layer.borderColor = ballStrikeColor.cgColor
            hardContactButton.backgroundColor = ballStrikeHighlight
            hardContactButton.setTitleColor(ballStrikeColor, for: .normal)
            hardContactButton.addTarget(self, action: #selector(hardContactPressed), for: .touchUpInside)
            view.addSubview(hardContactButton)
            
        }else{
            bsButtons = ["Ball", "Strike"]
            executedLabel.isHidden = true
            pitchResultLabel.isHidden = true
            hardContactButton.isHidden = true
            var frame : CGRect = pitchTypeLabel.frame
            frame.origin.x = (w-frame.width)/2
            pitchTypeLabel.frame = frame;
        }
        // EXECUTED BUTTONS
        for (index, pitch) in bsButtons.enumerated(){
            
            let size: CGFloat = 65
            let t = w - (size + 10) * (CGFloat(index+1))
            
            var button = UIButton(type: .custom)
            button.frame = CGRect(x: t, y: (pitchPicker.frame.origin.y + pitchPicker.frame.height - 5), width: size, height: size)
            button.tag = index
            button = makeStandardButton(button: button, title: pitch)
            button.layer.borderColor = ballStrikeColor.cgColor
            button.backgroundColor = ballStrikeHighlight
            button.setTitleColor(ballStrikeColor, for: .normal)
            button.addTarget(self, action: #selector(strikeButtonPressed), for: .touchUpInside)
            strikeButtons.append(button)
            view.addSubview(button)
            
        }
        
        velField.keyboardType = .numberPad
        velField.placeholder = "velo"
        velField.backgroundColor = UIColor.white
        velField.layer.borderWidth = 1
        velField.layer.borderColor = enterButtonsColor.cgColor
        velField.textAlignment = .center
        velField.layer.cornerRadius = 7
        view.addSubview(velField)
        
        let ebwidth : CGFloat = 75
        enterButton.frame = CGRect(x: w-ebwidth-10 , y: h-ebwidth-10, width: ebwidth, height: ebwidth)
        enterButton = makeStandardButton(button: enterButton, title: "Enter")
        enterButton.backgroundColor = enterButtonsColor
        enterButton.setTitleColor(UIColor.white, for: .normal)
        enterButton.addTarget(self, action: #selector(enterPitch), for: .touchUpInside)
        view.addSubview(enterButton)
        
        let ubwidth : CGFloat = 35
        undoButton.frame = CGRect(x: (w-ubwidth)/2, y: h-ubwidth-10, width: ubwidth, height: ubwidth)
        undoButton = makeStandardButton(button: undoButton, title: "undo")
        undoButton.backgroundColor = enterButtonsColor
        
        let undoImage: UIImage? = UIImage(named: "Undo")?.withRenderingMode(.alwaysTemplate)
        
        
        
        undoButton.setImage(undoImage, for: .normal)
        undoButton.imageView?.tintColor = UIColor.white
        //undoButton.setTitleColor(UIColor.white, for: .normal)
        undoButton.addTarget(self, action: #selector(pressUndoPitch), for: .touchUpInside)
        view.addSubview(undoButton)
        
        StrikeZone.layer.borderColor = enterButtonsColor.cgColor
        StrikeZone.layer.borderWidth = 2
        
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
        let pitch = selectedPitch
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
        var resultCode:String
        switch selectedResult{
        case "None":
            resultCode = "NA"
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
            resultCode = "NA"
        }
        if BallLocation != nil{
            createPermanentBall(location: BallLocation!)
            
        }
        
        
        addPitch(pitch: pitch, strike: strike, vel: vel!, result: resultCode){ success in
            DispatchQueue.main.async {
                if success{
                    self.totalPitches += 1
                    self.pitchCountLabel.text = "Total: " + String(self.totalPitches)
                    self.statusLabel.text = "Last pitch: \(pitch), \(strike)"
                    if self.competitivePen{
                         self.statusLabel.text?.append(", \(resultCode)")
                    }
                    
                }else{
                    self.statusLabel.text = "Trouble connecting to database, try again"
                }
                self.enterButton.backgroundColor = self.enterButtonsColor
            }
            
            
        }
        velField.text = ""
        
        
        
    }
    
    
    func addPitch(pitch: String, strike: String, vel: String, result: String, completion: @escaping (Bool) -> ()){
        var s = strike
        if s=="Strike"{
            s = "S"
        }else if s=="Ball"{
            s = "B"
        }
        
        
        var data = "bullpen_id=\(bullpenID)&pitch_type=\(pitch)&ball_strike=\(s)&vel=\(vel)&result=\(result)"
    
        if BallLocation != nil{
            let loc : CGPoint = getTranslatedLocation(viewLocation: BallLocation!)
            print(loc.x, loc.y)
            data.append("&pitchX=\(loc.x)&pitchY=\(loc.y)")
            BallLocation = nil
        }
        
        
        
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
                    self.sendToSummaryVC(bullpenData: self.bullpenData)
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
    
    func sendToSummaryVC(bullpenData: [Any]) {
        let storyboard = UIStoryboard(name: "SummaryView", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "SummaryVC") as! SummaryViewController
        vc.bullpenData = bullpenData
        self.present(vc, animated: true, completion: nil)
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
        if component == 0{
             selectedPitch = pitches[component][row]
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
            showBall(location: BallLocation, color: UIColor.red)
        }
        
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !controllingBall{
            return
        }
        super.touchesMoved(touches, with: event)
        if let touch = touches.first{
            let loc = touch.location(in: StrikeZone)
            if loc.x < 0 || loc.x > StrikeViewWidth || loc.y < 0 || loc.y > StrikeViewHeight {
                controllingBall = false
                return
            }else{
                controllingBall = true
            }
            
            var lockX = false
            if loc.x < 0 || loc.x > StrikeViewWidth  {
                lockX = true
            }
            var lockY = false
            if loc.y < 0 || loc.y > StrikeViewHeight {
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
            
            showBall(location: BallLocation, color: UIColor.red)
        }
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first{
            let loc = touch.location(in: StrikeZone)
            controllingBall = false
            BallLocation = loc
            showBall(location: BallLocation, color: UIColor.red)
        }
    }
    
    func showBall(location: CGPoint?, color: UIColor){
    
        if !controllingBall || location == nil{
            return
        }
        var frame = ballImage.frame
        frame.origin.x = StrikeZone.frame.minX + location!.x - frame.width/2
        frame.origin.y = StrikeZone.frame.minY + location!.y - frame.height/2
        ballImage.frame = frame
    }
    
    func createPermanentBall(location: CGPoint){
        
        let permBallImage = UIImageView()
        permBallImage.frame = CGRect(x: StrikeZone.frame.origin.x + location.x - ballSize/2, y: StrikeZone.frame.origin.y + location.y - ballSize/2, width: ballSize, height: ballSize)
        permBallImage.image = UIImage.circle(diameter: ballSize, color: UIColor.gray)
        view.addSubview(permBallImage)
    }
    
    @objc func hardContactPressed(_ sender: UIButton){
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
        print(tx,ty)
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

}

extension UIImage {
    class func circle(diameter: CGFloat, color: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: diameter, height: diameter), false, 0)
        let ctx = UIGraphicsGetCurrentContext()!
        ctx.saveGState()
        
        let rect = CGRect(x: 0, y: 0, width: diameter, height: diameter)
        ctx.setFillColor(color.cgColor)
        ctx.fillEllipse(in: rect)
        
        ctx.restoreGState()
        let img = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return img
    }
}
