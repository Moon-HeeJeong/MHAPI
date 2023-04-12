import Foundation
import Alamofire
import RxSwift

public typealias Model_P = Decodable

public protocol MH_API: AnyObject{
    
    var session: Session{get set}
    var trustManager: ServerTrustManager? {get set}
    var sessionConfig: URLSessionConfiguration?{get set}
}

public extension MH_API{
    
    func call<T: MH_APIInfo>(api: T, completed: @escaping (T.ResponseType)->()){

        self.session.request(URL(string: api.address)!, method: api.method, parameters: api.parameters, headers: api.config?.headers).responseData { res in
            #if DEBUG
            print("=======================")
            print("📲url: \(api.address)")
            print("📲parameters: \(String(describing: api.parameters))")
            print("📲method: \(api.method)")
            print("📲header: \(String(describing: api.config?.headers))")
            #endif
            
            switch res.result{
            case .success(_):
                if let data = res.value{
                    do{
//                        let decodingData = try JSONDecoder().decode(T.ResponseType.self, from: data)
//                        if let _ = decodingData.data{
//                            completed(decodingData)
//                        }else{
//                            completed(T.ResponseType(responseType: .error(code: -1, message: "decoding error"), data: nil))
//                        }
                        let decodingData = try JSONDecoder().decode(T.ResponseType.self, from: data)
                        completed(decodingData)
                    }catch(let e){
                        completed(T.ResponseType(responseType: .error(code: e.asAFError?.responseCode ?? -1, message: e.localizedDescription), data: nil))
                    }
                }else{
                    completed(T.ResponseType(responseType: .error(code: res.error?.responseCode ?? -1, message: res.error?.localizedDescription), data: nil))
                }
                break
            case .failure(_):
                completed(T.ResponseType(responseType: .error(code: res.error?.responseCode ?? -1, message: res.error?.localizedDescription), data: nil))
                break
            }
        }
    }

    func callByRx<T: MH_APIInfo, R: Response_P>(_ api: T) -> Observable<R> where T.ResponseType == R {

        return Observable<R>.create { observer in
            
            let request = self.session.request(URL(string: api.address)!, method: api.method, parameters: api.parameters, headers: api.config?.headers).responseData { res in
#if DEBUG
                print("=======================")
                print("📲url: \(api.address)")
                print("📲parameters: \(String(describing: api.parameters))")
                print("📲method: \(api.method)")
                print("📲header: \(String(describing: api.config?.headers))")
#endif
                switch res.result{
                case .success(_):
                    if let data = res.value{
                        do{
                            let decodingData = try JSONDecoder().decode(R.self, from: data)
                            observer.onNext(decodingData)
                        }catch let e{
                            observer.onNext(R(responseType: ResponseType.error(code: (e as? AFError)?.responseCode ?? -1, message: e.localizedDescription), data: nil))
                        }
                    }else{
                        observer.onNext(R(responseType: ResponseType.error(code: (res.error as? AFError)?.responseCode ?? -1, message: res.error?.localizedDescription), data: nil))
                    }
                    break
                case .failure(_):
                    observer.onNext(R(responseType: ResponseType.error(code: (res.error as? AFError)?.responseCode ?? -1, message: res.error?.localizedDescription), data: nil))
                    break
                }
                observer.onCompleted()
            }.responseJSON { res in
                #if DEBUG
                print("responseJson \(String(describing: res.value))")
                print("=======================")
                #endif
            }
//            responseString { res in
//                #if DEBUG
//                print("responseString \(String(describing: res.value))")
//                print("=======================")
//                #endif
//            }
            return Disposables.create {
                request.cancel()
            }
        }
    }
}


public enum APICallError: Error{
    case decodingErr(code: Int, message: String?)
    case noDataErr(code: Int, message: String?)
    case networkingErr(code: Int, message: String?)
    case etcErr(code: Int, message: String?)
    
    var desc: String?{
        switch self {
        case .decodingErr(_, let message):
            return message
        case .noDataErr(_, let message):
            return message
        case .networkingErr(_, let message):
            return message
        case .etcErr(_, let message):
            return message
        }
    }
    
    var code: Int{
        switch self {
        case .decodingErr(let code, _):
            return code
        case .noDataErr(let code, _):
            return code
        case .networkingErr(let code, _):
            return code
        case .etcErr(let code, _):
            return code
        }
    }
}
