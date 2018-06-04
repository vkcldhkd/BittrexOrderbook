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
        case setArray([Coin],buyArray: [Coin])
    }
    
    // State is a current view state
    struct State {
        var sellArray : [Coin] = []
        var buyArray : [Coin] = []
        
    }
    
    let initialState = State()

    
    // Action -> Mutation
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .update:
            return DataResponser.getOrderBook().map{ Mutation.setArray($0.sell!, buyArray: $0.buy!) }
        }
    }
    
    // Mutation -> State
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        
        switch mutation {
        case let .setArray(sell,buy) :
            state.sellArray = sell
            state.buyArray = buy
            
        }
        
        return state
    }
}
