//
//  SummaryViewController.swift
//  BullpenTracker
//
//  Created by Sam Hollenbach on 8/28/17.
//  Copyright © 2017 Sam Hollenbach. All rights reserved.
//

import UIKit

class SummaryViewController: UIViewController, UIPopoverPresentationControllerDelegate {

    var bullpenData: [Any] = []
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
    static let fColor = UIColor.black
    static let sColor = UIColor.orange
    static let bColor = UIColor.blue
    static let xColor = UIColor.green
    static let twoColor = UIColor.purple
    static let cColor = UIColor.red
    
    var pitch_list: [UIImageView] = []
    var pitch_data: [[String:Any]] = []
    
    let ballSize : CGFloat = 12
    var ballImage: UIImageView!
    var strikeZoneImage: UIImageView!
    var StrikeViewWidth : CGFloat = 0.0
    var StrikeViewHeight : CGFloat = 0.0
    let strikeZoneRatio : CGFloat = 1.5
    var showPitchHistory = true
    let mainColor = UIColor(red:0.23, green:0.32, blue:0.56, alpha:1.0)
    
    var remakeZone = true
    var showingPitches: [String] = []
    
    @IBOutlet weak var emailButton: UIButton!
    @IBOutlet weak var addPitchesButton: UIButton!
    
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
        DispatchQueue.main.async {
            self.addButtons()
            self.makeGestures()
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
        
        let labCornerRad : CGFloat = 10
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
    }
    
    @objc func tapPitches(sender: UITapGestureRecognizer){
        let l = sender.view! as! UILabel
        if showingPitches.contains(l.text!){
            showingPitches.remove(at: showingPitches.index(of: l.text!)!)
            l.backgroundColor = UIColor.white
        }else{
            showingPitches.append(l.text!)
            l.backgroundColor = UIColor.lightGray
        }
        showOnlyPitches()
    }

    
    func showOnlyPitches(){
        for p in pitch_data{
            if showingPitches.contains(p["type"] as! String){
                (p["ballImg"] as! UIImageView).isHidden = false
            }else{
                (p["ballImg"] as! UIImageView).isHidden = true
            }
        }
    }
    
