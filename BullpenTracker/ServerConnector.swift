//
//  ServerConnector.swift
//  BullpenTracker
//
//  Created by Sam Hollenbach on 1/9/18.
//  Copyright © 2018 Sam Hollenbach. All rights reserved.
//

import Foundation


class ServerConnector {
    
    static let publicIP = "http://54.175.185.55"
    static let debug = true
    
    
    static func extractJSONtoList(_ data: Data) -> [[String:Any]] {
        let json_list: Any?
        do {
            json_list = try JSONSerialization.jsonObject(with: data, options: [])
        } catch { return []}
        if let list = json_list as? NSArray{
            var list_of_dicts : [[String:Any]] = []
            for l in list{
                
                if let dict = l as? [String:Any] {
                    list_of_dicts.append(dict)
                }else{
                    return []
                }
            }
            
            return list_of_dicts
        }else{
            return []
        }
    }
    
    static func extractJSONtoDict(_ data: Data) -> [String:Any] {
        let json: Any?
        do {
            json = try JSONSerialization.jsonObject(with: data, options: [])
        } catch { return [:]}
        if let dict = json as? [String:Any] {
            return dict
        }else{
            return [:]
        }
    }
    
    
    
    
    // TODO: START USING THIS !!!!!!
    // Make requests to server (POST, GET)
    // Returns (data, response, error)
    // data: JSON data from server to parse with extractJSON function (above), nil if error
    // response: Server response, nil if error
    // error: String describing error, nil if successful
    
    static func serverRequest(path: String, query_string: String, serverIP: String = publicIP, httpMethod: String = "POST", verbose: Bool? = nil,
                              finished: @escaping((_ data: Data?, _ response:URLResponse?, _ error: Error?)->Void)){
        
        // If verbose is not set, set it to debug value
        let verbose = verbose ?? debug
        
        // Make URL request
        let url: NSURL = NSURL(string: "\(publicIP)/\(path)")!
        let request:NSMutableURLRequest = NSMutableURLRequest(url:url as URL)
        request.httpMethod = httpMethod
        request.httpBody = query_string.data(using: String.Encoding.utf8);
        let task = URLSession.shared.dataTask(with: (request as URLRequest?)!,
                                              completionHandler: { data, response, error in
                                                
            print("Server Response:\n\(String(describing: response))")
            guard let data = data, error == nil else {
                // Check for fundamental networking error
                if verbose{ print("error=\(String(describing: error))") }
                finished(nil, nil, error)
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                // Check for http errors
                if verbose{
                    print("Error: HTTP response code is \(httpStatus.statusCode) (should be 200)")
                    
                }
                finished(nil, nil, error)
                return
            }
            
            let dataString = String(data: data, encoding: .utf8) ?? "nil"
            if verbose{ print("dataString = \(dataString)") }
            finished(data, response, nil)
            
        })
        task.resume()
        //sleep(1)
    }
    
    // DEPRECATED
    static func runScript(scriptName: String, data: String, verbose: Bool? = nil, httpMethod: String = "POST", finished: @escaping((_ response:String?)->Void) = { _ in }){
        // If verbose is not set, set it to debug value
        let verbose = verbose ?? debug
        // Make URL request
        let url: NSURL = NSURL(string: "\(publicIP)/\(scriptName)")!
        let request:NSMutableURLRequest = NSMutableURLRequest(url:url as URL)
        request.httpMethod = httpMethod
        request.httpBody = data.data(using: String.Encoding.utf8);
        let task = URLSession.shared.dataTask(with: (request as URLRequest?)!,
                                              completionHandler: { data, response, error in
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
    
    // DEPRECATED
    static func getURLData(urlString: String, data : String = "", verbose: Bool? = nil, httpMethod: String = "GET", finished: @escaping ((_ isSuccess: Bool, _ data:Data?, _ response:URLResponse?)->Void)) {
        // If verbose is not set, set it to debug value
        let verbose = verbose ?? debug
        // Make URL request
        let url: NSURL = NSURL(string: urlString)!
        let request = NSMutableURLRequest(url: (url as URL?)!)
        request.httpMethod = httpMethod
        request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
        request.httpBody = data.data(using: String.Encoding.utf8);
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
