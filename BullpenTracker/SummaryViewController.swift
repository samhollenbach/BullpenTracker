//
//  SummaryViewController.swift
//  BullpenTracker
//
//  Created by Sam Hollenbach on 8/28/17.
//  Copyright © 2017 Sam Hollenbach. All rights reserved.
//

import UIKit

class SummaryViewController: UIViewController, UIPopoverPresentationControllerDelegate {

    var CurrentBullpen : Bullpen?
    var CurrentPitcher : Pitcher?
    
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var StrikeZone: UIImageView!
    @IBOutlet weak var emailStatusLabel: UILabel!
    var graph: UIImage? = nil
    
    @IBOutlet weak var fLabel: UILabel!
    @IBOutlet weak var sLabel: UILabel!
    @IBOutlet weak var bLabel: UILabel!
    @IBOutlet weak var xLabel: UILabel!
    @IBOutlet weak var twoLabel: UILabel!
    @IBOutlet weak var cLabel: UILabel!
    @IBOutlet weak var loadingLabel: UILabel!
    @IBOutlet weak var executedLabel: UILabel!
    @IBOutlet weak var notExecutedLabel: UILabel!
    @IBOutlet weak var showVelocitiesLabel: UILabel!
    
    @IBOutlet weak var strikeRefImage: UIImageView!
    @IBOutlet weak var ballRefImage: UIImageView!
    
    @IBOutlet weak var pitcherNameLabel: UILabel!
    @IBOutlet weak var bullpenTypeLabel: UILabel!
    @IBOutlet weak var pitchCountLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    var pitch_list: [UIImageView] = []
    var pitch_data: [[String:Any]] = []
    var pitch_labels : [UILabel] = []
    
    let ballSize : CGFloat = 15
    var ballImage: UIImageView!
    var strikeZoneImage: UIImageView!
    var StrikeViewWidth : CGFloat = 0.0
    var StrikeViewHeight : CGFloat = 0.0
    let strikeZoneRatio : CGFloat = 1.5
    var showPitchHistory = true
    let mainColor = UIColor(red:0.23, green:0.32, blue:0.56, alpha:1.0)
    
    var remakeZone = true
    var showingPitches: [String] = []
    var selectedExecuted = false
    var selectedNotExecuted = false
    var showPitchLabels = false
    
    @IBOutlet weak var emailButton: UIButton!
    @IBOutlet weak var addPitchesButton: UIButton!
    
    var OfflinePitchData : [[String: Any?]] = []
    let backgroundColor = UIColor.white
    
    struct defaultsKeys {
        static let lastEmail = "lastEmail"
        static let keyTwo = "secondStringKey"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 11.0, *) {
            //self.additionalSafeAreaInsets.top = 20
        }
        navBar.sizeToFit()
        
        if CurrentPitcher != nil{
            pitcherNameLabel.text = CurrentPitcher!.fullName() ?? "Error loading name"
        }else{
            pitcherNameLabel.text = "Error loading name"
        }
        
        
        if CurrentBullpen != nil{
            bullpenTypeLabel.text = CurrentBullpen!.penTypeDisplay!
            let originalDate =  CurrentBullpen!.date
            var date = ""
            if originalDate != nil && originalDate != "" {
                date = BullpenViewController.formatDate(originalDate: originalDate!, originalFormat: "yyyy-MM-dd", newFormat: "MM/dd/yyyy")
            }
            dateLabel.text = date
            pitchCountLabel.text = "Loading..."
            CurrentBullpen!.pitchList = []
            
        }else{
            bullpenTypeLabel.text = "Error"
        }
        
