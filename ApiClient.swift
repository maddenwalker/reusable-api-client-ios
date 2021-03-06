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
    
    var loggingEnabled = false
    
    init(configuration: NSURLSessionConfiguration) {
        self.configuration = configuration
        
    }
    
    func cancelAllRequests() {
        for task in self.currentTasks {
            task.cancel()
        }
        self.currentTasks = []
    }
    
    //Assumption on generic parameter in function is the use of pod Argo
    func fetchResource<T: Decodable where T.DecodedType == T>(request: NSURLRequest, rootKey: String? = nil, completion: ApiClientResult<T> -> Void) {
        fetch(request, parseBlock: { (jsonResponse) -> T? in
            //Return T or return nil
            return T.decode(self.decodeJSONObbject(jsonResponse, rootKey: rootKey)).value
            }, completion: completion)
        
    }
    
    func fetchCollection<T: Decodable where T.DecodedType == T>(request: NSURLRequest, rootKey: String? = nil, completion: ApiClientResult<[T]> -> Void) {
        fetch(request, parseBlock: { (jsonResponse) -> [T]? in
            let json = self.decodeJSONObbject(jsonResponse, rootKey: rootKey)
            switch json {
            case .Array(let array):
                return array.map { T.decode($0).value! }
            default:
                self.debugLog("Response was not an array, cannot continue")
                self.debugLog("\(json)")
                return nil 
            }
            }, completion: completion)
    }
    
    //Generic Fetch Request
    func fetch<T>(request: NSURLRequest, parseBlock: (JSON) -> T?, completion: ApiClientResult<T> -> Void) {
        let task = jsonTaskWithRequest(request) { (json, response, error) in
            dispatch_async(dispatch_get_main_queue()) {
                if let error = error {
                    completion(.Error(error))
                } else {
                    //Should always have a response therefore we can unwrap
                    let statusCode = response!.statusCode
                    switch statusCode {
                    case 200:
                        if let resource = parseBlock(json!) {
                            completion(.Success(resource))
                        } else {
                            //We cannot parse the JSON file successfully into T
                            self.debugLog("WARNING: Could not parse the following JSON response as a \(T.self):")
                            self.debugLog("\(json!)")
                            completion(.UnexpectedResponse(json!))
                        }
                    case 404: completion(.NotFound)
                    case 400...499: completion(.ClientError(statusCode, NSHTTPURLResponse.localizedStringForStatusCode(statusCode)))
                    case 500...599: completion(.ServerError(statusCode, NSHTTPURLResponse.localizedStringForStatusCode(statusCode)))
                    default:
                        self.debugLog("Received HTTP \(statusCode), which was not handled")
                    }
                }
            }
        }
        task.resume()
    }
    
    //Assume HTTP Request and JSON Response
    func jsonTaskWithRequest(request: NSURLRequest, completion: JsonTaskCompletionHandler) -> NSURLSessionDataTask {
        var dataTask: NSURLSessionDataTask?
        dataTask = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) in
            self.currentTasks.remove(dataTask!)
            let httpResponse = response as! NSHTTPURLResponse
            if let error = error {
                self.debugLog("Received an error from HTTP \(request.HTTPMethod!) to \(request.URL!)")
                self.debugLog("Error: \(error)")
                completion(nil, httpResponse, error)
            } else {
                self.debugLog("Received HTTP \(httpResponse.statusCode) from \(request.HTTPMethod!) to \(request.URL!)")
                if let data = data {
                    do {
                        self.debugResponseData(data)
                        let jsonObject = try NSJSONSerialization.JSONObjectWithData(data, options: [])
                        let json = JSON(jsonObject)
                        completion(json, httpResponse, nil)
                    } catch {
                        self.debugLog("Error parsing the response as JSON")
                        completion(nil, httpResponse, ApiError.JSONError.asNSError())
                    }
                } else {
                    self.debugLog("Received an empty response from the API")
                    completion(nil, httpResponse, ApiError.EmptyResponse.asNSError())
                }
            }
        })
        
        currentTasks.insert(dataTask!)
        return dataTask!
    }
    
    //MARK: - Helper Methods
    
    func decodeJSONObbject(response: JSON, rootKey: String? = nil) -> JSON {
        let json: JSON
        if let rootKey = rootKey {
            //ARGO Specific Decoding
            let rootJSON: Decoded<JSON> = ( response <| rootKey ) <|> pure(response)
            json = rootJSON.value ?? .Null
        } else {
            json = response
        }
        return json
    }
    
    //MARK: - Logging 
    
    func debugLog(msg: String) {
        guard loggingEnabled else { return }
        print(msg)
    }
    
    func debugResponseData(data: NSData) {
        guard loggingEnabled else { return }
        if let body = String(data: data, encoding: NSUTF8StringEncoding) {
            print(body)
        } else {
            print("<empty response>")
        }
    }

}