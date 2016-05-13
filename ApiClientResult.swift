//
//  ApiClientResult.swift
//  Reusable API Client
//
//  Created by Ryan Walker on 5/13/16.
//  Copyright © 2016 Ryan Walker. All rights reserved.
//

import Foundation
import Argo

public enum ApiClientResult<T> {
    case Success(T)
    case Error(NSError)
    case NotFound
    case ServerError(Int, String)
    case ClientError(Int, String)
    case UnexpectedResponse(JSON)
}