        DispatchQueue.main.async {
            self.addButtons()
            self.makeGestures()
        }
    }
    
    func updatePitchCount(){
        let pc = CurrentBullpen!.pitchList != nil ? CurrentBullpen!.pitchList!.count : 0
        if pc == 1{
            pitchCountLabel.text = "1 pitch"
        }else{
            pitchCountLabel.text = "\(pc) pitches"
        }
    }
    
    override func viewDidLayoutSubviews() {
        if remakeZone{
            makeStrikeZone()
            remakeZone = false
        }
    }
    
    func makeGestures(){
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        //tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        let labCornerRad : CGFloat = 8
        let tapPitchesGesture1 = UITapGestureRecognizer(target: self, action: #selector(SummaryViewController.tapPitches))
        fLabel.tag = 1
        fLabel.isUserInteractionEnabled = true
        fLabel.layer.cornerRadius = labCornerRad
        fLabel.addGestureRecognizer(tapPitchesGesture1)
        let tapPitchesGesture2 = UITapGestureRecognizer(target: self, action: #selector(SummaryViewController.tapPitches))
        sLabel.tag = 2
        sLabel.isUserInteractionEnabled = true
        sLabel.layer.cornerRadius = labCornerRad
        sLabel.addGestureRecognizer(tapPitchesGesture2)
        let tapPitchesGesture3 = UITapGestureRecognizer(target: self, action: #selector(SummaryViewController.tapPitches))
        bLabel.tag = 3
        bLabel.isUserInteractionEnabled = true
        bLabel.layer.cornerRadius = labCornerRad
        bLabel.addGestureRecognizer(tapPitchesGesture3)
        let tapPitchesGesture4 = UITapGestureRecognizer(target: self, action: #selector(SummaryViewController.tapPitches))
        xLabel.tag = 4
        xLabel.isUserInteractionEnabled = true
        xLabel.layer.cornerRadius = labCornerRad
        xLabel.addGestureRecognizer(tapPitchesGesture4)
        let tapPitchesGesture5 = UITapGestureRecognizer(target: self, action: #selector(SummaryViewController.tapPitches))
        twoLabel.tag = 5
        twoLabel.isUserInteractionEnabled = true
        twoLabel.layer.cornerRadius = labCornerRad
        twoLabel.addGestureRecognizer(tapPitchesGesture5)
        let tapPitchesGesture6 = UITapGestureRecognizer(target: self, action: #selector(SummaryViewController.tapPitches))
        cLabel.tag = 6
        cLabel.layer.cornerRadius = labCornerRad
        cLabel.isUserInteractionEnabled = true
        cLabel.addGestureRecognizer(tapPitchesGesture6)
        
        let tapExecutedGesture1 = UITapGestureRecognizer(target: self, action: #selector(SummaryViewController.tapExecuted))
        executedLabel.tag = 1
        executedLabel.layer.cornerRadius = labCornerRad
        executedLabel.isUserInteractionEnabled = true
        executedLabel.addGestureRecognizer(tapExecutedGesture1)
        
        let tapExecutedGesture2 = UITapGestureRecognizer(target: self, action: #selector(SummaryViewController.tapExecuted))
        notExecutedLabel.tag = 2
        notExecutedLabel.layer.cornerRadius = labCornerRad
        notExecutedLabel.isUserInteractionEnabled = true
        notExecutedLabel.addGestureRecognizer(tapExecutedGesture2)
        
        let tapShowVelocitiesGesture = UITapGestureRecognizer(target: self, action: #selector(SummaryViewController.tapShowVelocities))
        showVelocitiesLabel.tag = 2
        showVelocitiesLabel.layer.cornerRadius = labCornerRad
        showVelocitiesLabel.isUserInteractionEnabled = true
        showVelocitiesLabel.addGestureRecognizer(tapShowVelocitiesGesture)
    }
    @objc func tapShowVelocities(sender: UITapGestureRecognizer){
        showPitchLabels = !showPitchLabels
        if showPitchLabels{
            showVelocitiesLabel.backgroundColor = UIColor.lightGray
        }else{
            showVelocitiesLabel.backgroundColor = UIColor.white
        }
        showVelocities()
    }
    
    func showVelocities(){
        if showPitchLabels{
            for i in 0..<pitch_labels.count{
                let pitchImg = pitch_data[i]["ballImg"] as! UIImageView
                if pitchImg.isHidden {
                    pitch_labels[i].isHidden = true
                }else{
                    pitch_labels[i].isHidden = false
                }
            }
        }else{
            
            for v in pitch_labels{
                v.isHidden = true
            }
        }
    }
    
    @objc func tapExecuted(sender: UITapGestureRecognizer){
        let t = sender.view!.tag
        if t == 1{
            if selectedExecuted{
                selectedExecuted = false
                executedLabel.backgroundColor = backgroundColor
            }else{
                selectedExecuted = true
                executedLabel.backgroundColor = UIColor.lightGray
            }
        }else if t == 2{
            if selectedNotExecuted{
                selectedNotExecuted = false
                notExecutedLabel.backgroundColor = backgroundColor
            }else{
                selectedNotExecuted = true
                notExecutedLabel.backgroundColor = UIColor.lightGray
            }
        }
        
        showOnlyPitches()
    }
    
    
    @objc func tapPitches(sender: UITapGestureRecognizer){
        let l = sender.view! as! UILabel
        if showingPitches.contains(l.text!){
            showingPitches.remove(at: showingPitches.index(of: l.text!)!)
            l.backgroundColor = backgroundColor
        }else{
            showingPitches.append(l.text!)
            l.backgroundColor = UIColor.lightGray
        }
        showOnlyPitches()
    }

    
    func showOnlyPitches(){
        for p in pitch_data{
            if ((!selectedExecuted && !selectedNotExecuted) || (selectedExecuted && (p["bs"] as! String == "S" || p["bs"] as! String == "X")) || (selectedNotExecuted && (p["bs"] as! String == "B" || p["bs"]  as! String == "N"))) && (showingPitches.contains(p["type"] as! String) || showingPitches.isEmpty){
                (p["ballImg"] as! UIImageView).isHidden = false
            }else{
                (p["ballImg"] as! UIImageView).isHidden = true
            }
        }
        showVelocities()
        
    }
    
    func addButtons(){
        
        emailButton.layer.cornerRadius = 0.5 * emailButton.bounds.size.width
        emailButton.clipsToBounds = true
        emailButton.setTitle("Email Stats", for: .normal)
        emailButton.layer.borderWidth = 1
        emailButton.layer.borderColor = UIColor.black.cgColor
        emailButton.backgroundColor = backgroundColor
        emailButton.setTitleColor(UIColor.black, for: .normal)
        emailButton.addTarget(self, action: #selector(pressEmailBullpen), for: .touchUpInside)
        
        addPitchesButton.layer.cornerRadius = 0.5 * addPitchesButton.bounds.size.width
        addPitchesButton.clipsToBounds = true
        addPitchesButton.layer.borderWidth = 1
        addPitchesButton.layer.borderColor = UIColor.black.cgColor
        addPitchesButton.setTitle("Add Pitches", for: .normal)
        addPitchesButton.backgroundColor = backgroundColor
        addPitchesButton.setTitleColor(UIColor.black, for: .normal)
        addPitchesButton.addTarget(self, action: #selector(addPitches), for: .touchUpInside)
        
        fLabel.textColor = BTHelper.PitchTypeColors["F"]
        sLabel.textColor = BTHelper.PitchTypeColors["S"]
        bLabel.textColor = BTHelper.PitchTypeColors["B"]
        xLabel.textColor = BTHelper.PitchTypeColors["X"]
        twoLabel.textColor = BTHelper.PitchTypeColors["2"]
        cLabel.textColor = BTHelper.PitchTypeColors["C"]
        
        strikeRefImage.image = UIImage.circle(hollow: false, diameter: ballSize, color: UIColor.black)
        ballRefImage.image = UIImage.circle(hollow: true, diameter: ballSize, color: UIColor.black)
        
        
    }
    
    func makeStrikeZone(){
        DispatchQueue.main.async {
            self.loadingLabel.isHidden = true
            // Main Strike Zone layer setup
            self.StrikeZone.isUserInteractionEnabled = true
            self.StrikeViewWidth = self.StrikeZone.frame.width
            self.StrikeViewHeight = self.StrikeZone.frame.height
            self.StrikeZone.layer.borderColor = self.mainColor.cgColor
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
            
        }
        
        DispatchQueue.main.async{
            self.fillStrikeZone()
        }
        
    }
    
    func fillStrikeZoneOffline(){
        for op in OfflinePitchData{
            if let px = op["pitchX"] as? CGFloat, let py = op["pitchY"] as? CGFloat{
                let type = op["pitch_type"] as! String
                var color = UIColor.black
                if let c = BTHelper.PitchTypeColors[type]{
                    color = c
                }
                
                let bs = op["ball_strike"] as! String
                
                var h = false
                if bs == "B" || bs == "N"{
                    h = true
                }
                
                var hc = op["hard_contact"] as? Bool
                var pr = op["pitch_result"] as? String
                var vel = op["vel"] as? String
                if hc == nil{
                    hc = false
                }
                var pr_b = true
                if pr == nil{
                    pr = "N/A"
                }
                if pr == "N/A"{
                    pr_b = false
                }
                var flipped = false
                if (pr == "LS" || pr == "SS"){
                    flipped = true
                }
                
                if vel == nil{
                    vel = "0"
                }
            
                DispatchQueue.main.async {
                    let loc = self.getTranslatedLocation(pitchLocation: CGPoint(x: px, y: py))
                    let ballImg = self.createPermanentBall(location: loc, color: color, hollow: h, pitchHasResult: pr_b, hardContact: hc!, flippedTriangle: flipped)
                    let pData = ["type":type, "bs": bs, "vel":vel!, "px":px, "py":py, "hardContact":hc!, "pitchResult":pr!, "ballImg":ballImg] as [String:Any]
                    self.pitch_data.append(pData)
                    
                    let pLabel = UILabel()
                    var plframe = ballImg.frame
                    plframe.origin.x += self.ballSize + 3
                    pLabel.frame = plframe
                    if (vel != "0"){
                        pLabel.text = vel
                    }else{
                        pLabel.text = ""
                    }
                    
                    pLabel.adjustsFontSizeToFitWidth = true
                    pLabel.isHidden = true
                    self.pitch_labels.append(pLabel)
                    
                    let tapPitchOnZoneGesture = UITapGestureRecognizer(target: self, action: #selector(SummaryViewController.tapPitchOnZone))
                    ballImg.isUserInteractionEnabled = true
                    ballImg.addGestureRecognizer(tapPitchOnZoneGesture)
                    self.view.addSubview(ballImg)
                    self.view.addSubview(pLabel)
                }
            }
            
            
        }
        
        
    }
    
    func fillStrikeZone(){
        if BTHelper.offlineMode{
            fillStrikeZoneOffline()
            return
        }
        let data = "bullpen_id=\(CurrentBullpen!.id!)"
        ServerConnector.runScript(scriptName: "GetBullpenPitches.php", data: data){ response in
            if response == nil{
                print("Could not load pitch data")
                return
            }
            let pitches = ServerConnector.extractJSONtoList(response!.data(using: .utf8)!)
            self.pitch_data = []
            for i in 0 ..< pitches.count {
                let pitch = pitches[i]
                if let type = pitch["pitch_type"] as? String, let px_s = pitch["pitchX"] as? String, let py_s = pitch["pitchY"] as? String, let bs = pitch["ball_strike"] as? String, let vel = pitch["vel"] as? String, let hc = pitch["hard_contact"] as? String, let pr = pitch["result"] as? String {
                    let px = CGFloat((px_s as NSString).floatValue)
                    let py = CGFloat((py_s as NSString).floatValue)
                    
                    var color = UIColor.black
                    if let c = BTHelper.PitchTypeColors[type]{
                        color = c
                    }
                    let h = (bs == "B" || bs == "N")
                    let hc_b = (hc == "1") // hard contact 1 = yes
                    let pr_b = (pr != "N/A") && (pr != "NA") // pitch result exists
                    let flipped = (pr == "LS" || pr == "SS") // pitch result flip icon
                    let pl = PitchLocation(x: px, y: py, catcherView: true)
                    
                    //TODO: read in at bat ID
                    let cp = Pitch(pitchType: type, ballStrike: bs, vel: Float(vel), pitchLocation: pl, pitchResult: pr, hardContact: hc_b ? 1 : 0, atBat: nil, uploadedToServer: true)
                    self.CurrentBullpen?.pitchList?.append(cp)
                    
                    DispatchQueue.main.async {
                        let loc = self.getTranslatedLocation(pitchLocation: CGPoint(x: px, y: py))
                        let ballImg = self.createPermanentBall(location: loc, color: color, hollow: h, pitchHasResult: pr_b, hardContact: hc_b, flippedTriangle: flipped)
                        let pData = ["type":type, "bs": bs, "vel":vel, "px":px, "py":py, "hardContact":hc, "pitchResult":pr, "ballImg":ballImg] as [String:Any]
                        self.pitch_data.append(pData)
                        
                        let pLabel = UILabel()
                        var plframe = ballImg.frame
                        plframe.origin.x += self.ballSize + 3
                        pLabel.frame = plframe
                        if (vel != "0"){
                            pLabel.text = vel
                        }else{
                            pLabel.text = ""
                        }
                        
                        pLabel.adjustsFontSizeToFitWidth = true
                        pLabel.isHidden = true
                        self.pitch_labels.append(pLabel)
                    }
                }
        
            }
            DispatchQueue.main.async{
                for i in 0 ..< self.pitch_data.count{
                    let tapPitchOnZoneGesture = UITapGestureRecognizer(target: self, action: #selector(SummaryViewController.tapPitchOnZone))
                    let p = self.pitch_data[i]
                    let bimg = p["ballImg"] as! UIView
                    bimg.tag = i
                    bimg.isUserInteractionEnabled = true
                    bimg.addGestureRecognizer(tapPitchOnZoneGesture)
                    self.view.addSubview(bimg)
                    self.view.addSubview(self.pitch_labels[i])
                    
                    
                }
            }
            
        }
        
        updatePitchCount()
    }
    
    @objc func tapPitchOnZone(sender: UIGestureRecognizer){
        let p = pitch_data[sender.view!.tag]
        let popController = UIStoryboard(name: "SummaryView", bundle: nil).instantiateViewController(withIdentifier: "PitchPopover")
        popController.modalPresentationStyle = UIModalPresentationStyle.popover
        popController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.up
        popController.popoverPresentationController?.delegate = self as UIPopoverPresentationControllerDelegate
        popController.popoverPresentationController?.sourceView = sender.view
        popController.popoverPresentationController?.sourceRect = sender.view!.bounds
        let vc = popController as! PitchPopoverViewController
        var bsTemp = p["bs"]! as! String
        switch bsTemp{
        case "X":
            bsTemp = "Executed"
            break
        case "Y":
            bsTemp = "Executed"
            break
        case "N":
            bsTemp = "Not Executed"
            break
        case "S":
            bsTemp = "Strike"
            break
        case "B":
            bsTemp = "Ball"
            break
        default:
            bsTemp = "N/A"
            break
    
        }
        vc.ballStrike = bsTemp
        vc.pitchType = p["type"]! as! String
       
        
        var v = p["vel"]! as! String
        if (v == "0"){
            v = "N/A"
        }else{
            v.append(" mph")
        }
        vc.vel = v
        
        var hc = "No"
        if let hc_s = p["hardContact"] as? String{
            if (hc_s == "1"){
                hc = "Yes"
            }else{
                hc = "No"
            }
        }else if let hc_b = p["hardContact"] as? Bool{
            if hc_b{
                hc = "Yes"
            }
        }
        vc.hardContact = hc
        
        var pr = p["pitchResult"] as? String
        pr = BTHelper.PitchResults[pr!]
        if pr == nil{
            pr = "None"
        }
        
        vc.pitchResult = pr!
  
        self.present(popController, animated: true, completion: nil)
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
    
    func createPermanentBall(location: CGPoint, color: UIColor, hollow: Bool, pitchHasResult: Bool, hardContact: Bool, flippedTriangle: Bool = false) -> UIImageView{
        let permBallImage = UIImageView()
        permBallImage.frame = CGRect(x: location.x - ballSize/2, y: location.y - ballSize/2, width: ballSize, height: ballSize)
        if pitchHasResult{
            permBallImage.image = UIImage.triangle(hollow: hollow, diameter: ballSize, color: color, flipped: flippedTriangle)
        }else{
            permBallImage.image = UIImage.circle(hollow: hollow, diameter: ballSize, color: color, withX: hardContact)
        }
        
        return permBallImage
    }
    
    // Points will be relative to the center of the strike zone at (0, 0). Strike zone top should be at -strikeZoneRatio, left side at -1.0
    func getTranslatedLocation(pitchLocation : CGPoint) -> CGPoint{
        let tx = strikeZoneImage.frame.origin.x + strikeZoneImage.frame.width/2 + pitchLocation.x * strikeZoneImage.frame.width/2
        let ty = strikeZoneImage.frame.origin.y + strikeZoneImage.frame.height/2 + pitchLocation.y * strikeZoneImage.frame.width/2
        return CGPoint(x:tx,y:ty)
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
        let data = "bullpen_id=\(CurrentBullpen!.id!)"
        ServerConnector.runScript(scriptName: "RemoveBullpen.php", data: data)
        DispatchQueue.main.async {
            self.doneButtonPressed(self)
        }
    }
    
    @IBAction func unwindToSummary(segue: UIStoryboardSegue) {}
    

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
        
        if BTHelper.offlineMode{
            BTHelper.offlineMode = false
            DispatchQueue.main.async{
                self.performSegue(withIdentifier: "unwindToHomePage", sender: self)
            }
        }else{
            DispatchQueue.main.async{
                self.performSegue(withIdentifier: "unwindToBullpens", sender: self)
            }
        }
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
        let data = "bullpen_id=\(CurrentBullpen!.id!)&email=\(email)"
        ServerConnector.runScript(scriptName: "send_email.php", data: data){ response in
            completion(response != nil)
        }
    }
    
    
    @objc func addPitches(){
        sendToAddPitchesVC(CurrentBullpen: CurrentBullpen! ,CurrentPitcher: CurrentPitcher!)
    }
    
    func sendToAddPitchesVC(CurrentBullpen: Bullpen, CurrentPitcher: Pitcher) {
        let storyboard = UIStoryboard(name: "AddPitches", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "AddPitches") as! AddPitches
        vc.CurrentPitcher = CurrentPitcher
        vc.CurrentBullpen = CurrentBullpen
        vc.new = false
        DispatchQueue.main.async {
            self.present(vc, animated: true, completion: nil)
        }
        
    }
    
    
}
