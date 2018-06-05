//
//  NetworkingManager.swift
//  RequestManager
//
//  Created by Sung9 on 2018. 6. 5..
//  Copyright © 2018년 Sung Hyun. All rights reserved.
//

import Foundation
import Alamofire
import RxAlamofire
import IJProgressView
import RxSwift
import RxCocoa

class RequestManager {
    static let sharedManager: SessionManager = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForResource = Constants.TIMEOUT_SECONDS
        configuration.timeoutIntervalForRequest = Constants.TIMEOUT_SECONDS
        let sessionManager = SessionManager(configuration: configuration)
        return sessionManager
    }()
    
    class func request(method : HTTPMethod = .post, url : String) -> Observable<Dictionary<String,Any>?> {
        return RequestManager.sharedManager.rx.json(method, url)
            .retry(3)
            .observeOn(ConcurrentDispatchQueueScheduler(queue: .global()))
            .map{ json -> (Dictionary<String,Any>?) in
                guard let dict = json as? Dictionary<String,Any> else { return nil }
                LogHelper.printLog("request Json : \(dict)")
                return dict
        }
            .do(onError: { error in
                if case let .some(.httpRequestFailed(response, _)) = error as? RxCocoaURLError, response.statusCode == 403 {
                    LogHelper.printLog("⚠️ Bittrex API rate limit exceeded. Wait for 60 seconds and try again.")
                }else{
                    LogHelper.printLog("error : \(error.localizedDescription)")
                }
            })
            .catchErrorJustReturn(nil)
    }
}
