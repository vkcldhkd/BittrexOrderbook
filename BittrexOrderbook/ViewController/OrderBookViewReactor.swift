//
//  OrderBookViewReactor.swift
//  RequestManager
//
//  Created by Sung Hyun on 2018. 5. 31..
//  Copyright © 2018년 Sung Hyun. All rights reserved.
//

import ReactorKit
import RxCocoa
import RxSwift

final class OrderBookViewReactor : Reactor{
    // Action is an user interaction
    enum Action{
        case update
    }
    
    // Mutate is a state manipulator which is not exposed to a view
    enum Mutation{
        case setCoins(sell: [Coin]?, buy: [Coin]?)
    }
    
    // State is a current view state
    struct State {
        var sellItems = SectionOfCoin(items: [])
        var buyItems = SectionOfCoin(items: [])
        
    }
    
    let initialState = State()

    
    // Action -> Mutation
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .update:
            return DataResponser.getOrderBook().map{ Mutation.setCoins(sell: $0.sell, buy: $0.buy) }
        }
    }
    
    // Mutation -> State
    func reduce(state: State, mutation: Mutation) -> State {
        
        
        switch mutation {
        case let .setCoins(sell, buy):
            var newState = state
            
            if let sell = sell {
                newState.sellItems.items = sell.reversed()
                
            }
            
            if let buy = buy{
                newState.buyItems.items = buy
            }
            return newState
        }
        
        
        
        
    }
}
