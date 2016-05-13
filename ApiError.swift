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
    
    func asNSError() -> NSError {
        switch self {
        case .JSONError:
            return NSError(domain: errorDomain, code: errorCode, userInfo: nil)
        default:
            <#code#>
        }
    }
}