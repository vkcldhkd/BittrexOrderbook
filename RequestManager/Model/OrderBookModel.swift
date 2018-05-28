//
//  OrderBookModel.swift
//  RequestManager
//
//  Created by Sung Hyun on 2018. 5. 28..
//  Copyright © 2018년 Sung Hyun. All rights reserved.
//


import Foundation

struct OrderBookModel: Codable {
    let success: Bool?
    let message: String?
    let result: Result?
}

struct Result: Codable {
    let buy, sell: [Buy]?
}

struct Buy: Codable {
    let quantity, rate: Double
    
    enum CodingKeys: String, CodingKey {
        case quantity = "Quantity"
        case rate = "Rate"
    }
}
