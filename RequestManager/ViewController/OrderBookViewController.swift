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
    var arrays : (sell:[Coin],buy:[Coin]) = ([],[])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.reactor = OrderBookViewReactor()
        self.orderBookTableView.tableFooterView = UIView()
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
        
        reactor.state.map { $0.arrays }
            .filter{ !$0.0.isEmpty && !$0.1.isEmpty}
            .subscribe(onNext: { (arrays) in
                self.arrays.sell = arrays.0.reversed()
                self.arrays.buy = arrays.1
                DispatchQueue.main.async {
                    self.orderBookTableView.reloadData()
                }
                
            }).disposed(by: self.disposeBag)
        
        // View
        
        self.orderBookTableView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                guard let `self` = self else { return }
                self.view.endEditing(true)
                self.orderBookTableView.deselectRow(at: indexPath, animated: false)
                
                guard let cell = self.orderBookTableView.cellForRow(at: indexPath) as? ItemTableViewCell,
                    let priceTextField = cell.priceTextField,
                    let text = priceTextField.text else { return }
                self.valueLabel.text = text
            })
            .disposed(by: self.disposeBag)
    }
}

extension OrderBookViewController : UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : 5
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.orderBookTableView.frame.height / 11
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TitleCell", for: indexPath)
            return cell

        default:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ItemTableViewCell", for: indexPath) as? ItemTableViewCell else { return ItemTableViewCell() }

            if self.arrays.buy.count > indexPath.row && self.arrays.sell.count > indexPath.row {
                if indexPath.section == 1 {
                    
                    cell.backgroundColor = UIColor(hex: "#FCEBEB")
                    
                    cell.priceTextField.rx.text.asObservable()
                        .distinctUntilChanged()
                        .subscribe(onNext: { (text) in
                            if text != "\(self.arrays.sell[indexPath.row].rate)" {
                                DispatchQueue.main.async {
                                    UIView.animate(withDuration: 1.0, animations: {
                                        cell.backgroundColor = UIColor.red
                                        cell.backgroundColor = UIColor(hex: "#FCEBEB")
                                    })
                                }
                            }
                        })
                        .disposed(by: self.disposeBag)


                    cell.priceTextField.text = self.arrays.sell.count > 0 ? "\(self.arrays.sell[indexPath.row].rate)" : "nil"
                    cell.amountTextField.text = self.arrays.sell.count > 0 ? "\(self.arrays.sell[indexPath.row].quantity)" : "nil"


                }else{
                    cell.backgroundColor = UIColor(hex: "#F0F9FF")
                    cell.priceTextField.rx.text.asObservable()
                        .distinctUntilChanged()
                        .subscribe(onNext: { (text) in
                            if text != "\(self.arrays.buy[indexPath.row].rate)" {
                                DispatchQueue.main.async {
                                    UIView.animate(withDuration: 1.0, animations: {
                                        cell.backgroundColor = UIColor.blue
                                        cell.backgroundColor = UIColor(hex: "#F0F9FF")



                                    })
                                }
                            }
                        })
                        .disposed(by: self.disposeBag)

                    cell.priceTextField.text = self.arrays.buy.count > 0 ? "\(self.arrays.buy[indexPath.row].rate)" : "nil"
                    cell.amountTextField.text = self.arrays.buy.count > 0 ? "\(self.arrays.buy[indexPath.row].quantity)" : "nil"
                }
            }

            return cell
        }

    }
}
