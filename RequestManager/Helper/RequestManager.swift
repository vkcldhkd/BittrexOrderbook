//
//  RequestManager.swift
//  RequestManager
//
//  Created by Sung Hyun on 2018. 5. 28..
//  Copyright © 2018년 Sung Hyun. All rights reserved.
//
import Foundation
import Alamofire
import IJProgressView

/**
 * API 통신을 하기위한 struct
 */

class RequestManager{
    static fileprivate let queue = DispatchQueue(label: "requests.queue", qos: .utility)
    static fileprivate let mainQueue = DispatchQueue.main
    
    static let retrier = Retrier()
    static let sharedManager: Alamofire.SessionManager = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForResource = Constants.TIMEOUT_SECONDS
        configuration.timeoutIntervalForRequest = Constants.TIMEOUT_SECONDS
        let sessionManager = Alamofire.SessionManager(configuration: configuration)
        sessionManager.retrier = RequestManager.retrier
        return sessionManager
    }()
    
    
    
    /**
     * response를 판단 후 escaping 해주는 함수
     */
    fileprivate class func make(request: DataRequest, closure: @escaping (_ json: [String: Any]?, _ error: Error?)->()) {
        //        LogHelper.printLog("request : \(request`)")
        var isIndicator = false
        if let urlRequest = request.request{
            if let url = urlRequest.url{
                if url.absoluteString != Constants_apis.GET_USDT_BTC_ORDERBOOK(){
                    // indicator 를 표시하지 않을 주소 입력.
                    isIndicator = true
                }
            }
        }
        
        
        if isIndicator {
            RequestManager.mainQueue.async {
                if let topVC = UIApplication.shared.topViewController(){
                    NetworkActivityIndicatorVisible.disable()
                    IJProgressView.shared.showProgressView(topVC.view)
                }
            }
        }
        
        RequestManager.retrier.addRetryInfo(request: request)
        request.responseJSON(queue: RequestManager.queue) { response in
            RequestManager.retrier.deleteRetryInfo(request: request)
            
            // print(response.request ?? "nil")  // original URL request
            // print(response.response ?? "nil") // HTTP URL response
            // print(response.data ?? "nil")     // server data
            // print(response.result ?? "nil")   // result of response serialization
            
            
            if isIndicator{
                RequestManager.mainQueue.async {
                    NetworkActivityIndicatorVisible.enable()
                    IJProgressView.shared.hideProgressView()
                }
            }
            switch response.result {
            //실패할 경우
            case .failure(let error):
                RequestManager.mainQueue.async {
                    closure(nil, error)
                }
                
            case .success(let data):
                // 성공일 경우
                RequestManager.mainQueue.async {
                    closure((data as? [String: Any]) ?? [:], nil)
                }
                
                
            }
        }
    }
    
    /**
     * alamofire error check (internet 등)
     */
    class func errorChecker(_ error : Error?){
        if let error = error {
            LogHelper.printLog("request error !! \(error)")
        }
    }
    
    /**
     * 헤더 추가 함수
     */
    class func setHTTPHeaders(headers : HTTPHeaders = [:]) -> HTTPHeaders {
        var requestHeaders : HTTPHeaders = [:]
        
        if headers.count > 0 {
            for item in headers {
                requestHeaders[item.key] = item.value
            }
        }
        return requestHeaders
    }
    
    /**
     * http method = get
     */
    class func getRequest(url : String, param : Parameters = [:], closure: @escaping (_ json: [String: Any]?)->()) {
        //        let request = self.sharedManager.request(url)
        let request = self.sharedManager.request(url, method: .get, parameters: param)
        RequestManager.make(request: request) { (json, error) in
            
            self.errorChecker(error)
            closure(json)
        }
    }
    
    /**
     * http method = post
     */
    class func postRequest(url : String, param : Parameters,closure: @escaping (_ json: [String: Any]?)->()){
        let request = self.sharedManager.request(url, method: .post , parameters: param, encoding: JSONEncoding.default, headers: self.setHTTPHeaders())
        //        let request = self.createRequest(url: url, param: param)
        RequestManager.make(request: request) { (json, error) in
            self.errorChecker(error)
            closure(json)
        }
    }
    
    /**
     * http method = post + header 추가
     */
    class func postRequest(url : String, param : Parameters, headers : HTTPHeaders, closure: @escaping (_ json: [String: Any]?)->()){
        //        LogHelper.printLog("self.setHTTPHeaders(headers: headers) : \(self.setHTTPHeaders(headers: headers))")
        let request = self.sharedManager.request(url, method: .post , parameters: param, encoding: JSONEncoding.default, headers: self.setHTTPHeaders(headers: headers))
        //        let request = self.createRequest(url: url, param: param)
        RequestManager.make(request: request) { (json, error) in
            self.errorChecker(error)
            closure(json)
        }
    }
}

/**
 * 서버통신 실패 시 3번 재전송.
 */
class Retrier: RequestRetrier {
    
    var defaultRetryCount = 3
    private var requestsAndRetryCounts: [(Request, Int)] = []
    private var lock = NSLock()
    
    private func index(request: Request) -> Int? {
        return requestsAndRetryCounts.index(where: { $0.0 === request })
    }
    
    func addRetryInfo(request: Request, retryCount: Int? = nil) {
        lock.lock() ; defer { lock.unlock() }
        guard index(request: request) == nil else { LogHelper.printLog("ERROR addRetryInfo called for already tracked request"); return }
        
        requestsAndRetryCounts.append((request, retryCount ?? defaultRetryCount))
    }
    func deleteRetryInfo(request: Request) {
        lock.lock() ; defer { lock.unlock() }
        guard let index = index(request: request) else { LogHelper.printLog("ERROR deleteRetryInfo called for not tracked request"); return }
        
        requestsAndRetryCounts.remove(at: index)
    }
    
    func should(_ manager: SessionManager, retry request: Request, with error: Error, completion: @escaping RequestRetryCompletion){
        
        lock.lock() ; defer { lock.unlock() }
        
        guard let index = index(request: request) else { completion(false, 0); return }
        let (request, retryCount) = requestsAndRetryCounts[index]
        if retryCount == 0 {
            completion(false, 0)
        } else {
            requestsAndRetryCounts[index] = (request, retryCount - 1)
            completion(true, 0.5)
        }
    }
}