    func addButtons(){
        //let w = self.view.frame.size.width
        //let h = self.view.frame.size.height

        //emailButton.frame = CGRect(x: w/2-125, y: h-150, width: 100, height: 100)
        emailButton.layer.cornerRadius = 0.5 * emailButton.bounds.size.width
        emailButton.clipsToBounds = true
        emailButton.setTitle("Email Stats", for: .normal)
        emailButton.layer.borderWidth = 1
        emailButton.layer.borderColor = UIColor.black.cgColor
        emailButton.backgroundColor = UIColor.white
        emailButton.setTitleColor(UIColor.black, for: .normal)
        emailButton.addTarget(self, action: #selector(pressEmailBullpen), for: .touchUpInside)
        //view.addSubview(emailButton)
        
        //addPitchesButton.frame = CGRect(x: w/2+25, y: h-150, width: 100, height: 100)
        addPitchesButton.layer.cornerRadius = 0.5 * addPitchesButton.bounds.size.width
        addPitchesButton.clipsToBounds = true
        addPitchesButton.layer.borderWidth = 1
        addPitchesButton.layer.borderColor = UIColor.black.cgColor
        addPitchesButton.setTitle("Add Pitches", for: .normal)
        addPitchesButton.backgroundColor = UIColor.white
        addPitchesButton.setTitleColor(UIColor.black, for: .normal)
        addPitchesButton.addTarget(self, action: #selector(addPitches), for: .touchUpInside)
        //view.addSubview(addPitchesButton)
        
        fLabel.textColor = SummaryViewController.fColor
        sLabel.textColor = SummaryViewController.sColor
        bLabel.textColor = SummaryViewController.bColor
        xLabel.textColor = SummaryViewController.xColor
        twoLabel.textColor = SummaryViewController.twoColor
        cLabel.textColor = SummaryViewController.cColor
        
    }
    
    func makeStrikeZone(){
        DispatchQueue.main.async {
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
    
    func fillStrikeZone(){
        let data = "bullpen_id=\(bullpenData[0])"
        ServerConnector.runScript(scriptName: "GetBullpenPitches.php", data: data){ response in
            if response == nil{
                print("Could not load pitch data")
                return
            }
            let pitches = ServerConnector.extractJSON(response!.data(using: .utf8)!)
            self.pitch_data = []
            for i in 0 ..< pitches.count {
                if let pitch = pitches[i] as? NSDictionary {
                    if let type = pitch["pitch_type"] as? String, let px_s = pitch["pitchX"] as? String, let py_s = pitch["pitchY"] as? String, let bs = pitch["ball_strike"] as? String, let vel = pitch["vel"] as? String {
                        let px = CGFloat((px_s as NSString).floatValue)
                        let py = CGFloat((py_s as NSString).floatValue)
                        var color = UIColor.black
                        
                        switch type{
                        case "F":
                            color = SummaryViewController.fColor
                            break
                        case "S":
                            color = SummaryViewController.sColor
                            break
                        case "B":
                            color = SummaryViewController.bColor
                            break
                        case "X":
                            color = SummaryViewController.xColor
                            break
                        case "2":
                            color = SummaryViewController.twoColor
                            break
                        case "C":
                            color = SummaryViewController.cColor
                            break
                        default:
                            color = UIColor.black
                        }
                        
                        var h = false
                        if bs == "B" || bs == "N"{
                            h = true
                        }
                        
                        
                        
                        
                        
                        DispatchQueue.main.async {
                            let loc = self.getTranslatedLocation(pitchLocation: CGPoint(x: px, y: py))
                            let ballImg = self.createPermanentBall(location: loc, color: color, hollow: h)
                            let pData = ["type":type, "bs": bs, "vel":vel, "px":px, "py":py, "ballImg":ballImg] as [String:Any]
                            self.pitch_data.append(pData)
                        }
                        
                        
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
                    
                }
            }
            
        }
        
    }
    
    @objc func tapPitchOnZone(sender: UIGestureRecognizer){
        let p = pitch_data[sender.view!.tag]
        print(p["type"]!, p["bs"]!, p["vel"]!)
        
        let popController = UIStoryboard(name: "SummaryView", bundle: nil).instantiateViewController(withIdentifier: "PitchPopover")
        // set the presentation style
        popController.modalPresentationStyle = UIModalPresentationStyle.popover
        
        // set up the popover presentation controller
        popController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.up
        popController.popoverPresentationController?.delegate = self as UIPopoverPresentationControllerDelegate
        popController.popoverPresentationController?.sourceView = sender.view // button
        popController.popoverPresentationController?.sourceRect = sender.view!.bounds
        let vc = popController as! PitchPopoverViewController
        vc.pitchType = p["type"]! as! String
        vc.ballStrike = p["bs"]! as! String
        
        var v = p["vel"]! as! String
        if (v == "0"){
            v = "NA"
        }
        vc.vel = v
        
        
        vc.update()
        // present the popover
        self.present(popController, animated: true, completion: nil)
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        // return UIModalPresentationStyle.FullScreen
        return UIModalPresentationStyle.none
    }
    
    func createPermanentBall(location: CGPoint, color: UIColor, hollow: Bool) -> UIImageView{
        let permBallImage = UIImageView()
        permBallImage.frame = CGRect(x: location.x - ballSize/2, y: location.y - ballSize/2, width: ballSize, height: ballSize)
        permBallImage.image = UIImage.circle(hollow: hollow, diameter: ballSize, color: color)
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
        let data = "bullpen_id=\(bullpenData[0])"
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
        DispatchQueue.main.async{
            self.performSegue(withIdentifier: "unwindToBullpens", sender: self)
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
        DispatchQueue.main.async {
            self.present(vc, animated: true, completion: nil)
        }
        
    }
    
    
}
