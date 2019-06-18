//
//  SectionOfCoin.swift
//  BittrexOrderbook
//
//  Created by 1 on 18/06/2019.
//  Copyright © 2019 Sung Hyun. All rights reserved.
//
import RxDataSources

struct SectionOfCoin: Equatable {
    var items: [Coin]
}

extension SectionOfCoin: SectionModelType {
    init(original: SectionOfCoin, items: [Coin]) {
        self = original
        self.items = items
    }
}

