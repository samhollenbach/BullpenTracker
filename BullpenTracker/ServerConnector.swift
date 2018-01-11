//
//  ServerConnector.swift
//  BullpenTracker
//
//  Created by Sam Hollenbach on 1/9/18.
//  Copyright © 2018 Sam Hollenbach. All rights reserved.
//

import Foundation

let publicIP = "http://52.55.212.19/"
let debug = true

class ServerConnector {
    
    
    static func extractJSON(_ data: Data) -> NSArray {
        let json: Any?
        do {
            json = try JSONSerialization.jsonObject(with: data, options: [])
        } catch { return []}
        if let list = json as? NSArray{
            return list
        }else{
            return []
        }
    }
    
    
    static func runScript(scriptName: String, data: String, verbose: Bool? = nil, httpMethod: String = "POST", finished: @escaping((_ response:String?)->Void) = { _ in }){
        // If verbose is not set, set it to debug value
        let verbose = verbose ?? debug
        // Make URL request
        let url: NSURL = NSURL(string: "\(publicIP)\(scriptName)")!
        let request:NSMutableURLRequest = NSMutableURLRequest(url:url as URL)
        request.httpMethod = httpMethod
        request.httpBody = data.data(using: String.Encoding.utf8);
        let task = URLSession.shared.dataTask(with: request as URLRequest!, completionHandler: { data, response, error in
            guard let data = data, error == nil else {
                // check for fundamental networking error
                if verbose{
                    print("error=\(String(describing: error))")
                }
                finished(nil)
                return
            }
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                // check for http errors
                if verbose{
                    print("statusCode should be 200, but is \(httpStatus.statusCode)")
                    print("response = \(String(describing: response))")
                }
                finished(nil)
            }
            
            let responseString = String(data: data, encoding: .utf8)
            if verbose{
                print("responseString = \(String(describing: responseString))")
            }
            
            finished(responseString!)
            
        })
        task.resume()
        sleep(1)
    }
    
    
    static func getURLData(urlString: String, verbose: Bool? = nil, httpMethod: String = "GET", finished: @escaping ((_ isSuccess: Bool, _ data:Data?, _ response:URLResponse?)->Void)) {
        // If verbose is not set, set it to debug value
        let verbose = verbose ?? debug
        // Make URL request
        let url: NSURL = NSURL(string: urlString)!
        let request = NSMutableURLRequest(url: url as URL!)
        request.httpMethod = httpMethod
        request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
        let session = Foundation.URLSession.shared
        let task = session.dataTask(with: request as URLRequest, completionHandler: {(data, response, error) in
            if let error = error {
                if verbose{
                    print(error)
                }            }
            if let data = data{
                if verbose{
                    print("data =\(data)")
                }
            }
            if let response = response {
                let httpResponse = response as! HTTPURLResponse
                if verbose{
                    print("url = \(response.url!)")
                    print("response = \(response)")
                    print("response code = \(httpResponse.statusCode)")
                }
                if httpResponse.statusCode == 200{
                    finished(true, data, response)
                } else {
                    finished(false, nil, nil)
                }
            }
        })
        task.resume()
    }
    

}
