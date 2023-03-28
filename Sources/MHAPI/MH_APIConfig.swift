//
//  File.swift
//  
//
//  Created by LittleFoxiOSDeveloper on 2023/03/29.
//

import Foundation
import Alamofire
import RxSwift

/** API CONFIG **/
public protocol MH_APIConfig{
    var headers: HTTPHeaders?{get}
    var baseURL: String{get}
}
