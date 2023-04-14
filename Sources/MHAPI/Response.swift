//
//  File.swift
//  
//
//  Created by LittleFoxiOSDeveloper on 2023/03/29.
//

import Foundation
import Alamofire
import RxSwift

/** Response **/
public protocol Response_P: Model_T{
    
    associatedtype T: DataType_P
    
    var responseType: Response_E {get set}
    var data: T? {get set}
    
    init(responseType: Response_E, data: T?)
}

public protocol DataType_P: Model_T{
}

public enum Response_E{
    case ok(message: String?)
    case error(code: Int, message: String?)
    
    var message: String?{
        switch self {
        case .ok(let message):
            return message
        case .error(_, let message):
            return message
        }
    }
}


