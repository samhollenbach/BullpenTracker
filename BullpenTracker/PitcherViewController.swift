//
//  TableController.swift
//  uitableview_load_data_from_json_swift_3
//

import UIKit
import Foundation

class PitcherViewController: UITableViewController {
    
    @IBOutlet weak var navBar: UINavigationBar!
    
    @IBOutlet weak var refreshController: UIRefreshControl!

    static var PitcherList: [Pitcher] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 11.0, *) {
            //self.additionalSafeAreaInsets.top = 0
        }
        
        self.tableView.rowHeight = 80.0
        var f = self.view.frame
        f.origin.y = -20
        self.view.frame = f
        
        navBar.sizeToFit()
        refreshController.addTarget(self, action: #selector(refreshTable), for: .valueChanged)
        
        PitcherViewController.PitcherList = []
        
        getPitcherDataStandard()
        
    }
    
    @objc func refreshTable(){
        getPitcherDataStandard()
        
    }
    
    static func getPitcherName(id:Int) -> String{
        for pitcher in PitcherList{
            if pitcher.id != nil && pitcher.id! == id{
                return pitcher.fullName() ?? "Unknown Name (Internal Error)"
            }
        }
        return "Pitcher Not Found"
    }
    
    @IBAction func unwindToPitchers(segue: UIStoryboardSegue) {}
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return PitcherViewController.PitcherList.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.font = UIFont(name: "Helvetica Neue", size: 24)
        let ptext = "#\(PitcherViewController.PitcherList[indexPath.row].number!) \(PitcherViewController.PitcherList[indexPath.row].fullName()!)"
        cell.textLabel?.text = ptext
        return cell
    }
    
    //Send to bullpens
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //let str = PitcherViewController.TableData[indexPath.row]
        sendToBullpensVC(pitcherRowID: indexPath.row)
    }
    
    func getPitcherDataStandard(){
        getPitcherDataFromServer("GetPitchers.php")
        refreshController.endRefreshing()
    }
    
    
    func getPitcherDataFromServer(_ path: String) {
        let data = "team_id=\(BTHelper.CurrentTeam)"
        ServerConnector.serverRequest(path: path, query_string: data, finished: { data, response, error in
            if data != nil{
                self.fillPitcherData(data!)
            }else{
                print("Something went wrong")
            }
            
        })
    }
    
    
    func fillPitcherData(_ data: Data) {
        let pitcher_list = ServerConnector.extractJSONtoList(data)
        PitcherViewController.PitcherList.removeAll()
        for i in 0 ..< pitcher_list.count {
            let pitcher_obj = pitcher_list[i]
            let firstname = pitcher_obj["firstname"] as? String
            let lastname = pitcher_obj["lastname"] as? String
            let pitcher_id = pitcher_obj["id"] as? String
            let pitcher_num = (pitcher_obj["team_number"] as? String)
            let pitcher_email = pitcher_obj["email"] as? String
            let throw_side = pitcher_obj["throws"] as? String
                
            //TODO: ADD PITCHER TOKEN
            let curPitcher = Pitcher(id: Int(pitcher_id!), pitcherToken: "tmp", email: pitcher_email, firstname: firstname, lastname: lastname,  number: Int(pitcher_num), throwSide: throw_side)

            PitcherViewController.PitcherList.append(curPitcher)
            
            
        }
        PitcherViewController.PitcherList = PitcherViewController.PitcherList.sorted(by: {$0.number! < $1.number!})
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
        let curPitcher : Pitcher = PitcherViewController.PitcherList[pitcherRowID]
        let storyboard = UIStoryboard(name: "Bullpens", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "BullpensVC") as! BullpenViewController
        vc.CurrentPitcher = curPitcher
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
