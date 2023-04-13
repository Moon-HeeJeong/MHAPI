//
//  File.swift
//  
//
//  Created by LittleFoxiOSDeveloper on 2023/03/29.
//

import Foundation
import Alamofire
import RxSwift

/** API INFO **/
public protocol MH_APIInfo_P{
    associatedtype Response: Response_P
    
    var short: String {get}
    var method: HTTPMethod {get}
    var parameters: Parameters? {get}
    var config: MH_APIConfig_P? {get set}
}
public extension MH_APIInfo_P{
//    var address: String{
//        (self.config?.baseURL ?? "") + self.short
//    }
    var address: String{
        if method == .get { //get의
            return (self.config?.baseURL ?? "") + self.short + (self.parameters?.query ?? "")
        }else{
            return (self.config?.baseURL ?? "") + self.short
        }
    }
}

extension Dictionary{
    var query: String{
        if(count == 0){
            return ""
        }
        let params = self
        let urlParams = params.compactMap({ (key, value) -> String in
                    "\(key)=\(value)"
        }).joined(separator: "&")
        var urlString = "?" + urlParams
        if let url = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed){
            urlString = url
        }
        return urlString
    }
}

