//
//  DataResponser.swift
//  RequestManager
//
//  Created by Sung Hyun on 2018. 5. 28..
//  Copyright © 2018년 Sung Hyun. All rights reserved.
//
import Foundation
import RxSwift
import RxCocoa

class DataResponser {
    class func getOrderBook() -> Observable<Result>{
        
        let emptyResult : Result = Result(buy: [], sell: [])
        guard let url = URL(string: Constants_apis.GET_USDT_BTC_ORDERBOOK()) else { return .just(emptyResult) }
        return URLSession.shared.rx.json(url: url)
            .map { json -> (Result) in
                guard let dict = json as? [String: Any] ,
                    let jsonData = dict.jsonToString().data(using: .utf8),
                    let model = (try? JSONDecoder().decode(OrderBookModel.self, from: jsonData)),
                    let result = model.result else { return emptyResult }
                
                return result
            }
            .do(onError: { error in
                if case let .some(.httpRequestFailed(response, _)) = error as? RxCocoaURLError, response.statusCode == 403 {
                    LogHelper.printLog("⚠️ Bittrex API rate limit exceeded. Wait for 60 seconds and try again.")
                }
            })
            .catchErrorJustReturn(emptyResult)
    }
}
