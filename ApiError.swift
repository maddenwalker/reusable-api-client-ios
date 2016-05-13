//
//  ApiError.swift
//  Reusable API Client
//
//  Created by Ryan Walker on 5/12/16.
//  Copyright © 2016 Ryan Walker. All rights reserved.
//

import Foundation

public enum ApiError: ErrorType {
    case JSONError
    case EmptyResponse
    case NotHandled
    
    var errorDomain: String {
        return "com.maddenwalker.reusable-api-client"
    }
    
    var errorCode: Int {
        switch self {
        case .JSONError:
            return -1
        case .EmptyResponse:
            return -2
        default:
            return 0
        }
    }
    
    var userInfo: [NSObject: AnyObject]? {
        switch self {
        case .JSONError:
            return [NSLocalizedDescriptionKey : "The JSON received was not in the proper form and could not be serialized"]
        case .EmptyResponse:
            return [NSLocalizedDescriptionKey : "The server returned an empty response, please try again"]
        default:
            return nil
        }
    }
    
    func asNSError() -> NSError {
        return NSError(domain: errorDomain, code: errorCode, userInfo: userInfo)
    }
}