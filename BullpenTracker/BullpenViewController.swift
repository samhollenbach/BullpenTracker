//
//  TableController.swift
//  uitableview_load_data_from_json_swift_3
//

import UIKit

class BullpenViewController: UITableViewController {
    
    var TableData:Array< String > = Array < String >()
    let currentPitcherName = PitcherViewController.getPitcherName(id: PitcherViewController.getCurrentPitcher())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // TODO: Setvartle of VC to pitcher name
        //self.parent?.title = currentPitcherName
        self.tableView.rowHeight = 80.0
        get_data_from_url("http://52.55.212.19/get_bullpens.php")
    }
    
    func update(){
        get_data_from_url("http://52.55.212.19/get_bullpens.php")
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return TableData.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "bullpen_cell", for: indexPath)
        cell.textLabel?.font = UIFont(name: "Helvetica Neue", size: 24)
        cell.textLabel?.text = TableData[indexPath.row]
        return cell
    }
    
    @IBAction func sendToPitchersVC(_ sender: UIBarButtonItem) {
        self.performSegue(withIdentifier: "unwindToPitchers", sender: self)
        
        //let storyboard = UIStoryboard(name: "Main", bundle: nil)
        //let vc = storyboard.instantiateViewController(withIdentifier: "PitchersVC") as! PitcherViewController
        //present(vc, animated: true, completion: nil)
    }
    
    func sendToAddPitchesVC(bullpen_id: Int) {
        let storyboard = UIStoryboard(name: "AddPitches", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "AddPitches") as! AddPitches
        vc.bullpenID = bullpen_id
        present(vc, animated: true, completion: nil)
    }
    
    
    @IBAction func addBullpen(_ sender: AnyObject) {
        
        let url: NSURL = NSURL(string: "http://52.55.212.19/add_bullpen.php")!
        let request:NSMutableURLRequest = NSMutableURLRequest(url:url as URL)
        request.httpMethod = "POST"
        let pitcher_id = PitcherViewController.getCurrentPitcher()
        let data = "pitcher_id=\(pitcher_id)"
        request.httpBody = data.data(using: String.Encoding.utf8);
        let task = URLSession.shared.dataTask(with: request as URLRequest!, completionHandler: { data, response, error in
            guard let data = data, error == nil else {                                                 // check for fundamental networking error
                print("error=\(error)")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(response)")
                return
            }
            
            let responseString = String(data: data, encoding: .utf8)!
            print("responseString = \(responseString)")
            let id: Int = Int(responseString.components(separatedBy: "~")[1])!
            DispatchQueue.main.async {
                self.sendToAddPitchesVC(bullpen_id: id)
            }
            return
            
        })
        task.resume()
        
        
    }
    
    @IBAction func unwindToBullpens(segue: UIStoryboardSegue) {}
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //let str = TableData[indexPath.row]
        //let pen_id = str.components(separatedBy: ". ")[0]
//        print(TableData[indexPath.row])
//
//        let storyboard = UIStoryboard(name: "Bullpens", bundle: nil)
//        let vc = storyboard.instantiateViewController(withIdentifier: "BullpensVC") as UIViewController
//        present(vc, animated: true, completion: nil)
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
        if let bullpen_list = json as? NSArray{
            for i in 0 ..< data_list.count {
                if let bullpen_obj = bullpen_list[i] as? NSDictionary {
                    if let id = bullpen_obj["id"] as? String {
                        if let pitcher_id = bullpen_obj["pitcher_id"] as? String {
                            if Int(pitcher_id)! != PitcherViewController.getCurrentPitcher(){
                                 continue
                            }
                            let pitcher_name = PitcherViewController.getPitcherName(id: Int(pitcher_id)!)
                            if let date = bullpen_obj["date"] as? String {
                                TableData.append(id + ". " + pitcher_name + " on " + date)
                            }
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
