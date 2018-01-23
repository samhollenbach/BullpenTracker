//
//  TableController.swift
//  uitableview_load_data_from_json_swift_3
//

import UIKit
import Foundation

class PitcherViewController: UITableViewController {
    
    @IBOutlet weak var navBar: UINavigationBar!
    static private var currentPitcher:Int = -1
    static private var currentBullpen:Int = -1
    
    static var PitcherData:[[String]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 11.0, *) {
            self.additionalSafeAreaInsets.top = 0
        }
        PitcherViewController.PitcherData = []
        self.tableView.rowHeight = 80.0
        
        //navBar.frame = CGRect(x: 0, y: 0, width: (navBar.frame.size.width), height: (navBar.frame.size.height)+UIApplication.shared.statusBarFrame.height)
        navBar.frame = CGRect(x: 0, y: 0, width: (navBar.frame.size.width), height: 44)
        getPitcherDataFromURL("http://52.55.212.19/GetPitchers.php")
    }
    
    
    static func getCurrentPitcher() -> Int{
        return currentPitcher
    }
    
    static func setCurrentPitcher(pitcherId : Int){
        currentPitcher = pitcherId
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
        return currentBullpen
    }
    
    static func setCurrentBullpen(bullpenId : Int){
        currentBullpen = bullpenId
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //let str = PitcherViewController.TableData[indexPath.row]
        let id = Int(PitcherViewController.PitcherData[indexPath.row][0])!
        
        PitcherViewController.setCurrentPitcher(pitcherId: id)
        let storyboard = UIStoryboard(name: "Bullpens", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "BullpensVC") as! BullpenViewController
        present(vc, animated: true, completion: nil)
    }
    
    func getPitcherDataFromURL(_ link:String) {
        ServerConnector.getURLData(urlString: link) { (success, data, response) in
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
        print(PitcherViewController.PitcherData)
        
        DispatchQueue.main.async(execute: {self.do_table_refresh()})
    }
    
    func do_table_refresh() {
        self.tableView.reloadData()
        
    }
    
}
