//
//  DataResponser.swift
//  RequestManager
//
//  Created by Sung Hyun on 2018. 5. 28..
//  Copyright © 2018년 Sung Hyun. All rights reserved.
//

import Foundation

class DataResponser {
    class func getOrderBook(closure: @escaping (OrderBookModel?)->()){
        RequestManager.postRequest(url: Constants_apis.GET_USDT_BTC_ORDERBOOK(), param: [:]) { (json) in
            LogHelper.printLog("orderbook json : \(json)")
            guard let json = json ,
                let jsonData = json.jsonToString().data(using: .utf8) else { return }
            closure(try? JSONDecoder().decode(OrderBookModel.self, from: jsonData))
        }
    }
}
