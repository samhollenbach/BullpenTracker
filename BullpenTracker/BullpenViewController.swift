//
//  TableController.swift
//  uitableview_load_data_from_json_swift_3
//

import UIKit

class BullpenViewController: UITableViewController {
    
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var titleView: UINavigationItem!
    
    var CurrentBullpen : Bullpen?
    var CurrentPitcher : Pitcher?
    
    var BullpenList : [Bullpen] = []
    var currentPitcherName : String?
    let noBullpenString = "You have no saved bullpens"
    var individualMode : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.rowHeight = 80.0
        navBar.sizeToFit()

        CurrentBullpen = nil
        BullpenList = []
        
        if individualMode{
            CurrentPitcher = BTHelper.getLoggedInPitcher()
        }
        
        if CurrentPitcher != nil{
            currentPitcherName = CurrentPitcher!.fullName()
        }
        
        if currentPitcherName == nil || (currentPitcherName == "Pitcher Not Found" &&  BTHelper.CurrentTeam == -1){
            titleView.title = "My Bullpens"
        }else{
            titleView.title = "\(CurrentPitcher!.firstname!)\'s Bullpens"
        }
        
        update()
        
    }
    
    func update(){
        if individualMode{
            let data = "pitcher=\(CurrentPitcher!.id!)&team=\(1)"
            
            ServerConnector.serverRequest(URI: "GetBullpens.php", parameters: data, finished: { data, response, error in
                self.fillBullpenList(data!)
            })
            
        }else{
            
            let data = "pitcher=\(CurrentPitcher!.id!)&team=\(BTHelper.CurrentTeam)"
            ServerConnector.serverRequest(URI: "GetTeamBullpens.php", parameters: data, finished: { data, response, error in
                self.fillBullpenList(data!)
            })
            
        }
        
        
    }
    
    
    func fillBullpenList(_ data: Data) {
        let bullpen_list = ServerConnector.extractJSONtoList(data)
        BullpenList = []
        for i in 0 ..< bullpen_list.count {
            let bullpen_obj = bullpen_list[i]
            if let id = bullpen_obj["id"] as? String , let pitcher_id = bullpen_obj["pitcher_id"] as? String , let date = bullpen_obj["date"] as? String, let pen_type = bullpen_obj["type"] as? String  {
                
                if Int(pitcher_id)! != CurrentPitcher!.id!{
                    continue
                }
                
                var compPen = false
                var pen_type_display = "Bullpen"
                
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
                
                //TODO: Change how pitch count is read
                var displayString = ""
                if let pitch_count = bullpen_obj["pitch_count"] as? String {
                    displayString = "\(pen_type_display) (\(pitch_count) pitches)"
                }else{
                    displayString = "\(pen_type_display) (NA)"
                }
                let newPen = Bullpen(pitcher: CurrentPitcher, id: Int(id), penType: pen_type, compPen: compPen, pitchList: nil, date: date, penTypeDisplay: pen_type_display, tableViewDisplay: displayString)
                BullpenList.append(newPen)
                
                
            }
        }
        //        if TableData.isEmpty{
        //            TableData.append(noBullpenString)
        //        }
        DispatchQueue.main.async{
            self.do_table_refresh()
        }
    }
    
    
    @IBAction func sendToPitchersVC(_ sender: UIBarButtonItem) {
        if BTHelper.CurrentTeam == -1{
            self.performSegue(withIdentifier: "unwindToHomePage", sender: self)
        }else{
            self.performSegue(withIdentifier: "unwindToPitchers", sender: self)
        }
        
        
        
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
        
        self.present(bullpenTypeSelector, animated: true) {}
        
    }
    
    
    func createNewBullpen(type: String){
        let pitcher_id = CurrentPitcher!.id!
        let data = "pitcher_id=\(pitcher_id)&type=\(type)&team=\(BTHelper.CurrentTeam)"
        
        ServerConnector.serverRequest(URI: "AddBullpen.php", parameters: data, finished: { data, response, error in
            let pitcher = ServerConnector.extractJSONtoList(data!)[0]
            print(pitcher)
            if pitcher.isEmpty{
                BTHelper.showErrorPopup(source: self, errorTitle: "Error Connecting to Server")
            }
            
            let idString = pitcher["bid"] as? String
            let id: Int = Int(idString!)!
            let compPen = (type == "COMP" || type == "GAME")
            
            //TODO: Replace pitcher(id) with pitcherToken
            self.CurrentBullpen = Bullpen(pitcher: self.CurrentPitcher, id: id, penType: type, compPen: compPen, pitchList: nil, date: "", penTypeDisplay: "", tableViewDisplay: "")
  
            DispatchQueue.main.async {
                self.sendToAddPitchesVC(currentBullpen : self.CurrentBullpen!, currentPitcher: self.CurrentPitcher!)
            }
            
        })
    }
    
    func sendToAddPitchesVC(currentBullpen: Bullpen, currentPitcher: Pitcher) {
        let storyboard = UIStoryboard(name: "AddPitches", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "AddPitches") as! AddPitches
        vc.CurrentBullpen = currentBullpen
        vc.CurrentPitcher = currentPitcher
        present(vc, animated: true, completion: nil)
    }
    
    @IBAction func unwindToBullpens(segue: UIStoryboardSegue) {
        DispatchQueue.main.async {
            sleep(1)
            self.update()
        }
    }
    

    
    
    func sendToSummaryVC(CurrentBullpen: Bullpen) {
        let storyboard = UIStoryboard(name: "SummaryView", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "SummaryVC") as! SummaryViewController
        vc.CurrentBullpen = CurrentBullpen
        vc.CurrentPitcher = CurrentPitcher
        present(vc, animated: true, completion: nil)
        
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
        
        if !BullpenList.isEmpty {
            let bpen =  BullpenList[indexPath.row]
            cell?.textLabel?.text = bpen.tableViewDisplay
            
            let dateFormatted = BullpenViewController.formatDate(originalDate: bpen.date!, originalFormat: "yyyy-MM-dd", newFormat: "MMMM dd, yyyy")
            
            cell?.detailTextLabel?.text = dateFormatted
        }else{
            cell?.textLabel?.text = noBullpenString
            cell?.detailTextLabel?.text = "Click the + to start"
        }
        
        
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        if !BullpenList.isEmpty{
            sendToSummaryVC(CurrentBullpen: BullpenList[indexPath.row])
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return BullpenList.isEmpty ? 1 : BullpenList.count
    }
    
    
    func do_table_refresh() {
        self.tableView.reloadData()
        
    }
    
    
    static func formatDate(originalDate: String, originalFormat: String, newFormat: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = originalFormat
        let yourDate = formatter.date(from: originalDate)
        formatter.dateFormat = newFormat
        return formatter.string(from: yourDate!)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
