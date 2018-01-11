//
//  TableController.swift
//  uitableview_load_data_from_json_swift_3
//

import UIKit

class BullpenViewController: UITableViewController {
    
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var titleView: UINavigationItem!
    var TableData = [String]()
    let currentPitcherName = PitcherViewController.getPitcherName(id: PitcherViewController.getCurrentPitcher())
    let noBullpenString = "You have no saved bullpens"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // TODO: Setvartle of VC to pitcher name
        //self.parent?.title = currentPitcherName
        self.tableView.rowHeight = 80.0
        navBar.frame = CGRect(x: 0, y: 0, width: (navBar.frame.size.width), height: (navBar.frame.size.height)+UIApplication.shared.statusBarFrame.height)
        
        //self.tableView.contentInset = UIEdgeInsets(top: UIApplication.shared.statusBarFrame.size.height, left: 0, bottom: 0, right: 0)
        UIApplication.shared.statusBarStyle = .default
        titleView.title = "\(currentPitcherName)\'s Bullpens"
        update()
        
    }
    
    func update(){
        
        ServerConnector.getURLData(urlString: "http://52.55.212.19/GetBullpens.php", verbose: false) { (success, data, response) in
            self.fillBullpenList(data!)
        }
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return TableData.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "Cell"
        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: cellIdentifier)
        }
        cell?.textLabel?.font = UIFont(name: "Helvetica Neue", size: 24)
        cell?.textLabel?.textColor = UIColor(red:0.06, green:0.11, blue:0.26, alpha:1.0)
        cell?.textLabel?.adjustsFontSizeToFitWidth = true
        
        let t = TableData[indexPath.row]
        let data = t.components(separatedBy: "~")
        
        if data.count > 1{
            let _ = data[0]
            cell?.textLabel?.text = data[1]
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            
            let yourDate = formatter.date(from: data[2])
            
            formatter.dateFormat = "MMMM dd, yyyy"
            
            let dateFormatted = formatter.string(from: yourDate!)
            
            cell?.detailTextLabel?.text = dateFormatted
        }else{
            cell?.textLabel?.text = t
            cell?.detailTextLabel?.text = "Click the + to start"
        }
        
        
        return cell!
    }
    
    @IBAction func sendToPitchersVC(_ sender: UIBarButtonItem) {
        self.performSegue(withIdentifier: "unwindToPitchers", sender: self)
        
    }
    
    func sendToAddPitchesVC(bullpen_id: Int) {
        let storyboard = UIStoryboard(name: "AddPitches", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "AddPitches") as! AddPitches
        vc.bullpenID = bullpen_id
        present(vc, animated: true, completion: nil)
    }
    
    
    @IBAction func addBullpen(_ sender: AnyObject) {
        
        let bullpenTypeSelector = UIAlertController(title: "Bullpen Type", message: "Pick the type of bullpen to add", preferredStyle: .alert)
        
        let standardAction = UIAlertAction(title: "Standard", style: .default) { _ in
            self.createNewBullpen(type: "NULL")
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
        let data = "pitcher_id=\(pitcher_id)&type=\(type)"
        
        ServerConnector.runScript(scriptName: "AddBullpen.php", data: data) { (responseString) in
            let list = ServerConnector.extractJSON((responseString?.data(using: .utf8))!)
            let pitcher = list[0] as? NSDictionary
            let id = pitcher!["bid"] as? String
            DispatchQueue.main.async {
                self.sendToAddPitchesVC(bullpen_id: Int(id!)!)
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
        let str = TableData[indexPath.row]
        if str == noBullpenString{
            print("Not a valid bullpen")
            return
        }
        
        let pen_id:Int = Int(str.components(separatedBy: "~")[0])!
       
        sendToSummaryVC(bullpen_id: pen_id)
        
    }
    
    
    func sendToSummaryVC(bullpen_id: Int) {
        let storyboard = UIStoryboard(name: "SummaryView", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "SummaryVC") as! SummaryViewController
        vc.currentBullpenID = bullpen_id
        
        present(vc, animated: true, completion: nil)
        
        DispatchQueue.main.async {
            vc.refreshImage()
        }
        
    }
    
    
    func fillBullpenList(_ data: Data) {
        let bullpen_list = ServerConnector.extractJSON(data)
        
        TableData = Array < String >()
        for i in 0 ..< bullpen_list.count {
                
            if let bullpen_obj = bullpen_list[i] as? NSDictionary , let id = bullpen_obj["id"] as? String , let pitcher_id = bullpen_obj["pitcher_id"] as? String , let date = bullpen_obj["date"] as? String {
                    
                if Int(pitcher_id)! != PitcherViewController.getCurrentPitcher(){
                    continue
                }
                var pen_type_display = "Bullpen"
                if let pen_type = bullpen_obj["type"] as? String {
                    switch pen_type {
                        case "COMP":
                            pen_type_display = "Competitive Bullpen"
                        case "FLAT":
                            pen_type_display = "Flatground"
                        case "GAME":
                            pen_type_display = "Game Appearance"
                        default:
                            break
                    }
                }
                        
                if let pitch_count = bullpen_obj["pitch_count"] as? String {
                    TableData.append("\(id)~\(pen_type_display) (\(pitch_count) pitches)~\(date)")
                }else{
                    TableData.append("\(id)~\(pen_type_display) (NA)~\(date)")
                }
            }
        }
        if TableData.isEmpty{
            TableData.append(noBullpenString)
        }
        DispatchQueue.main.async{
            self.do_table_refresh()
        }
    }
    
    func do_table_refresh() {
        self.tableView.reloadData()
       
        
    }
    
}
