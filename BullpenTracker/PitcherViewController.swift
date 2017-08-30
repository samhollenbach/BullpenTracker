//
//  TableController.swift
//  uitableview_load_data_from_json_swift_3
//

import UIKit
import Foundation

class PitcherViewController: UITableViewController {
    
    static var PitcherNames = [Int:String]()
    static var TableData:Array< String > = Array < String >()
    static private var currentPitcher:Int = -1
    static private var currentBullpen:Int = -1
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        PitcherViewController.PitcherNames = [Int:String]()
        PitcherViewController.TableData = Array < String >()
        self.tableView.rowHeight = 80.0
        get_data_from_url("http://52.55.212.19/get_pitchers.php")
    }
    
    static func getCurrentPitcher() -> Int{
        return currentPitcher
    }
    
    static func setCurrentPitcher(pitcherId : Int){
        currentPitcher = pitcherId
    }
    
    static func getPitcherName(id:Int) -> String{
        return PitcherNames[id]!
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
        return PitcherViewController.TableData.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.font = UIFont(name: "Helvetica Neue", size: 24)
        cell.textLabel?.text = PitcherViewController.TableData[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let str = PitcherViewController.TableData[indexPath.row]
        let id = str.components(separatedBy: ". ")[0]
        
        PitcherViewController.setCurrentPitcher(pitcherId: Int(id)!)
        let storyboard = UIStoryboard(name: "Bullpens", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "BullpensVC") as! BullpenViewController
        present(vc, animated: true, completion: nil)
    }
    
    func get_data_from_url(_ link:String) {
        let url:URL = URL(string: link)!
        let session = URLSession.shared
        
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "GET"
        request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
        
        let task = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) in
            
            guard let _:Data = data, let _:URLResponse = response  , error == nil else {
                return
            }
            self.extract_json(data!)
        })
        task.resume()
    }
    
    
    func extract_json(_ data: Data) {
        let json: Any?
        
        do {
            json = try JSONSerialization.jsonObject(with: data, options: [])
        } catch { return }
        
        guard let data_list = json as? NSArray else {
            return
        }
        if let pitcher_list = json as? NSArray{
            for i in 0 ..< data_list.count {
                if let pitcher_obj = pitcher_list[i] as? NSDictionary {
                    if let name = pitcher_obj["name"] as? String {
                        if let pitcher_id = pitcher_obj["number"] as? String {
                            PitcherViewController.PitcherNames[Int(pitcher_id)!] = name
                            PitcherViewController.TableData.append(pitcher_id + ". " + name)
                        }
                    }
                }
            }
        }
        DispatchQueue.main.async(execute: {self.do_table_refresh()})
    }
    
    func do_table_refresh() {
        self.tableView.reloadData()
        
    }
    
}
