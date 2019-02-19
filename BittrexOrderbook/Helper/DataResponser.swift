//
//  DataResponser.swift
//  RequestManager
//
//  Created by Sung Hyun on 2018. 5. 28..
//  Copyright © 2018년 Sung Hyun. All rights reserved.
//
import Foundation
import RxSwift


class DataResponser {
    class func getOrderBook() -> Observable<Result>{
        let emptyResult : Result = Result(buy: [], sell: [])
        return RequestManager.request(method: .get, url: Constants_apis.GET_USDT_BTC_ORDERBOOK())
            .map{ json -> (Result) in
                guard let dict = json,
                    let jsonData = dict.jsonToString().data(using: .utf8),
                    let model = (try? JSONDecoder().decode(OrderBookModel.self, from: jsonData)),
                    let result = model.result else { return emptyResult }
                return result
        }
    }
}
