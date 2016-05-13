//
//  ApiClient.swift
//  Reusable API Client
//
//  Created by Ryan Walker on 5/12/16.
//  Copyright © 2016 Ryan Walker. All rights reserved.
//

import Foundation
import Argo

typealias JsonTaskCompletionHandler = (JSON?, NSHTTPURLResponse?, NSError?) -> Void

class ApiClient {
    let configuration: NSURLSessionConfiguration
    
    lazy var session: NSURLSession = {
        return NSURLSession(configuration: self.configuration)
        
    }()
    
    //Keep track of current tasks
    var currentTasks: Set<NSURLSessionDataTask> = []
    
    init(configuration: NSURLSessionConfiguration) {
        self.configuration = configuration
        
    }
    
    //Assumption on generic parameter in function is the use of pod Argo
    func fetchResource<T: Decodable where T.DecodedType == T>(request: NSURLRequest, rootKey: String? = nil, completion: () -> ()) {
        
        
    }
    
    //Generic Fetch Request
    func fetch<T>(request: NSURLRequest, parseBlock: (JSON) -> T?, completion: Void -> Void) {
        
    }
    
    //Assump HTTP Request and JSON Response
    func jsonTaskWithRequest(request: NSURLRequest, completion: JsonTaskCompletionHandler) -> NSURLSessionDataTask {
        var dataTask: NSURLSessionDataTask?
        dataTask = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) in
            let httpResponse = response as! NSHTTPURLResponse
            if let error = error {
                completion(nil, httpResponse, error)
            } else {
                if let data = data {
                    do {
                        let jsonObject = try NSJSONSerialization.JSONObjectWithData(data, options: [])
                        let json = JSON(jsonObject)
                        completion(json, httpResponse, nil)
                    } catch {
                        completion(nil, httpResponse, ApiError.JSONError)
                    }
                } else {
                    //TODO: Separate Subclass of applicable errors needed here
                    completion(nil, httpResponse, NSError(domain: "com.reusableApiClient.emptyresponse", code: 11, userInfo: nil))
                }
            }
        })
        
        return dataTask
        
    }
}