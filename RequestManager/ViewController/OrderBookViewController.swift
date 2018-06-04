//
//  ViewController.swift
//  RequestManager
//
//  Created by Sung Hyun on 2018. 5. 28..
//  Copyright © 2018년 Sung Hyun. All rights reserved.
//

import UIKit
import ReactorKit
import RxCocoa
import RxSwift
import RxDataSources




class OrderBookViewController: UIViewController {
    
    @IBOutlet weak var orderBookTableView: UITableView!
    @IBOutlet weak var valueLabel: UILabel!
    
    var disposeBag = DisposeBag()
    var sellArray : [Coin] = []
    var buyArray : [Coin] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.orderBookTableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        self.reactor = OrderBookViewReactor()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


extension OrderBookViewController : StoryboardView{
    
    func bind(reactor: OrderBookViewReactor) {
        // Action
        
        /**
         * orderbook을 1초마다 받아오기 위한 타이머 Action.
         */
        Observable<Int>.interval(1, scheduler: MainScheduler.asyncInstance)
            .map{ _ in Reactor.Action.update }
            .bind(to : reactor.action)
            .disposed(by: self.disposeBag)
        
        // State
        
        reactor.state.map { $0.sellArray }
            .subscribe(onNext: { (sell) in
                self.sellArray = sell
                self.orderBookTableView.reloadSections([0], animationStyle: .none)
            }).disposed(by: self.disposeBag)
        
        reactor.state.map { $0.buyArray }
            .subscribe(onNext: { (buy) in
                self.buyArray = buy
                self.orderBookTableView.reloadSections([1], animationStyle: .none)
            }).disposed(by: self.disposeBag)
        
        // View
        self.orderBookTableView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                guard let `self` = self else { return }
                self.view.endEditing(true)
                self.orderBookTableView.deselectRow(at: indexPath, animated: false)

                guard let cell = self.orderBookTableView.cellForRow(at: indexPath),
                let textLabel = cell.textLabel,
                let text = textLabel.text else { return }
                self.valueLabel.text = text
            })
            .disposed(by: self.disposeBag)
    }
}

extension OrderBookViewController : UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.orderBookTableView.frame.height / 10
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        cell.textLabel?.numberOfLines = 0

        if self.buyArray.count > indexPath.row && self.sellArray.count > indexPath.row {
            if indexPath.section == 0 {
                cell.textLabel?.textColor = UIColor.red
                cell.textLabel?.text = sellArray.count > 0 ? "quantity : \(sellArray[indexPath.row].quantity)\nrate:\(sellArray[indexPath.row].rate)" : "nil"
                
            }else{
                cell.textLabel?.textColor = UIColor.blue
                cell.textLabel?.text = buyArray.count > 0 ? "quantity : \(buyArray[indexPath.row].quantity)\nrate:\(buyArray[indexPath.row].rate)" : "nil"
            }
        }

        return cell
    }
}

