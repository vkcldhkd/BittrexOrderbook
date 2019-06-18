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
    var sections = PublishSubject<[SectionOfCoin]>()
    
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
extension OrderBookViewController{
    func dataSource() -> RxTableViewSectionedReloadDataSource<SectionOfCoin> {
        return RxTableViewSectionedReloadDataSource<SectionOfCoin>(
            configureCell: { (dataSource, tableView, indexPath, model) -> UITableViewCell in
                switch indexPath.section{
                case 0:
                    let cell = tableView.dequeueReusableCell(withIdentifier: "TitleCell", for: indexPath)
                    return cell
                    
                default:
                    guard let cell = tableView.dequeueReusableCell(withIdentifier: "ItemTableViewCell", for: indexPath) as? ItemTableViewCell else { return ItemTableViewCell() }
                    
                    
                    let bgColor = indexPath.section == 1 ? UIColor(hex: "#FCEBEB") : UIColor(hex: "#F0F9FF")
                    cell.setView(isSell: indexPath.section == 1 , backgroundColor: bgColor, rate: model.rate, quantity: model.quantity)
                    
                    return cell
                }
        })
    }
}


extension OrderBookViewController : StoryboardView{
    
    func bind(reactor: OrderBookViewReactor) {
        // Action
        
        /**
         * orderbook을 1초마다 받아오기 위한 타이머 Action.
         */
        
        Observable<Int>.interval(1, scheduler: ConcurrentDispatchQueueScheduler(qos: .background))
            .map{ _ in Reactor.Action.update }
            .bind(to : reactor.action)
            .disposed(by: self.disposeBag)
        
        // State
        
        let dataSource = self.dataSource()
        sections.asObservable()
            .bind(to: orderBookTableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        let sell = reactor.state.map { $0.sellItems }
            .distinctUntilChanged()
            .filter{ $0.items.count > 5 }
            .map{ Array($0.items[0..<5]) }
        
        let buy = reactor.state.map { $0.buyItems }
            .distinctUntilChanged()
            .filter{ $0.items.count > 5 }
            .map{ Array($0.items[0..<5]) }
        
        Observable.combineLatest(sell,buy)
            .map{ tuple -> [SectionOfCoin] in
                var sectionArray: [SectionOfCoin] = []
                sectionArray.append(SectionOfCoin(items: []))
                sectionArray.append(SectionOfCoin(items: tuple.0))
                sectionArray.append(SectionOfCoin(items: tuple.1))
                return sectionArray
            }
            .bind(to: self.sections)
            .disposed(by: disposeBag)
        
        // TableView
        self.orderBookTableView.rx.setDelegate(self)
            .disposed(by: self.disposeBag)
        
        
        
        self.orderBookTableView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                guard let self = self else { return }
                
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

extension OrderBookViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.orderBookTableView.frame.height / 11
    }
}

