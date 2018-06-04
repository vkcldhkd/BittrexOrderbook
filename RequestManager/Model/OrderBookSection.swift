//
//  OrderBookSection.swift
//  RequestManager
//
//  Created by BV on 2018. 5. 31..
//  Copyright © 2018년 Sung Hyun. All rights reserved.
//

import Foundation
import RxDataSources

struct OrderBookSection {
    var header: String
    var items: [Coin]
}
extension OrderBookSection: SectionModelType {
    typealias Item = Coin
    
    init(original: OrderBookSection, items: [Item]) {
        self = original
        self.items = items
    }
}
