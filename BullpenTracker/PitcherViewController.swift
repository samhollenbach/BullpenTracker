//
//  TableController.swift
//  uitableview_load_data_from_json_swift_3
//

import UIKit
import Foundation

class PitcherViewController: UITableViewController {
    
    @IBOutlet weak var navBar: UINavigationBar!
    
    @IBOutlet weak var refreshController: UIRefreshControl!

    
    static var PitcherData:[[String]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 11.0, *) {
            //self.additionalSafeAreaInsets.top = 0
        }
        
        self.tableView.rowHeight = 80.0
        var f = self.view.frame
        f.origin.y = -20
        self.view.frame = f
        
        BTHelper.ResetPitcher()
        
        navBar.sizeToFit()
        refreshController.addTarget(self, action: #selector(refreshTable), for: .valueChanged)
        PitcherViewController.PitcherData = []
        getPitcherDataStandard()
        
    }
    
    @objc func refreshTable(){
        getPitcherDataStandard()
        
    }
    
    
    
    static func getCurrentPitcher() -> Int{
        return BTHelper.CurrentPitcher
    }
    
    static func setCurrentPitcher(pitcherId : Int){
        BTHelper.CurrentPitcher = pitcherId
    }
    
    static func getPitcherName(id:Int) -> String{
        for pdat in PitcherData{
            if Int(pdat[0])! == id{
                return pdat[1]
            }
        }
        return "Pitcher Not Found"
    }
    
    static func getCurrentBullpen() -> Int{
        return BTHelper.CurrentBullpen
    }
    
    static func setCurrentBullpen(bullpenId : Int){
        BTHelper.CurrentBullpen = bullpenId
    }
    
    @IBAction func unwindToPitchers(segue: UIStoryboardSegue) {}
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return PitcherViewController.PitcherData.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.font = UIFont(name: "Helvetica Neue", size: 24)
        let ptext = "#\(PitcherViewController.PitcherData[indexPath.row][2]) \(PitcherViewController.PitcherData[indexPath.row][1])"
        cell.textLabel?.text = ptext
        return cell
    }
    
    //Send to bullpens
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //let str = PitcherViewController.TableData[indexPath.row]
        sendToBullpensVC(pitcherRowID: indexPath.row)
    }
    
    
    
    
    func getPitcherDataStandard(){
        getPitcherDataFromURL("\(ServerConnector.publicIP)GetPitchers.php")
        refreshController.endRefreshing()
    }
    
    
    func getPitcherDataFromURL(_ link:String) {
        let data = "team_id=\(BTHelper.CurrentTeam)"
        ServerConnector.getURLData(urlString: link, data: data, httpMethod: "POST") { (success, data, response) in
            if data != nil{
                self.fillPitcherData(data!)
            }else{
                print("Something went wrong")
            }
            
        }
    }
    
    
    func fillPitcherData(_ data: Data) {
        let pitcher_list = ServerConnector.extractJSON(data)
        PitcherViewController.PitcherData.removeAll()
        for i in 0 ..< pitcher_list.count {
            if let pitcher_obj = pitcher_list[i] as? NSDictionary {
                if let name = pitcher_obj["name"] as? String, let pitcher_id = pitcher_obj["id"] as? String, let pitcher_num = pitcher_obj["number"] as? String{
                    let pdata = [pitcher_id, name, pitcher_num]
                    PitcherViewController.PitcherData.append(pdata)
                }
            }
        }
        PitcherViewController.PitcherData = PitcherViewController.PitcherData.sorted(by: {Int($0[2])! < Int($1[2])!})
        
        DispatchQueue.main.async(execute: {self.do_table_refresh()})
    }
    
    func do_table_refresh() {
        self.tableView.reloadData()
        
    }
    
    @IBAction func dismissVC(_ sender: Any) {
        BTHelper.ResetTeam()
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addPitcherPressed(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "addTeamPlayer") as! AddTeamPlayerViewController
        present(vc, animated: true, completion: nil)
    }
    
    @IBAction func backPressed(_ sender: Any) {
        sendToTeamsVC()
    }
    
    func sendToBullpensVC(pitcherRowID: Int){
        let pData = PitcherViewController.PitcherData[pitcherRowID]
        let id = Int(pData[0])!
        
        PitcherViewController.setCurrentPitcher(pitcherId: id)
        let storyboard = UIStoryboard(name: "Bullpens", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "BullpensVC") as! BullpenViewController
        vc.PitcherData = pData
        present(vc, animated: true, completion: nil)
    }
    
    func sendToTeamsVC(){
        let storyboard = UIStoryboard(name: "TeamSelect", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "myTeams") as! TeamSelectViewController
        present(vc, animated: true, completion: nil)
    }
    
    func animateTable() {
        self.tableView.reloadData()
        let cells = tableView.visibleCells
        let tableHeight: CGFloat = tableView.bounds.size.height
        for (index, cell) in cells.enumerated() {
            cell.transform = CGAffineTransform(translationX: 0, y: tableHeight)
            UIView.animate(withDuration: 1.0, delay: 0.05 * Double(index), usingSpringWithDamping: 0.85, initialSpringVelocity: 0, options: [], animations: {
                    cell.transform = CGAffineTransform(translationX: 0, y: 0);
                }, completion: nil)
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
}
