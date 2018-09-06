//
//  TableController.swift
//  uitableview_load_data_from_json_swift_3
//

import UIKit

class BullpenViewController: UITableViewController {
    
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var titleView: UINavigationItem!
    //var TableData = [String]()
    var BullpenData = [[Any!]]()
    var PitcherData : [String] = []
    let currentPitcherName = PitcherViewController.getPitcherName(id: PitcherViewController.getCurrentPitcher())
    let noBullpenString = "You have no saved bullpens"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.rowHeight = 80.0
        navBar.sizeToFit()
        
        BullpenData = []
        
        
        if currentPitcherName == "Pitcher Not Found" &&  BTHelper.CurrentTeam == -1{
            titleView.title = "My Bullpens"
        }else{
            
            titleView.title = "\(currentPitcherName)\'s Bullpens"
        }
        update()
        
    }
    
    func update(){
        if BTHelper.CurrentTeam == -1{
            let data = "pitcher=\(BTHelper.CurrentPitcher)&team=\(1)"
            ServerConnector.getURLData(urlString: "\(ServerConnector.publicIP)GetBullpens.php", data: data, httpMethod: "POST") { (success, data, response) in
                self.fillBullpenList(data!)
            }
        }else{
            let data = "pitcher=\(BTHelper.CurrentPitcher)&team=\(BTHelper.CurrentTeam)"
            ServerConnector.getURLData(urlString: "\(ServerConnector.publicIP)GetTeamBullpens.php", data: data, httpMethod: "POST") { (success, data, response) in
                self.fillBullpenList(data!)
            }
        }
        
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return BullpenData.isEmpty ? 1 : BullpenData.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //just leave this because it works
        let cellIdentifier = "Cell"
        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: cellIdentifier)
        }
        cell?.textLabel?.font = UIFont(name: "Helvetica Neue", size: 24)
        cell?.textLabel?.textColor = UIColor(red:0.06, green:0.11, blue:0.26, alpha:1.0)
        cell?.textLabel?.adjustsFontSizeToFitWidth = true
        
        if !BullpenData.isEmpty {
            let data = BullpenData[indexPath.row]
            let _ = data[0]
            cell?.textLabel?.text = data[4] as? String
            
            let dateFormatted = BullpenViewController.formatDate(originalDate: data[3] as! String, originalFormat: "yyyy-MM-dd", newFormat: "MMMM dd, yyyy")
            
            cell?.detailTextLabel?.text = dateFormatted
        }else{
            cell?.textLabel?.text = noBullpenString
            cell?.detailTextLabel?.text = "Click the + to start"
        }
        
        
        return cell!
    }
    static func formatDate(originalDate: String, originalFormat: String, newFormat: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = originalFormat
        let yourDate = formatter.date(from: originalDate)
        formatter.dateFormat = newFormat
        return formatter.string(from: yourDate!)
    }
    
    
    @IBAction func sendToPitchersVC(_ sender: UIBarButtonItem) {
        if BTHelper.CurrentTeam == -1{
            self.performSegue(withIdentifier: "unwindToHomePage", sender: self)
        }else{
            self.performSegue(withIdentifier: "unwindToPitchers", sender: self)
        }
        
        
        
    }
    
    func sendToAddPitchesVC(bullpenData: [Any], PitcherData:[String]) {
        let storyboard = UIStoryboard(name: "AddPitches", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "AddPitches") as! AddPitches
        vc.bullpenData = bullpenData
        vc.PitcherData = PitcherData
        present(vc, animated: true, completion: nil)
    }
    
    
    @IBAction func addBullpen(_ sender: AnyObject) {
        
        let bullpenTypeSelector = UIAlertController(title: "Bullpen Type", message: "Pick the type of bullpen to add", preferredStyle: .alert)
        
        let standardAction = UIAlertAction(title: "Standard", style: .default) { _ in
            self.createNewBullpen(type: "NORM")
        }
        let compAction = UIAlertAction(title: "Competitive", style: .default) { _ in
            self.createNewBullpen(type: "COMP")
        }
        let flatAction = UIAlertAction(title: "Flatground", style: .default) { _ in
            self.createNewBullpen(type: "FLAT")
        }
        let gameAction = UIAlertAction(title: "Game", style: .default) { _ in
            self.createNewBullpen(type: "GAME")
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        bullpenTypeSelector.addAction(standardAction)
        bullpenTypeSelector.addAction(compAction)
        bullpenTypeSelector.addAction(flatAction)
        bullpenTypeSelector.addAction(gameAction)
        bullpenTypeSelector.addAction(cancelAction)
        
        
        
        self.present(bullpenTypeSelector, animated: true) {
            // ...
        }
        
        
        
    }
    
    func createNewBullpen(type: String){
        
        let pitcher_id = PitcherViewController.getCurrentPitcher()
        let data = "pitcher_id=\(pitcher_id)&type=\(type)&team=\(BTHelper.CurrentTeam)"
        
        ServerConnector.runScript(scriptName: "AddBullpen.php", data: data) { (responseString) in
            if let list = ServerConnector.extractJSON((responseString?.data(using: .utf8))!) as? [NSDictionary]{
                let pitcher = list[0] as NSDictionary
                let idString = pitcher["bid"] as? String
                let id: Int = Int(idString!)!
                var compPen = false
                if type == "COMP" || type == "GAME"{
                    compPen = true
                }
                
                DispatchQueue.main.async {
                    print(self.PitcherData)
                    self.sendToAddPitchesVC(bullpenData: [id, compPen, "", "", "", 0], PitcherData: self.PitcherData)
                }
            }else{
                print("Error connecting to server")
            }
            
        }
       
        
    }
    
    
    @IBAction func unwindToBullpens(segue: UIStoryboardSegue) {
        DispatchQueue.main.async {
            sleep(1)
            self.update()
        }
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //let str = TableData[indexPath.row]
        if BullpenData.count == 0{
            print("Not a valid bullpen")
            return
        }
        
        tableView.deselectRow(at: indexPath, animated: false)
        sendToSummaryVC(bullpenData: BullpenData[indexPath.row])
        
    }
    
    
    func sendToSummaryVC(bullpenData: [Any]) {
        let storyboard = UIStoryboard(name: "SummaryView", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "SummaryVC") as! SummaryViewController
        vc.bullpenData = bullpenData
        vc.PitcherData = PitcherData
        present(vc, animated: true, completion: nil)
        
    }
    

    func fillBullpenList(_ data: Data) {
        let bullpen_list = ServerConnector.extractJSON(data)
        
        //TableData = Array < String >()
        
        BullpenData = []
        for i in 0 ..< bullpen_list.count {
                
            if let bullpen_obj = bullpen_list[i] as? NSDictionary , let id = bullpen_obj["id"] as? String , let pitcher_id = bullpen_obj["pitcher_id"] as? String , let date = bullpen_obj["date"] as? String {
                    
                if Int(pitcher_id)! != PitcherViewController.getCurrentPitcher(){
                    continue
                }
                var compPen = false
                var pen_type_display = "Bullpen"
                if let pen_type = bullpen_obj["type"] as? String {
                    switch pen_type {
                        case "COMP":
                            pen_type_display = "Competitive Bullpen"
                            compPen = true
                        case "FLAT":
                            pen_type_display = "Flatground"
                        case "GAME":
                            pen_type_display = "Game Appearance"
                            compPen = true
                        default:
                            break
                    }
                }
                
                
                var pc = 0
                //TODO: Change how pitch count is read
                var displayString = ""
                if let pitch_count = bullpen_obj["pitch_count"] as? String {
                    displayString = "\(pen_type_display) (\(pitch_count) pitches)"
                    pc = Int(pitch_count)!
                }else{
                    displayString = "\(pen_type_display) (NA)"
                }
                let pdata = [Int(id)!, compPen, pen_type_display, date, displayString, pc] as [Any]
                
                BullpenData.append(pdata)
                
                
            }
        }
//        if TableData.isEmpty{
//            TableData.append(noBullpenString)
//        }
        DispatchQueue.main.async{
            self.do_table_refresh()
        }
    }
    
    func do_table_refresh() {
        self.tableView.reloadData()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
